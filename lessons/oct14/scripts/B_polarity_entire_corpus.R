#' Title: Polarity on a corpus
#' Purpose: Learn and calculate polarity 
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Oct 12, 2021
#'

# Wd
setwd("~/Documents/GitHub/LUX_NLP_student/lessons/oct14/data")

# Libs
library(tm)
library(qdap)

# Data I
text <- readLines('pharrell_williams_happy.txt')

# Polarity on the document
polarity(text)

# Does it Matter if we process it?
source('~/Documents/GitHub/LUX_NLP_student/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

txt <- VCorpus(VectorSource(text))
txt <- cleanCorpus(txt, stopwords("SMART"))
polarity(content(txt[[1]])) #GG: after removing stopwords polarity increases

# Examine the polarity obj more
pol <- polarity(content(txt[[1]]))

# Word count detail
pol$all$wc

# Polarity Detail
pol$all$polarity

# Pos Words ID'ed
pol$all$pos.words

# Neg Words ID'ed
pol$all$neg.words

# What are the doc words after polarity processing?
cat(pol$all$text.var[[1]])

# Document View
pol$group

# End
