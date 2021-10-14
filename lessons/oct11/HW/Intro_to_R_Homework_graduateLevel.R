#' Author: Ted Kwartler
#' Data: 9-2-2020
#' Student:
#' Assignment: EDA, Functions, visuals & mapping
#' Instructions: Complete the scaffolded code for Canvas.
 
## Set the working directory (HINT: it should be your HW folder)
setwd("~/Documents/GitHub/LUX_NLP_student/lessons/oct11/HW")

## Load the libraries, maps ggplot2, ggthemes
library(maps)
library(ggplot2)
library(ggthemes)

## Exercises
# 1. Read in diamonds.csv data and call it 'df'
df <- read.csv("diamonds.csv") 

# 2. Examine the first 10 rows of data
df[1:10,]
head(df, n = 10L)

# 3. What is the first value for the 'color' column when looking at head()? 
df$color[1]
# Answer: "E"

# 4. Create a new data frame called 'diamonds' by sorting the 'df' object by price and decreasing is FALSE
diamonds <- df[sort(df$price, decreasing=F]

diamonds <- sort(df$price, decreasing=F)

topPerformers <- sort(charTally[,1], decreasing = T)[1:n]

# 5. Examine the last 6 rows of the 'diamonds' data frame.  What is the most expensive diamond in the set?

# Answer: 

# 6. Copy and paste the results of the 'summary()' stats for the 'caret' attribute below.  


# Introducing additional functions to try out:
?max
?min
?range

# 7. What is the maximum value for the "depth" attribute?
# Answer:

# 8. What is the minimum value for the "table" attribute?
# Answer: 

# 9. What is the range of values for the "price" column?
# Answer:

# 10. Find the 347th diamond in the data set using row indexing.  Copy paste the single row below.


# 11. Create a barplot of the diamonds' $cut column.  Using jpeg() as the function create a file "barplot.jpg" then create the bar plot so it is saved to disk.




# 12. Create a ggplot scatterplot of points with the following aesthetics:
# color = clarity
# x axis = carat
# y axis = price
# point size size = 0.25
# theme = theme_economist_white()
# legend = none




# 13. Examine the price distribution by creating a ggplot geom_histogram() instead of a scatter plot layer.  Use the code scaffold below with the following parameters:
# data = diamonds
# type = geom_histogram
# x = price (we are only examining a single attribute here)
# bin width = 100

____(data= _____) + ________(aes(x=____), binwidth=___)


#14. What is the class() of the carat vector?  HINT: apply class() as a function to the carat column using $ or index number


#15. What is the class of the color vector?


######### OMIT for Oct 12, did not cover in class ######

#16. Read in the WesternCellTowers.csv cell towers as westTowers
westTowers <- read.csv(____)

#17. Using map() create a state map of 'oregon', 'utah', 'nevada', 'california' & add points() with westtowers$lon,westtowers$lat, col='blue'


#18. Load the county map data called counties (HINT: with map_data)
counties <- ____('____')

#19. Load the state data called state 
allStates <- _____('____')

#20. Subset counties and allStates into the objects below; add the last states, california & nevada to the search index
westernCounties <- ____[____$____ %in% c("oregon","utah", "_____", "_____"),]
westernStates   <- ____[____$____ %in% c("oregon","utah", "_____", "_____") ,]


#21. Create a ggplot map of the cell phone towers in the 4 western states.  Refer to the lesson's example code.



# End
