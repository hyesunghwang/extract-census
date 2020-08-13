
#### extract race characteristics from 2018 American Community Survey - Demographic and Housing Estimates 

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


#################### RACE ####################
# Import ACS ACS DEMOGRAPHIC AND HOUSING ESTIMATES dataset (see readme for how to download this dataset)
setwd("/Users/hyesunghwang/Dropbox/extract-census")
ACS_race<-read.csv("ACSDP5Y2018.DP05_data_with_overlays_2020-07-21T075534.csv", header=TRUE)
# clean up zip code column to get only the number
ACS_race<-ACS_race %>% separate(2, into = c('ZCTA', 'census_zipcode'), sep = 6)
# delete null first row
ACS_race<-ACS_race[-1,]

# create a hispanic cateogry that includes ethnicity of mexican 
# DP05_0072PE mexican : Percent Estimate!!HISPANIC OR LATINO AND RACE!!Total population!!Hispanic or Latino (of any race)!!Mexican
# DP05_0073PE Puerto Rican: Percent Estimate!!HISPANIC OR LATINO AND RACE!!Total population!!Hispanic or Latino (of any race)!!Puerto Rican
# DP05_0074PE cuban: Percent Estimate!!HISPANIC OR LATINO AND RACE!!Total population!!Hispanic or Latino (of any race)!!Cuban
# DP05_0075PE other hispanic or latino: Percent Estimate!!HISPANIC OR LATINO AND RACE!!Total population!!Hispanic or Latino (of any race)!!Other Hispanic or Latino
# DP05_0071PE all hispanic: Percent Estimate!!HISPANIC OR LATINO AND RACE!!Total population!!Hispanic or Latino (of any race) = this column is equal to adding all the columns above

ACS_race2<-dplyr::select(ACS_race, DP05_0071PE, DP05_0072PE, DP05_0073PE, DP05_0074PE, DP05_0075PE)

# change values into numeric
ACS_race2[] <- lapply(ACS_race2, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x
})
sapply(ACS_race2, class)

# sum to create a hispanic column
ACS_race2$Hispanic<-rowSums(ACS_race2[,c(2:4)])

# extract columns of interest (the % of population in that race)
ACS_race_short<-dplyr::select(ACS_race, DP05_0077PE, DP05_0078PE, DP05_0079PE, DP05_0080PE, DP05_0081PE, DP05_0071PE, DP05_0082PE, DP05_0083PE)

# change columns names
colnames(ACS_race_short)[which(names(ACS_race_short) == "DP05_0077PE")] <- "white_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "DP05_0078PE")] <- "black_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "DP05_0079PE")] <- "americanindian_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "DP05_0080PE")] <- "asian_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "DP05_0081PE")] <- "nativehawaiian_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "DP05_0071PE")] <- "hispanic_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "DP05_0082PE")] <- "some_other_race_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "DP05_0083PE")] <- "two_or_more_zipcode"

# add the hispanic column
#ACS_race_short$Hispanic<-ACS_race2$Hispanic

# change values into numeric
ACS_race_short[] <- lapply(ACS_race_short, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x
})
sapply(ACS_race_short, class)

ACS_race_short$zipcode<-ACS_race$census_zipcode


############################################################################### import the column with the zipcodes of interest from an excel dataset
setwd("/Users/hyesunghwang/Dropbox/food_diversity/child_food_study/Study2_increase_sample_size")
Data<-read_excel("child_food_study_data_cleaned.xlsx")
Data$zipcode<-as.numeric(Data$zipcode)
list<-Data$zipcode

## Loop to extract only zip codes of interest
# empty data frame to hold results
cc_race<-data.frame() 
for (i in list) {
  dd<-as.data.frame(matrix(nrow=1,ncol=NCOL(ACS_race_short)))
  dd<-subset(ACS_race_short, ACS_race_short$zipcode==i)
  cc_race<-rbind(cc_race,dd)
}

# divide all values by 100 to change sum to 1
cc_race_corrected<-cc_race[,-9]/100
cc_race_corrected$zipcode<-cc_race$zipcode

# put in column names for extracted dataset with zip codes of interest
colnames(cc_race_corrected)<-colnames(ACS_race_short)

# calculate whether all the population % add to 100%
cc_race_corrected$sum_zipcode<- rowSums(cc_race_corrected[,c(1:7)])

