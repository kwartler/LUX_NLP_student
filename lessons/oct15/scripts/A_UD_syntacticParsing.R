#' Title: UD Syntactic Parsing
#' Purpose: Apply syntactic parsing
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Oct 13, 2021
#'

# Libs
library(udpipe)
library(tm)
library(pbapply)
library(qdap)
library(reshape2)
library(dplyr)

# Wd
setwd("~/Documents/GitHub/LUX_NLP_student/lessons/oct15/data")

# Inputs #GG: lemmatization takes long. try code on a testing parameter
datPth          <- 'tweets_jairbolsonaro.csv'
testing         <- F
nonBasicStops   <- c('segura', 'seguro')

# Options
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL','C')

# Bring in the cleaning function
source('~/Documents/GitHub/LUX_NLP_student/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

# Get a language model to the server
?udpipe_download_model 
udModel <- udpipe_download_model(language  = "portuguese-gsd", 
                                 model_dir = getwd())

# Load into the space
udModel <- udpipe_load_model('portuguese-gsd-ud-2.5-191206.udpipe')
# Bring in data & organize
textData <- read.csv(datPth)
text     <- data.frame(doc_id = 1:nrow(textData), #GG: can parse a vector or a dataframe; in the latter case gotta have "doc_id" has first colname
                       text   = textData$text)

# Convert
#Encoding(text$text)
#iconvlist()
#stringi::stri_enc_detect(text$text) #GG: makes a guess on which language special characters come from.
text$text <- iconv(text$text, "latin1", "ISO-8859-1", sub="") #GG: enforces characters conversions based on portuguese encoding

# Apply the cleaning function, then get the plain text version
textCorp <- VCorpus(DataframeSource(text))
textCorp <- cleanCorpus(textCorp, c(stopwords('portuguese'),nonBasicStops))
text     <- pblapply(textCorp, content)


#text[[1]] #Uh oh! #GG: there are still some characters that were not recognized. so we brute force strip them out
text     <- pblapply(textCorp, bracketX) #GG: bracketX removes everything between brackets
#text[[1]] #better

# Re-organize to keep track of doc_id
text <- data.frame(doc_id = 1:nrow(textData), 
                   text   = unlist(text))

# Reduce for testing
nDocs            <- ifelse(testing ==T, 2, nrow(text))

syntatcicParsing <- udpipe(text[1:nDocs,], object = udModel) #GG: udpipe 0.8.6 creates a problem. v0.8.5 works. You can roll back via "remotes::install_version("udpipe", "0.8.5")"
saveRDS(syntatcicParsing, 'syntatcicParsing_allTweets.rds') #GG: saving a copy of the outputs
head(syntatcicParsing)
tail(syntatcicParsing)

# ID and replace any non-lemma terms
syntatcicParsing$cleanTxt <- ifelse(is.na(syntatcicParsing$lemma), 
                                    syntatcicParsing$token, 
                                    syntatcicParsing$lemma)

# Aggregate back to the document level
lemmaText        <- aggregate(syntatcicParsing$cleanTxt,
                              list(syntatcicParsing$doc_id), paste, collapse=" ")

names(lemmaText) <- c('doc_id', 'text')

lemmaText$doc_id <- as.numeric(as.character(lemmaText$doc_id))
lemmaText <- lemmaText[order(lemmaText$doc_id),]

#text[1,2]
#lemmaText[1,]
#text[5,2]
#lemmaText[5,]

# From here you can reapply DTM using the lemmatized text for improved aggregation, then apply the previous methods learned.
# You can also get dense data about the document, which _can possibly_ be useful for ML 
# Codes can be found here: https://universaldependencies.org/u/dep/

# Wide form
head(reshape2::dcast(syntatcicParsing, doc_id ~  xpos))

# Long Form 
syntatcicParsing %>% select(c(doc_id, xpos)) %>%
  group_by(doc_id, xpos) %>% tally()

# End
