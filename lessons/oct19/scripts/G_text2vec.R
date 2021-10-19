#' Title: text2vec example
#' Purpose: Perform text2vec to find abstractive relationships
#' Author: Ted Kwartler
#' email: edward.kwartler@hult.edu
#' License: GPL>=3
#' Date: Oct 18, 2021
#'
#'

# WD
setwd("~/Desktop/LUX_NLP_student/lessons/oct19/data")

# Libs
library(data.table)
library(tm)
library(pbapply)
library(text2vec)

# Code Testing
testing <- F

# Bring in our supporting functions
source('~/Desktop/LUX_NLP_student/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')
airbnb <- readr::read_csv('Airbnb-boston_only.zip')
names(airbnb)

# Make appropriate for tm
airbnbTxt <- data.table(doc_id = airbnb$listing_id, 
                        text = airbnb$comments,
                        reviewScores = airbnb$review_scores_rating)
rm(airbnb)
gc()

# Apply standard cleaning
#txt <- VCorpus(DataframeSource(airbnbTxt))
#txt <- cleanCorpus(txt, c(stopwords('en'), 'boston'))
#saveRDS(txt,'txt.rds')
txt <- readRDS('txt.rds')

# Get the cleaned text out
txtTokens <- unlist(pblapply(txt, content))

# Create the vocabulary iterator (string splitting)
if(testing == T){
  n <- 10
} else {
  n <- length(txtTokens)
}
iter <- itoken(txtTokens[1:n],
            tokenizer = word_tokenizer, n_chunks = 10)
nGramVocab <- create_vocabulary(iter, c(1, 3) )

# Examine
head(nGramVocab, 8)

# Heuristic prune
nGramVocab <- prune_vocabulary(nGramVocab, term_count_min = 5)

# Create the custom function 
tokenVecs <- vocab_vectorizer(nGramVocab)

# Create a DTM if needed
tmDTM <-  create_dtm(iter, tokenVecs, type = 'dgTMatrix')
class(tmDTM)
tmDTM <- as.DocumentTermMatrix(tmDTM, weighting = 'weightTf')
tmDTM
rm(tmDTM)

# PPTX review skip gram method
# Create the term-cooccurence matrix; "TCM matrix usually used with GloVe word embedding model."
tcm <- create_tcm(iter, # tokenized & normalized stings
                  tokenVecs, # function: n-gram & specific word vec construction
                  skip_grams_window = 5, # token's context is defined by 5 words before and after
                  skip_grams_window_context = "symmetric")
# Square since all retained tokens are shared between 1+ docs
# Each element the matrix represents how often word i appears in context of word j.
dim(tcm)

# Build the GloVe model
# instantiate the object
fitGlove <- GlobalVectors$new(rank = 50,  # how many vectors to represent
                              x_max = 10) # max number of cooccurences; focus on 10 most frequent co-occurences

# Fit the model; pg 176 in the book
contextGlove <- fitGlove$fit_transform(tcm, 
                                   n_iter = 10, 
                                   convergence_tol = 0.01, 
                                   n_threads = 8)

# According to the package author there are two vectors
gloveContext <-  fitGlove$components
dim(gloveContext)

# From package
# While both of word-vectors matrices can be used as result it usually better (idea from GloVe paper) to average or take a sum of main and context vector
wordVectors <- contextGlove + t(gloveContext)
head(wordVectors)

# Find the closest word vectors for good walks in boston airbnb stays 
goodWalks <- wordVectors["walk", , drop = FALSE] - 
  wordVectors["disappointed", , drop = FALSE] + 
  wordVectors["good", , drop = FALSE]
goodWalks

cosSimilarity <- sim2(x = wordVectors, 
                      y = goodWalks, 
                      method = "cosine")
cosSimilarity <- data.frame(term = rownames(cosSimilarity),
                            coSineSim = cosSimilarity[,1], 
                            row.names = NULL)

# get only the top 20 contextualized terms 
cosSimilarity <- cosSimilarity[order(cosSimilarity$coSineSim, decreasing = T),]
head(cosSimilarity, 20)

# Find the closest word vectors for dirty sinks in boston airbnb stays 
dirtyStay <- wordVectors["dirty", , drop = FALSE] - 
  wordVectors["condition", , drop = FALSE] -
  wordVectors["clean", , drop = FALSE] 
dirtyStay

cosSimilarity <- sim2(x = wordVectors, 
                      y = dirtyStay, 
                      method = "cosine")
cosSimilarity <- data.frame(term = rownames(cosSimilarity),
                            coSineSim = cosSimilarity[,1], 
                            row.names = NULL)

# get only the top 20 contextualized terms 
cosSimilarity <- cosSimilarity[order(cosSimilarity$coSineSim, decreasing = T),]
head(cosSimilarity, 20)

# End