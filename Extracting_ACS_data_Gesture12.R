#### Gesture 12 - data collected in Nov 2012 to July 2013
#### extract race characteristics from 2017 American Community Survey 5 year estimate

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
setwd("/Users/hyesunghwang/Dropbox/extract-census")

#################### RACE ####################
# Import ACS race dataset (see readme for how to download this dataset)
setwd("/Users/hyesunghwang/Dropbox/extract-census")
ACS_race<-read.csv("ACS_17_5YR_DP05_with_ann.csv", header=TRUE)
# extract columns of interest (the % of population in that race)
ACS_race_short<-select(ACS_race, GEO.id2, HC03_VC54, HC03_VC55, HC03_VC56, HC03_VC61, HC03_VC69, HC03_VC74, HC03_VC75)

# change columns names
colnames(ACS_race_short)[which(names(ACS_race_short) == "GEO.id2")] <- "zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "HC03_VC54")] <- "white_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "HC03_VC55")] <- "black_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "HC03_VC56")] <- "americanindian_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "HC03_VC61")] <- "asian_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "HC03_VC69")] <- "nativehawaiian_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "HC03_VC74")] <- "some_other_race_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "HC03_VC75")] <- "two_or_more_zipcode"

# change values into numeric
ACS_race_short[] <- lapply(ACS_race_short, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x
})
sapply(ACS_race_short, class)

############################################################################### import the column with the zipcodes of interest from an excel dataset
setwd("/Users/hyesunghwang/Dropbox/MN_Secondary/Gesture12/")
Data<-read_excel("Gesture12_ALLDATA_13a.xlsx")
list<-Data$Zipcode

## Loop to extract only zip codes of interest
# empty data frame to hold results
cc_race<-data.frame() 
for (i in list) {
  dd<-as.data.frame(matrix(nrow=1,ncol=NCOL(ACS_race_short)))
  dd<-subset(ACS_race_short, ACS_race_short$zipcode==i)
  cc_race<-rbind(cc_race,dd)
}

# put in column names for extracted dataset with zip codes of interest
colnames(cc_race)<-colnames(ACS_race_short)

# calculate whether all the population % add to 100%
cc_race$sum_zipcode<- rowSums(cc_race[,c(2:8)])

# calculate how much off from 100 (since there is error in measurement typically the numbers are off by .1%)
cc_race$sum_zipcode_diff<-100-cc_race$sum_zipcode

# To make the sum equal 100 (since entropy measurement requires all numbers to sum to 0), add a new column that adds the error to white population
cc_race_corrected<-cc_race
cc_race_corrected$white_zipcode<-cc_race_corrected$white_zipcode+cc_race_corrected$sum_zipcode_diff

# create a new sum now to make sure all population adds to 100
cc_race_corrected$new_sum_zipcode<- rowSums(cc_race_corrected[,c(2:8)])

# divide all values by 100 to change sum to 1
cc_race_corrected<-cc_race_corrected[,-1]/100

## Extract the values into vectors and calculate entropy for each zipcode
# create column to hold entropy values
cc_race_corrected$entropy<-NA
# load entropy library
library(philentropy)

for (i in 1:nrow(cc_race_corrected)) {
  zipcode_vector<-as.numeric(as.vector(cc_race_corrected[i,c(1:7)])) # get the values extracted into vectors for each zipcode/row
  cc_race_corrected[i,11]<-H(zipcode_vector) # calcualte entropy and put it in the entropy column and corresponding zipcode
}

# add in the zipcode column back in
cc_race_corrected$zipcode<-cc_race$zipcode

#################### NonEnglish Language Speakers (%) ####################

# Import ACS foreignborn dataset (see readme for how to download this dataset)
setwd("/Users/hyesunghwang/Dropbox/extract-census")
ACS_nonenglish<-read.csv("ACS_17_5YR_S1601_with_ann.csv", header=TRUE)

# extract columns of interest (the % of population in that race)
ACS_nonenglish_short<-select(ACS_nonenglish, GEO.id2, HC02_EST_VC03)

# change columns names
colnames(ACS_nonenglish_short)[which(names(ACS_nonenglish_short) == "GEO.id2")] <- "zipcode"
colnames(ACS_nonenglish_short)[which(names(ACS_nonenglish_short) == "HC02_EST_VC03")] <- "nonenglish" # Percent; Estimate; Speak a language other than English

# change values into numeric
ACS_nonenglish_short[] <- lapply(ACS_nonenglish_short, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x
})
sapply(ACS_nonenglish_short, class)

# import the column with the zipcodes of interest from an excel dataset
## Loop to extract only zip codes of interest
# empty data frame to hold results
cc_nonenglish<-data.frame() 
for (i in list) {
  dd<-as.data.frame(matrix(nrow=1,ncol=NCOL(ACS_nonenglish_short)))
  dd<-subset(ACS_nonenglish_short, ACS_nonenglish_short$zipcode==i)
  cc_nonenglish<-rbind(cc_nonenglish,dd)
}

# put in column names for extracted dataset with zip codes of interest
colnames(cc_nonenglish)<-colnames(ACS_nonenglish_short)

#################### MEDIAN INCOME ##################### 
# Import ACS income dataset (see readme for how to download this dataset)
setwd("/Users/hyesunghwang/Dropbox/extract-census")
ACS_income<-read.csv("ACS_17_5YR_DP03_with_ann.csv", header=TRUE)
# extract column: Estimate; INCOME AND BENEFITS (IN 2017 INFLATION-ADJUSTED DOLLARS) - Total households - Median household income (dollars)
ACS_income_short<-select(ACS_income, GEO.id2, HC01_VC85)

