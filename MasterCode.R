#Install and load packages -----------------------------------------------------

#install.packages("tidyverse")
#install.packages("corrplot")
#install.packages("MIAmaxent") 
#install.packages("ggplot2")
#install.packages("dplyr")
#install.packages("extrafont")
#install.packages("gt")
#install.packages("broom")

library(tidyverse) #data wrangling
library(corrplot) #correlation plots
library(MIAmaxent) #for variable selection and model building
library(ggplot2) #for plots
library(dplyr) #data manipulation
library(extrafont) #for importing system fonts (Times New Roman in plots)
library(gt) #creating nice tables
library(broom) #for tidying model outputs into data frames


#Specify working directory etc.-------------------------------------------------

#Set locale to Norwegian with UTF-8 encoding 
#for characters and formatting
Sys.setlocale(locale='no_NB.utf8') 

#Set working directory to the folder where your data is located
setwd('C:/Users/mberg/OneDrive - NTNU/Documents/MSc Natural Resouces Management/Master yeyeye')

#Import fonts
font_import()
loadfonts(device = "win") #register fonts on your Windows

#Prepare input dataset----------------------------------------------------------
#Read in dataset to be analyzed
analysis_data <- read.csv(#path/to/your/data.csv,
                                 header = TRUE, sep = ",", encoding = "latin") |> as_tibble()

#Making a copy of the dataset
data <- analysis_data

#Replace exact zeros with NA in specific columns 
#(the null values were replaced with 0 when exported from GIS)
data[c('slope_min', 'slope_max', 'slope_median', 'slope_mean', 'mean_precipitation', 'mean_temperature', 'aspect')] <- lapply(
  data[c('slope_min', 'slope_max', 'slope_median', 'slope_mean', 'mean_precipitation', 'mean_temperature', 'aspect')],
  function(x) {
    x[x == 0.00000000] <- NA  #Replace exact zeros with NA
    return(x)
  }
)

#Drop rows with missing values
data <- drop_na(data)

#Leaving out category 1 for enhanced certainty
data2 <- data |> filter(peat_cat %in% c(2, 3))

#Rename response variable to RV (recorded value, 0 1)
#Place it before any other variables in the dataset
data2 <- data2 %>%
  rename(RV = nedbygd) %>%
  relocate(RV, .before = everything())

#Explore dataset----------------------------------------------------------------
#Check distribution of response variable, intact = 0 vs lost = 1
hist(data2$RV)
percent_rv <- prop.table(table(data2$RV)) * 100
print(percent_rv)

# Dropping GIS-specific variables that are 
#irrelevant for the analysis
data2 <- data2 |> select(-Id, -X, -Shape_Length, -Shape_Area, -sqm)

#Make histograms of variables for inspection
data2 [,1:9] %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_histogram(bins = 20, color="white", fill="#0072B2", alpha=0.8)

data2 [,10:18] %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_histogram(bins = 20, color="white", fill="#0072B2", alpha=0.8)

c_data [,19:27] %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_histogram(bins = 20, color="white", fill="#0072B2", alpha=0.8)

data2 [,28:36] %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_histogram(bins = 20, color="white", fill="#0072B2", alpha=0.8)

data2 [,37:45] %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_histogram(bins = 20, color="white", fill="#0072B2", alpha=0.8)

data2 [,46:53] %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_histogram(bins = 20, color="white", fill="#0072B2", alpha=0.8)

#Check for correlation ---------------------------------------------------------
data_num <- data2 |> dplyr::select(-RV) |> na.omit() 

correlations <- round(cor(data_num, method = "pearson"),2)
correlations

corrplot(correlations, method = 'number', order = "hclust")

#Make model to explain loss of peatland-----------------------------------------
#Make new dataset called PA train to use for modelling
pa_train <- data2

#First make integer values to numeric
pa_train <- pa_train %>%
  mutate(RV = as.numeric(RV), 
         hoyde = as.numeric(hoyde), 
         hyttefelt_ = as.numeric(hyttefelt_), 
         treeline = as.factor (treeline),
         hundrebelt = as.factor (hundrebelt))

#Drop variables that are irrelevant for the analysis
pa_train <- pa_train |> select(-peat_cat)
pa_train <- as.data.frame(pa_train) #plotFOP() expects a data.frame


