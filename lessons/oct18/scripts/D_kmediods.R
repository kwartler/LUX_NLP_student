#' Title: K Mediods
#' Purpose: apply k Mediod clustering to text
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Oct 21, 2021
#' https://cran.r-project.org/web/packages/kmed/vignettes/kmedoid.html
#' Additional Resume data sets from kaggle.com
#' 220_resumes.csv 
#' 15k_resumes.csv

# Wd
setwd("~/Documents/GitHub/LUX_NLP_student/lessons/oct18/data")

# Libs
library(kmed)
library(tm)
library(clue)
library(cluster)
library(wordcloud) #used to make word clouds out of clusters

# Bring in our supporting functions
source('~/Documents/GitHub/LUX_NLP_student/lessons/Z_otherScripts/ZZZ_supportingFunctions.R')

# Options & Functions
options(stringsAsFactors = FALSE)
Sys.setlocale('LC_ALL','C')

# Stopwords
stops <- c(stopwords('SMART'), 'work')

# Read & Preprocess
txtMat <- cleanMatrix(pth = 'basicResumes.csv', 
                      columnName  = 'text', # clue answer text 
                      collapse = F, 
                      customStopwords = stops, 
                      type = 'DTM', 
                      wgt = 'weightTfIdf') #weightTf or weightTfIdf

# Remove empty docs w/TF-Idf
txtMat <- subset(txtMat, rowSums(txtMat) > 0)

# Use a manhattan distance matrix; default for kmed
manhattanDist <- distNumeric(txtMat, txtMat, method = "mrw") 

# Calculate the k-mediod
txtKMeds <- fastkmed(manhattanDist, ncluster = 5, iterate = 5)

# Number of docs per cluster
table(txtKMeds$cluster)
barplot(table(txtKMeds$cluster), main = 'k-mediod')

# Silhouette
# https://en.wikipedia.org/wiki/Silhouette_(clustering)
# consistency of clusters, -1 to 1, high values indicate the correct number of clusters and separation
silPlot          <- silhouette(txtKMeds$cluster, manhattanDist)
plot(silPlot, col=1:max(txtKMeds$cluster), border=NA)

# Median centroid documents:
txtKMeds$medoid

# End