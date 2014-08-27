#=======================================================================================================================================
#=========================================== Load require libraries ====================================================================

require(shiny)
require(shinyIncubator)
require(tm)
require(RCurl)




#=======================================================================================================================================
#========================= Load required functions in global scope to be used anywhere in the App ======================================


#cleanSweepCorpus<- function(corpus, useStopwords=FALSE, stem=FALSE, removePunct=FALSE, removeNum=FALSE, useSynonyms=FALSE,
#			    initialWords, replacementWords, useCustomStopwords=FALSE, customStopwords){
#  newCorpus <- corpus
#  newCorpus <- sapply(newCorpus, function(x) tolower(x))
#  newCorpus <- gsub("[\\\\()/]", " ", newCorpus)
#  if (useStopwords != FALSE){
#	engStopwords <- c(stopwords("SMART"),stopwords("english"))
#	engStopwords <- gsub("^","\\\\b",engStopwords)
#	engStopwords <- gsub("$","\\\\b",engStopwords)
#	x <- mapply(FUN= function(...){
#		newCorpus <<- gsub(..., replacement=" ", x=newCorpus)},
#		pattern=engStopwords)
#	rm(x)
#  }
#  if (useCustomStopwords != FALSE){
#	stopwords <- unlist(strsplit(customStopwords, split=","))
#	#Encoding(stopwordsList) <- "UTF-8"
#	modifiedStopwords <- gsub("^[[:space:]]*", "\\\\b", stopwords)
#	modifiedStopwords <- gsub("[[:space:]]*$", "\\\\b", modifiedStopwords)
#	x <- mapply(FUN= function(...){
#		newCorpus <<- gsub(..., replacement=" ", x=newCorpus)},
#		pattern=modifiedStopwords)
#	rm(x)
#  }
#  if (useSynonyms != FALSE){
#	toChange <- unlist(strsplit(initialWords, split=","))
#	changeTo <- unlist(strsplit(replacementWords, split=","))
#	#Encoding(toChange)<- "UTF-8"
#	#Encoding(changeTo)<- "UTF-8"
#	toChangeWords <- gsub("^[[:space:]]*", "\\\\b", toChange)
#	toChangeWords <- gsub("[[:space:]]*$", "\\\\b", toChangeWords)
#	changeToWords <- gsub("^[[:space:]]*", "\\\\b", changeTo)
#	changeTowords <- gsub("[[:space:]]*$", "\\\\b", changeToWords)
#	if (length(toChangeWords) == length(changeToWords)){
#		x <- mapply(FUN= function(...){
#		newCorpus <<- gsub(..., x=newCorpus)},
#		pattern=toChangeWords, replacement=changeToWords)
#		rm(x)
#	} else {
#		print("It appears that the number of replacing and to be replaced words are not the same...")
#	}
#  }
#  if (removePunct != FALSE){
#	newCorpus <- gsub("[[:punct:]]", " ", newCorpus)
#  }
#  if (removeNum != FALSE){
#	newCorpus <- gsub("[[:digit:]]", " ", newCorpus)
#  }
#  newCorpus <- stripWhitespace(newCorpus)
#  newCorpus <- gsub("^[[:space:]]*", "", newCorpus)
#  newCorpus <- gsub("[[:space:]]*$", "", newCorpus)
#  newCorpus <- gsub("[^[:alnum:]]", " ", newCorpus)
#  finalCorpus <- Corpus(VectorSource(newCorpus))
#  if (stem != FALSE){
#	finalCorpus <- tm_map(finalCorpus, stemDocument)
#  }
#  finalCorpus <- tm_map(finalCorpus, stripWhitespace)
#  return(finalCorpus)
#}


#======= Cosine similarity function for checking document similarity
#
#cosineDist<- function(x){
#x %*% t(x) / sqrt(rowSums(x^2) %*% t(rowSums(x^2))) }



#======= Access my GitHub url for loading datasets

ghubURL <- "https://raw2.github.com/noobuseR/Datasets/master/"


#======================================================================================================================#
#============================= The Shiny application =================================================================##