#Plots showiing occurrence-variable relationships
par(mfrow=c(3,3)) #plotting window with three columns and three rows
for (i in 2:10) plotFOP(pa_train, i,intervals=500)
for (i in 11:19) plotFOP(pa_train,i,intervals=500)
for (i in 20:28) plotFOP(pa_train,i,intervals=500)
for (i in 29:37) plotFOP(pa_train,i,intervals=500)
for (i in 38:46) plotFOP(pa_train,i,intervals=500)
for (i in 48:52) plotFOP(pa_train, i, intervals = 500)

#Transforming explanatory variables
DVs <- deriveVars(pa_train, 
                  transformtype = c("L", "M", "D", "HF"),
                  allsplines = FALSE,
                  algorithm = "maxent",
                  write = FALSE, 
                  dir = NULL, 
                  quiet=FALSE)

#Preparing predictors with all variables 
dvdata <- DVs$dvdata

#Selecting transformed variables for modelling; 
#first for all variables (without extra predictors)
#then for all variables including extra predictors
DVselect <- selectDVforEV(
  dvdata,
  alpha = 0.01,
  retest = FALSE,
  test = "Chisq",
  algorithm = "LR",
  write = FALSE,
  dir = NULL,
  quiet = FALSE
)

#Create a summary table of the derived variables and their transformations
summary_table <- lapply(dvdata, function(x) if (is.data.frame(x)) names(x)) %>% #For each list element in dvdata, return the variable names if it's a data frame
  Filter(Negate(is.null), .) %>% #Remove NULL entries (RV or others without derived variables)
  stack() %>% #Convert the list of names to a two-column data frame (values and ind)
  rename(DerivedVariable = values, #'values' column contains names of derived variables
         OriginalVariable = ind) %>% #'ind' column contains the name of the original variable each came from
  mutate(Transformation = gsub(".*_", "", DerivedVariable)) %>%  #Extract transformation type (e.g., L, M, D) from variable name
  group_by(OriginalVariable) %>% #Group by original (untransformed) variable name
  summarise(
    `Transformation Types Retained` = paste(unique(Transformation), collapse = ", "), #List unique transformation types used
    `Number of Derived Variables` = n() #Count how many derived variables were created from each original variable
  )

print(summary_table, n = 50)

#Building Parsimonious Models---------------------------------------------------
#Without extra predictors
EVselect <- selectEV(DVselect$dvdata, 
                     alpha = 0.01, 
                     interaction = FALSE, 
                     write = FALSE) 


#How many derived variables that survived the first Chi-squared test:
summary(DVselect$dvdata)

#Which variables remained significant after the second round of filtering:
summary(EVselect$dvdata)

#Best models in each round:
EVselect$selection[!duplicated(EVselect$selection$round), ]

#Plot model improvement across selection rounds (D-squared vs. selection round)
plot(EVselect$selection$round, EVselect$selection$Dsq, 
     xlab="Selection Round", ylab="Deviance Explained")

#Models ranked by deviance explained
trail <- EVselect$selection
print(trail)

#Final model--------------------------------------------------------------------
#Get model formula
EVselect$selectedmodel$formula

#Convert 'fdyrk.dist' (only predictor variable) from list to plain numeric vector
EVselect$dvdata$fdyrk.dist <- unlist(EVselect$dvdata$fdyrk.dist)

#Check that the lengths of response and predictor match (important before modeling)
length(EVselect$dvdata$RV)
length(EVselect$dvdata$fdyrk.dist)

#Create a clean data frame for modeling with equal-length vectors
modeldata <- data.frame(
  RV = EVselect$dvdata$RV,                        
  fdyrk.dist = EVselect$dvdata$fdyrk.dist[1:14435] #Trimmed to match RV length
)

#Fit a logistic regression model to predict peatland loss (RV)
#based on distance to fully cultivated areas (fdyrk.dist)
model <- glm(RV ~ fdyrk.dist, 
             data = modeldata, 
             family = binomial())

#Display model summary: estimates, significance, fit, etc.
summary(model)


#Make all plots for the thesis -------------------------------------------------
par(family = "Times New Roman")
par(mfrow = c(2, 3), mar = c(4.5, 4.5, 2, 5))

