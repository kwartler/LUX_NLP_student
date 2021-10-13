#' Title: Text Organization for Bag of Words
#' Purpose: Learn some basic cleaning functions & term frequency
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Oct 11, 2021
#'

# Set the working directory
setwd("~/Desktop/LUX_NLP_student/lessons/oct13/data")

# Libs
library(tm)

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
  corpus <- tm_map(corpus, content_transformer(tryTolower))
  corpus <- tm_map(corpus, removeWords, customStopwords)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, stripWhitespace)
  return(corpus)
} #GG: we use this function so that we don't need to apply what it does text by text, but we can do it on the whole corpus

# Create custom stop words
stops <- c(stopwords('english'), 'lol', 'smh')

# Data
text <- read.csv('coffee.csv', header=TRUE)

# As of tm version 0.7-3 tabular was deprecated
names(text)[1] <- 'doc_id' #GG: again, need to rename first column

# Make a volatile corpus
txtCorpus <- VCorpus(DataframeSource(text))

# Preprocess the corpus
txtCorpus <- cleanCorpus(txtCorpus, stops)

# Need to plain text cleaned copy?r
df <- data.frame(text = unlist(sapply(txtCorpus, `[`, "content")),
                 stringsAsFactors=F)
#write.csv(df,'plain_coffee.csv',row.names = F)

# Compare a single tweet
text$text[4]
df[4,]

# Make a Document Term Matrix or Term Document Matrix depending on analysis
txtDtm  <- DocumentTermMatrix(txtCorpus)
txtDtmM <- as.matrix(txtDtm)

# Examine
txtDtmM[610:611,491:493]

# Get the most frequent terms
topTermsA <- colSums(txtDtmM)
topTermsSLAM <- slam::col_sums(txtDtmM) #alternative mem efficient #GG: library_name_space::command from that library without loading it

# Add the terms
topTermsA <- data.frame(terms     = colnames(txtDtmM), 
                        freq      = topTermsA, 
                        row.names = NULL)
# Review
head(topTermsA)

# Order
exampleReOrder <- topTermsA[order(topTermsA$freq, decreasing = T),] #GG: reordering rows in a decreasing fashion
head(exampleReOrder)

# End