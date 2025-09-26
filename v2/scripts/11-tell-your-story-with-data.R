## ----message=FALSE------------------------------------------------------------
library(tidyverse)
library(moderndive)
library(fivethirtyeight)
library(infer)




## ----eval=FALSE---------------------------------------------------------------
# View(house_prices)
# glimpse(house_prices)



## ----eval=FALSE---------------------------------------------------------------
# gain_summary <- flights |>
#   summarize(min = min(gain, na.rm = TRUE),
#             q1 = quantile(gain, 0.25, na.rm = TRUE),
#             median = quantile(gain, 0.5, na.rm = TRUE),
#             q3 = quantile(gain, 0.75, na.rm = TRUE),
#             max = max(gain, na.rm = TRUE),
#             mean = mean(gain, na.rm = TRUE),
#             sd = sd(gain, na.rm = TRUE),
#             missing = sum(is.na(gain)))


## ----eval=FALSE---------------------------------------------------------------
# house_prices |>
#   select(price, sqft_living, condition) |>
#   tidy_summary()


## ----echo=FALSE---------------------------------------------------------------
house_prices |> 
  select(price, sqft_living, condition) |> 
  tidy_summary() |> 
  kbl(caption = "(ref:some-house-price-vars)") |> 
  kable_styling(
    font_size = ifelse(is_latex_output(), 7.8, 16),
    latex_options = c("HOLD_position")
  )


## ----eval=FALSE, message=FALSE------------------------------------------------
# # Histogram of house price:
# ggplot(house_prices, aes(x = price)) +
#   geom_histogram(color = "white") +
#   labs(x = "price (USD)", title = "House price")
# 
# # Histogram of sqft_living:
# ggplot(house_prices, aes(x = sqft_living)) +
#   geom_histogram(color = "white") +
#   labs(x = "living space (square feet)", title = "House size")
# 
# # Barplot of condition:
# ggplot(house_prices, aes(x = condition)) +
#   geom_bar() +
#   labs(x = "condition", title = "House condition")




## ----echo=FALSE, results="asis"-----------------------------------------------
if(!is_latex_output()) 
  cat("If you are unfamiliar with such transformations, we highly recommend you read [Appendix A online](https://moderndive.com/v2/appendixa) on logarithmic (log) transformations.")


## -----------------------------------------------------------------------------
house_prices <- house_prices |>
  mutate(
    log10_price = log10(price),
    log10_size = log10(sqft_living)
  )


## -----------------------------------------------------------------------------
house_prices |> 
  select(price, log10_price, sqft_living, log10_size)


## ----eval=FALSE---------------------------------------------------------------
# # Before log10 transformation:
# ggplot(house_prices, aes(x = price)) +
#   geom_histogram(color = "white") +
#   labs(x = "price (USD)", title = "House price: Before")
# 
# # After log10 transformation:
# ggplot(house_prices, aes(x = log10_price)) +
#   geom_histogram(color = "white") +
#   labs(x = "log10 price (USD)", title = "House price: After")




## ----eval=FALSE---------------------------------------------------------------
# # Before log10 transformation:
# ggplot(house_prices, aes(x = sqft_living)) +
#   geom_histogram(color = "white") +
#   labs(x = "living space (square feet)", title = "House size: Before")
# 
# # After log10 transformation:
# ggplot(house_prices, aes(x = log10_size)) +
#   geom_histogram(color = "white") +
#   labs(x = "log10 living space (square feet)", title = "House size: After")



## ----eval=FALSE---------------------------------------------------------------
# # Plot interaction model
# ggplot(house_prices,
#        aes(x = log10_size, y = log10_price, col = condition)) +
#   geom_point(alpha = 0.05) +
#   geom_smooth(method = "lm", se = FALSE) +
#   labs(y = "log10 price",
#        x = "log10 size",
#        title = "House prices in Seattle")
# # Plot parallel slopes model
# ggplot(house_prices,
#        aes(x = log10_size, y = log10_price, col = condition)) +
#   geom_point(alpha = 0.05) +
#   geom_parallel_slopes(se = FALSE) +
#   labs(y = "log10 price",
#        x = "log10 size",
#        title = "House prices in Seattle")



