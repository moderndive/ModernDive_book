## ----setup_tidy, include=FALSE-------------------------------------------
chap <- 5
lc <- 0
rq <- 0
# **`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`**
# **`r paste0("(RQ", chap, ".", (rq <- rq + 1), ")")`**

knitr::opts_chunk$set(
  tidy = FALSE, 
  out.width = '\\textwidth', 
  fig.height = 4,
  fig.align='center',
  warning = FALSE
)

options(scipen = 99, digits = 3)

# In knitr::kable printing replace all NA's with blanks
options(knitr.kable.NA = '')

# Set random number generator see value for replicable pseudorandomness. Why 76?
# https://www.youtube.com/watch?v=xjJ7FheCkCU
set.seed(76)


## ----warning=FALSE, message=FALSE----------------------------------------
library(dplyr)
library(ggplot2)
library(readr)
library(tidyr)
library(nycflights13)
library(fivethirtyeight)


## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.
library(knitr)
library(kableExtra)
library(fivethirtyeight)
library(stringr)


## ----message=FALSE, eval=FALSE-------------------------------------------
## library(readr)
## dem_score <- read_csv("https://moderndive.com/data/dem_score.csv")
## dem_score

## ----message=FALSE, echo=FALSE-------------------------------------------
dem_score <- read_csv("data/dem_score.csv")
dem_score


## ----read-excel, echo=FALSE, fig.cap="Reading in an Excel file to R."----
include_graphics("images/read_excel.png")


## ------------------------------------------------------------------------
drinks


## ------------------------------------------------------------------------
drinks_smaller <- drinks %>% 
  filter(country %in% c("USA", "China", "Italy", "Saudi Arabia")) %>% 
  select(-total_litres_of_pure_alcohol) %>% 
  rename(beer = beer_servings, spirit = spirit_servings, wine = wine_servings)
drinks_smaller


## ----drinks-smaller, fig.cap="Comparing alcohol consumption in 4 countries.", fig.height=3.5, echo=FALSE----
drinks_smaller_tidy <- drinks_smaller %>% 
  gather(type, servings, -country)
ggplot(drinks_smaller_tidy, aes(x=country, y=servings, fill=type)) +
  geom_col(position = "dodge") +
  labs(x = "country", y = "servings")


## ------------------------------------------------------------------------
drinks_smaller_tidy


## ------------------------------------------------------------------------
drinks_smaller


## ----tidyfig, echo=FALSE, fig.cap="Tidy data graphic from 'R for Data Science'."----
knitr::include_graphics("images/tidy-1.png")


## ----non-tidy-stocks, echo=FALSE-----------------------------------------
stocks <- tibble(
  Date = as.Date('2009-01-01') + 0:4,
  `Boeing Stock Price` = paste("$", c("173.55", "172.61", "173.86", "170.77", "174.29"), sep = ""),
  `Amazon Stock Price` = paste("$", c("174.90", "171.42", "171.58", "173.89", "170.16"), sep = ""),
  `Google Stock Price` = paste("$", c("174.34", "170.04", "173.65", "174.87", "172.19") ,sep = "")
) %>% 
  slice(1:2)
stocks %>% 
  kable(
    digits = 2,
    caption = "Stock Prices (Non-Tidy Format)", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ----tidy-stocks, echo=FALSE---------------------------------------------
stocks_tidy <- stocks %>% 
  rename(
    Boeing = `Boeing Stock Price`,
    Amazon = `Amazon Stock Price`,
    Google = `Google Stock Price`
  ) %>% 
  gather(`Stock Name`, `Stock Price`, -Date)
stocks_tidy %>% 
  kable(
    digits = 2,
    caption = "Stock Prices (Tidy Format)", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ----tidy-stocks-2, echo=FALSE-------------------------------------------
stocks <- tibble(
  Date = as.Date('2009-01-01') + 0:4,
  `Boeing Price` = paste("$", c("173.55", "172.61", "173.86", "170.77", "174.29"), sep = ""),
  `Weather` = c("Sunny", "Overcast", "Rain", "Rain", "Sunny")
) %>% 
  slice(1:2)
stocks %>% 
  kable(
    digits = 2,
    caption = "Date, Boeing Price, Weather Data", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16), 
                latex_options = c("HOLD_position"))


## **_Learning check_**




## ------------------------------------------------------------------------
drinks_smaller


## ------------------------------------------------------------------------
drinks_smaller_tidy <- drinks_smaller %>% 
  gather(key = type, value = servings, -country)
drinks_smaller_tidy


## ---- eval=FALSE---------------------------------------------------------
## drinks_smaller_tidy <- drinks_smaller %>%
##   gather(key = type, value = servings, c(beer, spirit, wine))
## drinks_smaller_tidy


## ----drinks-smaller-tidy-barplot, fig.cap="Comparing alcohol consumption in 4 countries.", fig.height=3.5----
ggplot(drinks_smaller_tidy, 
       aes(x = country, y = servings, fill = type)) +
  geom_col(position = "dodge")


## **_Learning check_**


## ---- eval=FALSE---------------------------------------------------------
## airline_safety


## ------------------------------------------------------------------------
airline_safety_smaller <- airline_safety %>% 
  select(-c(incl_reg_subsidiaries, avail_seat_km_per_week))
airline_safety_smaller




## ------------------------------------------------------------------------
guat_dem <- dem_score %>% 
  filter(country == "Guatemala")
guat_dem


## ------------------------------------------------------------------------
guat_dem_tidy <- guat_dem %>% 
  gather(key = year, value = democracy_score, -country) 
guat_dem_tidy


## ------------------------------------------------------------------------
guat_dem_tidy <- guat_dem_tidy %>% 
  mutate(year = as.numeric(year))


## ----guat-dem-tidy, fig.cap="Democracy scores in Guatemala 1952-1992.", fig.height=3.5----
ggplot(guat_dem_tidy, aes(x = year, y = democracy_score)) +
  geom_line() +
  labs(x = "Year", y = "Democracy Score")






## ---- eval=FALSE---------------------------------------------------------
## library(dplyr)
## library(ggplot2)
## library(readr)
## library(tidyr)


## ---- eval=FALSE---------------------------------------------------------
## library(tidyverse)


## ---- eval=FALSE---------------------------------------------------------
## library(ggplot2)
## library(dplyr)
## library(tidyr)
## library(readr)
## library(purrr)
## library(tibble)
## library(stringr)
## library(forcats)


## ----import-cheatsheet, echo=FALSE, fig.cap="Data Import cheatsheet."----
include_graphics("images/import_cheatsheet-1.png")


## ----echo=FALSE, fig.cap="ModernDive flowchart - On to Part II!", fig.align='center'----
knitr::include_graphics("images/flowcharts/flowchart/flowchart.005.png")

