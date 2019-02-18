## **_Learning check_**

## NA
## ---- eval=FALSE---------------------------------------------------------
## library(ggplot2)

## **_Learning check_**

## NA
## ----message=FALSE-------------------------------------------------------
library(nycflights13)
library(dplyr)
library(knitr)

## ----load_flights--------------------------------------------------------
flights

## **_Learning check_**

## NA
## ------------------------------------------------------------------------
glimpse(flights)

## **_Learning check_**

## NA
## ----eval=FALSE----------------------------------------------------------
## airlines
## kable(airlines)

## ----eval=FALSE----------------------------------------------------------
## airlines
## airlines$name

## ------------------------------------------------------------------------
glimpse(airports)

## **_Learning check_**

## ----eval=FALSE----------------------------------------------------------
## ?flights

## ----echo=FALSE, fig.cap="ModernDive flowchart", out.width='110%', fig.align='center'----
knitr::include_graphics("images/flowcharts/flowchart/flowchart.004.png")

