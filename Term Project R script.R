# SBA Loan Default Prediction using R

library(caret)
library(gains)
library(pROC)
library(tidyr)
library(dplyr)
library(readxl)

sba_data <- read_excel("C:/Users/emzar/OneDrive - Cal Poly/1_Business Analytics/Term Project/Term project data FULL SET.xlsx")


'Data Wrangling'

View(sba_data)

# Takes away Scientific Notation
options(scipen = 999)

# Checking for missing values within the data 
summary(sba_data)  # Descriptive statistics for numerical variables
is.na(sba_data)    # Identify missing values
colSums(is.na(sba_data))  # Count missing values per column

# Handling missing values that are found in the code 
# Identify missing numeric values and replace with median
sba_data$NoEmp[which(is.na(sba_data$NoEmp))] <- median(sba_data$NoEmp, na.rm=TRUE)
sba_data$Term[which(is.na(sba_data$Term))] <- median(sba_data$Term, na.rm=TRUE)

# Replace missing categorical variables with "Unknown"
sba_data$RevLineCr[which(is.na(sba_data$RevLineCr))] <- "Unknown"
sba_data$UrbanRural[which(is.na(sba_data$UrbanRural))] <- "0"


# Creating subset without the ChgOffDate variable due to extensive missing values
sba_subset <- subset(sba_data, select = -ChgOffDate)

# Count missing values per column
colSums(is.na(sba_subset))

# Remove rows with missing values
sba_cleaned <- na.omit(sba_subset)

# Check to see if there are any missing values in the clean data set
colSums(is.na(sba_cleaned))

# Create a new column "Loan_Status_Binary" with 1 for "PIF" and 0 for "CHGOFF"
sba_cleaned$Loan_Status_Binary <- ifelse(sba_cleaned$MIS_Status == "P I F", 1, 0)

# Convert 'RevLineCr' to only have 'Y' or 'N'
sba_cleaned$RevLineCr <- ifelse(sba_cleaned$RevLineCr == "Y", "Y", "N")

# Convert 'LowDoc' to only have 'Y' or 'N'
sba_cleaned$LowDoc <- ifelse(sba_cleaned$LowDoc == "Y", "Y", "N")

# convert 'DisbursementDate' & 'ApprovalDate' to Date/Time Variable
sba_cleaned$DisbursementDate <- as.Date(sba_cleaned$DisbursementDate, format = "%Y/%m/%d")
sba_cleaned$ApprovalDate <- as.Date(sba_cleaned$ApprovalDate, format = "%Y/%m/%d")


#Make Variables into  categorical variables
sba_cleaned$Loan_Status_Binary <- as.factor(sba_cleaned$Loan_Status_Binary)
sba_cleaned$UrbanRural <- as.factor(sba_cleaned$UrbanRural)
sba_cleaned$RevLineCr <- as.factor(sba_cleaned$RevLineCr)
sba_cleaned$NewExist <- as.factor(sba_cleaned$NewExist)
sba_cleaned$LowDoc <- as.factor(sba_cleaned$LowDoc)

summary(sba_cleaned) 


write.csv(sba_cleaned, "SBA_Cleaned_Data.csv", row.names = FALSE)

        
'Determining Variables'


#Compare these variable for to understand if certain categorical features affect loan defaults
table(sba_cleaned$NewExist, sba_cleaned$Loan_Status_Binary)
table(sba_cleaned$LowDoc, sba_cleaned$Loan_Status_Binary)
table(sba_cleaned$RevLineCr, sba_cleaned$Loan_Status_Binary)




#Build Logical Regression Model


# glm for logistical
# use logit function
Logistic_Model <- glm(Loan_Status_Binary ~ DisbursementGross + GrAppv + Term + NoEmp + 
                        CreateJob + RetainedJob + NewExist + RevLineCr + LowDoc, 
                      family = binomial(link = "logit"), data = sba_cleaned)

summary(Logistic_Model)