#FOP plots of variables with less and more explanatory strength 
vars_to_plot <- c(49, 40, 34, 36, 21, 42)
x_labels <- c("Distance Wind Power Plants",
              "Mean Aspect",
              "Distance to Protected Areas (m)",
              "Mean Slope Max Value",
              "Distance to Any Road (m)",
              "Distance to Fully Cultivated Areas (m)")
labels <- c('FOP for Wind Power Plants',
            'FOP for Aspect',
            'FOP for Protected Areas',
            'FOP for Slope',
            'FOP for Distance to Road',
            'FOP for Distance to Cultivated Areas')

for (j in seq_along(vars_to_plot)) {
  i <- vars_to_plot[j]
  t <- labels
  plotFOP(pa_train, i, intervals = 500,
          main = "", xlab = "", ylab = "", lwd = 2,
          cex.main = 1.4, cex.lab = 1.2, cex.axis = 1,
          font.main = 2, font.lab = 1, font.axis = 1,
          family = "Times New Roman")
  title(main = t[j],
        xlab = x_labels[j],
        ylab = "Frequency of Observed Presence",
        cex.main = 2, cex.lab = 1.6,
        font.main = 2, font.lab = 1.6)
}



#Make model table + confidence intervals + odds ratios
model_table <- tidy(model) %>%
  mutate(
    lower_ci = round(estimate - 1.96 * std.error, 3),
    upper_ci = round(estimate + 1.96 * std.error, 3),
    CI = paste0(Estimate <- round(estimate, 3), " [", lower_ci, ", ", upper_ci, "]"),
    `Odds ratio` = round(exp(estimate), 3),
    SE = round(std.error, 3),
    Z = round(statistic, 2),
    p = ifelse(p.value < 0.001, "< .001", round(p.value, 3))
  ) %>%
  select(
    Predictor = term,
    `Estimate [95% CI]` = CI,
    SE,
    Z,
    p,
    `Odds ratio`
  )

model_table %>%
  gt() %>%
  tab_header(
    title = "Model Coefficients – Fully Cultivated Areas"
  ) %>%
  cols_label(
    SE = "Std. Error",
    Z = "Z-value",
    p = "P-value",
    `Odds ratio` = "Odds Ratio"
  ) %>%
  tab_options(
    table.font.size = 12,
    heading.title.font.size = 14,
    column_labels.font.weight = "bold",
    table.font.names = "Times New Roman"
  ) %>%
  opt_align_table_header(align = "left") %>%
  tab_source_note(
    source_note = "Note: Estimates represent the log odds of land take or conversion of peatlands."
  )



#Make regression line with probability lines
#Model coefficients
intercept <- 3.96613
slope <- -22.32115

#Logistic function
logistic <- function(x) {
  1 / (1 + exp(-(intercept + slope * x)))
}

#X range: assuming distance scaled 0 to 1
x_vals <- seq(0, 1, length.out = 1000)
y_vals <- logistic(x_vals)

#Threshold probabilities
thresholds <- c(0.9, 0.75, 0.5, 0.25, 0.1)
distances <- (intercept - log(thresholds / (1 - thresholds))) / abs(slope)
distances_m <- round(distances * 1000, 1)


#Data frame of predicted curve
curve_data <- data.frame(
  distance = x_vals * 1000,
  probability = y_vals
)


#Threshold lines
threshold_df <- data.frame(
  prob = thresholds,
  distance = distances * 1000,
  label = paste0(round(distances * 1000), " m (P = ", thresholds, ")")
)

ggplot(curve_data, aes(x = distance, y = probability)) +
  geom_line(color = "blue", size = 1.2) +
  geom_hline(yintercept = thresholds, linetype = "dotted", color = "gray") +
  geom_vline(data = threshold_df, aes(xintercept = distance), linetype = "dashed", color = "red") +
  geom_text(data = threshold_df, aes(x = distance + 10, y = prob, label = label),
            hjust = 0, size = 4, color = "red") +
  labs(
    title = "Probability of Land-Take or Conversion vs. Distance from Fully Cultivated Areas",
    x = "Distance to Fully Cultivated Areas (m)",
    y = "Predicted Probability for Land-Take or Conversion"
  ) +
  theme_minimal(base_family = "serif") +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    axis.title = element_text(size = 14)
  )