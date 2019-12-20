## ---- eval=FALSE---------------------------------------------------------
## library(ggplot2)
## library(dplyr)

## ----message=FALSE-------------------------------------------------------
library(dplyr)

# Be sure to install these first!
library(nycflights13)
library(knitr)

## ----load_flights--------------------------------------------------------
flights

## **_Learning check_**

## **Learning Check Solutions**

## NA
## ------------------------------------------------------------------------
glimpse(flights)

## **_Learning check_**

## **Learning Check Solutions**

## NA
## ----eval=FALSE----------------------------------------------------------
## airlines
## kable(airlines)

## ----eval=FALSE----------------------------------------------------------
## airlines
## airlines$name

## ----eval=FALSE----------------------------------------------------------
## ?flights

## ---- echo=FALSE, warning=FALSE, message=FALSE, results='hide'-----------
# needed_pkgs <- c("nycflights13", "tibble", "dplyr", "ggplot2", "knitr", 
#   "okcupiddata", "dygraphs", "rmarkdown", "mosaic", 
#   "ggplot2movies", "fivethirtyeight", "readr")
# 
# new.pkgs <- needed_pkgs[!(needed_pkgs %in% installed.packages())]
# 
# if(length(new.pkgs)) {
#   install.packages(new.pkgs, repos = "http://cran.rstudio.com")
# }

