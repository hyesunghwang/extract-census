
#### extract race characteristics from 2022 American Community Survey - Demographic and Housing Estimates 

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


## call in data
rai <- read_excel("RAI_census2.xlsx")

library(zipcodeR)

# Ensure you have the latest version of zipcodeR loaded to access the most up-to-date schema of zip_code_db
# If zip_code_db includes a state column, adjust the selection accordingly
county_info <- zip_code_db[, c("zipcode", "county", "state")]

# If you want to concatenate county and state into a single string for easier comparison or display:
county_info$county_state <- paste(county_info$county, county_info$state, sep = ", ")

# Then merge the updated county_info with your rai dataframe
rai <- merge(rai, county_info, by.x = "zipcode", by.y = "zipcode", all.x = TRUE)



library(tidycensus)

census_api_key("d7383e71ddb61433025098b281266373aa595043", install = TRUE) 

# Example: Getting data for a specific state; replace "XX" with a state abbreviation
population_data <- get_acs(
  geography = "county",
  variables = c(white = "B02001_002",
                black = "B02001_003"),
  year = 2022, # most recent year as of March 5 2024
 output = "wide"
)


# Selecting and renaming for clarity
population_data_clean <- population_data %>%
  select(county = NAME, GEOID, White_population_county = whiteE, Black_population_county = blackE)

library(maps)

# Assuming population_data has been fetched and contains a "county" column
population_data_clean2 <- population_data_clean %>%
  # Separate the county column into "county_name" and "state_name"
  separate(county, into = c("county", "state_name"), sep = ", ") %>%
  # Convert state names to abbreviations
  mutate(state = state.abb[match(state_name, state.name)])

# Example to make column names lowercase for both dataframes
names(rai) <- tolower(names(rai))
names(population_data_clean2) <- tolower(names(population_data_clean2))

# Then try merging again with lowercase column names in the 'by' argument
merged_df <- merge(rai, population_data_clean2, by = c("county", "state"), all.x = TRUE)

## calculating dissimiliaryt index
# To calculate the Black-White Residential Segregation Index, often referred to as the Dissimilarity Index (D), for county-level data in R, you'll first need to ensure that your merged dataframe contains the necessary population data. This index quantifies the distribution of two groups across neighborhoods or, in this case, counties, indicating how segregated the groups are from one another.




#################### RACE ####################
# Import ACS ACS DEMOGRAPHIC AND HOUSING ESTIMATES dataset (see readme for how to download this dataset)
ACS_race<-read.csv("ACSDP5Y2022.DP05-Data.csv", header=TRUE)
# clean up zip code column to get only the number
ACS_race<-ACS_race %>% separate(2, into = c('ZCTA', 'census_zipcode'), sep = 6)
# delete null first row
ACS_race<-ACS_race[-1,]

# extract columns of interest (the % of population in that race; always double-check b/c census likes to change these column numbers)
ACS_race_short<-dplyr::select(ACS_race, DP05_0073PE, DP05_0079PE, DP05_0080PE, DP05_0081PE, DP05_0082PE, DP05_0083PE, DP05_0084PE, DP05_0085PE)
                              
# change columns names
colnames(ACS_race_short)[which(names(ACS_race_short) == "DP05_0073PE")] <- "hispanic_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "DP05_0079PE")] <- "white_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "DP05_0080PE")] <- "black_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "DP05_0081PE")] <- "americanindian_alaskan_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "DP05_0082PE")] <- "asian_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "DP05_0083PE")] <- "nativehawaiian_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "DP05_0084PE")] <- "some_other_race_zipcode"
colnames(ACS_race_short)[which(names(ACS_race_short) == "DP05_0085PE")] <- "two_or_more_zipcode"


# change values into numeric
ACS_race_short[] <- lapply(ACS_race_short, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x
})
sapply(ACS_race_short, class)

ACS_race_short$zipcode<-ACS_race$census_zipcode


############################################################################### import the column with the zipcodes of interest from an excel dataset
Data<-read_xlsx("RAI_Combined_social_network2.xlsx")

list<-Data$zipcode

## Loop to extract only zip codes of interest
# empty data frame to hold results
cc_race<-data.frame() 
for (i in list) {
  dd<-as.data.frame(matrix(nrow=1,ncol=NCOL(ACS_race_short)))
  dd<-subset(ACS_race_short, ACS_race_short$zipcode==i)
  cc_race<-rbind(cc_race,dd)
}

