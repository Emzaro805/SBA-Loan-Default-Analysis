#Subset Data so only Relevenat Columns are in the Data
selected_columns <- c("Name", "Bank", "Term", "NoEmp", "NewExist", "LowDoc", 
                      "DisbursementGross", "MIS_Status","GrAppv", "SBA_Appv")

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


#Compare these variable for to understand if certain categorical features affect loan defaults
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
# make column to see how accuarcy you were
sampleData$Accuracy <- ifelse(sampleData$Status == sampleData$yHat, 1, 0)
# Percentage of accuracy 
sum(sampleData$Accuracy)/length(sampleData$Accuracy)


# Create True Positive Column 
sampleData$TP <- ifelse(sampleData$Status == 1 & sampleData$yHat == 1, 1, 0)
# Create True Negative Column 
sampleData$TN <- ifelse(sampleData$Status == 0 &sampleData$yHat == 0, 1, 0)
# Create False Positive Column 
sampleData$FP <- ifelse(sampleData$Status == 0 & sampleData$yHat == 1, 1, 0)
# Create False Negative Column 
sampleData$FN <- ifelse(sampleData$Status == 1 & sampleData$yHat == 0, 1, 0)

# sum the columns
sum(sampleData$TP)
sum(sampleData$TN)
sum(sampleData$FP)
sum(sampleData$FN)

# Sensitivity
sum(sampleData$TP) / (sum(sampleData$TP) + sum(sampleData$FN)) 

# Specificity
sum(sampleData$TN) / (sum(sampleData$TN) + sum(sampleData$FP))

knn_variables <- c("Status",
                   "DisbursementGross", "GrAppv", "Term",
                   "NoEmp", "SBA_Appv") 
knn_subset <- sampleData[, knn_variables]

#Knn Assessment 
myData1<- scale(knn_subset[2:6])  
myData1<- data.frame(myData1, knn_subset$Status) 
colnames(myData1)[6] <- 'Status'  
myData1$Status<- as.factor(myData1$Status) 

set.seed(1) 
myIndex<- createDataPartition(myData1$Status, p=0.6, list=FALSE) 
trainSet <- myData1[myIndex,] 
validationSet <- myData1[-myIndex,]

myCtrl <- trainControl(method="cv", number=10) 
myGrid <- expand.grid(.k=c(1:10)) 

set.seed(1) 
KNN_fit <- train(Status ~ ., data=trainSet, method = "knn", trControl=myCtrl, tuneGrid = myGrid) 
KNN_fit 

KNN_Class <- predict(KNN_fit, newdata = validationSet) # Predict the y-hat values
confusionMatrix(KNN_Class, validationSet$Status, positive = '1') # Compute the confusion matrix to assess the model performance. Note that the default cut-off value is 0.5

KNN_Class_prob <- predict(KNN_fit, newdata = validationSet, type='prob') # Predict the p-hat values
KNN_Class_prob # Show the p-hat values
confusionMatrix(as.factor(ifelse(KNN_Class_prob$`1` > 0.25, '1', '0')),
                validationSet$Status, positive = '1') # Change the cut-off value from 0.5 to 0.25

