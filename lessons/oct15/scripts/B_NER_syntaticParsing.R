#' Title: Named Entity Reco Syntactic Parsing
#' Purpose: Apply openNLPg
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Oct 13, 2021
#'

# WD
setwd("~/Documents/GitHub/LUX_NLP_student/lessons/oct15/data")

# Inputs
fileFolder <- '~/Documents/GitHub/LUX_NLP_student/lessons/oct15/data/clinton'
testing    <- F

# Libs
library(pbapply)
library(stringr)
library(tm)
library(qdap)
library(openNLP) #GG: has Named Entity Recognition (NER) but not often updated (although not orphan) and poor documentation
#install.packages("openNLPmodels.en", dependencies=TRUE, repos = "http://datacube.wu.ac.at/")
#if it times out download the tar.gz from the site and install locally by changing the path
#install.packages("/address/to/openNLPmodels.en_1.5-1.tar.gz", repos = NULL, type="source")
library(openNLPmodels.en)
##GG[VFI]: the reason you need to do Named Entity Recognition (NER) on the whole sentences instead of just bag of words is that, in order to do such recognition, you need the CONTEXT. And in bag of words, they are just individual words (or tokens like bigram) but out of context. The NER algorithm needs the context to understand what is what.
# Custom Functions needed bc of new class obj #GG: i.e. x <- as.String(x) 
txtClean <- function(x) {
  x <- x[-1] 
  x <- paste(x,collapse = " ")
  x <- str_replace_all(x, "[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+", "") #GG: Removes email addresses
  x <- str_replace_all(x, "Doc No.", "")
  x <- str_replace_all(x, "UNCLASSIFIED U.S. Department of State Case No.", "")
  x <- removeNumbers(x)
  x <- as.String(x)
  return(x)
}

# Get data & Organize
tmp           <- list.files(path = fileFolder, pattern = '.txt', full.names = T) #GG: pulls all names of .txt files in the folder
emails        <- pblapply(tmp, readLines) #GG: warnings are due to incomplete last lines; they are fine
names(emails) <- gsub('.txt', '', list.files(path = fileFolder, pattern = '.txt'))

# Examine 1
emails$C05758905

# Examine cleaning in action
txtClean(emails[[1]])[[1]] #GG: that's the thing we get, a single example

if(testing == T){
  emails <- emails[1:10]
}

# Apply cleaning to all emails; review one email in the list
allEmails <- pblapply(emails,txtClean)
allEmails[[2]][[1]][1]

# POS Tagging #GG: Now we start with the Named Entity Recognition (NER)
persons            <- Maxent_Entity_Annotator(kind='person')
locations          <- Maxent_Entity_Annotator(kind='location')
organizations      <- Maxent_Entity_Annotator(kind='organization')
sentTokenAnnotator <- Maxent_Sent_Token_Annotator(language='en')
wordTokenAnnotator <- Maxent_Word_Token_Annotator(language='en')
posTagAnnotator    <- Maxent_POS_Tag_Annotator(language='en')

# Annotate each document in  a loop
annotationsData <- list()
for (i in 1:length(allEmails)){
  print(paste('starting annotations on doc', i))
  annotations <- annotate(allEmails[[i]], list(sentTokenAnnotator, #GG: you need to detach ggplot2 because they share the function -annotate-
                                               wordTokenAnnotator, 
                                               posTagAnnotator, 
                                               persons, 
                                               locations, 
                                               organizations))
  annDF           <- as.data.frame(annotations)[,2:5]
  annDF$features  <- unlist(as.character(annDF$features))
  
  
  annotationsData[[tmp[i]]] <- annDF
  print(paste('finished annotations on doc', i))
}

# Examine
annotationsData[[1]][1:20,]

# Annotations have character indices 
# Now obtain terms by index from each document using a NESTED loop 
allData<- list()
for (i in 1:length(allEmails)){
  x <- allEmails[[i]]       # get an individual document
  y <- annotationsData[[i]] # get an individual doc's annotation information
  print(paste('starting document:',i, 'of', length(allEmails)))
  
  # for each row in the annotation information, extract the term by index
  POSls <- list()
  for(j in 1:nrow(y)){
    annoChars <- ((substr(x,y[j,2],y[j,3]))) #substring position
    
    # Organize information in data frame
    z <- data.frame(doc_id = i,
                    type     = y[j,1],
                    start    = y[j,2],
                    end      = y[j,3],
                    features = y[j,4],
                    text     = as.character(annoChars))
    POSls[[j]] <- z
  }
  
  # Bind each documents annotations & terms from loop into a single DF
  docPOS       <- do.call(rbind, POSls)
  
  # So each document will have an individual DF of terms, and annotations as a list element
  allData[[i]] <- docPOS
}

# Examine a portion
head(allData[[1]][10:20,])

# Now to subset for each document #GG: kinda creepy but super cool
people       <- pblapply(allData, subset, grepl("*person", features))
location     <- pblapply(allData, subset, grepl("*location", features))
organization <- pblapply(allData, subset, grepl("*organization", features))

### Or if you prefer to work with flat objects make it a data frame w/all info
POSdf <- do.call(rbind, allData)

# Subsetting example w/2 conditions; people found in email 1
subset(POSdf, POSdf$doc_id ==9 & grepl("*person", POSdf$features) == T)
subset(POSdf, POSdf$doc_id ==1 & grepl("*location", POSdf$features) == T)
subset(POSdf, POSdf$doc_id ==7 & grepl("*organization", POSdf$features) == T)


# Example: apply a quick polarity by person
peeps <- subset(POSdf, grepl("*person", POSdf$features) == T )
peepTally <- as.data.frame(table(peeps$text))
peepTally <- peepTally[order(peepTally$Freq, decreasing = T),]
head(peepTally, 50)

# Let's select some interesting people
keeps <- c('^Bill Clinton$', '^Tom Donilon$','^Obama$','^Tony Blair$')
keepsIDX <- grep(paste0(keeps, collapse = '|'), peeps$text)
docIDX <- peeps$doc_id[keepsIDX]
emailVec <- do.call(rbind, allEmails)
emailVec <- emailVec[docIDX]
emailDF <- data.frame( doc_id = peeps$doc_id[keepsIDX], 
                       text = emailVec,
                       person = make.names(peeps$text[keepsIDX]))
polarity(emailDF$text, grouping.var = emailDF$person)

# End
