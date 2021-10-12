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
stops <- c(stopwords('SMART'), 'amp', 'britishairways', 'british',
                     'flight', 'flights', 'airways')

# Read in Data, clean & organize
text      <- read.csv('BritishAirways.csv')
txtCorpus <- VCorpus(VectorSource(text$text))
txtCorpus <- cleanCorpus(txtCorpus, stops)
tweetTDM  <- TermDocumentMatrix(txtCorpus)
tweetTDMm <- as.matrix(tweetTDM)

# Frequency Data Frame
tweetSums <- rowSums(tweetTDMm)
tweetFreq <- data.frame(word=names(tweetSums),
                        frequency=tweetSums)

# Review a section
tweetFreq[50:55,]

# Remove the row attributes meta family
rownames(tweetFreq) <- NULL
tweetFreq[50:55,]

# Simple barplot; values greater than 15
topWords      <- subset(tweetFreq, tweetFreq$frequency >= 15) 
topWords      <- topWords[order(topWords$frequency, decreasing=F),]

# Chg to factor for ggplot
topWords$word <- factor(topWords$word, 
                        levels=unique(as.character(topWords$word))) 

ggplot(topWords, aes(x=word, y=frequency)) + 
  geom_bar(stat="identity", fill='darkred') + 
  coord_flip()+ theme_gdocs() +
  geom_text(aes(label=frequency), colour="white",hjust=1.25, size=3.0)

# qdap version, slightly different results based on params but single line
plot(freq_terms(text$text, top=35, at.least=2, stopwords = stops))

# End
