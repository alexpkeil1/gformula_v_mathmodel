### gformula_v_mathmodel ###
Implementation of the Bayesian g-formula.

See link to paper [here](http://arxiv.org/abs/1512.04809)

Purpose: give heuristic to show the relations between mathematical modeling and the Bayesian g-formula
Descriptions: gives "slider" bars to control the priors of the Bayesian g-formula. At the extremes are mathematical modeling (point mass priors) or the frequentist g-formula (highly diffuse priors).
 

Running: If you have R installed, install the `shiny` package and the `Rstan` package (install instructions [here]( https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started))
	
Once R and the two packages are installed, open R and run:
```R
	library("shiny")
	runGitHub("gformula_v_mathmodel", "alexpkeil1")
```
