#' Title: Polarity Over Time
#' Purpose: Learn and calculate polarity 
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Oct 12, 2021
#'

#GG: looking at polarity in Paul Krugman's tweets over time
# Wd
setwd("~/Documents/GitHub/LUX_NLP_student/lessons/oct14/data")

# Libs
library(tm)
library(qdap)
#library(rtweet)
library(lubridate)
library(dplyr)

# Custom Functions
source('~/Documents/GitHub/LUX_NLP_student/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

# Data
#econ <- rtweet::get_timeline('PaulKrugman', n = 1000)
#saveRDS(econ, 'econ.rds')
econ <- readRDS('econ.rds')

# Data
head(econ$created_at)
class(econ$created_at)
min(econ$created_at)
max(econ$created_at)

# Extract Temporal Grouping Options
econ$min <-  minute(econ$created_at)
econ$hr  <-   hour(econ$created_at)
econ$day <- day(econ$created_at)
econ$weekDay <-  weekdays(econ$created_at)
econ$week    <- week(econ$created_at)

# Examine to see what's been extracted
head(econ$min)
head(econ$hr)
head(econ$day)
head(econ$weekDay)
head(econ$week)

# Now get the polarity for each doc
polUni <- polarity(as.character(econ$text))
polUni

# Now Organize the temporal and polarity info
timePol <- data.frame(tweetPol = polUni$all$polarity,
                      min      = econ$min,
                      hr       = econ$hr,
                      day      = econ$day, 
                      weekDay  = econ$weekDay,
                      week     = econ$week)

# Examine
head(timePol)
mean(timePol$tweetPol, na.rm = T)
polUni

# NA to 0
timePol[is.na(timePol)] <- 0

# Week Avg
wklyPol <- aggregate(tweetPol~week, timePol, mean)
wklyPol
plot(wklyPol$week, wklyPol$tweetPol, type = 'l')

# Hourly Avg
hrPol <- aggregate(tweetPol~day+hr, timePol, mean)
hrPol <- hrPol[order(hrPol$day, hrPol$hr),]
plot(hrPol$tweetPol, type = 'l')

# Minute by Minute Avg
minPol <- aggregate(tweetPol~day+hr+min, timePol, mean)
minPol[order(minPol$day, minPol$hr, minPol$min),]

# Summary Stats by weekday, useful for repeating patterns (seasonality)
weekDayPol <- aggregate(tweetPol~weekDay, timePol, mean)
weekDayPol

# Tell R the ordinal nature of the factor levels
weekDayPol$weekDay <- factor(weekDayPol$weekDay, 
                             levels= c("Sunday", "Monday", "Tuesday", 
                                       "Wednesday", "Thursday", "Friday", "Saturday"))

weekDayPol[order(weekDayPol$weekDay), ]

# Week of Yr
weekPol <- aggregate(tweetPol~week, timePol, mean)
weekPol

# Don't forget its often helpful to get N for each period.  Plus you could marry temporal polarity to events and announcements.  Here is an example:
weekN <- as.data.frame(table(timePol$week))
weekN$Var1 <- as.numeric(as.character(weekN$Var1))
left_join(weekPol, weekN, by = c('week' = 'Var1'))

hrN <- as.data.frame(table(hrPol$day, hrPol$hr))
names(hrN) <- c('day', 'hr', 'Freq')
hrN$day <- as.numeric(as.character(hrN$day))
hrN$hr <- as.numeric(as.character(hrN$hr))
left_join(hrPol, hrN, by = c('day' = 'day', 'hr' = 'hr'))

# Quanteda package does time series analysis too but not covered in class.
# https://stackoverflow.com/questions/58918872/performing-time-series-analysis-of-quanteda-tokens
# End