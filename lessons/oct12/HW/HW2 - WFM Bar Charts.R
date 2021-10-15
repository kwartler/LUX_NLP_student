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
library(ggplot2)
library(ggthemes)
library(tidyr)

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
  #corpus <- tm_map(corpus, content_transformer(replace_contraction)) 
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  return(corpus)
}

### Creating custom stop words
stops <- c(stopwords('SMART'), 'amp', 'econtwitter', 'yrs', 'years', 'year', 'yesterday')


# Use both content() to examine 1 document content that is "cleaned"
# Use meta() to examine 1 document's meta information

## Getting data in shape to be fed to DataframeSource()
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

## Checking Meta Data for tweet n.100 in each of the two corpuses

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

## Creating Term Document Matrices
nobelTdm        <- TermDocumentMatrix(nobelCorpus)
nobelTdmM       <- as.matrix(nobelTdm)

## Examining them at some random matrix slice
nobelTdmM[1749:1751,1:4]

## Word Frequency Matrix (nobel)
nobelWordFreqMat        <- rowSums(nobelTdmM)
nobelWordFreqMat        <- data.frame(terms = rownames(nobelTdmM), freq = nobelWordFreqMat)

# Order the WFM decreasing = T
nobelWordFreqMat <- arrange(nobelWordFreqMat, desc(freq))

# Review the top 25
head(nobelWordFreqMat, n = 25L)

# Build a single bar plot with only Data --A using flipped coordinates and add an appropriate title.
topWords      <- subset(nobelWordFreqMat, nobelWordFreqMat$freq >= 65) 
topWords      <- topWords[order(topWords$freq, decreasing=F),]

topWords$terms <- factor(topWords$terms, 
                        levels=unique(as.character(topWords$terms))) 

jpeg('barplot_nobel.jpg')
ggplot(topWords, aes(x=terms, y=freq)) + 
  geom_bar(stat="identity", fill='darkred') + 
  coord_flip() + theme_gdocs() +
  geom_text(aes(label=freq), colour="white",hjust=1.25, size=3.0) +
  ggtitle("Frequency of top 25 terms in tweets about Nobel")
dev.off()

# For Data --B 
# Be sure to paste/collapse both A and B
nobelWordFreqMat$terms <- NULL
nobelWordFreqMat <- as.matrix(nobelWordFreqMat)

## For the sake of variety, I obtain econtwitterWordFreqMat through a different routine where I collapse immediately and then use VectorSource()
econtwitter             <- readRDS('econtwitter.rds')
econtwitter             <- paste(econtwitter$text, collapse = ' ')
econtwitterCorpus       <- VCorpus(VectorSource(econtwitter))
econtwitterCorpus       <- cleanCorpus(econtwitterCorpus, stops)
econtwitterWordFreqMat  <- TermDocumentMatrix(econtwitterCorpus)
econtwitterWordFreqMat  <- as.matrix(econtwitterWordFreqMat)

# Merge the data set
bothTerms <- merge(nobelWordFreqMat, econtwitterWordFreqMat, by ='row.names')
bothTerms <- arrange(bothTerms, desc(Row.names))
dim(bothTerms)
names(bothTerms) <- c('terms', 'nobel', 'econtwitter')
head(bothTerms, n = 25L)

# Pivot the two data sets
bothTerms <- pivot_longer(bothTerms,c(nobel,econtwitter))

# Obtain the top 35 terms from both
bothTerms <- bothTerms[order(bothTerms$value, decreasing = T),]
print(as_tibble(bothTerms), n=35)
## get top 35 to plot
top35 <- bothTerms[1:35,]
top35$terms <- as.factor(top35$terms)

# Create a stacked bar chart with appropriate title
jpeg('stacked.jpg')
ggplot(top35, aes(x=reorder(terms, -value), y = value, fill=as.factor(name) )) + 
  geom_col() + 
  theme_hc() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
  ggtitle('word frequencies shared by nobel & econtwitter')
dev.off()

# Create a proportional bar chart with appropriate title
jpeg('proportion.jpg')
ggplot(top35, aes(x=reorder(terms, -value), y = value, fill=as.factor(name) )) + 
  geom_col(position = "fill" ) + 
  theme_hc() + 
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
  ggtitle('word frequencies shared by nobel & econtwitter')
dev.off()

