
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/emillykkejensen/metaR.svg?branch=master)](https://travis-ci.org/emillykkejensen/metaR)

metaR
=====

The goal of metaR is to provide functions for extracting meta-information from various R elements.

Installation
------------

You can install metaR from github with:

``` r
# install.packages("devtools")
devtools::install_github("emillykkejensen/metaR")
```

Get meta data on tables
-----------------------

The only function of metaR curretly is to get meta data on tables such as Data Frames, Data Tables, Tibbels etc.

To do this, simply run the get\_metadata() function.

``` r

library(metaR)
#> Loading required package: data.table
#> Loading required package: magrittr

df <-
  data.frame(
    letters = letters,
    num = 1:26,
    letters2 = c(rep("a", 4),rep(NA_character_, 6), rep("b", 10), rep(NA_character_, 6)),
    date = as.POSIXct("2010-01-01"))

df_meta <- get_metadata(df)

print(df_meta)
#>       name colNo           class empty_count empty_pct uniqueValues_count
#> 1  letters     1          factor           0      0.00                 26
#> 2      num     2         integer           0      0.00                 26
#> 3 letters2     3          factor          12     46.15                  3
#> 4     date     4 POSIXct, POSIXt           0      0.00                  1
#>   uniqueValues_pct dataExample
#> 1           100.00           m
#> 2           100.00           1
#> 3            11.54           b
#> 4             3.85  2010-01-01
```
