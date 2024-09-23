## ----message=FALSE------------------------------------------------------------
library(dplyr)
library(ggplot2)
library(readr)
library(tidyr)
library(nycflights13)
library(fivethirtyeight)




## ----message=FALSE, eval=FALSE------------------------------------------------
## library(readr)
## dem_score <- read_csv("https://moderndive.com/data/dem_score.csv")
## dem_score







## -----------------------------------------------------------------------------
drinks_smaller <- drinks %>% 
  filter(country %in% c("USA", "China", "Italy", "Saudi Arabia")) %>% 
  select(-total_litres_of_pure_alcohol) %>% 
  rename(beer = beer_servings, spirit = spirit_servings, wine = wine_servings)
drinks_smaller




















## -----------------------------------------------------------------------------
drinks_smaller


## -----------------------------------------------------------------------------
drinks_smaller_tidy <- drinks_smaller %>% 
  pivot_longer(names_to = "type", 
               values_to = "servings", 
               cols = -country)
drinks_smaller_tidy


## ----eval=FALSE---------------------------------------------------------------
## drinks_smaller %>%
##   pivot_longer(names_to = "type",
##                values_to = "servings",
##                cols = c(beer, spirit, wine))


## ----eval=FALSE---------------------------------------------------------------
## drinks_smaller %>%
##   pivot_longer(names_to = "type",
##                values_to = "servings",
##                cols = beer:wine)


## ----eval=FALSE---------------------------------------------------------------
## ggplot(drinks_smaller_tidy, aes(x = country, y = servings, fill = type)) +
##   geom_col(position = "dodge")








## -----------------------------------------------------------------------------
airline_safety_smaller <- airline_safety %>% 
  select(airline, starts_with("fatalities"))
airline_safety_smaller




## -----------------------------------------------------------------------------
guat_dem <- dem_score %>% 
  filter(country == "Guatemala")
guat_dem


## -----------------------------------------------------------------------------
guat_dem_tidy <- guat_dem %>% 
  pivot_longer(names_to = "year", 
               values_to = "democracy_score", 
               cols = -country,
               names_transform = list(year = as.integer)) 
guat_dem_tidy


## ----guat-dem-tidy, fig.cap="Democracy scores in Guatemala 1952-1992.", fig.height=3----
ggplot(guat_dem_tidy, aes(x = year, y = democracy_score)) +
  geom_line() +
  labs(x = "Year", y = "Democracy Score")

