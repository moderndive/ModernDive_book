## ----tidy-load-packages, message=FALSE----------------------------------------
library(dplyr)
library(ggplot2)
library(readr)
library(tidyr)
library(nycflights23)
library(fivethirtyeight)




## ----tidy-load-readr, message=FALSE, eval=FALSE-------------------------------
# library(readr)
# dem_score <- read_csv("https://moderndive.com/data/dem_score.csv")
# dem_score







## ----tidy-create-drinks_smaller-----------------------------------------------
drinks_smaller <- drinks |> 
  filter(country %in% c("USA", "China", "Italy", "Saudi Arabia")) |> 
  select(-total_litres_of_pure_alcohol) |> 
  rename(beer = beer_servings, spirit = spirit_servings, wine = wine_servings)
drinks_smaller




















## ----tidy-v9------------------------------------------------------------------
drinks_smaller


## ----tidy-pivot-longer--------------------------------------------------------
drinks_smaller_tidy <- drinks_smaller |> 
  pivot_longer(names_to = "type", 
               values_to = "servings", 
               cols = -country)
drinks_smaller_tidy


## ----tidy-pivot-longer2, eval=FALSE-------------------------------------------
# drinks_smaller |>
#   pivot_longer(names_to = "type",
#                values_to = "servings",
#                cols = c(beer, spirit, wine))


## ----tidy-pivot-longer2-dup1, eval=FALSE--------------------------------------
# drinks_smaller |>
#   pivot_longer(names_to = "type",
#                values_to = "servings",
#                cols = beer:wine)


## ----tidy-bar, eval=FALSE-----------------------------------------------------
# ggplot(drinks_smaller_tidy, aes(x = country, y = servings, fill = type)) +
#   geom_col(position = "dodge")








## ----tidy-create-airline_safety_sma-------------------------------------------
airline_safety_smaller <- airline_safety |> 
  select(airline, starts_with("fatalities"))
airline_safety_smaller




## ----tidy-create-guat_dem-----------------------------------------------------
guat_dem <- dem_score |> 
  filter(country == "Guatemala")
guat_dem


## ----tidy-pivot-longer2-dup2--------------------------------------------------
guat_dem_tidy <- guat_dem |> 
  pivot_longer(names_to = "year", 
               values_to = "democracy_score", 
               cols = -country,
               names_transform = list(year = as.integer)) 
guat_dem_tidy


## ----guat-dem-tidy, fig.cap="Democracy scores in Guatemala 1952-1992.", fig.height=ifelse(knitr::is_latex_output(), 3, 4)----
ggplot(guat_dem_tidy, aes(x = year, y = democracy_score)) +
  geom_line() +
  labs(x = "Year", y = "Democracy Score")

