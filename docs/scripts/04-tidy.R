## ----setup_tidy, include=FALSE-------------------------------------------
chap <- 4
lc <- 0
rq <- 0
# **`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`**
# **`r paste0("(RQ", chap, ".", (rq <- rq + 1), ")")`**
knitr::opts_chunk$set(tidy = FALSE, out.width = '\\textwidth')
# This bit of code is a bug fix on asis blocks, which we use to show/not show LC solutions, which are written like markdown text. In theory, it shouldn't be necessary for knitr versions <=1.11.6, but I've found I still need to for everything to knit properly in asis blocks. More info here:
# https://stackoverflow.com/questions/32944715/conditionally-display-block-of-markdown-text-using-knitr
library(knitr)
knit_engines$set(asis = function(options) {
  if (options$echo && options$eval) knit_child(text = options$code)
})
# This controls which LC solutions to show. Options for solutions_shown: "ALL" (to show all solutions), or subsets of c('3-1', '3-2','3-3'), including the null vector c('') to show no solutions.
solutions_shown <- c("")
show_solutions <- function(section){return(solutions_shown == "ALL" | section %in% solutions_shown)}

## ----warning=FALSE, message=FALSE----------------------------------------
library(nycflights13)
library(dplyr)

## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.
library(knitr)
library(tidyr)

## ----tidyfig, echo=FALSE, fig.cap="Tidy data graphic from http://r4ds.had.co.nz/tidy-data.html"----
knitr::include_graphics("images/tidy-1.png")

## ----echo=FALSE----------------------------------------------------------
stocks <- data_frame(
  Date = as.Date('2009-01-01') + 0:4,
  Boeing = paste("$", c("173.55", "172.61", "173.86", "170.77", "174.29"), sep=""),
  Amazon = paste("$", c("174.90", "171.42", "171.58", "173.89", "170.16"), sep=""),
  Google = paste("$", c("174.34", "170.04", "173.65", "174.87", "172.19") ,sep="")
) %>% 
  slice(1:2)
stocks %>% 
  kable(
    digits=2,
    caption = "Stock Prices (Non-Tidy Format)", 
    booktabs = TRUE
  )

## ----echo=FALSE----------------------------------------------------------
stocks_tidy <- stocks %>% 
  gather(`Stock Name`, Price, -Date)
stocks_tidy %>% 
  kable(
    digits=2,
    caption = "Stock Prices (Tidy Format)", 
    booktabs = TRUE
  )

## **_Learning check_**

## **Learning Check Solutions**

## ---- include=show_solutions('3-1'), warning=FALSE, echo=FALSE, warning=FALSE, message=FALSE----
library(tidyverse)
data.frame(
  Date = as.Date('2009-01-01') + 0:4,
  Boeing = paste("$", c("173.55", "172.61", "173.86", "170.77", "174.29"), sep=""),
  Amazon = paste("$", c("174.90", "171.42", "171.58", "173.89", "170.16"), sep=""),
  Google = paste("$", c("174.34", "170.04", "173.65", "174.87", "172.19") ,sep="")
) %>% 
  gather(`Stock Name`, Price, -Date) %>% 
  kable()

## **_Learning check_**

## ----eval=FALSE----------------------------------------------------------
## View(weather)
## View(planes)
## View(airports)
## View(airlines)

## **Learning Check Solutions**

## ------------------------------------------------------------------------
glimpse(airports)

## **_Learning check_**

## **Learning Check Solutions**

## ----message=FALSE-------------------------------------------------------
library(dplyr)
joined_flights <- inner_join(x = flights, y = airlines, by = "carrier")

## ----eval=FALSE----------------------------------------------------------
## View(joined_flights)

## **_Learning check_**

## ----echo=FALSE, message=FALSE-------------------------------------------
library(dplyr)
library(knitr)
students <- c(4, 6)
faculty <- c(2, 3)
kable(data_frame("students" = students, "faculty" = faculty))

## ----echo=FALSE, message=FALSE, warning=FALSE----------------------------
library(dplyr)
role <- c(rep("student", 10), rep("faculty", 5))
sociology <- c(rep(TRUE, 4), rep(FALSE, 6), rep(TRUE, 2), rep(FALSE, 3))
school_type <- c(rep("Public", 6), rep("Private", 4), rep("Public", 3), rep("Private", 2))
kable(data_frame("role" = role, `Sociology?` = sociology,
  `Type of School` = school_type))

## **Learning Check Solutions**

## ------------------------------------------------------------------------
students <- c(4, 6)
faculty <- c(2, 3)
data_frame("students" = students, "faculty" = faculty) %>% 
  kable()

## **`r paste0("(LC", chap, ".", (lc - 2), ")")`** We need at least a third variable to identify the observations. For example a variable "Department".

