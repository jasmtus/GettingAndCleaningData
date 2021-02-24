#loading required packages
library(dplyr)
library(data.table)

#Downloading dataset
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")

#unzip the dataset
unzip(zipfile="./data/Dataset.zip",exdir="./data")

#unzipped files are in the folderUCI HAR Dataset. Get the list of the files
path_rf <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
files

#Assigning all data frames
features <- read.table(file.path(path_rf,"features.txt"), col.names = c("n", "functions"))
activity <- read.table(file.path(path_rf,"activity_labels.txt"), col.names = c("class", "activity"))
subject_test <- read.table(file.path(path_rf, "test", "subject_test.txt"), col.names = "subject")
X_test <- read.table(file.path(path_rf, "test", "X_test.txt"), col.names = features$functions)
Y_test <- read.table(file.path(path_rf, "test", "Y_test.txt"), col.names = "code")
subject_train <- read.table(file.path(path_rf, "train", "subject_train.txt"), col.names = "subject")
X_train <- read.table(file.path(path_rf, "train", "X_train.txt"), col.names = features$functions)
Y_train <- read.table(file.path(path_rf, "train", "Y_train.txt"), col.names = "code")

#Look at properties of the data frames
str(features)
str(activity)
str(subject_test)
str(X_test)
str(Y_test)
str(subject_train)
str(X_train)
str(Y_train)

#Combine test and train dataset into one
merged_X <-rbind(X_test, X_train)
merged_Y <- rbind(Y_test, Y_train)
merged_subject <- rbind(subject_test, subject_train)
data <- cbind(merged_subject, merged_X, merged_Y)
str(data)

#Extract only the measurments on the mean and std dev
tidyData <- data %>% select(subject, code, contains("mean"), contains("std"))
str(tidyData)

#Use descriptive activity names to name the activities in the dataset
tidyData$code <- activity[tidyData$code, 2]

#Appropriately label the data set with descriptive variable names
names(tidyData)[2] = "activity"
names(tidyData) <- gsub("Acc", "Accelerometer", names(tidyData))
names(tidyData) <- gsub("Gyro", "Gyroscope", names(tidyData))
names(tidyData) <- gsub("^t", "Time", names(tidyData))
names(tidyData) <- gsub("BodyBody", "Body", names(tidyData))
names(tidyData) <- gsub("Mag", "Magnitude", names(tidyData))
names(tidyData) <- gsub("^f", "Frequency", names(tidyData))
names(tidyData)<-gsub("mean", " Mean", names(tidyData), ignore.case = TRUE)
names(tidyData)<-gsub("STD", "STD", names(tidyData), ignore.case = TRUE)
names(tidyData)<-gsub("freq", "Frequency", names(tidyData), ignore.case = TRUE)
names(tidyData)<-gsub("angle", "Angle", names(tidyData))
str(tidyData)
?summarise_all

#Create a second, independent tidy data set with the average of each variable for each activity and each subject.
FinalData <- tidyData %>% group_by(subject, activity) %>% summarise_all(funs(mean))
write.table(FinalData, "./FinalData.txt", row.names = FALSE)
str(FinalData)
