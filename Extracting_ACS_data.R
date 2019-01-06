
#### extract race characteristics from 2017 American Community Survey - Demographic and Housing Estimates 

### Set the workspace

# Clear the workspace and console
rm(list = ls(all = TRUE)) 
cat("\014")

# load library
library(readxl)
library(psych)
library(tidyr)
library(plyr)
library(dplyr)

  
# set working directory
setwd("/Users/hyesunghwang/Dropbox/MN_Secondary/Census_data")
 
# Import ACS survey dataset (see readme for how to download this dataset)
ACS_survey<-read.csv("ACS_17_5YR_DP05_with_ann.csv", header=TRUE)

# extract columns of interest (the % of population in that race)
ACS_survey_short<-select(ACS_survey, GEO.id2, HC03_VC54, HC03_VC55, HC03_VC56, HC03_VC61, HC03_VC69, HC03_VC74, HC03_VC75)

# change columns names
colnames(ACS_survey_short)[which(names(ACS_survey_short) == "GEO.id2")] <- "zipcode"
colnames(ACS_survey_short)[which(names(ACS_survey_short) == "HC03_VC54")] <- "white_zipcode"
colnames(ACS_survey_short)[which(names(ACS_survey_short) == "HC03_VC55")] <- "black_zipcode"
colnames(ACS_survey_short)[which(names(ACS_survey_short) == "HC03_VC56")] <- "americanindian_zipcode"
colnames(ACS_survey_short)[which(names(ACS_survey_short) == "HC03_VC61")] <- "asian_zipcode"
colnames(ACS_survey_short)[which(names(ACS_survey_short) == "HC03_VC69")] <- "nativehawaiian_zipcode"
colnames(ACS_survey_short)[which(names(ACS_survey_short) == "HC03_VC74")] <- "some_other_race_zipcode"
colnames(ACS_survey_short)[which(names(ACS_survey_short) == "HC03_VC75")] <- "two_or_more_zipcode"

# change values into numeric
ACS_survey_short[] <- lapply(ACS_survey_short, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x
})
sapply(ACS_survey_short, class)

# import the column with the zipcodes of interest from an excel dataset
Data<-read_excel("PtS_mastersheet.xlsx", sheet= "Sheet1")
list<-Data$Zipcode

## Loop to extract only zip codes of interest
# empty data frame to hold results
cc<-data.frame() 
for (i in list) {
  dd<-as.data.frame(matrix(nrow=1,ncol=NCOL(ACS_survey_short)))
  dd<-subset(ACS_survey_short, ACS_survey_short$zipcode==i)
  cc<-rbind(cc,dd)
}

# put in column names for extracted dataset with zip codes of interest
colnames(cc)<-colnames(ACS_survey_short)

# calculate whether all the population % add to 100%
cc$sum_zipcode<- rowSums(cc[,c(2:8)])

# calculate how much off from 100 (since there is error in measurement typically the numbers are off by .1%)
cc$sum_zipcode_diff<-100-cc$sum_zipcode

# To make the sum equal 100 (since entropy measurement requires all numbers to sum to 0), add a new column that adds the error to white population
cc_corrected<-cc
cc_corrected$white_zipcode<-cc_corrected$white_zipcode+cc_corrected$sum_zipcode_diff

# create a new sum now to make sure all population adds to 100
cc_corrected$new_sum_zipcode<- rowSums(cc_corrected[,c(2:8)])

# divide all values by 100 to change sum to 1
cc_corrected<-cc_corrected[,-1]/100



## Extract the values into vectors and calculate entropy for each zipcode
# create column to hold entropy values
cc_corrected$entropy<-NA
# load entropy library
library(philentropy)

for (i in 1:nrow(cc_corrected)) {
  zipcode_vector<-as.numeric(as.vector(cc_corrected[i,c(1:7)])) # get the values extracted into vectors for each zipcode/row
  cc_corrected[i,11]<-H(zipcode_vector) # calcualte entropy and put it in the entropy column and corresponding zipcode
}

# add in the zipcode column back in
cc_corrected$zipcode<-cc$zipcode

# write data into csv file
write.csv(cc_corrected, file = "Pts_ACS_survey_zipcode.csv")


##############
# put zipcode into corresponding values in the dataset - still in the works
# read in data file
BIG_zipcode<-read_excel("BIG_zipcode.xlsx")

# subset to only the relevant subject numbers
BIG_zipcode_short<-subset(BIG_zipcode, P %in% c("14", "19",
                                                "20",
                                                "22",
                                                "26",
                                                "34",
                                                "36",
                                                "38",
                                                "39",
                                                "40",
                                                "42",
                                                "45",
                                                "51",
                                                "53",
                                                "55",
                                                "58",
                                                "62",
                                                "63",
                                                "64",
                                                "65",
                                                "69",
                                                "70",
                                                "72",
                                                "78"))

write.csv(BIG_zipcode_short, file = "BIG_zipcode_short.csv")