# calculate how much off from 100 (since there is error in measurement typically the numbers are off by .1%)
cc_race_corrected$sum_zipcode_diff<-1-cc_race_corrected$sum_zipcode

# To make the sum equal 100 (since entropy measurement requires all numbers to sum to 0), add a new column that adds the error to two or more race population
cc_race_corrected$two_or_more_zipcode<-cc_race_corrected$two_or_more_zipcode+cc_race_corrected$sum_zipcode_diff

# create a new sum now to make sure all population adds to 1
cc_race_corrected$new_sum_zipcode<- rowSums(cc_race_corrected[,c(1:7)])

## Extract the values into vectors and calculate entropy for each zipcode
# create column to hold entropy values
cc_race_corrected$race_entropy<-NA
# load entropy library
library(philentropy)

for (i in 1:nrow(cc_race_corrected)) {
  zipcode_vector<-as.numeric(as.vector(cc_race_corrected[i,c(1:7)])) # get the values extracted into vectors for each zipcode/row
  cc_race_corrected[i,13]<-H(zipcode_vector) # calcualte entropy and put it in the entropy column and corresponding zipcode
}


# delete columns that are no longer useful
cc_race_corrected<-dplyr::select(cc_race_corrected, -c(sum_zipcode,sum_zipcode_diff, new_sum_zipcode))

#################### NonEnglish Language Speakers (%) ####################

# Import ACS Language Spoken at home dataset (see readme for how to download this dataset)
setwd("/Users/hyesunghwang/Dropbox/extract-census")
ACS_nonenglish<-read.csv("ACSST5Y2018.S1601_data_with_overlays_2020-07-28T181025.csv", header=TRUE)

# clean up zip code column to get only the number
ACS_nonenglish<-ACS_nonenglish %>% separate(2, into = c('ZCTA', 'census_zipcode'), sep = 6)
# delete null first row
ACS_nonenglish<-ACS_nonenglish[-1,]

# extract columns of interest (the % of population in that race)
ACS_nonenglish_short<-dplyr::select(ACS_nonenglish, S1601_C02_003E, S1601_C02_002E, S1601_C02_004E, S1601_C02_008E, S1601_C02_012E, S1601_C02_016E)

# change columns names
colnames(ACS_nonenglish_short)[which(names(ACS_nonenglish_short) == "S1601_C02_003E")] <- "percent_nonenglish" # Estimate!!Percent!!Population 5 years and over!!Speak a language other than English
colnames(ACS_nonenglish_short)[which(names(ACS_nonenglish_short) == "S1601_C02_002E")] <- "percent_englishonly" # Estimate!!Percent of specified language speakers!!Percent speak English only or speak English very well"!!Population 5 years and over!!Speak a language other than English"
colnames(ACS_nonenglish_short)[which(names(ACS_nonenglish_short) == "S1601_C02_004E")] <- "percent_spanish_speaking" # Estimate!!Percent!!Population 5 years and over!!SPEAK A LANGUAGE OTHER THAN ENGLISH!!Spanish
colnames(ACS_nonenglish_short)[which(names(ACS_nonenglish_short) == "S1601_C02_008E")] <- "percent_IndoEuropean_speaking" #Estimate!!Percent!!Population 5 years and over!!SPEAK A LANGUAGE OTHER THAN ENGLISH!!Other Indo-European languages
colnames(ACS_nonenglish_short)[which(names(ACS_nonenglish_short) == "S1601_C02_012E")] <- "percent_AsianPacific_speaking"# Estimate!!Total!!Population 5 years and over!!SPEAK A LANGUAGE OTHER THAN ENGLISH!!Asian and Pacific Island languages
colnames(ACS_nonenglish_short)[which(names(ACS_nonenglish_short) == "S1601_C02_016E")] <- "percent_otherlang_speaking"# Estimate!!Percent!!Population 5 years and over!!SPEAK A LANGUAGE OTHER THAN ENGLISH!!Other languages

##### add in language measures
# change values into numeric
ACS_nonenglish_short[] <- lapply(ACS_nonenglish_short, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x
})
sapply(ACS_nonenglish_short, class)

# divide by 100 so it is in decimal point
ACS_nonenglish_short<-ACS_nonenglish_short/100

# add zip code
ACS_nonenglish_short$zipcode<-ACS_nonenglish$census_zipcode

