library(data.table)
library(dplyr)

URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dest<- "CourseDataset.zip"
if (!file.exists(destFile)){
  download.file(URL, destfile = dest, mode='wb')
}
if (!file.exists("./UCI_HAR_Dataset")){
  unzip(destFile)
}

Activity_test <- read.table("./test/y_test.txt", header = F)
Activity_train <- read.table("./train/y_train.txt", header = F)
Features_test <- read.table("./test/X_test.txt", header = F)
Features_train <- read.table("./train/X_train.txt", header = F)
Subject_test <- read.table("./test/subject_test.txt", header = F)
Subject_train <- read.table("./train/subject_train.txt", header = F)

ActivityLabels <- read.table("./activity_labels.txt", header = F)
FeaturesNames <- read.table("./features.txt", header = F)

##Merging
Features_data <- rbind(Features_test, Features_train)
Subject_data <- rbind(Subject_test, Subject_train)
Activity_data <- rbind(Activity_test, Activity_train)

##Renaming
names(Activity_data) <- "ActivityN"
names(ActivityLabels) <- c("ActivityN", "Activity")
Activity <- left_join(Activity_data, ActivityLabels, "ActivityN")[, 2]
names(Subject_data) <- "Subject"
names(Features_data) <- FeaturesNames$V2

###Create one large Dataset with only these variables: SubjectData,  Activity,  FeaturesData
DataSet <- cbind(SubjectData, Activity)
DataSet <- cbind(DataSet, FeaturesData)

##dataset for only the measurements on the mean and standard deviation for each measurement
subFeaturesNames <- FeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", FeaturesNames$V2)]
Data_names <- c("Subject", "Activity", as.character(subFeaturesNames))
DataSet <- subset(DataSet, select=Data_names)

###Renaming the columns
names(DataSet)<-gsub("^t", "time", names(DataSet))
names(DataSet)<-gsub("^f", "frequency", names(DataSet))
names(DataSet)<-gsub("Acc", "Accelerometer", names(DataSet))
names(DataSet)<-gsub("Gyro", "Gyroscope", names(DataSet))
names(DataSet)<-gsub("Mag", "Magnitude", names(DataSet))
names(DataSet)<-gsub("BodyBody", "Body", names(DataSet))

##A second, independent tidy data set with the average of each variable for each activity and each subject
SecondDataSet<-aggregate(. ~Subject + Activity, DataSet, mean)
SecondDataSet<-SecondDataSet[order(SecondDataSet$Subject,SecondDataSet$Activity),]

#Save this tidy dataset to local file
write.table(SecondDataSet, file = "tidydataset.txt",row.name=FALSE)