shinyServer(function(input, output, session){



#========================================================================================================================#
##======================= Section 1: Importing Corpus ==========================================================================##




	initialCorpus <- reactive ({ 
				if (input$uploadBtn == 0)
				return()
				isolate ({
					if (input$corpusType == "user"){
						userUpload <- reactive ({ input$myPath })
						userFilesPath <- userUpload()$datapath
						myData <- unlist(lapply(userFilesPath, function(x) scan(file=x, what="character", sep="\n",
						fileEncoding="UTF-8", encoding="UTF-8")))
					} else {
						myFile <- getURL(url=paste0(ghubURL, input$sampleCorpus, ".txt"), ssl.verifypeer=FALSE)
						myData <- unlist(strsplit(myFile, split="\n"))
					}
					myCorpus <- Corpus(VectorSource(myData))
					return(myCorpus)
			})
	})
					

	output$corpusStatus <- renderPrint ({
					if (input$uploadBtn == 0)
					return("No corpus selection made yet...")
					withProgress(session, {
						setProgress(message="Uploading your corpus...")
						isolate ({
							initialCorpus()
						})
			})
	})


#========================================================================================================================#
##======================= Section 2: Pre-processing Corpus ==========================================================================##


	preprocessedCorpus <- reactive ({
				if (input$preprocessBtn == 0)
				return()
				isolate ({
					originalCorpus <- initialCorpus()
#					newCorpus <- cleanSweepCorpus(corpus=originalCorpus, useStopwords=input$stopwords, stem=input$stemming,
#							removePunct=input$punctuation, removeNum=input$numbers,
#							useSynonyms=input$customThes, initialWords=input$customThesInitial,
#							replacementWords=input$customThesReplacement, 													useCustomStopwords=input$customStopword,
#							customStopwords=input$cusStopwords)
#					rm(originalCorpus)
#					return(newCorpus)
					return(originalCorpus)
			})
	})


	output$procCorpusStatus <- renderPrint({
					if(input$preprocessBtn == 0)
					return("No pre-processing applied on Corpus")
					withProgress(session,{
						setProgress(message="Processing your corpus...")
						isolate({
							preprocessedCorpus() 
						})
			})
	})


#========================================================================================================================#
#=========================== Section 3: Feature Generation, Weighting, and Selection ========================================##


initialUnigramMatrix<- reactive({
				if(input$generateMatrix==0)
				return()
				isolate({
					corpus<- preprocessedCorpus()
					weightingScheme<- paste0(input$termWeight,input$docWeight,input$normalisation)
					initialMatrix<- TermDocumentMatrix(corpus,
								control=list(weighting=function(x) weightSMART(x,spec=weightingScheme)))
					rm(corpus)
					return(initialMatrix) 
			})
	})


lowerFreqRange<- reactive({
			myMatrix<- initialUnigramMatrix()
			freq<- rowSums(as.matrix(myMatrix))
			range(freq)
	})


output$lowerFreqSlider<- renderUI({
				sliderInput("lowerFreqBound","Please set the Lower Bound for Frequency",
				min=round(lowerFreqRange()[1]),max=round(lowerFreqRange()[2]),value=round(lowerFreqRange()[1]),step=NULL,ticks=TRUE)
	})

finalUnigramMatrix<- reactive({
				if(input$selectFeatures==0)
				return()
				isolate({
					finalUnigramMatrix<- initialUnigramMatrix()
					if(input$lowerFreqBound!=lowerFreqRange()[1]){
						lowerBound<- findFreqTerms(finalUnigramMatrix,round(input$lowerFreqBound),Inf)
						finalUnigramMatrix<- finalUnigramMatrix[lowerBound,]}
					if(input$sparsity!=100){
						finalUnigramMatrix<- removeSparseTerms(finalUnigramMatrix,sparse=(input$sparsity/100))}
					return(finalUnigramMatrix) 
			})
	})

output$initialuniMatrix<- renderPrint({ 
				if(input$generateMatrix==0)
				return("No Term-Document matrix constituted of single words available at the moment")
				withProgress(session, {
					setProgress(message="Calculating your Term Document Matrix...")
					isolate ({ initialUnigramMatrix() 
					})
			})
	})

output$finaluniMatrix<- renderPrint({
				if(input$selectFeatures==0)
				return("No Feature Selection procedure applied at the moment")
				withProgress(session, {
					setProgress(message="Applying Feature Selection procedures...")
					isolate ({ finalUnigramMatrix() 
					})
			})
	})



	observe({
		if(input$phase == "import" | input$phase == "preprocess" | input$phase == "featureSelect"){
			updateTabsetPanel(session,"tabset1","Corpus Generation")
		}
	})
})										
