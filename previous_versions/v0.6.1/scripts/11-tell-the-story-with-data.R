## ----setup_thinking_with_data, include=FALSE-----------------------------
chap <- 11
lc <- 0
rq <- 0
# **`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`**
# **`r paste0("(RQ", chap, ".", (rq <- rq + 1), ")")`**

knitr::opts_chunk$set(
  tidy = FALSE, 
  out.width = '\\textwidth', 
  fig.height = 4,
  warning = FALSE
  )

options(scipen = 99, digits = 3)

# Set random number generator see value for replicable pseudorandomness.
set.seed(76)




## ----pipeline-figure-conclusion, echo=FALSE, fig.align='center', fig.cap="Data/Science Pipeline."----
knitr::include_graphics("images/r4ds/data_science_pipeline.png")


## ---- eval = FALSE-------------------------------------------------------
## library(tidyverse)
## library(moderndive)
## library(skimr)
## library(fivethirtyeight)

## ---- message=FALSE, warning=FALSE, echo=FALSE---------------------------
library(tidyverse)
library(moderndive)
# DO NOT load the skimr package as a whole as it will break all kable() code for 
# the remaining chapters in the book.
# Furthermore all skimr::skim() output in this Chapter has been hard coded. 
# library(skimr)
library(fivethirtyeight)


## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.
library(knitr)
library(kableExtra)
library(patchwork)
library(scales)


## ---- eval = FALSE-------------------------------------------------------
## View(house_prices)
## glimpse(house_prices)

## ---- echo=FALSE---------------------------------------------------------
glimpse(house_prices)


## ---- eval = FALSE-------------------------------------------------------
## gain_summary <- flights %>%
##   summarize(
##     min = min(gain, na.rm = TRUE),
##     q1 = quantile(gain, 0.25, na.rm = TRUE),
##     median = quantile(gain, 0.5, na.rm = TRUE),
##     q3 = quantile(gain, 0.75, na.rm = TRUE),
##     max = max(gain, na.rm = TRUE),
##     mean = mean(gain, na.rm = TRUE),
##     sd = sd(gain, na.rm = TRUE),
##     missing = sum(is.na(gain))
##   )


## ---- eval = FALSE-------------------------------------------------------
## house_prices %>%
##   select(price, sqft_living, condition) %>%
##   skim()


## ---- eval = FALSE, message=FALSE, warning=FALSE-------------------------
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


## ----house-prices-viz, echo=FALSE, message=FALSE, warning=FALSE, fig.cap="Exploratory visualizations of Seattle house prices data.", fig.width=16/2, fig.height=9*2/3----
p1 <- ggplot(house_prices, aes(x = price)) +
  geom_histogram(color = "white") +
  labs(x = "price (USD)", title = "House price") 
p2 <- ggplot(house_prices, aes(x = sqft_living)) +
  geom_histogram(color = "white") +
  labs(x = "living space (square feet)", title = "House size")
p3 <- ggplot(house_prices, aes(x = condition)) +
  geom_bar() +
  labs(x = "condition", title = "House condition")
p1 + p2 + p3 + plot_layout(ncol = 2)


## ------------------------------------------------------------------------
house_prices <- house_prices %>%
  mutate(
    log10_price = log10(price),
    log10_size = log10(sqft_living)
    )


## ------------------------------------------------------------------------
house_prices %>% 
  select(price, log10_price, sqft_living, log10_size)


## ---- eval = FALSE-------------------------------------------------------
## # Before log10-transformation:
## ggplot(house_prices, aes(x = price)) +
##   geom_histogram(color = "white") +
##   labs(x = "price (USD)", title = "House price: Before")
## 
## # After log10-transformation:
## ggplot(house_prices, aes(x = log10_price)) +
##   geom_histogram(color = "white") +
##   labs(x = "log10 price (USD)", title = "House price: After")

## ----log10-price-viz, echo=FALSE, message=FALSE, warning=FALSE, fig.cap="House price before and after log10-transformation.", fig.width=16/2, fig.height=9/2----
p1 <- ggplot(house_prices, aes(x = price)) +
  geom_histogram(color = "white") +
  labs(x = "price (USD)", title = "House price: Before")
p2 <- ggplot(house_prices, aes(x = log10_price)) +
  geom_histogram(color = "white") +
  labs(x = "log10 price (USD)", title = "House price: After")
p1 + p2


## ---- eval = FALSE-------------------------------------------------------
## # Before log10-transformation:
## ggplot(house_prices, aes(x = sqft_living)) +
##   geom_histogram(color = "white") +
##   labs(x = "living space (square feet)",
##        title = "House size: Before")
## 
## # After log10-transformation:
## ggplot(house_prices, aes(x = log10_size)) +
##   geom_histogram(color = "white") +
##   labs(x = "log10 living space (square feet)",
##        title = "House size: After")

