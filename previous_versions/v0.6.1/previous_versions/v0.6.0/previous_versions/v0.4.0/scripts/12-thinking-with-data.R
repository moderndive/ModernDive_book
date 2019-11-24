## ----setup_thinking_with_data, include=FALSE-----------------------------
chap <- 12
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
solutions_shown <- c('')
show_solutions <- function(section){
  return(solutions_shown == "ALL" | section %in% solutions_shown)
  }

## ----moderndive-figure-conclusion, echo=FALSE, fig.align='center', fig.cap="ModernDive Flowchart"----
knitr::include_graphics("images/flowcharts/flowchart/flowchart.002.png")

## ----pipeline-figure-conclusion, echo=FALSE, fig.align='center', fig.cap="Data/Science Pipeline"----
knitr::include_graphics("images/tidy1.png")

## ---- message=FALSE, warning=FALSE---------------------------------------
library(ggplot2)
library(dplyr)
library(moderndive)
library(fivethirtyeight)

## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.
library(knitr)
library(patchwork)
library(scales)

## ----warning=FALSE, message=FALSE----------------------------------------
library(ggplot2)
library(dplyr)
library(moderndive)

## ---- eval=FALSE---------------------------------------------------------
## View(house_prices)
## glimpse(house_prices)

## ---- echo=FALSE---------------------------------------------------------
glimpse(house_prices)

## ---- eval=FALSE, message=FALSE, warning=FALSE---------------------------
## # Histogram of house price:
## ggplot(house_prices, aes(x = price)) +
##   geom_histogram(color = "white") +
##   labs(x = "price (USD)", title = "House price")
## 
## # Histogram of sqft_living:
## ggplot(house_prices, aes(x = sqft_living)) +
##   geom_histogram(color = "white") +
##   labs(x = "living space (square feet)", title = "House size")
## 
## # Barplot of condition:
## ggplot(house_prices, aes(x = condition)) +
##   geom_bar() +
##   labs(x = "condition", title = "House condition")

## ----house-prices-viz, echo=FALSE, message=FALSE, warning=FALSE, fig.cap="Exploratory visualizations of Seattle house prices data", fig.width=16/2, fig.height=9/2.5----
library(patchwork)
p1 <- ggplot(house_prices, aes(x = price)) +
  geom_histogram(color = "white") +
  labs(x = "price (USD)", title = "House price")
p2 <- ggplot(house_prices, aes(x = sqft_living)) +
  geom_histogram(color = "white") +
  labs(x = "living space (square feet)", title = "House size")
p3 <- ggplot(house_prices, aes(x = condition)) +
  geom_bar() +
  labs(x = "condition", title = "House condition")
p1 + p2 + p3

## ------------------------------------------------------------------------
house_prices %>% 
  summarize(
    mean_price = mean(price),
    median_price = median(price),
    sd_price = sd(price),
    IQR_price = IQR(price)
  )

## ----log10-orders-of-magnitude, echo=FALSE-------------------------------
data_frame(Price = c(1,10,100,1000,10000,100000,1000000)) %>% 
  mutate(
    `log10(Price)` = log10(Price),
    Price = dollar(Price),
    `Order of magnitude` = c("Singles", "Tens", "Hundreds", "Thousands", "Tens of thousands", "Hundreds of thousands", "Millions"),
    `Examples` = c("Cups of coffee", "Books", "Mobile phones", "High definition TV's", "Cars", "Luxury cars & houses", "Luxury houses")
    ) %>% 
  kable(
    caption = "log10-transformated prices, orders of magnitude, and examples", 
    booktabs = TRUE
  )

## ------------------------------------------------------------------------
house_prices <- house_prices %>%
  mutate(
    log10_price = log10(price),
    log10_size = log10(sqft_living)
    )

## ---- eval=FALSE---------------------------------------------------------
## house_prices %>%
##   select(price, log10_price, sqft_living, log10_size)

## ---- echo=FALSE---------------------------------------------------------
house_prices %>% 
  select(price, log10_price, sqft_living, log10_size) %>% 
  slice(1:10)

## ---- eval=FALSE---------------------------------------------------------
## # Before:
## ggplot(house_prices, aes(x = price)) +
##   geom_histogram(color = "white") +
##   labs(x = "price (USD)", title = "House price: Before")
## 
## # After:
## ggplot(house_prices, aes(x = log10_price)) +
##   geom_histogram(color = "white") +
##   labs(x = "log10 price (USD)", title = "House price: After")

## ----log10-price-viz, echo=FALSE, message=FALSE, warning=FALSE, fig.cap="House price before and after log10-transformation", fig.width=16/2, fig.height=9/2----
library(patchwork)
p1 <- ggplot(house_prices, aes(x = price)) +
  geom_histogram(color = "white") +
  labs(x = "price (USD)", title = "House price: Before")
