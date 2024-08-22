library(dplyr)
library(janitor)

testSet <- read.table("./data/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/test/X_test.txt")
trainSet <- read.table("./data/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/train/X_train.txt")

featureNames <- read.table("./data/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/features.txt")

testSet %>% 
    data.table::setnames(
        old = testSet %>% names(),
        new = featureNames[["V2"]]
    )
	
trainSet %>% 
    data.table::setnames(
        old = trainSet %>% names(),
        new = featureNames[["V2"]]
    )
	
testSet <- clean_names(testSet)
trainSet <- clean_names(trainSet)


testSet <-  mutate(testSet, set="test")
trainSet <-  mutate(trainSet, set="training")

personsTest <- read.table("./data/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/test/subject_test.txt")


colnames(personsTest)[1] <- "person_id"

personsTrain <- read.table("./data/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/train/subject_train.txt")

colnames(personsTrain)[1] <- "person_id"


testSet <-  mutate(testSet, person_id=personsTest[["person_id"]])
trainSet <-  mutate(trainSet, person_id=personsTrain[["person_id"]])


exercisesTest <- read.table("./data/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/test/y_test.txt")

exercisesTrain <- read.table("./data/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/train/y_train.txt")


exerciseLabels <- read.table("./data/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/activity_labels.txt")


testSet <-  mutate(testSet, exercise_id=exercisesTest[[1]])
trainSet <-  mutate(trainSet, exercise_id=exercisesTrain[[1]])


colnames(exerciseLabels)[1] <- "exercise_id"
colnames(exerciseLabels)[2] <- "activity_label"

testSet <- testSet %>%
    inner_join(exerciseLabels, by = 'exercise_id')
	
trainSet <- trainSet %>%
    inner_join(exerciseLabels, by = 'exercise_id')

testSet <- testSet %>% 
    select(-exercise_id)
	
trainSet <- trainSet %>% 
    select(-exercise_id)

harData <- rbind(testSet, trainSet)


# Step 4. Extracts only the measurements on the mean and standard deviation for each measurement. 

harData <- harData %>% 
    select(grep("mean|std|set|activity_label|person_id", names(harData)))
	

# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject

groupedHarData <- harData %>%
   group_by(activity_label, person_id) %>%
   summarise_at(vars(-group_cols(), -set), mean)
	
write.table(groupedHarData, "./data/groupedHarData.txt", row.name=FALSE)





