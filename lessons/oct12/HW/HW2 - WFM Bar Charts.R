#' Title: Homework II
#' Purpose: Obtain Data, save it, perform word frequency, then compare shared word frequencies
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Oct 10, 2021
#'

# Preliminaries

## Setting the working directory
setwd("~/Documents/GitHub/LUX_NLP_student/lessons/oct12/HW")

## Libraries
library(rtweet)
library(tm)
library(dplyr)

## Obtaing Data -- A - search term: "nobel"
nobel       <- search_tweets(q = 'nobel', n = 1000, lang = "en")
## Obtaing Data -- B - search term: "econtwitter" (this is a popular hastag academic economists use on twitter)
econtwitter <- search_tweets(q = 'econtwitter', n = 1000, lang = "en")

## Saving original data to turn in with HW.
saveRDS(nobel, 'nobel.rds') # Data --A
saveRDS(econtwitter, 'econtwitter.rds') # Data --B


## Performing all text preprocessing steps with custom functions & stopwords

### Options & Functions
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL','C')

tryTolower <- function(x){
  y = NA
  try_error = tryCatch(tolower(x), error = function(e) e)
  if (!inherits(try_error, 'error'))
    y = tolower(x)
  return(y)
}

cleanCorpus<-function(corpus, customStopwords){
  corpus <- tm_map(corpus, content_transformer(qdapRegex::rm_url))
  corpus <- tm_map(corpus, content_transformer(replace_contraction)) 
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

### Creating custom stop words
stops <- c(stopwords('SMART'), 'amp')


# Use both content() to examine 1 document content that is "cleaned"
# Use meta() to examine 1 document's meta information
econtwitter$doc_id  <- seq.int(nrow(econtwitter))
econtwitter         <- econtwitter[,c(ncol(econtwitter), 1:(ncol(econtwitter)-1))]

nobel$doc_id        <- seq.int(nrow(nobel))
nobel               <- nobel[,c(ncol(nobel), 1:(ncol(nobel)-1))]

## Making volatile corpuses
econtwitterCorpus   <- VCorpus(DataframeSource(econtwitter))
nobelCorpus         <- VCorpus(DataframeSource(nobel))

## Preprocessing the corpuses
econtwitterCorpus   <- cleanCorpus(econtwitterCorpus, stops)
nobelCorpus         <- cleanCorpus(nobelCorpus, stops)

## Checking Meta Data for tweet n.10 in each of the two corpuses

### nobel
nobelCorpus[[100]]
meta(nobelCorpus[[100]])
t(meta(nobelCorpus[100]))

content(nobelCorpus[100])
content(nobelCorpus[[100]])

### econtwitter
econtwitterCorpus[[100]]
meta(econtwitterCorpus[[100]])
t(meta(econtwitterCorpus[100]))

content(econtwitterCorpus[100])
content(econtwitterCorpus[[100]])


# For Data --A 
# Create a single word frequency matrix
# Order the WFM decreasing = T
# Review the top 25
# Build a single bar plot with only Data --A using flipped coordinates and add an appropriate title.

# For Data --B 
# Be sure to paste/collapse both A and B
# Merge the data set
# Pivot the two data sets
# Obtain the top 35 terms from both
# Create a stacked bar chart with appropriate title
# Create a proportional bar chart with appropriate title

# End