
#### extract median population from 2017 American Community Survey - Demographic and Housing Estimates 

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
setwd("/Users/hyesunghwang/Dropbox/MN_Secondary/Census_data/")


# Import ACS population dataset (see readme for how to download this dataset)
ACS_population<-read.csv("ACS_17_5YR_DP05_with_ann.csv", header=TRUE)
ACS_land_area<-read.csv("DEC_10_SF1_GCTPH1.ST09_with_ann.csv", header=TRUE)
#Population, Housing Units, Area, and Density: 2010 - State -- 5-digit ZIP Code Tabulation Area  more information - 2010 Census Summary File 1

# extract columns: 
# GEO.id2 = zipcode
# HC01_VC03 = Estimate; SEX AND AGE - Total population; 
ACS_population_short<-select(ACS_population, GEO.id2, HC01_VC03)
# GCT_STUB.display-label (7th column) = Target zipcode
# HD01 = population
# SUBHD0303 = AREA CHARACTERISTICS - Area (Land)
# SUBHD0401 = Density per square mile of land area - Population
ACS_land_area_short<-select(ACS_land_area, 7, HD01, SUBHD0303, SUBHD0401)
# change columns names
colnames(ACS_population_short)[which(names(ACS_population_short) == "GEO.id2")] <- "zipcode"
colnames(ACS_population_short)[which(names(ACS_population_short) == "HC01_VC03")] <- "total_population"

colnames(ACS_land_area_short)<-c("zipcode", "HD01","SUBHD0303","SUBHD0401")
colnames(ACS_land_area_short)[which(names(ACS_land_area_short) == "HD01")] <- "population"
colnames(ACS_land_area_short)[which(names(ACS_land_area_short) == "SUBHD0303")] <- "land_area"
colnames(ACS_land_area_short)[which(names(ACS_land_area_short) == "SUBHD0401")] <- "census_density"

# delete strings from the zipcode
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
ACS_land_area_short_agg<-aggregate(. ~ zipcode, data = ACS_land_area_short, sum)

# bind togehter
ACS_population_short<-ACS_population_short[-1,]
ACS_population_density<-cbind(ACS_population_short, ACS_land_area_short_agg)

# change values into numeric
ACS_population_density[] <- lapply(ACS_population_density, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x
})
sapply(ACS_population_density, class)

# calculate poulation density
ACS_population_density$density<-(ACS_population_density$total_population/ACS_population_density$land_area)


# import the column with the zipcodes of interest from an excel dataset
Data<-read_excel("Grace_PtS_muERD.xlsx")
list<-Data$Zipcode

## Loop to extract only zip codes of interest
# empty data frame to hold results
cc<-data.frame() 
for (i in list) {
  dd<-as.data.frame(matrix(nrow=1,ncol=NCOL(ACS_population_density)))
  dd<-subset(ACS_population_density, ACS_population_density$zipcode==i)
  cc<-rbind(cc,dd)
}

# put in column names for extracted dataset with zip codes of interest
colnames(cc)<-colnames(ACS_population_density)

# write data into csv file
write.csv(cc, file = "Pts_population_density_muERD.csv")
