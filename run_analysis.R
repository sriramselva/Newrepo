library("data.table")
library("reshape2")


#Extract training data
training_X <- read.csv("UCI HAR Dataset/train/X_train.txt", sep="", header=FALSE)
training_Y<-read.csv("UCI HAR Dataset/train/Y_train.txt", sep="", header=FALSE)
training_subject<-read.csv("UCI HAR Dataset/train/subject_train.txt", sep="", header=FALSE)

#Extract testing data
testing_X <- read.csv("UCI HAR Dataset/test/X_test.txt", sep="", header=FALSE)
testing_Y<-read.csv("UCI HAR Dataset/test/Y_test.txt", sep="", header=FALSE)
testing_subject<-read.csv("UCI HAR Dataset/test/subject_test.txt", sep="", header=FALSE)

#Extract features
features <- read.table("UCI HAR Dataset/features.txt")[,2]

names(testing_X) = features

#Features containg only mean and standard deviation in second column of features table
filteredf <- grepl("mean|std", features)
head(filteredf)
testing_X = testing_X[,filteredf]

#Extract activity labels
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels <- activity_labels[,2]

#Set column 2 as activity labels based on col 1 data in Y
testing_Y[,2] = activity_labels[testing_Y[,1]]
names(testing_Y) = c("Activity_ID", "Activity_Label")
names(testing_subject) = "Subject"

#Column bind all testing data
all_test_data <- cbind(as.data.table(testing_subject), testing_Y, testing_X)

names(training_X) = features
training_X = training_X[,filteredf]

#Set column 2 as activity labels based on col 1 data in Y
training_Y[,2] = activity_labels[training_Y[,1]]
names(training_Y) = c("Activity_ID", "Activity_Label")
names(training_subject) = "Subject"

#Column bind all training data
all_train_data <- cbind(as.data.table(training_subject), training_Y, training_X)

#Merge all data
all_data = rbind(all_test_data, all_train_data)

#Reshape data with Subject Activity_ID Activity_Label values
id_labels = c("Subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(all_data), id_labels)
melt_data = melt(all_data, id = id_labels, measure.vars = data_labels)

#Recast data with mean
tidy_data = dcast(melt_data, Subject + Activity_Label ~ variable, mean)
write.table(tidy_data, file = "./tidy_data.txt",row.name=FALSE)