# change dataframe to numeric
cc_race<-as.data.frame(lapply(cc_race, as.numeric))

# divide all values by 100 to change sum to 1
cc_race_corrected<-cc_race[,-9]/100
cc_race_corrected$zipcode<-cc_race$zipcode

# put in column names for extracted dataset with zip codes of interest
colnames(cc_race_corrected)<-colnames(ACS_race_short)

# calculate whether all the population % add to 100%
cc_race_corrected$sum_zipcode<- rowSums(cc_race_corrected[,c(1:8)])

# calculate how much off from 100 (since there is error in measurement typically the numbers are off by .1%)
cc_race_corrected$sum_zipcode_diff<-1-cc_race_corrected$sum_zipcode

# To make the sum equal 100 (since entropy measurement requires all numbers to sum to 0), add a new column that adds the error to two or more race population
cc_race_corrected$two_or_more_zipcode<-cc_race_corrected$two_or_more_zipcode+cc_race_corrected$sum_zipcode_diff

# create a new sum now to make sure all population adds to 1
cc_race_corrected$new_sum_zipcode<- rowSums(cc_race_corrected[,c(1:8)])

## Extract the values into vectors and calculate entropy for each zipcode
# create column to hold entropy values
cc_race_corrected$race_entropy<-NA
# load entropy library
library(philentropy)

for (i in 1:nrow(cc_race_corrected)) {
  zipcode_vector<-as.numeric(as.vector(cc_race_corrected[i,c(1:8)])) # get the values extracted into vectors for each zipcode/row
  cc_race_corrected[i,13]<-H(zipcode_vector) # calcualte entropy and put it in the entropy column and corresponding zipcode
}


# delete columns that are no longer useful
cc_race_corrected<-dplyr::select(cc_race_corrected, -c(sum_zipcode,sum_zipcode_diff, new_sum_zipcode))


#################### MEDIAN INCOME ##################### 
# Import ACS income dataset (see readme for how to download this dataset)
ACS_income<-read.csv("ACSST5Y2022.S2503-Data.csv", header=TRUE)

# extract column: Estimate!!Occupied housing units!!Occupied housing units!!HOUSEHOLD INCOME IN THE PAST 12 MONTHS (IN 2022 INFLATION-ADJUSTED DOLLARS)!!Median household income (dollars)
ACS_income_short<-dplyr::select(ACS_income, NAME, S2503_C01_013E)

# delete null first row
ACS_income_short2<-ACS_income_short[-1,]

# clean up zip code column to get only the number
ACS_income_short3 <- ACS_income_short2 %>%
  separate(NAME, into = c('ZCTA', 'census_zipcode'), sep = 6)

# change columns names
colnames(ACS_income_short3)[which(names(ACS_income_short3) == "S2503_C01_013E")] <- "median_income"

# change values into numeric
ACS_income_short3$median_income<-as.numeric(ACS_income_short3$median_income)
  
# add zip code
ACS_income_short3$zipcode<-ACS_income$census_zipcode

## Loop to extract only zip codes of interest
cc_income <- ACS_income_short3 %>%
  filter(census_zipcode %in% list)


# delete column info not needed
cc_income<-dplyr::select(cc_income, -ZCTA)

colnames(cc_income)[colnames(cc_income) == "census_zipcode"] <- "zipcode"

#################### POPULATION DENSITY ##################### 
# set working directory
#Population, Housing Units, Area, and Density: 2010 - State -- 5-digit ZIP Code Tabulation Area  more information - 2010 Census Summary File 1
ACS_land_area<-read.csv("DEC_10_SF1_GCTPH1.ST09_with_ann.csv", header=TRUE)

# clean up zip code column to get only the number
ACS_land_area2<-ACS_land_area %>% separate(7, into = c('ZCTA', 'census_zipcode'), sep = 5)

# delete null first row
ACS_land_area3<-ACS_land_area2[-1,]

# delete leading columns not needed
ACS_land_area3<-ACS_land_area3[,-c(1:6)]

# extract columns: 
# GCT_STUB.display-label (7th column) = Target zipcode
# HD01 = population
# SUBHD0303 = AREA CHARACTERISTICS - Area (Land)
# SUBHD0401 = Density per square mile of land area - Population
ACS_land_area_short4<-dplyr::select(ACS_land_area3, HD01, SUBHD0303, SUBHD0401)

