# Library, and setting the seed
library(randomForest)
set.seed(100)

#attach probabilities[,2] vector to test before using predictWinners

predictWinners <- function(data) { # data assumed to be from roughImplementation
  year <- data$Year[1]
  winners <- logical()
  yearDat <- numeric()
  for (i in 1:dim(data)[1]) {
    if (i == (dim(data)[1])) {
      
      yearDat <- c(yearDat, data$probabilities[i])
      maxProb <- max(yearDat)
      yearWinners <- (yearDat == maxProb)
      winners <- c(winners, yearWinners)
    }
    else if (data$Year[i] == year) {
      yearDat <- c(yearDat, data$probabilities[i])
    }
    
    else {
      maxProb <- max(yearDat)
      yearWinners <- (yearDat == maxProb) 
      winners <- c(winners, yearWinners)
      
      # Now clear the data
      year = year + 1 
      yearDat <- numeric() 
      yearDat <- c(yearDat, data$probabilities[i])
    }
  }
  return(winners)
  
}


# NOTES: These functions used for feature engineering.
# FEATURE ENGINEER:
# Data on "number of nominations". Also better way to group data. See oscars info.

# this function takes in an author, the year, and the dataset (defaulting to Hugo) and gives 
# the number of award nominations the author has had since their most recent award win BEFORE the
# current year. Therefore, it counts the current year's nomination (if any) as a nomination, 
# but will not output 0 if the author also won that same year.

hugosURL <- "https://raw.githubusercontent.com/tommymtang/Predicting-the-Hugo-Awards/master/Dataset/HugosPolished.csv"
nomsWithoutWin <- function(author, year, data = read.csv(url(hugosURL))) {
  id <- which(data$Year == year)[length(which(data$Year == year))]
  found <- FALSE
  count <- 0
  authors <- removeWinnerAsterisk(data$Author) # assumes a winner column
  while (!found && (id > 0)) { # halt once id finished scrolling or author has won
    if (authors[id] == author) {
      if (data$Winner[id]) {
        found = TRUE
        if (data$Year[id] == year) {
          count = count + 1
        }
      }
      else {
        count = count + 1
      }
    }
    id <- id - 1 
    
  }
  return (count)
}

getNoms <- function(data) {
  
  return (mapply(nomsWithoutWin, data$Author, data$Year, MoreArgs = list(data = data)))
}

removeWinnerAsterisk <- function(author) {
  return (unlist(strsplit(as.character(author), "[*]")))
}
