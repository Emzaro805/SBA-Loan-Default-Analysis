# Load necessary libraries
library(readxl)
library(dplyr)
library(caret)
library(e1071)

# Load the dataset
sba_data <- read_excel("C:/Users/emzar/OneDrive - Cal Poly/1_Business Analytics/Term Project/Term project data FULL SET.xlsx")


"Data Wrangling" 

#Subset Data so only Relevant Columns are in the Data
selected_columns <- c("Name", "Bank", "Term", "NoEmp", "NewExist", "LowDoc", 
                      "DisbursementGross", "MIS_Status", "GrAppv", "SBA_Appv")

# Create the subset with selected variables
subset_data <- myData[, selected_columns]

# View the subset
View(subset_data)

#Checking for missing values within the data
is.na(subset_data)
colSums(is.na(subset_data))

#Ommiting any data that is not a complete case and creating a new subset
subset_data[!complete.cases(subset_data),]
completeData<- na.omit(subset_data)
colSums(is.na(completeData))

#Change MIS Status to 1 and 0, because it is the target variable
completeData$Status <- ifelse(completeData$MIS_Status == "P I F", 1, 0)
completeData$Status <- as.factor(completeData$Status)

# Keep only rows where LowDoc is 'Y' or 'N'
completeData <- completeData[completeData$LowDoc %in% c("Y", "N"), ]

# Verify that only 'Y' and 'N' remain
completeData$LowDoc <- ifelse(completeData$LowDoc == "Y", "Y", "N")
completeData$LowDoc <- as.factor(completeData$LowDoc)
table(completeData$LowDoc)

# Remove rows where NewExist is 0
completeData <- completeData[completeData$NewExist != 0, ]
completeData$NewExist <- ifelse(completeData$NewExist == "1", "1", "2")

# Verify that 0 values are removed
table(completeData$NewExist)
completeData$NewExist <- as.factor(completeData$NewExist)

# Load necessary library
library(dplyr)

# Randomly select 5000 rows from the full dataset
sampleData <- completeData[sample(nrow(completeData), 5000), ]

# View the subset
View(sampleData)

# Save the smaller dataset as a CSV file
write.csv(sampleData, "SampleData.csv", row.names = FALSE)


'Determining Variables'

#Compare these variables to understand if certain categorical features affect loan defaults
table(sampleData$NewExist,sampleData$Status )
table(sampleData$LowDoc, sampleData$Status)

#Get rid of scientific Notation
options(scipen = 999)

# Run logistic regression model
Logistic_Model <- glm(Status ~ DisbursementGross + GrAppv + Term + NoEmp + 
                        NewExist + LowDoc + SBA_Appv,
                      family = binomial(link = "logit"), 
                      data = sampleData)

# View model summary
summary(Logistic_Model)

sampleData$pHat <- Logistic_Model$fitted.values

# make a column to predict above 50%
sampleData$yHat <- ifelse(sampleData$pHat > 0.5, 1, 0)
# Make a column to see how accurate you were
sampleData$Accuracy <- ifelse(sampleData$Status == sampleData$yHat, 1, 0)
# Percentage of accuracy 
sum(sampleData$Accuracy)/length(sampleData$Accuracy)


# Create a True Positive Column 
sampleData$TP <- ifelse(sampleData$Status == 1 & sampleData$yHat == 1, 1, 0)
# Create a True Negative Column 
sampleData$TN <- ifelse(sampleData$Status == 0 &sampleData$yHat == 0, 1, 0)
# Create a False Positive Column 
sampleData$FP <- ifelse(sampleData$Status == 0 & sampleData$yHat == 1, 1, 0)
# Create a False Negative Column 
sampleData$FN <- ifelse(sampleData$Status == 1 & sampleData$yHat == 0, 1, 0)

# Sum the columns
sum(sampleData$TP)
sum(sampleData$TN)
sum(sampleData$FP)
sum(sampleData$FN)

# Sensitivity
sum(sampleData$TP) / (sum(sampleData$TP) + sum(sampleData$FN)) 

# Specificity
sum(sampleData$TN) / (sum(sampleData$TN) + sum(sampleData$FP))

# Set variables and subset
knn_variables <- c("Status",
                   "DisbursementGross", "GrAppv", "Term",
                   "NoEmp", "SBA_Appv") 
knn_subset <- sampleData[, knn_variables]

"KNN Assessment"

# Remove the categorical variable and scale the columns 2-6 and subset
myData1<- scale(knn_subset[2:6])  
# Add categorical variable to the end of the table
myData1<- data.frame(myData1, knn_subset$Status) 
# Rename column 
colnames(myData1)[6] <- 'Status'  
# Factor the variable
myData1$Status<- as.factor(myData1$Status) 

# Set seed to 1
set.seed(1) 

# Partion data 60/40
myIndex<- createDataPartition(myData1$Status, p=0.6, list=FALSE) 
# 60% of training
trainSet <- myData1[myIndex,] 
# 40% for validating
validationSet <- myData1[-myIndex,]

# Use 10-fold cross-validation
myCtrl <- trainControl(method="cv", number=10) 

# Tune data for up to 10 k-Nearest Neighbors
myGrid <- expand.grid(.k=c(1:10)) 

# Set seed to 1 again
set.seed(1) 

# KNN Model 
KNN_fit <- train(Status ~ ., data=trainSet, method = "knn", trControl=myCtrl, tuneGrid = myGrid) 
# Show
KNN_fit 

# Predict the y-hat values
KNN_Class <- predict(KNN_fit, newdata = validationSet)

# Compute the confusion matrix to assess the model performance. Note that the default cut-off value is 0.5
confusionMatrix(KNN_Class, validationSet$Status, positive = '1')

 # Predict the p-hat values
KNN_Class_prob <- predict(KNN_fit, newdata = validationSet, type='prob') 
# Show the p-hat values
KNN_Class_prob 
# Change the cut-off value from 0.5 to 0.25
confusionMatrix(as.factor(ifelse(KNN_Class_prob$`1` > 0.25, '1', '0')),
                validationSet$Status, positive = '1')

