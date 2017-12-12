Extract-and-Clean
================
Tommy Tang
November 6, 2017

Extract and Clean
-----------------

This file describes how I downloaded and prepared data for analysis.

Recall that the five datasets come from the Locus Awards, the Campbell Awards, the Hugo Awards, the Nebula Awards, and Goodreads data.

Wiki Data
---------

Here we handle the tables of nominations downloaded from Wikipedia - the Locus and Goodreads data are handled in the following sections, since both require a different set of scraping and cleaning scripts. After downloading and storing the data from Wikipedia (see here), the data still needed to be edited and wrangled into proper format for our data.

First, we load our data:

`r   Campbell <- read.csv(url("https://raw.githubusercontent.com/tommymtang/Predicting-the-Hugo-Awards/master/Dataset/Campbell.csv"))   Nebula <- read.csv(url("https://raw.githubusercontent.com/tommymtang/Predicting-the-Hugo-Awards/master/Dataset/Nebula%20nominees.csv"))   Hugo <- read.csv(url("https://raw.githubusercontent.com/tommymtang/Predicting-the-Hugo-Awards/master/Dataset/Hugo%20nominees.csv"))` These three are tabulated very similarly. Let's take a look:

``` r
head(Nebula)
```

    ##   Year          Author.s.
    ## 1 1966     Frank Herbert*
    ## 2   NA  Clifford D. Simak
    ## 3   NA Theodore L. Thomas
    ## 4   NA       Kate Wilhelm
    ## 5   NA     Philip K. Dick
    ## 6   NA        James White
    ##                                                Title    Publisher.s.
    ## 1                                               Dune Chilton Company
    ## 2                                 All Flesh is Grass       Doubleday
    ## 3                                          The Clone   Berkley Books
    ## 4                                                                   
    ## 5 Dr. Bloodmoney, or How We Got Along After the Bomb       Ace Books
    ## 6                                   The Escape Orbit       Ace Books