# change columns names
colnames(ACS_land_area_short4)<-c("HD01","SUBHD0303","SUBHD0401")
colnames(ACS_land_area_short4)[which(names(ACS_land_area_short4) == "HD01")] <- "population"
colnames(ACS_land_area_short4)[which(names(ACS_land_area_short4) == "SUBHD0303")] <- "land_area"
colnames(ACS_land_area_short4)[which(names(ACS_land_area_short4) == "SUBHD0401")] <- "census_density"

# change values into numeric
## factors to numeric
ACS_land_area_short4[] <- lapply(ACS_land_area_short4, function(x) {
  if(is.factor(x)) as.numeric(as.character(x)) else x
})
sapply(ACS_land_area_short4, class)

## characters to numeric
ACS_land_area_short4[] <- lapply(ACS_land_area_short4, function(x) {
  if(is.character(x)) as.numeric(as.character(x)) else x
})
sapply(ACS_land_area_short4, class)

ACS_land_area_short4$zipcode<-ACS_land_area3$census_zipcode

## sum the part zipcodes into one zipcode value
ACS_population_density<-aggregate(. ~ zipcode, data = ACS_land_area_short4, sum)

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
#cc_density<-dplyr::select(cc_density, -zipcode)

#################### Education ##################### 

# Import ACS ed dataset (see readme for how to download this dataset)
ACS_ed<-read.csv("ACSST5Y2022.S1501-Data.csv", header=TRUE)

# clean up zip code column to get only the number
ACS_ed<-ACS_ed %>% separate(2, into = c('ZCTA', 'census_zipcode'), sep = 6)

# delete null first row
ACS_ed<-ACS_ed[-1,]

# extract column: HC02_EST_VC17 : Percent; Estimate; Percent high school graduate or higher; HC02_EST_VC18 :Percent; Estimate; Percent bachelor's degree or higher
ACS_ed_short<-dplyr::select(ACS_ed, S1501_C02_014E, S1501_C02_015E)

# change columns names
colnames(ACS_ed_short)[which(names(ACS_ed_short) == "S1501_C02_014E")] <- "Ed_highschool_higher" #Estimate!!Percent!!AGE BY EDUCATIONAL ATTAINMENT!!Population 25 years and over!!High school graduate or higher 
colnames(ACS_ed_short)[which(names(ACS_ed_short) == "S1501_C02_015E")] <- "Ed_ba_higher" #Estimate!!Percent!!AGE BY EDUCATIONAL ATTAINMENT!!Population 25 years and over!!Bachelor's degree or higher
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
#cc_ed<-dplyr::select(cc_ed, -zipcode)

#################### combine datasets for the census data  #################### 
cc_combined<-cbind(cc_race_corrected, cc_density, cc_ed)

# delete the zip codes that are duplicate columns
cc_race_corrected2<-dplyr::select(cc_race_corrected, -zipcode)
cc_density2<-dplyr::select(cc_density, -zipcode)

cc_combined2<-cbind(cc_race_corrected2, cc_density2, cc_ed)

# add income which has diff # of row bc not all info possible by zipcode 
cc_combined3 <- left_join(cc_combined2, cc_income2, by = "zipcode")

############################################################################### write data into csv file ############################################################################### 
write.csv(cc_combined3, file = "RAI_census.csv")

#################### put in zip code based census data into the original data set  #################### 
# delete redundant information in zip code
library(dplyr)
cc_combined_short<-distinct(cc_combined3)
Data<-read_xlsx("RAI_Combined_social_network2.xlsx")


# add in the zipcode column to reference
cc_combined_short$zipcode_final<-cc_combined_short$zipcode
Data$zipcode_final<-Data$zipcode

# include empty columns to fill the census
cc_combined_short2<-cc_combined_short[1,]
cc_combined_short2[1,]<-NA
Data<-cbind(Data, cc_combined_short2)

# loop through and include data only if have info on that zip code
for (i in  1:nrow(Data)) {
  if(ifelse(sum(ifelse(cc_combined_short$zipcode_final==as.character(Data[i,match("zipcode_final",names(Data))]), 1,0), na.rm=T) >0, 1,0) >0) # if there is a zip code that matches in the COVID & census data set, then extract that data and put it in. else put in NAs.
  {
    Data[i,match("hispanic_zipcode",names(Data)):ncol(Data)]<-subset(cc_combined_short, cc_combined_short$zipcode_final==as.character(Data[i,match("zipcode_final",names(Data))]))
  }
  else{}
}

# reset row names
rownames(Data)<-1:nrow(Data)

# write data
write.csv(Data, file = "RAI_census.csv")
