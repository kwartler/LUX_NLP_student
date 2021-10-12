#' Title: Text Organization for Bag of Words
#' Purpose: Learn some basic cleaning functions & term frequency
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Oct 10, 2021
#'

# Set the working directory
setwd("~/Documents/GitHub/LUX_NLP_student/lessons/oct12/data")

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
}

# Create custom stop words
stops <- c(stopwords('english'), 'lol', 'smh')

# Data
text <- read.csv('beer.csv', header=TRUE)

# As of tm version 0.7-3 tabular was deprecated
names(text)[1] <- 'doc_id' 

# Make a volatile corpus
txtCorpus <- VCorpus(DataframeSource(text))

# Preprocess the corpus
txtCorpus <- cleanCorpus(txtCorpus, stops)

# Check Meta Data; brackets matter!!
txtCorpus[[4]]
meta(txtCorpus[4])
content(txtCorpus[[4]])

# Need to plain text cleaned copy?r
df <- data.frame(text = unlist(sapply(txtCorpus, `[`, "content")),
                 stringsAsFactors=F)

# Or as a single vector
cleanTxt <- sapply(txtCorpus, content)

# Compare a single tweet
text$text[4]
df[4,]

# Make a Document Term Matrix or Term Document Matrix depending on analysis
txtDtm  <- DocumentTermMatrix(txtCorpus)
txtTdm  <- TermDocumentMatrix(txtCorpus)
txtDtmM <- as.matrix(txtDtm)
txtTdmM <- as.matrix(txtTdm)

# Examine
txtDtmM[283:285,491:493]
txtTdmM[491:493,283:285]

# Get the most frequent terms
topTermsA <- colSums(txtDtmM)
topTermsB <- rowSums(txtTdmM)

# Add the terms
topTermsA <- data.frame(terms = colnames(txtDtmM), freq = topTermsA)
topTermsB <- data.frame(terms = rownames(txtTdmM), freq = topTermsB)

# Remove row attributes
rownames(topTermsA) <- NULL
rownames(topTermsB) <- NULL

# Review
head(topTermsA)
head(topTermsB)

# Order
exampleReOrder <- topTermsA[order(topTermsA$freq, decreasing = T),]
head(exampleReOrder)

# Which term is the most frequent?
idx <- which.max(topTermsA$freq)
topTermsA[idx, ]

### Alternatively, when presented with large data, as.matrix can cause problems, instead stay with simple triplet matrices using library(slam)
class(txtDtm)
class(txtTdm)

head(slam::col_sums(txtDtm)) #GG: use slam when you have really large data
head(slam::row_sums(txtTdm))

slamWFM <- data.frame(term = names(slam::col_sums(txtDtm)),
                      freq = slam::col_sums(txtDtm))
rownames(slamWFM) <- NULL
head(slamWFM)
# End