sba_cleaned$pHat <- Logistic_Model$fitted.values

# make a column to predict above 50%
sba_cleaned$yHat <- ifelse(sba_cleaned$pHat > 0.5, 1, 0)
# make column to see how accuarcy you were
sba_cleaned$Accuracy <- ifelse(sba_cleaned$Loan_Status_Binary == sba_cleaned$yHat, 1, 0)
# Percentage of accuracy 
sum(sba_cleaned$Accuracy)/length(sba_cleaned$Accuracy)


# Create True Positive Column 
sba_cleaned$TP <- ifelse(sba_cleaned$Loan_Status_Binary == 1 & sba_cleaned$yHat == 1, 1, 0)
# Create True Negative Column 
sba_cleaned$TN <- ifelse(sba_cleaned$Loan_Status_Binary == 0 & sba_cleaned$yHat == 0, 1, 0)
# Create False Positive Column 
sba_cleaned$FP <- ifelse(sba_cleaned$Loan_Status_Binary == 0 & sba_cleaned$yHat == 1, 1, 0)
# Create False Negative Column 
sba_cleaned$FN <- ifelse(sba_cleaned$Loan_Status_Binary == 1 & sba_cleaned$yHat == 0, 1, 0)

# sum the columns
sum(myData$TP)
sum(myData$TN)
sum(myData$FP)
sum(myData$FN)

write.csv(myData, "LogResResults.csv")



#KNN Model

# Create list of variables 
knn_variables <- c("Loan_Status_Binary",
                   "DisbursementGross", "GrAppv", "Term",
                   "NoEmp", "CreateJob", "RetainedJob") 
                  
# Create Subet set for KNN Model                   
knn_subset <- sba_cleaned[, knn_variables]

# Compute the z-scores for variables 2, 3, and 4
knn_subsetz<- scale(knn_subset[2:7])  
knn_subsetz<- data.frame(knn_subsetz, knn_subset$Loan_Status_Binary) # Re-attach the response variable back to the standardized predictors
colnames(knn_subsetz)[7] <- 'Loan_Status_Binary'  # Label the response variable as Loan_Status_Binary, not myData.Enroll
knn_subsetz$Loan_Status_Binary<- as.factor(knn_subsetz$Loan_Status_Binary) # Make sure that the Enroll variable is categorical

set.seed(1) # Set the random seed so that everybody gets the same data partitioning results
myIndex<- createDataPartition(knn_subsetz$Loan_Status_Binary, p=0.6, list=FALSE) # Randomly partition the data into training and validation sets, using the main variable
trainSet <- knn_subsetz[myIndex,]
validationSet <- knn_subsetz[-myIndex,]

myCtrl <- trainControl(method="cv", number=10) # Use the 10-fold cross validation method
myGrid <- expand.grid(.k=c(1:10)) # Specify and evaluate k = 1 through 10 for the kNN algorithm


set.seed(1) # Set random seed again so that everybody gets the same kNN results

KNN_fit <- train(Loan_Status_Binary ~ .,
                 data=trainSet,
                 method = "knn",
                 trControl=myCtrl,
                 tuneGrid = myGrid) # Run the kNN algorithm on the training data set

KNN_fit # Show the kNN results from the training data set




# Cross validate the kNN results on the validation data set
KNN_Class <- predict(KNN_fit, newdata = validationSet) # Predict the y-hat values
confusionMatrix(KNN_Class, validationSet$Enroll, positive = '1') # Compute the confusion matrix to assess the model performance. Note that the default cut-off value is 0.5

KNN_Class_prob <- predict(KNN_fit, newdata = validationSet, type='prob') # Predict the p-hat values
KNN_Class_prob # Show the p-hat values
confusionMatrix(as.factor(ifelse(KNN_Class_prob$`1` > 0.25, '1', '0')),
                validationSet$Enroll, positive = '1') # Change the cut-off value from 0.5 to 0.25






















