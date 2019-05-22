# R Script to Extract US Census Data by Zip Code

## Introduction 
This R script helps extract the population percentage estimates (for example, by race/ethnicity) from the American Community Survey (ACS) and US Census for relevant zip codes. This script also includes a way to calculate an entropy value that represents the diversity of different racial/ethnic groups in that particular zip code (i.e., a way to weigh the number and amount of different racial/ethnic groups in a zip code) using the R package 'philentropy.'

Before using this script, download the relevant American Community Surveys from the US census download center (https://factfinder.census.gov/faces/nav/jsf/pages/download_center.xhtml)

## Race & Ethnicity
ACS Demographic and Housing Estimates.
In the download center, narrow your selections to:
1) Dataset: 2017 ACS 5-year estimates 
2) 5-Digist ZCTA All 5-Digit ZIP Code Tabulation Areas within United States and Puerto Rico
3) Demographics
The file name of the dataset should be : ACS_17_5YR_DP05_with_ann.csv

Below is a screenshot of how to access and download the correct dataset file for 2017 dataset:

![ACS_screenshot](ACS_dataset_extraction_screenshot.png)

### Description of columns of interests 

#### Major racial and ethnic categories

- GEO.id2 : zip code 
- HC03_VC54 : Percent; RACE - One race - White
- HC03_VC55 : Percent; RACE - One race - Black or African American
- HC03_VC56 : Percent; RACE - One race - American Indian and Alaska Native
- HC03_VC61 : Percent; RACE - One race - Asian
- HC03_VC69 : Percent; RACE - One race - Native Hawaiian and Other Pacific Islander
- HC03_VC74 : Percent; RACE - One race - Some other race
- HC03_VC75 : Percent; RACE - Two or more races

#### Asian sub-categories 

- HC03_VC62 : Percent; RACE - One race - Asian Indian
- HC03_VC63 : Percent; RACE - One race -Chinese 
- HC03_VC64 : Percent; RACE - One race -Fillipino 
- HC03_VC65 : Percent; RACE - One race -Japanese 
- HC03_VC66 : Percent; RACE - One race -Korean 
- HC03_VC67 : Percent; RACE - One race -Vietnamese 
- HC03_VC68 : Percent; RACE - One race -Other asian

## Non-English speaking population
Language Spoken at Home.
In the download center, narrow your selections to:
1) Dataset: 2017 ACS 5-year estimates 
2) 5-Digist ZCTA All 5-Digit ZIP Code Tabulation Areas within United States and Puerto Rico
3) Language spoken at home
The file name of the dataset should be : ACS_17_5YR_S1601_with_ann.csv

### Description of columns of interests 
 - GEO.id2 : zip code
 - HC02_EST_VC03 : Percent; Estimate; Speak a language other than English

## Median income 
Selected economic characteristics
In the download center, narrow your selections to:
1) Dataset: 2017 ACS 5-year estimates 
2) 5-Digist ZCTA All 5-Digit ZIP Code Tabulation Areas within United States and Puerto Rico
3) selected economic characteristics
The file name of the dataset should be : ACS_17_5YR_DP03_with_ann.csv

### Description of columns of interests 
 - GEO.id2 : zip code
 - HC01_VC85 : Estimate; INCOME AND BENEFITS (IN 2017 INFLATION-ADJUSTED DOLLARS) - Total households - Median household income (dollars)
 
## Education attainment
In the download center, narrow your selections to:
1) Dataset: 2017 ACS 5-year estimates 
2) 5-Digist ZCTA All 5-Digit ZIP Code Tabulation Areas within United States and Puerto Rico
3) B15003: EDUCATIONAL ATTAINMENT FOR THE POPULATION 25 YEARS AND OVER 
The file name of the dataset should be : ACS_17_5YR_B15003_with_ann.csv
 
## Population density
This one is taken from the 2010 US census instead of ACS because ACS does not have population density measures (or as far as I can find).
Instead of download center, go to advanced search and search the following term:
"Population, Housing Units, Area, and Density: 2010 - State -- 5-digit ZIP Code Tabulation Area  more information - 2010 Census Summary File 1""

The file name of the dataset should be : DEC_10_SF1_GCTPH1.ST09_with_ann.csv

### Description of columns of interests 
 - GCT_STUB.display-label (7th column) : Target zipcode
 - HD01 : population
 - SUBHD0303 : AREA CHARACTERISTICS - Area (Land)
 - SUBHD0401 : Density per square mile of land area - Population
 
 
 
 
 