# change columns names
colnames(ACS_income_short)[which(names(ACS_income_short) == "GEO.id2")] <- "zipcode"
colnames(ACS_income_short)[which(names(ACS_income_short) == "HC01_VC85")] <- "median_income"

# change values into numeric
ACS_income_short[] <- lapply(ACS_income_short, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x
})
sapply(ACS_income_short, class)

## Loop to extract only zip codes of interest
# empty data frame to hold results
cc_income<-data.frame() 
for (i in list) {
  dd<-as.data.frame(matrix(nrow=1,ncol=NCOL(ACS_income_short)))
  dd<-subset(ACS_income_short, ACS_income_short$zipcode==i)
  cc_income<-rbind(cc_income,dd)
}

# put in column names for extracted dataset with zip codes of interest
colnames(cc_income)<-colnames(ACS_income_short)

#################### POPULATION DENSITY ##################### 
# set working directory
setwd("/Users/hyesunghwang/Dropbox/extract-census")
#Population, Housing Units, Area, and Density: 2010 - State -- 5-digit ZIP Code Tabulation Area  more information - 2010 Census Summary File 1
ACS_land_area<-read.csv("DEC_10_SF1_GCTPH1.ST09_with_ann.csv", header=TRUE)

# extract columns: 
# GCT_STUB.display-label (7th column) = Target zipcode
# HD01 = population
# SUBHD0303 = AREA CHARACTERISTICS - Area (Land)
# SUBHD0401 = Density per square mile of land area - Population
ACS_land_area_short<-select(ACS_land_area, 7, HD01, SUBHD0303, SUBHD0401)

# change columns names
colnames(ACS_land_area_short)<-c("zipcode", "HD01","SUBHD0303","SUBHD0401")
colnames(ACS_land_area_short)[which(names(ACS_land_area_short) == "HD01")] <- "population"
colnames(ACS_land_area_short)[which(names(ACS_land_area_short) == "SUBHD0303")] <- "land_area"
colnames(ACS_land_area_short)[which(names(ACS_land_area_short) == "SUBHD0401")] <- "census_density"

# delete strings from the zipcode column
ACS_land_area_short$zipcode = (gsub("[\\ZCTA(part)]", "", ACS_land_area_short$zipcode))
ACS_land_area_short$zipcode = (gsub("[[:blank:]]", "", ACS_land_area_short$zipcode))

# change values into numeric
## factors to numeric
ACS_land_area_short[] <- lapply(ACS_land_area_short, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x
})
sapply(ACS_land_area_short, class)
## characters to numeric
ACS_land_area_short[] <- lapply(ACS_land_area_short, function(x) {
  if(is.character(x)) as.numeric(as.character(x)) else x
})
sapply(ACS_land_area_short, class)

## sum the part zipcodes into one zipcode value
ACS_population_density<-aggregate(. ~ zipcode, data = ACS_land_area_short, sum)

# import the column with the zipcodes of interest from an excel dataset
## Loop to extract only zip codes of interest
# empty data frame to hold results
cc_density<-data.frame() 
for (i in list) {
  dd<-as.data.frame(matrix(nrow=1,ncol=NCOL(ACS_population_density)))
  dd<-subset(ACS_population_density, ACS_population_density$zipcode==i)
  cc_density<-rbind(cc_density,dd)
}

# put in column names for extracted dataset with zip codes of interest
colnames(cc_density)<-colnames(ACS_population_density)

# combine datasets
cc_combined<-cbind(cc_race_corrected, cc_nonenglish, cc_income, cc_density)


#################### Foreign born ####################

# Import ACS foreignborn dataset (see readme for how to download this dataset)
setwd("/Users/hyesunghwang/Dropbox/extract-census")
ACS_foreignborn<-read.csv("ACS_17_5YR_S0501_with_ann.csv", header=TRUE)

# extract columns of interest (the % of population in that race)
ACS_foreignborn_short<-select(ACS_foreignborn, GEO.id2, HC03_EST_VC01)

# change columns names
colnames(ACS_foreignborn_short)[which(names(ACS_foreignborn_short) == "GEO.id2")] <- "zipcode"
colnames(ACS_foreignborn_short)[which(names(ACS_foreignborn_short) == "HC03_EST_VC01")] <- "foreignborn" # Foreign born; Estimate; Total population

# change values into numeric
ACS_foreignborn_short[] <- lapply(ACS_foreignborn_short, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x
})
sapply(ACS_foreignborn_short, class)

## Loop to extract only zip codes of interest
# empty data frame to hold results
cc_foreignborn<-data.frame() 
for (i in list) {
  dd<-as.data.frame(matrix(nrow=1,ncol=NCOL(ACS_foreignborn_short)))
  dd<-subset(ACS_foreignborn_short, ACS_foreignborn_short$zipcode==i)
  cc_foreignborn<-rbind(cc_foreignborn,dd)
}

# put in column names for extracted dataset with zip codes of interest
colnames(cc_foreignborn)<-colnames(ACS_foreignborn_short)


############################################################################### write data into csv file
setwd("/Users/hyesunghwang/Dropbox/MN_Secondary/Gesture12/")
write.csv(cc_combined, file = "Gesture12_zip.csv")

