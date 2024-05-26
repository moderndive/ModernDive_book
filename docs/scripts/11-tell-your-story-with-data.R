## ----eval=FALSE---------------------------------------------------------------
## library(tidyverse)
## library(moderndive)
## library(skimr)
## library(fivethirtyeight)

## ----echo=FALSE, message=FALSE, purl=TRUE-------------------------------------
# The code presented to the reader in the chunk above is different than the code
# in this chunk that is actually run to build the book. In particular we do not
# load the skimr package.
# 
# This is because skimr v1.0.6 which we used for the book causes all
# kable() code to break for the remaining chapters in the book. v2 might
# fix these issues:
# https://github.com/moderndive/ModernDive_book/issues/271

# As a workaround for v1 of ModernDive, all skimr::skim() output in this chapter
# has been hard coded.
library(tidyverse)
library(moderndive)
# library(skimr)
library(fivethirtyeight)




## ----eval=FALSE---------------------------------------------------------------
## View(house_prices)
## glimpse(house_prices)



## ----eval=FALSE---------------------------------------------------------------
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


## ----eval=FALSE---------------------------------------------------------------
## house_prices %>%
##   select(price, sqft_living, condition) %>%
##   skim()


## ----eval=FALSE, message=FALSE------------------------------------------------
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




## -----------------------------------------------------------------------------
house_prices <- house_prices %>%
  mutate(
    log10_price = log10(price),
    log10_size = log10(sqft_living)
    )


## -----------------------------------------------------------------------------
house_prices %>% 
  select(price, log10_price, sqft_living, log10_size)


## ----eval=FALSE---------------------------------------------------------------
## # Before log10 transformation:
## ggplot(house_prices, aes(x = price)) +
##   geom_histogram(color = "white") +
##   labs(x = "price (USD)", title = "House price: Before")
## 
## # After log10 transformation:
## ggplot(house_prices, aes(x = log10_price)) +
##   geom_histogram(color = "white") +
##   labs(x = "log10 price (USD)", title = "House price: After")




## ----eval=FALSE---------------------------------------------------------------
## # Before log10 transformation:
## ggplot(house_prices, aes(x = sqft_living)) +
##   geom_histogram(color = "white") +
##   labs(x = "living space (square feet)", title = "House size: Before")
## 
## # After log10 transformation:
## ggplot(house_prices, aes(x = log10_size)) +
##   geom_histogram(color = "white") +
##   labs(x = "log10 living space (square feet)", title = "House size: After")



## ----eval=FALSE---------------------------------------------------------------
## # Plot interaction model
## ggplot(house_prices,
##        aes(x = log10_size, y = log10_price, col = condition)) +
##   geom_point(alpha = 0.05) +
##   geom_smooth(method = "lm", se = FALSE) +
##   labs(y = "log10 price",
##        x = "log10 size",
##        title = "House prices in Seattle")
## # Plot parallel slopes model
## ggplot(house_prices,
##        aes(x = log10_size, y = log10_price, col = condition)) +
##   geom_point(alpha = 0.05) +
##   geom_parallel_slopes(se = FALSE) +
##   labs(y = "log10 price",
##        x = "log10 size",
##        title = "House prices in Seattle")



## ----eval=FALSE---------------------------------------------------------------
## ggplot(house_prices,
##        aes(x = log10_size, y = log10_price, col = condition)) +
##   geom_point(alpha = 0.4) +
##   geom_smooth(method = "lm", se = FALSE) +
##   labs(y = "log10 price",
##        x = "log10 size",
##        title = "House prices in Seattle") +
##   facet_wrap(~ condition)




## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## price_interaction <- lm(log10_price ~ log10_size * condition,
##                         data = house_prices)
## 
## # Get regression table:
## get_regression_table(price_interaction)









## -----------------------------------------------------------------------------
2.45 + 1 * log10(1900)


## -----------------------------------------------------------------------------
10^(2.45 + 1 * log10(1900))






## -----------------------------------------------------------------------------
glimpse(US_births_1994_2003)


## -----------------------------------------------------------------------------
US_births_1999 <- US_births_1994_2003 %>%
  filter(year == 1999)


## ----us-births, fig.cap="Number of births in the US in 1999.", fig.height=6.4----
ggplot(US_births_1999, aes(x = date, y = births)) +
  geom_line() +
  labs(x = "Date", 
       y = "Number of births", 
       title = "US Births in 1999")


## -----------------------------------------------------------------------------
US_births_1999 %>% 
  arrange(desc(births))

