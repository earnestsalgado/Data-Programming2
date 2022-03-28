# Data and Programming for Public Policy II
# PPHA 30536


## Name of project: Crime, guns, and mental health in Chicago
## Winter 2022
## By Guillermo Trefogli and Earnest Salgado

### Project Description:
We as Hyde Park transplants and Harris students feel there are definitely extraordinary happenings associated with neighborhood violent crime. Recent shootings near campus seem as they're reaching levels not seen in decades, with reasons why still missing. 

At the end of Fall Quarter 2021, UChicago Professor and Pritzker Crime Lab Director Jens Ludwig joined the Big Brains Podcast to give his profound and thoughtful hypothesis as to what causes violent crime to happen at all-and what can be done to help prevent it. According to him, the majority of violent crimes in Chicago stem from altercations and arguments, mostly starting with heated words between strangers. The chief underlying cause of these altercations is stress and mental health. In economically disadvantaged, under-resourced neighborhoods, stress and trauma are much more prevalent than in more affluent neighborhoods. This runs in contrast to common media depictions of gun violence as motivated by money, and is premeditated and deliberate. 

For this final project, we attempt to validate Professor Ludwig's hypothesis and assumptions by examining Chicago's crime and other characteristics that we consider proxy variables for the mental health and prominence of guns in the city

#### Data and data wrangling
The main sources of information from which we got the data are **two datasets** and the content's web scrape from **one independent news service** for Chicago city.

The first source is for **crimes**. We are obtaining the dataset from the City of Chicago open portal. The dataset can be downloaded from the following link: https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-Present/ijzp-q8t2. The size of the dataset is 1.6GB since it contains information from 2001 until the present (last view: March 17, 2022). In order to perform our analysis, as part of the **data-wrangling** process, we subset the dataset by converting the date variable from a string into a datetime and then filtering for the period of summer 2019. The subset dataset is reported as part of the files in the repository of this report.

The second source is for **covariates**. We obtained the dataset from the Chicago Health Atlas data of the Chicago Department of Public Health. The dataset can be downloaded from the following link: https://chicagohealthatlas.org/. The dataset maintains several public health-related indicators, and to perform our analysis we chose 10 of them, for the period between 2015 to 2019, which are reported in our analysis.

The third source is for **independent news service**. The portal we are employing is the following one: https://cwbchicago.com. It is an independent community-funded news service dedicated to reporting crime-related stories. We employ it to analyze sentiments of the news coverage surrounding the crimes data we have. 

We finally employed two complementary sources of information. The fourth one is the **brains podcast** website, from which we got the full transcript for the interview with Professor Ludwig. It can be found in the following link: https://news.uchicago.edu/confronting-gun-violence-data-jens-ludwig. The second one is the **thesaurus website** from which we got the list of mental health concepts. It can be found in the following link: https://thesaurus.yourdictionary.com/mental-health. 

#### Empirics
Specifically, we will examine crimes activity, mental health, and prominence of guns, by the following analysis:

1. **Crime, guns, mental health, and locations**
We first explore the prominence of crime activity in the city of Chicago plotting a map (using **shiny**) which describes the level of activity and locations. To allow the user to explore the relationship of crimes and locations and other indicators, which we consider are proxies to mental health issues, we add an extra section with options to choose plots (in **shiny**) which show the relationship between these complementary indicators and locations. Specifically, the choropleths show various stress and mental health indicators such as poverty, unemployment rate, and suicide mortality to crime areas. The link for the app is the following: https://esalgado.shinyapps.io/final-project-salgadoe/

2. **Crime in the media**
We explore the coverage of crime in the media. Following Professor Ludwig's thesis, we expect to find a coverage that does not highlight the relationship between crimes and mental health or with the prevalence of guns, nor for simple altercations. As an analysis, we will be performing **text processing by web scrapping and sentimental analysis**. The latter will be divided into two parts. First, a general picture about the sentiments in the coverages on the media about crimes. Second, we will analyze the content in terms of mental health terms or concepts. To do so, we will web scrape a list of keywords related to mental health, and then verify the frequency of these words in the content of a media portal for the entire period under analysis (summer 2019).
   
3. **Regression of criminal activity on guns and other covariates**. We explore the relationship between criminal activity and covariates by fitting a model which includes as an outcome variable the level of criminal activity and as explanatory variables the level of guns, level of arrests, ward, and month. We particularly expect to find a positive and strong relationship between the level of criminal activity and the level of gun activity and wards. As can be noticed, we are not trying to recover any causal effects since we are not applying any identification strategy nor applying specifications to estimate causal parameters. Conversely, the coefficients we are recovering should just consider as an initial exploration of the relationship of crimes with some explanatory variables that we consider relevant based on the framework described at the beginning of this report. If we were to revisit this research question again, we would examine the relationship between the indicators for stress and mental health with the crime locations to see if we can predict where and when a crime happens.

In sum, we are reporting the following outputs as part of our analysis:

**R file:**
- app.R file for shiny
- crimes data set subset.R, which contains the data wrangling performed to subset the original crimes dataset from 2001 
- tidy and analysis for crimes.R, which contains the work to get a tidy version for crimes dataset and its associated analysis
- regressions.R for the regression analysis
- webscrap and text analysis.R, which contains the text analysis

**Dataset:**
- Crimes_summer2019_.csv, which contains the subset referred before
- Crimes_tidy.csv which, which contains the tidy version for crimes dataset
- Chicago Health Atlas Data Download - Community areas-10-indicators.csv, which is the original dataset for covariates
- Indicators_tidy.csv, , which contains the tidy version for the set of covariates referred before
**Shape files**
- Shape files needed to perform the spatial analysis

**Text file**
- transcript.txt, which contains the full text of the podcast

**Plots folder**
- We are reporting plots folder which contains all the plots and maps and time series created as part of our analysis  