## ----log10-size-viz, echo=FALSE, message=FALSE, warning=FALSE, fig.cap="House size before and after log10-transformation.", fig.width=16/2, fig.height=9/2----
p1 <- ggplot(house_prices, aes(x = sqft_living)) +
  geom_histogram(color = "white") +
  labs(x = "living space (square feet)", 
       title = "House size: Before")
p2 <- ggplot(house_prices, aes(x = log10_size)) +
  geom_histogram(color = "white") +
  labs(x = "log10 living space (square feet)", 
       title = "House size: After")
p1 + p2


## ---- eval = FALSE-------------------------------------------------------
## # Plot interaction model
## ggplot(house_prices,
##        aes(x = log10_size, y = log10_price, col = condition)) +
##   geom_point(alpha = 0.05) +
##   geom_smooth(method = "lm", se = FALSE) +
##   labs(y = "log10 price", x = "log10 size",
##        title = "House prices in Seattle")
## 
## # Plot parallel slopes model
## gg_parallel_slopes(y = "log10_price", num_x = "log10_size",
##                    cat_x = "condition", data = house_prices,
##                    alpha = 0.05)

## ----house-price-parallel-slopes, echo=FALSE, message=FALSE, warning=FALSE, fig.cap="Interaction and parallel slopes models."----
interaction <- ggplot(house_prices, 
                      aes(x = log10_size, y = log10_price, col = condition)) +
  geom_point(alpha = 0.05) +
  labs(y = "log10 price", x = "log10 size") +
  geom_smooth(method = "lm", se = FALSE) +
  guides(color=FALSE) +
  labs(title = "House prices in Seattle", x = "log10 size", y = "log10 price")
parallel_slopes <- 
  gg_parallel_slopes(y = "log10_price", num_x = "log10_size", 
                     cat_x = "condition", data = house_prices, alpha = 0.05) +
  labs(y = NULL, x = "log10 size")
if(knitr::is_html_output()){
  interaction + parallel_slopes
} else {
  (interaction + scale_color_grey()) + 
    (parallel_slopes + scale_color_grey())
}


## ----eval=FALSE----------------------------------------------------------
## ggplot(house_prices,
##        aes(x = log10_size, y = log10_price, col = condition)) +
##   geom_point(alpha = 0.4) +
##   geom_smooth(method = "lm", se = FALSE) +
##   labs(y = "log10 price", x = "log10 size",
##        title = "House prices in Seattle") +
##   facet_wrap(~condition)


## ----house-price-interaction-2, echo=FALSE, message=FALSE, warning=FALSE, fig.cap="Facetted plot of interaction model."----
interaction_2_plot <- ggplot(house_prices, 
                             aes(x = log10_size, y = log10_price, 
                                 col = condition)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(y = "log10 price", x = "log10 size", 
       title = "House prices in Seattle") +
  facet_wrap(~condition)
if(knitr::is_html_output()){
  interaction_2_plot
} else {
  interaction_2_plot + scale_color_grey()
}


## ---- eval=FALSE---------------------------------------------------------
## # Fit regression model:
## price_interaction <- lm(log10_price ~ log10_size * condition,
##                         data = house_prices)
## # Get regression table:
## get_regression_table(price_interaction)

## ----seattle-interaction, echo=FALSE-------------------------------------
price_interaction <- lm(log10_price ~ log10_size * condition, 
                        data = house_prices)
get_regression_table(price_interaction) %>% 
  knitr::kable(
    digits = 3,
    caption = "Regression table for interaction model.", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))


## ----house-price-interaction-3, echo=FALSE, message=FALSE, warning=FALSE, fig.cap="Interaction model with prediction.", fig.width=16/2, fig.height=9/2----
new_house <- data_frame(log10_size = log10(1900), condition = factor(5)) %>% 
  get_regression_points(price_interaction, newdata = .)

with_prediction_plot <- ggplot(house_prices, aes(x = log10_size, y = log10_price, col = condition)) +
  geom_point(alpha = 0.05) +
  labs(y = "log10 price", x = "log10 size", title = "House prices in Seattle") +
  geom_smooth(method = "lm", se = FALSE) +
  geom_vline(xintercept = log10(1900), linetype = "dashed", size = 1) +
  geom_point(data = new_house, aes(y = log10_price_hat), col ="black", size = 3)
if(knitr::is_html_output()){
  with_prediction_plot
} else {
  with_prediction_plot + scale_color_grey()  
}


## ------------------------------------------------------------------------
2.45 + 1 * log10(1900)


## ------------------------------------------------------------------------
10^(2.45 + 1 * log10(1900))






## ------------------------------------------------------------------------
glimpse(US_births_1994_2003)


## ------------------------------------------------------------------------
US_births_1999 <- US_births_1994_2003 %>%
  filter(year == 1999)


## ----us-births, fig.cap="Number of births in US in 1999.", fig.align='center'----
ggplot(US_births_1999, aes(x = date, y = births)) +
  geom_line() +
  labs(x = "Data", y = "Number of births", title = "US Births in 1999")


## ------------------------------------------------------------------------
US_births_1999 %>% 
  arrange(desc(births))

