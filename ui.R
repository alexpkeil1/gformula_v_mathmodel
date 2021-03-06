library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel(h1("The g-formula slider, v0.1 (logistic model, 3 binary variables)"), windowTitle="The g-formula slider"),

  # Sidebar with a slider input for the number of bins
    sidebarLayout(
    sidebarPanel(
      h1("G-formula slider: Rstan"),
      h3("Priors"),
      sliderInput("b0mean",
                  "beta_0: prior mean",
                  min = -20.0,
                  max = 20.0,
                  value = 0),
      sliderInput("b0var",
                  "beta_0: prior std. dev",
                  min = 0.01,
                  max = 100.0,
                  value = 10),
      sliderInput("b1mean",
                  "beta_x: prior mean",
                  min = -20.0,
                  max = 20.0,
                  value = 0.0),
      sliderInput("b1var",
                  "beta_x: prior std. dev",
                  min = 0.01,
                  max = 100.0,
                  value = 3.0),
      sliderInput("b2mean",
                  "beta_z: prior mean",
                  min = -20.0,
                  max = 20.0,
                  value = 0.0),
      sliderInput("b2var",
                  "beta_z: prior std. dev",
                  min = 0.01,
                  max = 100.0,
                  value = 3.0),
      h3("MCMC settings"),
      numericInput("nchains",
      			   "Number of chains",
      			   min=1,
      			   value=1,
      			   step=1
      				),
      numericInput("niterations",
      			   "Number of iterations",
      			   min=100,
      			   max=20000,
      			   value=100,
      			   step=100
      				),
      h3("Intervention values"),
      numericInput("xset",
      			   "Set x to:",
      			   min=0,
      			   max=1,
      			   value=1,
      			   step=1
      				)
    ),

    # Show a plot of the generated distribution
	mainPanel(
		tabsetPanel(
			tabPanel("Quick start instructions",
			br(),
			p("0. Install 'shiny' and 'Rstan' packages in R"),
			p("\n\n1. Download sample data (to your local drive) from", 
      a("here,", href="https://raw.githubusercontent.com/alexpkeil1/gformula_v_mathmodel/master/data/testdata.csv", target="_blank"),
      a("here, ", href="https://raw.githubusercontent.com/alexpkeil1/gformula_v_mathmodel/master/data/testdata2.csv", target="_blank"),
      a("or here:", href="https://raw.githubusercontent.com/alexpkeil1/gformula_v_mathmodel/master/data/testdata3.csv", target="_blank")
			  ),
			p("2. Upload data from step 1 (using 'Choose file' button on logistic model tab), be a little patient (stan first compiles the model into an executable, which may take a while)"),
			p("3. ?"),
			p("4. Profit"),
			p("5. Play around with priors, MCMC settings in left tab (better to do this before uploading data, once you have this figured out)")
			
			),
			
    		tabPanel("Logistic model",
			    br(),
			    p("Model: log-odds(y) = beta_0 + beta_x*x + beta_z*z"),
			    p("Priors: beta_0 ~ N(prior mean, prior variance)"),
			    p("Priors: beta_x ~ N(prior mean, prior variance)"),
			    p("Priors: beta_z ~ N(prior mean, prior variance)"),
			    br(),
    			fileInput('indata', 'Upload data (csv, three variables named x,y,z [y must be in [0,1]])', 
    				accept=c('text/csv','text/comma-separated-values,text/plain','.csv')),
    			h4("Frequentist results"),
				tableOutput("crudemodData"),
    			h4("Bayesian results"),			    
				  br(),
			    p("fy = average observed outcome"),
			    p("fy0 = average outcome, had x been set to 0 for everyone (g-formula)"),
			    p("rd = fy[intervention] - fy0 (set intervention on left tab) (g-formula)"),
			    p("OR, beta parameters directly from Bayesian logistic model"),
				dataTableOutput("bayesmodData"),
				h4("Prior and posterior distributions"),
				fluidRow(
					column(6,plotOutput("priorPlot", width=300, height=300)),
					column(6, plotOutput("postPlot", width=300, height=300))
					),
				h4("Trace plots"),
				plotOutput("tracePlot", width=600, height=300)
    		),
    		tabPanel("Stan model, data",
    			fluidRow(
				h4("Model statement"),
    				column(12,textOutput("stanModtext")),
				h4("Imported data"),
				dataTableOutput("importData")
    			)
    		)
)))))