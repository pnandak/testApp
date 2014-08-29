


library(shiny)
library(shinyIncubator)




shinyUI(pageWithSidebar(
				headerPanel(
					"Exploratory Qualitative Analysis with R",
					windowTitle = "Exploring Textual Data with R"),


sidebarPanel(tags$h4("Phase Selection"),

		br(),

		progressInit(),
		selectInput("phase", "Which phase would you like to choose?",
				c("User Guide" = "userGuide",
				"1. Importing Corpus" = "import",
				"2. Pre-processing" = "preprocess",
				"3. Feature Generation" = "featureGenerate",
				"4. Feature Selection" = "featureSelect", 
				"About" = "about"),
				selected = "userGuide"),

		br(),

		conditionalPanel(
			condition = "input.phase == 'import'",
			wellPanel(tags$strong("Importing a Corpus"),
				selectInput("corpusType", "Select the type of Corpus?",
					c("Use Personal Corpus" = "userCorpus",
				  	"Use Sample Corpus" = "sampleCorpus")),
				conditionalPanel(
					condition = "input.corpusType == 'userCorpus'",
					fileInput("userPath", "", multiple=TRUE)
					),
#				conditionalPanel(
#					condition = "input.corpusType == 'sampleCorpus'",
#					radioButtons("choiceCorpus", "Select sample Corpus:",
#					c("UAE Expat Forum" = "UAEexpatForum",
#				  	"UAE Trip Advisor" = "UAEtripAdvisor",
#				  	"Middle East Politics" = "middleEastPolitics"))
#					),
			actionButton("uploadBtn", "Upload Corpus")
			)
		),		

		conditionalPanel(
			condition = "input.phase == 'preprocess'",
			wellPanel(tags$strong("Pre-processing on Corpus"),
				checkboxInput("punctuation", "Punctuation Removal", FALSE),
				checkboxInput("numbers", "Numbers Removal", FALSE),
				checkboxInput("stemming", "Stem Words", FALSE),
				checkboxInput("stopwords", "Stopwords Removal", FALSE),
				checkboxInput("customStopword", "Custom Stopwords", FALSE),
				conditionalPanel(
					condition = "input.customStopword",
					#helpText("Please enter your stopwords separated by comma"),
					textInput("cusStopwords", "Please enter your stopwords separated by comma")
					),
				checkboxInput("customThes", "Custom Thesaurus", FALSE),
				conditionalPanel(
					condition = "input.customThes",
					#helpText("Note: Please enter words separated by comma"),
					textInput("customThesInitial", "Please enter words separated by comma"),
					textInput("customThesReplacement", "Enter Replacement words")
					),

				br(),

				actionButton("preProcessBtn", "Apply Pre-processing")
			)
		),

		conditionalPanel(
			condition = "input.phase == 'featureGenerate'",
			wellPanel(tags$strong("Feature Generation"),
				radioButtons("termWeight", "What are your Weighting Crietria for Words?",
					c("Word Frequency" = "n",
				  	"Binary Frequency" = "b",
				  	"Logarithmic Scaling of Frequency" = "l",
				  	"Augmented Frequency" = "a",
				  	"Log-Average Frequency" = "L")),
				radioButtons("docWeight", "What is your Weighting Criterion for Documents?",
					c("Document Frequency" = "n",
				  	"Inverse Document Frequency" = "t",
				  	"Probabilistic Inverse Document Frequency Factor" = "p")),
				radioButtons("normalisation", "What is your Normalisation scheme?",
					c("None" = "n",
				  	"Cosine" = "c")),

				br(),

				actionButton("generateMatrixBtn", "Generate Features")
			)
		),


	conditionalPanel(
		condition = "input.phase == 'featureSelect'",
			wellPanel(tags$strong("Feature Selection"),

				br(),

				uiOutput("lowerFreqSlider"),
				sliderInput("sparsity", "Please set the Maximum Allowed Sparsity (in %)",
						min = 20, max = 100, value = 100, step = 1),

				br(),

			actionButton("selectFeaturesBtn", "Select Features")
			)
		)
	),				


##================================= Select settings for mainPanel ================================================##

	mainPanel(
		tabsetPanel(id = "tabset1",
			tabPanel(title = "User Guide", includeHTML("introduction.html")),
			tabPanel(title = "Corpus Generation", verbatimTextOutput("corpusStatus"), verbatimTextOutput("procCorpusStatus"), verbatimTextOutput("initialuniMatrix"), verbatimTextOutput("finaluniMatrix")),
#			tabPanel(title = "Initial Analysis", plotOutput("rankFreqPlot",width="auto"), plotOutput("wordFreqPlot",width="auto")),
#			tabPanel(title = "Clustering Documents", plotOutput("docClusters",width="auto"), verbatimTextOutput("topicModels")),
#			tabPanel(title = "Clustering Words", plotOutput("assocCloud",width="auto"), plotOutput("dendrogram", width="auto")),
#			tabPanel(title = "Word Networks", plotOutput("wordNetwork",width="auto")),
			tabPanel(title = "About", includeHTML("about.html"))
			)
		)
))