# import the column with the zipcodes of interest from an excel dataset
## Loop to extract only zip codes of interest
# empty data frame to hold results
cc_nonenglish<-data.frame() 
for (i in list) {
  dd<-as.data.frame(matrix(nrow=1,ncol=NCOL(ACS_nonenglish_short)))
  dd<-subset(ACS_nonenglish_short, ACS_nonenglish_short$zipcode==i)
  cc_nonenglish<-rbind(cc_nonenglish,dd)
}

# calculate linguistic entropy
# calculate whether all the population % add to 100%
cc_nonenglish$sum_zipcode<- rowSums(cc_nonenglish[,c(2:6)])

# calculate how much off from 100 (since there is error in measurement typically the numbers are off by .1%)
cc_nonenglish$sum_zipcode_diff<-1-cc_nonenglish$sum_zipcode

# To make the sum equal 100 (since entropy measurement requires all numbers to sum to 0), add a new column that adds the error to other language population
cc_nonenglish_corrected<-cc_nonenglish
cc_nonenglish_corrected$percent_otherlang_speaking<-cc_nonenglish_corrected$percent_otherlang_speaking+cc_nonenglish_corrected$sum_zipcode_diff

# create a new sum now to make sure all population adds to 10
cc_nonenglish_corrected$new_sum_zipcode<- rowSums(cc_nonenglish_corrected[,c(2:6)])

## Extract the values into vectors and calculate entropy for each zipcode
# create column to hold entropy values
cc_nonenglish_corrected$lang_entropy<-NA
# load entropy library
library(philentropy)

for (i in 1:nrow(cc_nonenglish_corrected)) {
  zipcode_vector<-as.numeric(as.vector(cc_nonenglish_corrected[i,c(2:6)])) # get the values extracted into vectors for each zipcode/row
  cc_nonenglish_corrected[i,11]<-H(zipcode_vector) # calcualte entropy and put it in the entropy column and corresponding zipcode
}

# delete columns that are no longer useful
cc_nonenglish_corrected<-dplyr::select(cc_nonenglish_corrected, -c(zipcode, sum_zipcode,sum_zipcode_diff, new_sum_zipcode))

#################### MEDIAN INCOME ##################### 
# Import ACS income dataset (see readme for how to download this dataset)
setwd("/Users/hyesunghwang/Dropbox/extract-census")
ACS_income<-read.csv("ACSDP5Y2018.DP03_data_with_overlays_2020-07-28T144525.csv", header=TRUE)

# clean up zip code column to get only the number
ACS_income<-ACS_income %>% separate(2, into = c('ZCTA', 'census_zipcode'), sep = 6)
# delete null first row
ACS_income<-ACS_income[-1,]

# extract column: Estimate!!INCOME AND BENEFITS (IN 2018 INFLATION-ADJUSTED DOLLARS)!!Total households!!Median household income (dollars)
ACS_income_short<-dplyr::select(ACS_income, DP03_0062E)

# change columns names
colnames(ACS_income_short)[which(names(ACS_income_short) == "DP03_0062E")] <- "median_income"

# change values into numeric
ACS_income_short[] <- lapply(ACS_income_short, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x
})
sapply(ACS_income_short, class)

# add zip code
ACS_income_short$zipcode<-ACS_income$census_zipcode

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

# delete zip code to prevent redundant info
cc_income<-dplyr::select(cc_income, -zipcode)

#################### POPULATION DENSITY ##################### 
# set working directory
setwd("/Users/hyesunghwang/Dropbox/extract-census")
#Population, Housing Units, Area, and Density: 2010 - State -- 5-digit ZIP Code Tabulation Area  more information - 2010 Census Summary File 1
ACS_land_area<-read.csv("DEC_10_SF1_GCTPH1.ST09_with_ann.csv", header=TRUE)

# clean up zip code column to get only the number
ACS_land_area<-ACS_land_area %>% separate(7, into = c('ZCTA', 'census_zipcode'), sep = 5)

# delete null first row
ACS_land_area<-ACS_land_area[-1,]

# extract columns: 
# GCT_STUB.display-label (7th column) = Target zipcode
# HD01 = population
# SUBHD0303 = AREA CHARACTERISTICS - Area (Land)
# SUBHD0401 = Density per square mile of land area - Population
ACS_land_area_short<-dplyr::select(ACS_land_area, HD01, SUBHD0303, SUBHD0401)

