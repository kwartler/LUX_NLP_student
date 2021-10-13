#' Title: Frequency and Associations
#' Purpose: Obtain term frequency and explore associations
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Oct 10, 2021
#'

# Set the working directory
setwd("~/Documents/GitHub/LUX_NLP_student/lessons/oct12/data")

# Libs
library(tm)
library(qdap)
library(ggplot2)
library(ggthemes)
library(tidyr)

# Options & Functions
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


# Create custom stop words
stops <- c(stopwords('SMART'), 'amp', 'beer', 'coffee')

# Read in Data -- A
beer      <- read.csv('beer.csv')
beer      <- paste(beer$text, collapse = ' ')
beerCorpus <- VCorpus(VectorSource(beer))
beerCorpus <- cleanCorpus(beerCorpus, stops)
beerTDM  <- TermDocumentMatrix(beerCorpus)
beerTDMm <- as.matrix(beerTDM)

# Read in Data -- B
coffee      <- read.csv('coffee.csv')
coffee      <- paste(coffee$text, collapse = ' ')
coffeeCorpus <- VCorpus(VectorSource(coffee))
coffeeCorpus <- cleanCorpus(coffeeCorpus, stops)
coffeeTDM  <- TermDocumentMatrix(coffeeCorpus)
coffeeTDMm <- as.matrix(coffeeTDM)

# Later we will perform inner_join and left_join but this is fine for now
bothTerms <- merge(beerTDMm, coffeeTDMm, by ='row.names')
head(bothTerms)
dim(bothTerms)

# rename
names(bothTerms) <- c('terms', 'beer', 'coffee')
head(bothTerms)

# Reshape for ggplot
bothTerms <- pivot_longer(bothTerms,c(beer,coffee))
head(bothTerms,12)
bothTerms <- bothTerms[order(bothTerms$value, decreasing = T),]

# get top 50 to plot
top50 <- bothTerms[1:50,]
top50$terms <- as.factor(top50$terms)

# Stacked
ggplot(top50, aes(x=reorder(terms, -value), y = value, fill=as.factor(name) )) + 
  geom_col() + 
  theme_hc() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
  ggtitle('word frequencies shared w beer & coffee')

# Proportion
ggplot(top50, aes(x=reorder(terms, -value), y = value, fill=as.factor(name) )) + 
  geom_col(position = "fill" ) + 
  theme_hc() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
  ggtitle('word frequencies shared w beer & coffee')

# Side by Side isn't very good in this example
ggplot(top50, aes(x=reorder(terms, -value), y = value, fill=as.factor(name) )) + 
  geom_col(position = "dodge" ) + 
  theme_hc() + 
  geom_text(aes(label = value), hjust = -0.5, size = 2.5, colour = 'black', angle = 90) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
  ggtitle('word frequencies shared w beer & coffee')

# End