There are two main issues with these data. The first is that not every title has a year. The second is that for ease of use, we would like an additional column indicating whether the title had won the award in question. (Currently, the winner is indicated with an asterisk next to the winning author's name.)

We do this with the fillYear.R and fillWinners.R scripts from prep-Data.R.

``` r
Nebula$Year <- fillYear(Nebula$Year)
Nebula$Winners <- winners(Nebula)

Campbell$Year <- fillYear(Campbell$Year)
Campbell$Winners <- winners(Campbell)

Hugo$Year <- fillYear(Hugo$Year)
Hugo$Winners <- winners(Hugo)
```

Now our data looks like

``` r
head(Nebula)
```

    ##   Year          Author.s.
    ## 1 1966     Frank Herbert*
    ## 2 1966  Clifford D. Simak
    ## 3 1966 Theodore L. Thomas
    ## 4 1966       Kate Wilhelm
    ## 5 1966     Philip K. Dick
    ## 6 1966        James White
    ##                                                Title    Publisher.s.
    ## 1                                               Dune Chilton Company
    ## 2                                 All Flesh is Grass       Doubleday
    ## 3                                          The Clone   Berkley Books
    ## 4                                                                   
    ## 5 Dr. Bloodmoney, or How We Got Along After the Bomb       Ace Books
    ## 6                                   The Escape Orbit       Ace Books
    ##   Winners
    ## 1    TRUE
    ## 2   FALSE
    ## 3   FALSE
    ## 4   FALSE
    ## 5   FALSE
    ## 6   FALSE

Locus Data
----------

The Locus Awards were a bit different. For one, the full lists of nominees and winners were not on Wikipedia, and so I had to extract them year by year from this website.

Now, as you can see, the formatting is a bit different:

`r   head(Locus)`

`##                                       Title..Author..Publisher. Year   ## 1                    Death's End, Cixin Liu (Tor; Head of Zeus) 2016   ## 2 The Underground Railroad, Colson Whitehead (Doubleday; Fleet) 2016   ## 3                    Babylon's Ashes, James S. A. Corey (Orbit) 2016   ## 4                       Central Station, Lavie Tidhar (Tachyon) 2016   ## 5                            Company Town, Madeline Ashby (Tor) 2016   ## 6                                  Visitor, C. J. Cherryh (DAW) 2016   ##          Category Winner   ## 1 Science Fiction   TRUE   ## 2 Science Fiction     NA   ## 3 Science Fiction     NA   ## 4 Science Fiction     NA   ## 5 Science Fiction     NA   ## 6 Science Fiction     NA`

The prep-Data.R scripts contain the specific functions I used and a more in-depth description of the wrangling I performed for the Locus Data sets. Now done with the awards, let us add data to our Hugo awards, using prep-Data.R

``` r
Hugo$Locus.data <- sapply(Hugo$Title, searchTitle, Award = Locus)
Hugo$Nebula.data <- sapply(Hugo$Title, searchTitle, Award = Nebula)
Hugo$Campbell.data <- sapply(Hugo$Title, searchTitle, Award = Campbell)
```

Our Hugo dataset now looks like this:

`r   head(Hugo)`

`##   Year              Author   ## 1 1966      Frank Herbert*   ## 2 1966      Roger Zelazny*   ## 3 1966        John Brunner   ## 4 1966  Robert A. Heinlein   ## 5 1966     Edward E. Smith   ## 6 1967 Robert A. Heinlein*   ##                                                 Title   ## 1                                                Dune   ## 2 ...And Call Me Conrad (also known as This Immortal)   ## 3                             The Squares of the City   ## 4                The Moon Is a Harsh Mistress[Note 2]   ## 5                                    Skylark DuQuesne   ## 6                The Moon Is a Harsh Mistress[Note 2]   ##                                Publisher.s. Winners Locus.data Nebula.data   ## 1                           Chilton Company    TRUE          0           2   ## 2 The Magazine of Fantasy & Science Fiction    TRUE          0           0   ## 3                          Ballantine Books   FALSE          0           0   ## 4                                        If   FALSE          0           0   ## 5                                        If   FALSE          0           0   ## 6                                        If    TRUE          0           0   ##   Campbell.data   ## 1             0   ## 2             0   ## 3             0   ## 4             0   ## 5             0   ## 6             0` A bit clunky, but don't worry, we'll get rid of the earlier years anyways.

Goodreads Data
--------------

Here we describe briefly what we do to obtain the Goodreads ratings data using the Goodreads API. Specific functions and scripts can be found in prep-Data.R script.

The script explains this in greater detail, but here I will outline the method and the main difficulties. I'm going to load my key and secret from a local configuration file, though you will want to put your own.

The main workhorse is the function that searches Goodreads using a title and author (if given). The function cycles through every book on the Hugo nominations list and attaches the correct information for number of ratings and average rating.

There are two main searching challenges.

The first occurs when we search a very popular title using both title and author. For example, if one searches for Ursula Le Guin's "Left Hand of Darkness" with the query: "Ursula K. Le Guin, Left Hand of Darkness", the first result that pops up is in fact Harold Bloom's criticism book: "Ursula K. Le Guin's Left Hand of Darkness".

Now, we can correct for this by searching for just title, storing the result, and picking the one with more hits.

Unfortunately just searching the title and using volume of hits is precarious. For example, if one searches for Poul Anderson's "Fire Time", the most popular search is in fact James Baldwin's masterpiece: "The Fire Next Time."

We can engineer more sophisticated methods: What about when we take top the relevant results for title and author searching, and we take the one with the most number of ratings?, etc.

This is what I chose, using the function searchRating from the prep-Data.R script. For example, if I run it on Ursula Le Guin's Left Hand of Darkness.

``` r
myTitle <- "Left Hand of Darkness"
myAuthor <- "Ursula K. Le Guin"
searchRating(myTitle, myAuthor)
```

    ## [1] 75311.00     4.05

So we run this through the entries in our current data frame for Hugo - here we make a pit stop for weird titles in the document - , and collect the results.

``` r
ratings <- runGoodreadsRatings(272)
Hugo$Goodreads.Number.of.Ratings <- unlist(ratings$numRatings)
Hugo$Goodreads.Avg.Rating <- unlist(ratings$avgRating)
str(Hugo)
```

    ## 'data.frame':    272 obs. of  10 variables:
    ##  $ Year                       : int  1966 1966 1966 1966 1966 1967 1967 1967 1967 1967 ...
    ##  $ Author                     : Factor w/ 145 levels "Ada Palmer","Alexei Panshin",..: 41 127 67 118 37 119 129 117 31 56 ...
    ##  $ Title                      : Factor w/ 266 levels "","...And Call Me Conrad (also known as This Immortal)",..: 69 2 227 212 167 212 24 253 82 240 ...
    ##  $ Publisher.s.               : Factor w/ 69 levels "","Ace Books",..: 21 59 12 41 41 41 2 5 33 21 ...
    ##  $ Winners                    : logi  TRUE TRUE FALSE FALSE FALSE TRUE ...
    ##  $ Locus.data                 : num  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ Nebula.data                : num  2 0 0 0 0 0 2 0 2 0 ...
    ##  $ Campbell.data              : num  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ Goodreads.Number.of.Ratings: num  540760 8362 481 NA NA ...
    ##  $ Goodreads.Avg.Rating       : num  4.2 3.94 3.39 NA NA NA 3.78 4.09 4.07 4.17 ...

Let's clean the author names with removeWinnerAsterisk.

This we write to csv as "HugosCompletePrepolished.csv". We say prepolished because there are a few errors:

``` r
sum(is.na(unlist(ratings$numRatings)))
```

    ## [1] 10

Luckily, this is not too big, and we are guaranteed that unlike the other methods, this manner of searchRating will result in either a correct search or a missing value. (The other methods may give hard-to-detect incorrect answers.)

Thus we fill in by hand the missing values and save that as "HugosComplete.csv"