# change columns names
colnames(ACS_land_area_short)<-c("HD01","SUBHD0303","SUBHD0401")
colnames(ACS_land_area_short)[which(names(ACS_land_area_short) == "HD01")] <- "population"
colnames(ACS_land_area_short)[which(names(ACS_land_area_short) == "SUBHD0303")] <- "land_area"
colnames(ACS_land_area_short)[which(names(ACS_land_area_short) == "SUBHD0401")] <- "census_density"

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

ACS_land_area_short$zipcode<-ACS_land_area$census_zipcode
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

# delete zip code to prevent redundant info
cc_density<-dplyr::select(cc_density, -zipcode)

#################### Education ##################### 

# Import ACS ed dataset (see readme for how to download this dataset)
setwd("/Users/hyesunghwang/Dropbox/extract-census")
ACS_ed<-read.csv("ACSST5Y2018.S1501_data_with_overlays_2020-07-21T180804.csv", header=TRUE)

# clean up zip code column to get only the number
ACS_ed<-ACS_ed %>% separate(2, into = c('ZCTA', 'census_zipcode'), sep = 6)

# delete null first row
ACS_ed<-ACS_ed[-1,]

# extract column: HC02_EST_VC17 : Percent; Estimate; Percent high school graduate or higher; HC02_EST_VC18 :Percent; Estimate; Percent bachelor's degree or higher
ACS_ed_short<-dplyr::select(ACS_ed, S1501_C02_023E, S1501_C02_021E)

# change columns names
colnames(ACS_ed_short)[which(names(ACS_ed_short) == "S1501_C02_023E")] <- "Ed_highschool_higher" #Estimate!!Percent!!Population 25 years and over!!Population 45 to 64 years!!High school graduate or higher
colnames(ACS_ed_short)[which(names(ACS_ed_short) == "S1501_C02_021E")] <- "Ed_ba_higher" # Estimate!!Percent!!Population 25 years and over!!Population 35 to 44 years!!Bachelor's degree or higher


# change values into numeric
ACS_ed_short[] <- lapply(ACS_ed_short, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x
})
sapply(ACS_ed_short, class)

# add zip code
ACS_ed_short$zipcode<-ACS_ed$census_zipcode

## Loop to extract only zip codes of interest
# empty data frame to hold results
cc_ed<-data.frame() 
for (i in list) {
  dd<-as.data.frame(matrix(nrow=1,ncol=NCOL(ACS_ed_short)))
  dd<-subset(ACS_ed_short, ACS_ed_short$zipcode==i)
  cc_ed<-rbind(cc_ed,dd)
}

# put in column names for extracted dataset with zip codes of interest
colnames(cc_ed)<-colnames(ACS_ed_short)

# delete zip code to prevent redundant info
cc_ed<-dplyr::select(cc_ed, -zipcode)

#################### combine datasets for the census data  #################### 
cc_combined<-cbind(cc_race_corrected, cc_nonenglish_corrected, cc_income, cc_density, cc_ed)

############################################################################### write data into csv file
setwd("/Users/hyesunghwang/Dropbox/food_diversity/child_food_study/Study2_increase_sample_size")
write.csv(cc_combined, file = "child_food_study_data_zipcode_only.csv")

#################### put in zip code based census and covid data into the original data set  #################### 
# delete redundant information in zip code
library(dplyr)
cc_combined_short<-distinct(cc_combined)

# original data set
Data<-read_excel("child_food_study_data_cleaned.xlsx")

# add in the zipcode column to reference
cc_combined_short$zipcode_final<-cc_combined_short$zipcode
Data$zipcode_final<-Data$zipcode

# include empty columns to fill the census
cc_combined_short2<-cc_combined_short[1,]
cc_combined_short2[1,]<-NA
Data<-cbind(Data, cc_combined_short2)

# loop through and include data only if have info on that zip code
for (i in  1:nrow(Data)) {
  if(ifelse(sum(ifelse(cc_combined_short$zipcode_final==as.numeric(Data[i,match("zipcode_final",names(Data))]), 1,0), na.rm=T) >0, 1,0) >0) # if there is a zip code that matches in the COVID & census data set, then extract that data and put it in. else put in NAs.
  {
    Data[i,match("white_zipcode",names(Data)):ncol(Data)]<-subset(cc_combined_short, cc_combined_short$zipcode_final==as.numeric(Data[i,match("zipcode_final",names(Data))]))
  }
  else{}
}

# reset row names
rownames(Data)<-1:nrow(Data)

# write data
write.csv(Data, file = "Child_food_zipcode.csv")