## ----eval=FALSE---------------------------------------------------------------
# ggplot(house_prices,
#        aes(x = log10_size, y = log10_price, col = condition)) +
#   geom_point(alpha = 0.4) +
#   geom_smooth(method = "lm", se = FALSE) +
#   labs(y = "log10 price",
#        x = "log10 size",
#        title = "House prices in Seattle") +
#   facet_wrap(~ condition)


## -----------------------------------------------------------------------------
house_prices |> 
  count(condition)




## ----eval=FALSE---------------------------------------------------------------
# price_interaction <- lm(log10_price ~ log10_size * condition, data = house_prices)
# get_regression_table(price_interaction)









## -----------------------------------------------------------------------------
2.45 + 1 * log10(1900)


## ----echo=FALSE, results="asis"-----------------------------------------------
if(!is_latex_output()) 
  cat("This described in [Appendix A online](https://moderndive.com/v2/appendixa).")


## -----------------------------------------------------------------------------
10^(2.45 + 1 * log10(1900))


## ----eval=FALSE---------------------------------------------------------------
# price_interaction <- lm(log10_price ~ log10_size * condition, data = house_prices)
# get_regression_table(price_interaction)



## -----------------------------------------------------------------------------
observed_fit_coefficients <- house_prices |>
  specify(
    log10_price ~ log10_size * condition
    ) |>
  fit()
observed_fit_coefficients


## ----eval=FALSE---------------------------------------------------------------
# null_distribution_housing <- house_prices |>
#   specify(
#     log10_price ~ log10_size * condition
#     ) |>
#   hypothesize(null = "independence") |>
#   generate(reps = 1000, type = "permute") |>
#   fit()


## ----echo=FALSE---------------------------------------------------------------
if (!file.exists("rds/null_distribution_housing.rds")) {
  set.seed(2024)
  null_distribution_housing <- house_prices |>
    specify(log10_price ~ log10_size * condition) |>
    hypothesize(null = "independence") |>
    generate(reps = 1000, type = "permute") |>
    fit()
  saveRDS(
    object = null_distribution_housing,
    "rds/null_distribution_housing.rds"
  )
} else {
  null_distribution_housing <- readRDS("rds/null_distribution_housing.rds")
}


## ----eval=FALSE---------------------------------------------------------------
# visualize(null_distribution_housing) +
#   shade_p_value(obs_stat = observed_fit_coefficients,
#                 direction = "two-sided")


## ----echo=FALSE, message=FALSE------------------------------------------------
null_housing_shaded <- visualize(null_distribution_housing) +
  shade_p_value(obs_stat = observed_fit_coefficients, direction = "two-sided")
if (!file.exists("images/null_housing_shaded.png")) {
  ggsave(
    filename = "images/null_housing_shaded.png",
    plot = null_housing_shaded,
    width = 6,
    height = 11,
    dpi = 320
  )
}


## ----echo=FALSE, out.width="90%"----------------------------------------------
if(is_latex_output())
  knitr::include_graphics("images/null_housing_shaded.png")


## ----echo=FALSE, fig.height=12------------------------------------------------
if(is_html_output())
  null_housing_shaded


## -----------------------------------------------------------------------------
null_distribution_housing |>
  get_p_value(obs_stat = observed_fit_coefficients, direction = "two-sided")






## -----------------------------------------------------------------------------
glimpse(US_births_1994_2003)


## -----------------------------------------------------------------------------
US_births_1999 <- US_births_1994_2003 |>
  filter(year == 1999)


## ----us-births, fig.cap="Number of births in the US in 1999.", fig.height=ifelse(knitr::is_latex_output(), 6.4, 7)----
ggplot(US_births_1999, aes(x = date, y = births)) +
  geom_line() +
  labs(x = "Date", 
       y = "Number of births", 
       title = "US Births in 1999")


## -----------------------------------------------------------------------------
US_births_1999 |> 
  arrange(desc(births))










## ----echo=FALSE---------------------------------------------------------------
package_versions <- sessioninfo::package_info(c(needed_CRAN_pkgs)) |> 
  as_tibble() |> 
  filter(attached == TRUE | package %in% c("bookdown")) |> 
  select(package, version = ondiskversion)
readr::write_rds(package_versions, "rds/package_versions.rds")


## ----echo=FALSE, results='asis'-----------------------------------------------
if(!is_latex_output()){
  cat("# (APPENDIX) Appendix {-}")
} else {
  cat("\\appendix")
}

