# Auxiliary functions to help clean up the data. For some of these, the Locus Awards
# required their own customized functions to deal with their shit ass organization.

fillYear <- function(yearVec) {
  for (i in 1:length(yearVec)) {
    if (is.na(yearVec[i])) {
      yearVec[i] <- yearVec[i-1]
    }
  }
  yearVec
}
  
# Creates winners vector (DOES NOT WORK FOR LOCUS)
winners <- function(Award) {
  winner <- grepl("[*]", Award$Author)
}

# Locus-specific helper functions
getLocusTitle <- function(bookInfo) {
  
  infoVec <- unlist(strsplit(bookInfo, ","))
  infoVec[1]
  
}

getLocusAuthor <- function(bookInfo) {
  infoVec <- unlist(strsplit(bookInfo, ","))
  infoVec <- infoVec[2] # get part that exclude title
  unlist(strsplit(infoVec, "[()]"))[1]
}

getLocusPublisher <- function(bookInfo) {
  infoVec <- unlist(strsplit(bookInfo, ","))
  infoVec <- infoVec[2] # get part that exclude title
  unlist(strsplit(infoVec, "[()]"))[2]
}

#

# After basic cleaning and prep of all awards data, these auxiliary functions help attach 
# data from other awards and APIs to Hugo data.

searchTitle <- function(book, Award) { 
  splitTitle <- (unlist(strsplit(as.character(book), " [()]"))) 
  nommed <- splitTitle %in% Award$Title
  if (sum(nommed) == 0) {
    return(0)
  }
  else {
    id <- min(which(nommed))
    if (Award$Winner[which(Award$Title == splitTitle[id])] == TRUE) {
      return(2)
    }
    return(1)
    
  }
}

# Functions to use in conjunction with Goodreads API
key <- "GlnAEoDgbhhbNhf7C1fw"

# Given title and author, returns a vector consisting of the total number of ratings
# and the average rating score.
# Note that this is a search and therefore simply outputs "most relevant result" as
# as determined by Goodreads. 
library(XML)
library(xml2)
srURL <- "https://www.goodreads.com/search/index.xml"

searchRatings <- function(title, author) {
  if (is.na(author)) {
    result <- GET(srURL, query = list(q = title, key = key))
  }
  else {
    result <- GET(srURL, query = list(q = paste(title, author, sep = ", "), key = key))
  }
  response <- xmlTreeParse(rawToChar(result$content))
  resp <- content(result, as = "parsed")
  work <- xml_find_all(resp, ".//work")
  counts <- xml_find_all(work[1], ".//ratings_count")
  count <- as.numeric(xml_text(counts))
  avg <- as.numeric(xml_text(xml_find_all(work[1], ".//average_rating")))
  
  return (c(count, avg))
}

searchRating <- function(title, author) {
  if (is.na(author)) {
    result <- GET(srURL, query = list(q = title, key = key))
  }
  else {
    result <- GET(srURL, query = list(q = paste(title, author, sep = ", "), key = key))
  }
  response <- xmlTreeParse(rawToChar(result$content))
  resp <- content(result, as = "parsed")
  work <- xml_find_all(resp, ".//work")
  counts <- as.numeric(xml_text(xml_find_all(work, ".//ratings_count")))
  id <- which.max(counts)
  avg <- as.numeric(xml_text(xml_find_all(work[id], ".//average_rating")))
  count <- counts[id]
  
  return (c(count, avg))
}

# Assumes key and url have already been set. Input ISBN and outputs a vector of
# total number of ratings and average rating 

callURL <- "https://www.goodreads.com/book/review_counts.json"
getRatings <- function(isbn) {
  result <- GET(callURL, query = list(key = key, isbns = isbn, format = "JSON"))
  data <- fromJSON(rawToChar(result$content))
  avg <- data$books$average_rating
  return (as.numeric(c(count, avg)))
}


# Automatically add on reviews data fetched from API
library(httr)
library(jsonlite)
library(XML)

key <- "Your key here"
secret <- "Your secret here"

# NOW FETCH DATA.
numRatings = list()
avgRating = list()
runSearch <- function(n) {for (i in 1:n) {
  title <- Hugo$Title[i]
  author <- Hugo$Author[i]
  split <- unlist(strsplit(as.character(title), "[()]"))
  if (length(split) > 1) {
    title <- split[1]
    titleAlt <- split[2] # MODIFY THIS to be clean!!!!!
    # Cleaning titleAlt
    titleAlt <- unlist(strsplit((unlist(strsplit(titleAlt, "also known as ")))[2],"[()]"))[1]
    
    rateAll <- searchRatings(title, author)
    rateTitle <- searchRatings(title, author = NA)
    rateAllAlt <- searchRatings(titleAlt, author)
    rateTitleAlt <- searchRatings(titleAlt, author = NA)
    rateData <- c(rateAll, rateTitle, rateAllAlt, rateTitleAlt)
    id <- which.max(rateData)
    trueNum <- rateData[id]
    trueAvg <- rateData[id + 1]
  }
  else {
    rateAll <- searchRatings(title, author)
    rateTitle <- searchRatings(title, author = NA)
    rateData <- c(rateAll, rateTitle)
    id <- which.max(rateData)
    trueNum <- rateData[id]
    trueAvg <- rateData[id + 1]
  }
  
  numRatings <- c(numRatings, trueNum)
  avgRating = c(avgRating, trueAvg)
}
}

runGoodreadsRatings <- function(n) {
  numRatings = list()
  avgRating = list()
  for (i in 1:n) {
    title <- Hugo$Title[i]
    author <- Hugo$Author[i]
    split <- unlist(strsplit(as.character(title), "[()]"))
    if (length(split) > 1) {
      title <- split[1]
      titleAlt <- split[2] # MODIFY THIS to be clean!!!!!
      # Cleaning titleAlt
      titleAlt <- unlist(strsplit((unlist(strsplit(titleAlt, "also known as ")))[2],"[()]"))[1]
      rating <- searchRating(title, author)
      ratingAlt <- searchRating(titleAlt, author)
      if (rating[1] > ratingAlt[1] || is.na(ratingAlt[1])) {
        trueNum <- rating[1]
        trueAvg <- rating[2]
      }
      else {
        trueNum <- ratingAlt[1]
        trueAvg <- ratingAlt[2]
      }
    }
    else {
      rating <- searchRating(title, author)
      trueNum <- rating[1]
      trueAvg <- rating[2]
    }
    numRatings <- c(numRatings, trueNum)
    avgRating = c(avgRating, trueAvg)
  }
  ratingDF <- cbind(numRatings, avgRating)
  return (as.data.frame(ratingDF))
}

# The winning author was usually denoted with an asterisk. This function removes it so that
# the data looks better.
removeWinnerAsterisk <- function(author) {
  return (unlist(strsplit(as.character(author), "[*]")))
  
}

#Hugo$Goodreads.Avg.Rating <- unlist(avgRating)
#Hugo$Goodreads.Number.of.Ratings <- unlist(numRatings)