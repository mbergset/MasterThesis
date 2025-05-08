# Master Thesis R-Code
In this repository you can find the code used to conduct the analysis in my master thesis. 

## Working Title: Mapping Historical Loss of Peatlands, Identifying Key Drivers and Predicting Risk of Future Loss - A Case Study of Trøndelag County.
My master thesis mapped loss of peatlands in Trøndelag and identified key drivers behind this development. Based on identified
drivers, risk of future loss in remaining peatlands were identified. 


## Table of Contents
- [Overview](#overview)
- [R-Packages you need installed](#r-packages-you-need-installed) 
- [Usage](#usage)
- [Contributinions](#contributions)
- [Contact](#contact)


## Overview
The analysis in this script is conducted after peatland loss in the study area is estimated, and all anthropogenic and environmental variables are constructed. For detailed information
on how this was done, see Chapter 3.5.2 in the thesis. 


## R-Packages you need installed
- tidyverse
- MIAmaxent
- corrplot
- ggplot2
- dplyr
- gt
- broom
- extrafont (optional)

When conducting this analysis, I used R version 4.3.1


## Usage
The script is divided into 9 collapsable sections. In this chapter, each of them will be
described. 

### 1: Install and load packages
In this section, all the libraries you would need to run the script is provided both with
code for installation if you do not already have them installed, and code to load the
packages into the script. 

### 2: Specify working directory etc.
Here, technical specifications for the script is defined. Norwegian is set as locale
language, and the working directory where data is located is set. Furthermore, fonts
are imported as the figures have Times New Roman as font - but this is optional.

### 3: Prepare Input Dataset
In this section, the csv-dataset used for analysis is read into the script. For the dataset
used in my thesis, missing values were coded as 0 when exported from ArcGIS Pro, therefore
specific values in specific columns had to be recoded to NA. If this is not the case for your
data, this step can be skipped. 

Missing data is dropped, together with all observations within peatland category 1 - as these
observations hold the highest degrees of uncertainty. The response variable is also recoded
to "RV" and moved to the first column in the dataset. 

### 4: Explore the dataset
In this section, the aim is to become familiar with the dataset and all the explanatory
variables. GIS-specific variables are dropped, as these are not relevant for the analysis. 
Histograms for all variables are created. 

### 5: Check for correlation
In this step, correlation matrices are produced to check for correlation between variables. 

### 6: Select variables explaining loss of peatlands
First, all the variables are made sure to be numeric - except for binary variables.
Irrelevant variables are dropped, and all variables are plotted showing occurance of 
peatland loss - variable relationships. 

Next, all explanatory variables are transformed using Linear, Monotonic, Deviation and
Forward Hinge transformations to expand feature space in the model and enable a more
flexible fit. Multiple transformations for each variable allows for the model to select the 
most informative variables. 

Furthermore, the explanatory variables used for modelling are selected using Chi-square 
filtering, with a 1% significance threshold. First for all variables, then for all variables
including extra predictors. A table summarizing the derived variables and their 
transformation which survived the filtering was made. 

### 7: Building parsimonious models
The EV-select function in the MIA Maxent package selects the parsimonious set of explanatory
variables which best explains variation in the response variable representing loss of 
peatlands in the study area. It takes the pre-selected variables from the last step and runs
a stepwise forward variable seleection by comparing nested models using inference tests. In 
this script, only main effects are tested - hence no interaction terms between variables. 

Derived variables that survived the first and second step of filtering is then summarized,
before the best models in each rounds of selection is presented. The models are plotted and
printed ranked by deviance explained. Lastly, the selection trail is printed. 

### 8: Final model
In this step, the model formula of the best performing model from the previous step is
extracted and converted to a plain vector. In order to get a clean data frame for modelling,
the explanatory variable had to be trimmed to match the length of the response variable.
This step may not be necessary in your case. 

The formula is then fitted to a logistic regression model to predict peatland loss based
on distance to the explanatory variable (fully cultivated areas in my case), and the 
details of the model is summarized. 

### 9: Make plots for the thesis
In this step, the code to make plots for the thesis is provided. This could be used for 
inspiration and customized to fit your results and preferences. 

## Contributions
This script was developed together with Trond Simensen at the Norwegian Institute for Nature
Research. 

## Contact
Malin Bergset
📧 mbergset@hotmail.com
