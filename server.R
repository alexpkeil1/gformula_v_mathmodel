library(shiny)
library(rstan)
# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

	newData <- reactive({
		inFile <- input$indata
		if(is.null(inFile)) return(NULL)
		read.csv(inFile$datapath)
	})
	output$importData <- renderDataTable({
		dat <- newData()
		if(is.null(dat)) return(NULL)
		newData()
	},options = list(pageLength = 5)
	)
	output$priorPlot <- renderPlot({
		dat <- newData()
		if(is.null(dat)) return(NULL)
		plot(as.data.frame(dat))
		lim1=c(input$b0mean-3*input$b0var, input$b0mean+3*input$b0var)
		lim2=c(input$b1mean-3*input$b1var, input$b1mean+3*input$b1var)
		lim3=c(input$b2mean-3*input$b2var, input$b2mean+3*input$b2var)
		par(mfrow=c(1,3))
		curve(dnorm(x, input$b0mean, input$b0var), xlim=lim1, xlab="b0")
		curve(dnorm(x, input$b1mean, input$b1var), xlim=lim1, xlab="bx")
		curve(dnorm(x, input$b2mean, input$b2var), xlim=lim1, xlab="bz")
		
	})

	
	
	crudeModel <- reactive({
		dat <- newData()
		if(is.null(dat)) return(NULL)
		summary(glm(dat$y ~ dat$x + dat$z, family=binomial))$coefficients
	})

	stanModel <- reactive({
		paste0(
		'data {
		int<lower=0> N;
		
		vector[N] x;
		vector[N] z;
		int<lower=0,upper=1> y[N];
		}
		
		parameters {
		real b0;
		real bx;
		real bz;
		}
		model{
		 b0 ~ normal(',input$b0mean,', ', input$b0var*1.0,');
		 bx ~ normal(',input$b1mean,', ', input$b1var*1.0,');
		 bz ~ normal(',input$b2mean,',', input$b2var*1.0,');
		 
		 y ~ bernoulli_logit(b0 + bx * x + bz * z);
		}
		generated quantities{
		  real fy;
		  real fy0;
		  real rd;
		  real or_x;
		  {
		    real fyi[N];
		    real fyi0[N];
		    for(n in 1:N){
		    	fyi[n] = inv_logit(b0 + bx * ',input$xset,' + bz * z[n]);
		    	fyi0[n] = inv_logit(b0 + bz * z[n]);
		    }
		    fy = mean(fyi);
		    fy0 = mean(fyi0);
		  }
		  rd = fy-fy0;
		  or_x = exp(bx);
		}')
	})
	

	stanData <- reactive({
		dat <- newData()
		if(is.null(dat)) return(NULL)
		list(N=length(dat$x), x=dat$x, y=dat$y, z=dat$z)
	})
	
	output$stanDatatext <- renderText({
		stanModel()
	})
	output$stanModtext <- renderText({
		stanModel()
	})
	
	bayesModel <- reactive({
		dat <- newData()
		if(is.null(dat)) return(NULL)
		#model
		mod <- stanModel();
		#data
		datastan <- stanData()
		#stan code
		stan(model_code = mod, data = datastan, 
			iter=input$niterations, 
			chains=input$nchains, pars=c("fy", "fy0", "rd", "or_x", "bx", "bz", "b0"), verbose=FALSE)
	})
	
	getBayesresults <- reactive({
		mod <- bayesModel()
		if(is.null(mod)) return(NULL)
		data.frame(extract(mod))
	})
	
	output$crudemodData <- renderTable({
		crudeModel()
	})
	output$bayesmodData <- renderDataTable({
		posterior <- getBayesresults()
		if(is.null(posterior)) return(NULL)
		df <- data.frame(apply(posterior, 2, function(x) c(mean=mean(x), std=sd(x), median=median(x), p=quantile(x, 0.025), p=quantile(x, 0.975))))
		stat = rownames(df)
		data.frame(cbind(stat, df))
	}, options=list(digits=3))
	
	output$postPlot <- renderPlot({
		posterior <- getBayesresults()
		if(is.null(posterior)) return(NULL)
		par(mfrow=c(1,3))
		plot(density(posterior$b0))
		plot(density(posterior$bx))
		plot(density(posterior$bz))
	})
	output$tracePlot <- renderPlot({
		posterior <- getBayesresults()
		if(is.null(posterior)) return(NULL)
		iter = 1:length(posterior$b0)
		par(mfrow=c(1,3))
		plot(x=iter, y=(posterior$b0), type="l")
		plot(x=iter, y=(posterior$bx), type="l")
		plot(x=iter, y=(posterior$bz), type="l")
	})


})