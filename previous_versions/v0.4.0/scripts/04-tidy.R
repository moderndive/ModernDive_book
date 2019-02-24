## ----setup_tidy, include=FALSE-------------------------------------------
chap <- 4
lc <- 0
rq <- 0
# **`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`**
# **`r paste0("(RQ", chap, ".", (rq <- rq + 1), ")")`**

knitr::opts_chunk$set(
  tidy = FALSE, 
  out.width = '\\textwidth'
  )

# This bit of code is a bug fix on asis blocks, which we use to show/not show LC
# solutions, which are written like markdown text. In theory, it shouldn't be
# necessary for knitr versions <=1.11.6, but I've found I still need to for
# everything to knit properly in asis blocks. More info here: 
# https://stackoverflow.com/questions/32944715/conditionally-display-block-of-markdown-text-using-knitr
library(knitr)
knit_engines$set(asis = function(options) {
  if (options$echo && options$eval) knit_child(text = options$code)
})

# This controls which LC solutions to show. Options for solutions_shown: "ALL"
# (to show all solutions), or subsets of c('4-4', '4-5'), including the
# null vector c('') to show no solutions.
# solutions_shown <- c('4-1', '4-2', '4-3', '4-4')
solutions_shown <- c('')
show_solutions <- function(section){
  return(solutions_shown == "ALL" | section %in% solutions_shown)
  }

## ----warning=FALSE, message=FALSE----------------------------------------
library(dplyr)
library(ggplot2)
library(nycflights13)
library(tidyr)
library(readr)

## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.
library(knitr)
library(fivethirtyeight)
library(stringr)

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
  )

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
  ) 

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
  )

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

## **Learning Check Solutions**

## ----lc4-1solutions-2, include=show_solutions('4-1'), echo=FALSE---------
drinks_sub_tidy

## Note that how the rows are sorted is inconsequential in whether or not the data frame is in tidy format. In other words, the following data frame sorted by alcohol type instead of country is equally in tidy format.

## ----lc4-1solutions-4, include=show_solutions('4-1'), echo=FALSE---------
drinks_sub_tidy %>% 
  arrange(`alcohol type`)

## ------------------------------------------------------------------------
glimpse(airports)

## **_Learning check_**

## **Learning Check Solutions**

## ----message=FALSE, eval=FALSE-------------------------------------------
## library(readr)
## dem_score <- read_csv("https://moderndive.com/data/dem_score.csv")
## dem_score

## ----message=FALSE, echo=FALSE-------------------------------------------
dem_score <- read_csv("data/dem_score.csv")
dem_score

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
ggplot(data = guat_tidy, mapping = aes(x = year, y = democracy_score)) +
  geom_line()

## ----guatline, fig.cap="Guatemala's democracy score ratings from 1952 to 1992"----
ggplot(data = guat_tidy, mapping = aes(x = parse_number(year), y = democracy_score)) +
  geom_line() +
  labs(x = "year")

## **Learning Check Solutions**

## ----lc4-3solutions-2, include=show_solutions('4-3')---------------------
dem_score_tidy <- gather(data = dem_score, key = year, value = democracy_score, - country)

## Let's now compare the `dem_score` and `dem_score_tidy`. `dem_score` has democracy score information for each year in columns, whereas in `dem_score_tidy` there are explicit variables `year` and `democracy_score`. While both representations of the data contain the same information, we can only use `ggplot()` to create plots using the `dem_score_tidy` data frame.

## ----lc4-3solutions-4, include=show_solutions('4-3')---------------------
dem_score
dem_score_tidy

## **`r paste0("(LC", chap, ".", (lc - 1), ")")`** The code is similar

## ----lc4-3solutions-6, include=show_solutions('4-3'), echo=show_solutions('4-3'), message=FALSE, warning=FALSE----
life_expectancy <- read_csv('https://moderndive.com/data/le_mess.csv')
life_expectancy_tidy <- gather(data = life_expectancy, key = year, value = life_expectancy, -country)

## We observe the same construct structure with respect to `year` in `life_expectancy` vs `life_expectancy_tidy` as we did in `dem_score` vs `dem_score_tidy`:

## ----lc4-3solutions-8, lc4-2solutions-4, include=show_solutions('4-3')----
life_expectancy
life_expectancy_tidy

## ----message=FALSE-------------------------------------------------------
library(dplyr)
joined_flights <- inner_join(x = flights, y = airlines, by = "carrier")

## ----eval=FALSE----------------------------------------------------------
## View(joined_flights)

## **_Learning check_**

## **Learning Check Solutions**

