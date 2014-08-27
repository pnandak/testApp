#=======================================================================================================================================
#=========================================== Load require libraries ====================================================================

require(shiny)
require(shinyIncubator)


## Select type of page to create

shinyUI(pageWithSidebar(
			headerPanel(
				"Exploratory Qualitative Analysis with R",
				windowTitle = "Exploring Text Data with R"),


 	sidebarPanel(tags$h4("Phase Selection"),

		br(),

		progressInit(),

		selectInput("phase", "Which phase would you like to choose?",
					c("1. Importing Corpus" = "import",
					  "2. Preprocessing Corpus" = "preprocess",
					  "3. Feature Generation" = "featureGenerate",
					  "4. Feature Selection" = "featureSelect")),

		br(),

		conditionalPanel(
			condition = "input.phase == 'import'",
			wellPanel(tags$strong("Importing a Corpus"),
			selectInput("corpusType", "Select the type of corpus to analyse",
				c("Use Personal Corpus" = "userCorpus",
				  "Use Sample Corpus" = "sampleCorpus")),
					conditionalPanel(
						condition = "input.corpusType == 'userCorpus'",
						fileInput("myPath", "", multiple = TRUE)
							),
					conditionalPanel(
						condition = "input.corpusType == 'sampleCorpus'",
						radioButtons("sampleCorpus", "Select Sample Corpus:",
							c("UAE Expat Forums" = "UAEexpatForum",
							  "UAE Trip Advisor" = "UAEtripAdvisor",
							  "Middle East Politics" = "middleEastPolitics"))
							),
				actionButton("uploadBtn", "Upload Corpus")
				)
			),
		
		conditionalPanel(
			condition = "input.phase == 'preprocess'",
			wellPanel(tags$strong("Pre-processing Corpus"),
#			checkboxInput("punctuation", "Remove Punctuation", FALSE),
#			checkboxInput("numbers", "Remove Numbers", FALSE),
#			checkboxInput("stemming", "Stem Words", FALSE),
#			checkboxInput("stopwords", "Remove Stopwords", FALSE),
#			checkboxInput("customStopword", "Use Custom Stopwords", FALSE),
#			conditionalPanel(
#				condition = "input.customStopword",
#				textInput("cusStopwords", "Please enter your stopwords separated by comma")
#					),
#			checkboxInput("customThes", "Use Custom Thesauri", FALSE),
#			conditionalPanel(
#				condition = "input.customThes",
#				textInput("customThesInitial", "Please enter words separated by comma"),
#				textInput("customThesReplacement", "Enter Replacement words separated by a comma")
#					),
#			br(),
			actionButton("preprocessBtn", "Apply Pre-processing")
				)
			),

		conditionalPanel(
		condition="input.phase=='featureGenerate'",
		wellPanel(tags$strong("Feature Generation"),
		radioButtons("termWeight","What are your Weighting Crietria for Words?",
				c("Word Frequency"="n",
				  "Binary Frequency"="b",
				  "Logarithmic Scaling of Frequency"="l",
				  "Augmented Frequency"="a",
				  "Log-Average Frequency"="L")),
		radioButtons("docWeight","What is your Weighting Criterion for Documents?",
				c("Document Frequency"="n",
				  "Inverse Document Frequency"="t",
				  "Probabilistic Inverse Document Frequency Factor"="p")),
		radioButtons("normalisation","What is your Normalisation scheme?",
				c("None"="n",
				  "Cosine"="c")),
		br(),
		actionButton("generateMatrix","Generate Features")
				)
			),

		conditionalPanel(
		condition="input.phase=='featureSelect'",
		wellPanel(tags$strong("Feature Selection"),
		br(),
		uiOutput("lowerFreqSlider"),
		sliderInput("sparsity","Please set the Maximum Allowed Sparsity (in %)",
				min=20, max=100,value=100,step=1),
		br(),
		actionButton("selectFeatures", "Select Features")
				)
			)

	),

mainPanel(
	tabsetPanel(id="tabset1",
		tabPanel(title="Corpus Generation",verbatimTextOutput("corpusStatus"),verbatimTextOutput("procCorpusStatus"),verbatimTextOutput("initialuniMatrix"),verbatimTextOutput("finaluniMatrix"))
		)
	)
))