p2 <- ggplot(house_prices, aes(x = log10_price)) +
  geom_histogram(color = "white") +
  labs(x = "log10 price (USD)", title = "House price: After")
p1 + p2

## ---- eval=FALSE---------------------------------------------------------
## # Before:
## ggplot(house_prices, aes(x = sqft_living)) +
##   geom_histogram(color = "white") +
##   labs(x = "living space (square feet)", title = "House size: Before")
## 
## # After:
## ggplot(house_prices, aes(x = log10_size)) +
##   geom_histogram(color = "white") +
##   labs(x = "log10 living space (square feet)", title = "House size: After")

## ----log10-size-viz, echo=FALSE, message=FALSE, warning=FALSE, fig.cap="House size before and after log10-transformation", fig.width=16/2, fig.height=9/2----
library(patchwork)
p1 <- ggplot(house_prices, aes(x = sqft_living)) +
  geom_histogram(color = "white") +
  labs(x = "living space (square feet)", title = "House size: Before")
p2 <- ggplot(house_prices, aes(x = log10_size)) +
  geom_histogram(color = "white") +
  labs(x = "log10 living space (square feet)", title = "House size: After")
p1 + p2

## ----house-price-parallel-slopes, echo=FALSE, message=FALSE, warning=FALSE, fig.cap="Parallel slopes model", fig.width=16/2, fig.height=9/2----
model_price_3_points <-
  house_prices %>%
  lm(log10_price ~ log10_size + condition, data = .) %>%
  get_regression_points()
ggplot(house_prices, aes(x = log10_size, y = log10_price, col = condition)) +
  geom_point(alpha = 0.1) +
  labs(y = "log10 price", x = "log10 size", title = "House prices in Seattle: Parallel slopes model") +
  geom_line(data = model_price_3_points, aes(y = log10_price_hat), show.legend = FALSE, size = 1) +
  guides(colour = guide_legend(override.aes = list(alpha = 1)))

## ----house-price-interaction, message=FALSE, warning=FALSE, fig.cap="Interaction model", fig.width=16/2, fig.height=9/2----
ggplot(house_prices, aes(x = log10_size, y = log10_price, col = condition)) +
  geom_point(alpha = 0.1) +
  labs(y = "log10 price", x = "log10 size", title = "House prices in Seattle") +
  geom_smooth(method = "lm", se = FALSE)

## ----house-price-interaction-2, message=FALSE, warning=FALSE, fig.cap="Interaction model with facets", fig.width=16/2, fig.height=9/2----
ggplot(house_prices, aes(x = log10_size, y = log10_price, col = condition)) +
  geom_point(alpha = 0.3) +
  labs(y = "log10 price", x = "log10 size", title = "House prices in Seattle") +
  geom_smooth(method = "lm", se = FALSE) +
  facet_wrap(~condition)

## ------------------------------------------------------------------------
# Fit regression model:
price_interaction <- lm(log10_price ~ log10_size * condition, data = house_prices)
# Get regression table:
get_regression_table(price_interaction)

## ----house-price-interaction-3, echo=FALSE, message=FALSE, warning=FALSE, fig.cap="Interaction model with prediction", fig.width=16/2, fig.height=9/2----
new_house <- data_frame(log10_size = log10(1900), condition = factor(5)) %>% 
  get_regression_points(price_interaction, newdata = .)

ggplot(house_prices, aes(x = log10_size, y = log10_price, col = condition)) +
  geom_point(alpha = 0.1) +
  labs(y = "log10 price", x = "log10 size", title = "House prices in Seattle") +
  geom_smooth(method = "lm", se = FALSE) +
  geom_vline(xintercept = log10(1900), linetype = "dashed", size = 1) +
  geom_point(data = new_house, aes(y = log10_price_hat), col ="black", size = 3)

## ------------------------------------------------------------------------
2.45 + 1 * log10(1900)

## ------------------------------------------------------------------------
10^(2.45 + 1 * log10(1900))

## ----fivethirtyeight-----------------------------------------------------
library(ggplot2)
library(dplyr)
library(fivethirtyeight)

## ------------------------------------------------------------------------
# Preview data
glimpse(US_births_1994_2003)

## ------------------------------------------------------------------------
US_births_1999 <- US_births_1994_2003 %>%
  filter(year == 1999)

## ------------------------------------------------------------------------
ggplot(US_births_1999, aes(x = date, y = births)) +
  geom_line() +
  labs(x = "Data", y = "Number of births", title = "US Births in 1999")

