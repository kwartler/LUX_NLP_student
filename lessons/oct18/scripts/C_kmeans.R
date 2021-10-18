#' Title: K Means
#' Purpose: apply k means clustering to text
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Oct 17, 2021

# Wd
setwd("~/Documents/GitHub/LUX_NLP_student/lessons/oct18/data")

# Libs
library(tm)
library(clue)
library(cluster)
library(fst)
library(wordcloud) #used to make word clouds out of clusters

# Bring in our supporting functions
source('~/Documents/GitHub/LUX_NLP_student/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

# Options & Functions
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL','C')

# Stopwords
stops  <- c(stopwords('SMART'), 'work')

# Read & Preprocess
txtMat <- cleanMatrix(pth = 'basicResumes.csv', 
                      columnName  = 'text', # text column name
                      collapse = F, 
                      customStopwords = stops, 
                      type = 'DTM', 
                      wgt = 'weightTfIdf') #weightTf or weightTfIdf

txtMat    <- scale(txtMat) #subtract mean  & divide by stDev
txtKMeans <- kmeans(txtMat, 3) #GG: imposing K=3
txtKMeans$size
barplot(txtKMeans$size, main = 'k-means') #GG: not so good

# https://en.wikipedia.org/wiki/Silhouette_(clustering)
# consistency of clusters, -1 to 1, high values indicate the correct number of clusters and separation
dissimilarityMat <- dist(txtMat)
silPlot          <- silhouette(txtKMeans$cluster, dissimilarityMat)
plot(silPlot, col=1:max(txtKMeans$cluster), border=NA)
#GG: either not enough data or number of clusters wrong. Negative values indicate a cluster is nested within another

#calculate indices of closest document to each centroid
idx <- vector()
for (i in 1:max(txtKMeans$cluster)){
  
  # Calculate the absolute distance between doc & cluster center
  absDist <- abs(txtMat[which(txtKMeans$cluster==i),] -  txtKMeans$centers[i,])
  
  # Check for single doc clusters
  if(is.null(nrow(absDist))==F){
    absDist <- rowSums(absDist)
    minDist <- subset(absDist, absDist==min(absDist))
  } else {
    minDist <- txtKMeans$cluster[txtKMeans$cluster==i]
  }
  idx[i] <- as.numeric(names(minDist))
}

# Notification of closest doc to centroid
cat(paste('cluster',1:max(txtKMeans$cluster),': centroid doc is ', idx,'\n'))

# End
