# Load necessary libraries
library(ggplot2)
library(dplyr)
library(readxl)

# Load the dataset
sba_data <- read_excel("C:/Users/emzar/OneDrive - Cal Poly/1_Business Analytics/Term Project/Term project data FULL SET.xlsx")

# Select relevant columns
selected_columns <- c("Term", "NoEmp", "NewExist", "LowDoc", "DisbursementGross", "MIS_Status", "GrAppv", "SBA_Appv")
df <- df[selected_columns]

# Convert categorical variables to factors
df$NewExist <- as.factor(df$NewExist)
df$LowDoc <- as.factor(df$LowDoc)
df$MIS_Status <- as.factor(df$MIS_Status)

# Convert MIS_Status to binary (1 for Paid in Full, 0 for Default)
df$Status <- ifelse(df$MIS_Status == "P I F", 1, 0)

# Plot distribution of loan approval amounts
ggplot(df, aes(x = GrAppv)) +
  geom_histogram(bins = 50, fill = "blue", alpha = 0.7) +
  labs(title = "Distribution of Loan Approval Amounts",
       x = "Loan Approval Amount ($)",
       y = "Frequency") +
  xlim(0, quantile(df$GrAppv, 0.99))

# Plot the proportion of defaults by loan type (New vs Existing Business)
df_summary <- df %>%
  group_by(NewExist) %>%
  summarise(Prop_Paid = mean(Status))

ggplot(df_summary, aes(x = NewExist, y = Prop_Paid, fill = NewExist)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("red", "blue")) +
  labs(title = "Loan Default Rate: New vs Existing Businesses",
       x = "Business Type (1=Existing, 2=New)",
       y = "Proportion of Loans Paid in Full")

# Plot the impact of LowDoc loans on default rates
df_lowdoc <- df %>%
  group_by(LowDoc) %>%
  summarise(Prop_Paid = mean(Status))

ggplot(df_lowdoc, aes(x = LowDoc, y = Prop_Paid, fill = LowDoc)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("purple", "orange")) +
  labs(title = "Default Rate by LowDoc Loan Type",
       x = "LowDoc Loan (Y=Yes, N=No)",
       y = "Proportion of Loans Paid in Full")

# Scatter plot of loan disbursement vs approval amounts colored by loan status
ggplot(df, aes(x = DisbursementGross, y = GrAppv, color = as.factor(Status))) +
  geom_point(alpha = 0.5) +
  scale_color_manual(values = c("red", "green"), labels = c("Default", "Paid in Full")) +
  labs(title = "Loan Disbursement vs. Approval Amounts (Default vs. Paid in Full)",
       x = "Disbursement Amount ($)",
       y = "Loan Approval Amount ($)",
       color = "Loan Status") +
  xlim(0, quantile(df$DisbursementGross, 0.99)) +
  ylim(0, quantile(df$GrAppv, 0.99))
