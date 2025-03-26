# SBA Loan Default Risk Analysis

## 📊 Overview

This project presents a data-driven solution to help U.S. banks assess the risk of small business loan defaults. By analyzing over 900,000 loan records, we identify key variables that contribute to loan repayment outcomes. Our models enable smarter, data-supported loan approvals to reduce financial losses while supporting business growth.

## 📁 Dataset

- **Source**: The dataset is provided by the **U.S. Small Business Administration (SBA)** and contains **900,000+ historical loan records from 1987 to 2014**. Each observation represents a small business loan and includes: **Loan amount, approval details, job creation, industry classification, loan term, and loan status** (paid in full or defaulted).

- **Sample Size**: 5,000 loans (random sample from full dataset for performance optimization)
- **Key Features Used**:
  - `Term`: Length of the loan
  - `NoEmp`: Number of employees
  - `NewExist`: New (2) or Existing (1) business
  - `LowDoc`: Participation in LowDoc program (Less Documentation than Normal Loan) (Y/N)
  - `DisbursementGross`: Disbursed loan amount
  - `MIS_Status`: Loan status (Paid in Full vs Charge Off)
  - `GrAppv`: Gross approved loan amount
  - `SBA_Appv`: SBA-approved guaranteed amount

## 🧹 Data Cleaning & Preparation

- Removed irrelevant columns
- Handled missing values using `na.omit()`
- Converted categorical variables to `factor`
- Created binary target variable `Status`:
  - `1`: Paid in Full
  - `0`: Default (ChargeOff)
- Filtered out ambiguous values in `LowDoc` and `NewExist`
- Scaled numerical features for the KNN model

## 📈 Data Visualizations

1. **Loan Approval Amount Distribution**
   - Histograms to show skewness and upper outliers
   - ![image](https://github.com/user-attachments/assets/c5c9d3c6-498d-4f25-bb9f-8da1951460d9)

2. **Default Rates by Business Type**
   - Bar graph: New vs Existing businesses
   - ![image](https://github.com/user-attachments/assets/b5833b7b-f971-445a-86f4-b94b5aeeb091)

3. **Default Rates by Loan Documentation**
   - Bar graph: LowDoc (Y/N)
   - ![image](https://github.com/user-attachments/assets/2c326352-4eb8-433c-afcb-05635dbaf305)

4. **Disbursement vs Approval Scatterplot**
   - Colored by loan outcome (Default / Paid)
   - ![image](https://github.com/user-attachments/assets/32ee14e1-958f-4663-9bbf-148a2d95af20)
   - 
## 🔍 Modeling

### Logistic Regression
- **Target**: `Status`
- **Predictors**: DisbursementGross, GrAppv, Term, NoEmp, NewExist, LowDoc, SBA_Appv
- **Accuracy**: **82%**
- **Top Predictors**: Term, NoEmp, and LowDoc

### K-Nearest Neighbors (KNN)
- **Target**: `Status`
- **Predictors**: DisbursementGross, GrAppv, Term, NoEmp, SBA_Appv
- **Optimal K**: 3
- **Accuracy**: **86.2%**
- **Validation Accuracy**: **85.6%**
- **Kappa Score**: 0.435

# 📌 Key Insights 

1. Loans with less documentation (LowDoc) are much riskier.
   - Borrowers who didn’t provide full paperwork defaulted at significantly higher rates.
   - Recommendation: Require full documentation to reduce default risk.
       
2. Longer loan terms increase the risk of default.
   - The more time given to repay, the more uncertainty arises over repayment.
   - Recommendation: Be cautious with long-term loans, especially for high-risk applicants.

3. Bigger businesses (with more employees) were more likely to default in our data.
   - This may reflect overexpansion or weak internal financial controls.
   - Recommendation: Do not assume size equals low risk.

4. Our predictive models (Logistic Regression and K-Nearest Neighbors) can predict defaults with over 85% accuracy.
   - This allows banks to proactively flag high-risk loans before approval.

5. Strategic Actions for Banks:
   - Be stricter with LowDoc loans
   - Avoid long-term loans for high-risk businesses
   - Use this model to enhance the loan approval process and reduce financial losses


## 💻 Tools & Libraries

- **R**: `caret`, `ggplot2`, `dplyr`, `e1071`, `readxl`
- **Techniques**: Data Wrangling, Logistic Regression, K-Nearest Neighbors, Confusion Matrix, Cross-validation





















