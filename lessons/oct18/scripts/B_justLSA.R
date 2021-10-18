#' Title: Latent Semantic Analysis
#' Purpose: apply lsa to reduce dimensionality
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Oct 17, 2021
#' Another good option

# Set the working directory
setwd("~/Desktop/LUX_NLP_student/lessons/oct18/data")

# Libs
library(tm)
library(lsa)

# Bring in our supporting functions
source('~/Desktop/LUX_NLP_student/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

# Options & Functions
options(stringsAsFactors = FALSE, scipen = 999)
Sys.setlocale('LC_ALL','C')

# Create custom stop words
stops <- c(stopwords('SMART'), 'car', 'electronic')

# Bring in some data
carCorp <- VCorpus(DirSource("~/Desktop/LUX_NLP_student/lessons/oct18/data/AutoAndElectronics/rec.autos"))
electronicCorp <- VCorpus(DirSource("~/Desktop/LUX_NLP_student/lessons/oct18/data/AutoAndElectronics/sci.electronics"))

# Clean each one
carCorp        <- cleanCorpus(carCorp, stops)
electronicCorp <- cleanCorpus(electronicCorp, stops)

# Combine
allPosts <-  c(carCorp,electronicCorp)
rm(carCorp)
rm(electronicCorp)
gc()

# Construct the Target
yTarget <- c(rep(1,1000), rep(0,1000)) #1= about cars, 0 = electronics

# Make TDM; lsa docs save DTM w/"documents in colums, terms in rows and occurrence frequencies in the cells."!
allTDM <- TermDocumentMatrix(allPosts, 
                             control = list(weighting = weightTfIdf))
allTDM

# Get 20 latent topics
##### Takes awhile, may crash small computers, so saved a copy
#lsaTDM <- lsa(allTDM, 20)
#saveRDS(lsaTDM, 'lsaTDM_tfidf.rds')
lsaTDM <- readRDS('~/Desktop/LUX_NLP_student/lessons/oct18/data/AutoAndElectronics/lsaTDM_tfidf.rds')
head(lsaTDM$dk)

# End