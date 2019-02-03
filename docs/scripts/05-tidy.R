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

## ----tidyfig, echo=FALSE, fig.cap="Tidy data graphic from http://r4ds.had.co.nz/tidy-data.html"----
knitr::include_graphics("images/tidy-1.png")

## ----echo=FALSE----------------------------------------------------------
stocks <- data_frame(
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

## ----echo=FALSE----------------------------------------------------------
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

## ----echo=FALSE----------------------------------------------------------
stocks <- data_frame(
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

## ----echo=FALSE----------------------------------------------------------
drinks_sub <- drinks %>%
  select(-total_litres_of_pure_alcohol) %>% 
  filter(country %in% c("USA", "Canada", "South Korea"))
drinks_sub_tidy <- drinks_sub %>%
  gather(type, servings, -c(country)) %>%
  mutate(
    type = str_sub(type, start=1, end=-10)
  ) %>%
  arrange(country, type) %>% 
  rename(`alcohol type` = type)
drinks_sub

## ------------------------------------------------------------------------
glimpse(airports)

## **_Learning check_**

## ------------------------------------------------------------------------
guat_dem <- dem_score %>% 
  filter(country == "Guatemala")
guat_dem

## ------------------------------------------------------------------------
guat_tidy <- gather(data = guat_dem, 
                    key = year,
                    value = democracy_score,
                    - country) 
guat_tidy

## ----errors=TRUE---------------------------------------------------------
ggplot(data = guat_tidy, 
       mapping = aes(x = year, y = democracy_score)) +
  geom_line()

## ----guatline, fig.cap="Guatemala's democracy score ratings from 1952 to 1992"----
ggplot(data = guat_tidy, 
       mapping = aes(x = parse_number(year), 
                     y = democracy_score)) +
  geom_line() +
  labs(x = "year")

## ---- eval=FALSE---------------------------------------------------------
## library(dplyr)
## library(ggplot2)
## library(readr)
## library(tidyr)

## ---- eval=TRUE----------------------------------------------------------
library(tidyverse)

## ---- eval=TRUE----------------------------------------------------------
library(ggplot2)
library(dplyr)
library(tidyr)
library(readr)
library(purrr)
library(tibble)
library(stringr)
library(forcats)

## ----message=FALSE-------------------------------------------------------
joined_flights <- inner_join(x = flights, y = airlines, by = "carrier")

## ----eval=FALSE----------------------------------------------------------
## View(joined_flights)

## **_Learning check_**

## ----import-cheatsheet, echo=FALSE, fig.cap="Data Import cheatsheat"-----
include_graphics("images/import_cheatsheet-1.png")

## ----echo=FALSE, fig.cap="ModernDive flowchart - On to Part II!", fig.align='center'----
knitr::include_graphics("images/flowcharts/flowchart/flowchart.005.png")

