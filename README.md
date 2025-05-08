# 🌍 Master Thesis R Code

This repository contains the R script used for the statistical analysis in my master’s thesis on peatland loss, key land-use drivers, and future risk prediction in Trøndelag.

## 📝 Working Title
**Mapping Historical Loss of Peatlands, Identifying Key Drivers, and Predicting Risk of Future Loss – A Case Study of Trøndelag County**

The thesis investigates historical loss of peatlands in Trøndelag, identifies key environmental and anthropogenic drivers behind the observed changes, and predicts the risk of future conversion in remaining peatland areas.

---

## 📎 Table of Contents
- [Overview](#overview)
- [R Packages You Need Installed](#r-packages-you-need-installed) 
- [Usage](#usage)
- [Contributions](#contributions)
- [Contact](#contact)

---

## 👀 Overview

This script runs the analysis after peatland loss has been estimated and all explanatory variables have been prepared. For details on the methodological background and how variables were prepared, go to **Chapter 3.5.2** of the thesis.

---

## 📦 R Packages You Need Installed

Make sure you have the following packages installed before running the script:

- `tidyverse`
- `MIAmaxent`
- `corrplot`
- `ggplot2`
- `dplyr`
- `gt`
- `broom`
- `extrafont` *(optional, for Times New Roman styling)*

🗄️ R version used: **4.3.1**

---

## 🧮 Usage

The script is structured into **9 collapsible sections**, each of which is briefly described below:

### 1️⃣ Install and Load Packages
Provides installation and loading code for all necessary libraries.

### 2️⃣ Specify Working Directory and Locale
Sets working directory, language locale (Norwegian), and loads fonts for plot styling.

### 3️⃣ Prepare Input Dataset
Reads and preprocesses the dataset. This includes recoding missing values (if necessary) and filtering out uncertain peatland observations (Category 1).

### 4️⃣ Explore the Dataset
Removes GIS-specific variables and generates histograms to visualize variable distributions.

### 5️⃣ Check for Correlation
Creates correlation matrices to assess multicollinearity between explanatory variables.

### 6️⃣ Select Variables Explaining Peatland Loss
Applies multiple transformations and Chi-square filtering to identify statistically significant predictors for model training.

### 7️⃣ Build Parsimonious Models
Uses the `ev_select()` function from **MIAmaxent** to run stepwise forward selection of predictors and compare nested models.

### 8️⃣ Final Model
Extracts the best-performing model and fits a logistic regression. Summarizes and interprets model output.

### 9️⃣ Generate Thesis Figures
Creates publication-ready plots tailored to the thesis. Can be adapted for different projects.

---

## 🤝 Contributions

This script was developed in collaboration with **Trond Simensen** at the **Norwegian Institute for Nature Research (NINA)**.

---

## 📬 Contact

**Malin Bergset**  
📧 [mbergset@hotmail.com](mailto:mbergset@hotmail.com)

---

