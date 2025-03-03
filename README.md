# SBA Loan Default Prediction using R

## Overview
This project analyzes **U.S. Small Business Administration (SBA) loan data** to predict the likelihood of loan default. The goal is to help banks and policymakers make **informed decisions** when approving SBA-backed loans. Using **descriptive analysis, data visualization, and machine learning models**, we classify loan applications as **"higher risk"** or **"lower risk"** of default.

## Project Structure
\SBA-Loan-Default-Prediction

├── data/# Raw and cleaned datasets
│   ├── SBA_loans_raw.xlsx
│   └── SBA_loans_cleaned.csv

├── scripts/            # R scripts for analysis
│   ├── data_cleaning.R
│   ├── exploratory_analysis.R
│   └── modeling.R

├── reports/            # Findings and insights
│   ├── SBA_Loan_Analysis_Report.Rmd
│   └── SBA_Loan_Analysis.pdf

├── README.md           # Project overview
├── .gitignore          # Ignore unnecessary files (e.g., .Rhistory, .DS_Store)
├── LICENSE             # Open-source license
└── requirements.txt    # List of R packages used

## Project Goals
- **Identify key factors** influencing SBA loan defaults.
- **Apply Logistic Regression and k-Nearest Neighbors (kNN)** models for classification.
- **Provide insights** using data visualization and exploratory data analysis (EDA).
- **Deliver a business-oriented report** with actionable recommendations.

## Data Source
The dataset is provided by the **U.S. Small Business Administration (SBA)** and contains **900,000+ historical loan records from 1987 to 2014**. Each observation represents a small business loan and includes:
- **Loan amount, approval details, job creation, industry classification, loan term, and loan status** (paid in full or defaulted).

**Target Variable:** `MIS_Status`
- **PIF (Paid in Full)** – Loan was successfully paid off.
- **CHGOFF (Charged Off)** – Loan defaulted.

## Data Preprocessing & Exploratory Analysis
### Steps performed:
- **Data Cleaning** – Handling missing values, outliers, and formatting inconsistencies.
- **Feature Engineering** – Creating new variables to enhance model performance.
- **Exploratory Data Analysis (EDA)** – Summary statistics, distributions, and correlations.
- **Data Partitioning** – Splitting the dataset into **training** and **validation** sets.





















