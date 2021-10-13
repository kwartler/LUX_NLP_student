#' Title: Dendrograms and Word Networks
#' Purpose: Use text for various HC and network visuals
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Oct 11, 2021
#'

# Set the working directory
setwd("~/Documents/GitHub/LUX_NLP_student/lessons/oct13/data")

# Libs
library(tm)
library(qdap)
library(ggplot2)
library(ggthemes)
library(ggdendro)

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
stops <- c(stopwords('smart'), 'amp', 'britishairways', 'british',
           'flight', 'flights', 'airways')

# Read in Data, clean & organize
text      <- read.csv('BritishAirways.csv')
txtCorpus <- VCorpus(VectorSource(text$text))
txtCorpus <- cleanCorpus(txtCorpus, stops)
tweetTDM  <- TermDocumentMatrix(txtCorpus)

# Reduce TDM
reducedTDM <- removeSparseTerms(tweetTDM, sparse=0.985) #shoot for ~50 terms; 1.5% of cells in row have a value / #GG: retain rows where 1.5% or more cells have non-zerovalue  
reducedTDM

# Organize the smaller TDM
reducedTDM <- as.data.frame(as.matrix(reducedTDM)) #GG: Recast matrix as dataframe

# Basic Hierarchical Clustering / #GG: This would be like descriptive statistics
hc <- hclust(dist(reducedTDM))
plot(hc,yaxt='n')

ggdendrogram(hc, rotate=FALSE) #GG: check out dendextend for further graphical tweaks

############ Back to PPT

networkStops <- c(stops, 'britishairways', 'british', 'airways', 'rt')

assocText <- rm_url(text$text)

# MORE QDAP!
word_associate(assocText, 
               match.string = 'brewdog', 
               stopwords = networkStops,
               network.plot = T,
               cloud.colors = c('black','darkred'))

# MORE QDAP! #GG: size related to frequency but now don't know order of association
word_associate(assocText, 
               match.string = 'brewdog', 
               stopwords = networkStops,
               wordcloud = T,
               cloud.colors = c('black','darkred'))

# End

