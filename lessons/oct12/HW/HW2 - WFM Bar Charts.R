#' Title: Homework II
#' Purpose: Obtain Data, save it, perform word frequency, then compare shared word frequencies
#' Author: Ted Kwartler
#' email: edwardkwartler@fas.harvard.edu
#' License: GPL>=3
#' Date: Oct 10, 2021
#'

# libraries; you will need to load more for the assignment
library(rtweet)

# Obtain Data -- A
# You may use the twitter API as shown below, with a search term you are interested in.
# Or you may use your own data source from research. 
# So HW can be graded you will have to save and share the original data source.
# Please don't use the unicorns data, it is an example.
unicorns <- search_tweets(q = 'unicorns', n = 1000)

# Obtain Data -- B


# Save original data to turn in with HW.
saveRDS(unicorns, 'unicorns.rds')


# Perform all text preprocessing steps with custom functions & stopwords

# For Data --A 
# Create a single word frequency matrix
# Order the WFM decreasing = T
# Review the top 25
# Build a single bar plot with only Data --A using flipped coordinates and add an appropriate title.

# For Data --B 
# Be sure to paste/collapse both A and B
# Merge the data set
# Pivot the two data sets
# Obtain the top 35 terms from both
# Create a stacked bar chart with appropriate title
# Create a proportional bar chart with appropriate title

# End

# End