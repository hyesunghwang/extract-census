# R Script to Extract US Census Data by Zip Code

## Introduction 
This R script helps extract the population percentage estimates (for example, by race/ethnicity) from the 2017 American Community Survey - Demographic and Housing Estimates for relevant zip codes. This script also includes a way to calculate an entropy value that represents the diversity of different racial/ethnic groups in that particular zip code (i.e., a way to weigh the number and amount of different racial/ethnic groups in a zip code) using the R package 'philentropy.'

Before using this script, download the 2017 American Community Survey - Demographic and Housing Estimates from the US census website (https://factfinder.census.gov/faces/nav/jsf/pages/download_center.xhtml). Below is a screenshot of how to access and download the correct dataset file:

![ACS_screenshot](ACS_dataset_extraction_screenshot.png)

The file name of the dataset should be : ACS_17_5YR_DP05_with_ann.csv

## Description of columns of interests in the ACS dataset

### Major racial and ethnic categories

- GEO.id2 : zip code 
- HC03_VC54 : Percent; RACE - One race - White
- HC03_VC55 : Percent; RACE - One race - Black or African American
- HC03_VC56 : Percent; RACE - One race - American Indian and Alaska Native
- HC03_VC61 : Percent; RACE - One race - Asian
- HC03_VC69 : Percent; RACE - One race - Native Hawaiian and Other Pacific Islander
- HC03_VC74 : Percent; RACE - One race - Some other race
- HC03_VC75 : Percent; RACE - Two or more races

### Asian sub-categories 

- HC03_VC62 : Percent; RACE - One race - Asian Indian
- HC03_VC63 : Percent; RACE - One race -Chinese 
- HC03_VC64 : Percent; RACE - One race -Fillipino 
- HC03_VC65 : Percent; RACE - One race -Japanese 
- HC03_VC66 : Percent; RACE - One race -Korean 
- HC03_VC67 : Percent; RACE - One race -Vietnamese 
- HC03_VC68 : Percent; RACE - One race -Other asian


