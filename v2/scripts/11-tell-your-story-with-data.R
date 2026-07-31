## ----tell-your-story-with-data-load-packages, message=FALSE-------------------
library(tidyverse)
library(moderndive)
library(fivethirtyeight)
library(infer)




## ----tell-your-story-with-data-glimpse-house_prices, eval=FALSE---------------
# View(house_prices)
# glimpse(house_prices)



## ----tell-your-story-with-data-mean-and-sd, eval=FALSE------------------------
# gain_summary <- flights |>
#   summarize(min = min(gain, na.rm = TRUE),
#             q1 = quantile(gain, 0.25, na.rm = TRUE),
#             median = quantile(gain, 0.5, na.rm = TRUE),
#             q3 = quantile(gain, 0.75, na.rm = TRUE),
#             max = max(gain, na.rm = TRUE),
#             mean = mean(gain, na.rm = TRUE),
#             sd = sd(gain, na.rm = TRUE),
#             missing = sum(is.na(gain)))


## ----tell-your-story-with-data-select-vars, eval=FALSE------------------------
# house_prices |>
#   select(price, sqft_living, condition) |>
#   tidy_summary()


## ----tell-your-story-with-data-select-vars-sized, echo=FALSE------------------
house_prices |> 
  select(price, sqft_living, condition) |> 
  tidy_summary() |> 
  kbl(caption = "(ref:some-house-price-vars)") |> 
  kable_styling(
    font_size = ifelse(is_latex_output(), 7.8, 16),
    latex_options = c("HOLD_position")
  )


## ----tell-your-story-with-data-hist-price, eval=FALSE, message=FALSE----------
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




## ----tell-your-story-with-data-conditional-text, echo=FALSE, results="asis"----
if(!is_latex_output()) 
  cat("If you are unfamiliar with such transformations, we highly recommend you read [Appendix A online](https://moderndive.com/v2/appendixa) on logarithmic (log) transformations.")


## ----tell-your-story-with-data-create-house_prices----------------------------
house_prices <- house_prices |>
  mutate(
    log10_price = log10(price),
    log10_size = log10(sqft_living)
  )


## ----tell-your-story-with-data-select-vars-alt2-------------------------------
house_prices |> 
  select(price, log10_price, sqft_living, log10_size)


## ----tell-your-story-with-data-hist-white-border, eval=FALSE------------------
# # Before log10 transformation:
# ggplot(house_prices, aes(x = price)) +
#   geom_histogram(color = "white") +
#   labs(x = "price (USD)", title = "House price: Before")
# 
# # After log10 transformation:
# ggplot(house_prices, aes(x = log10_price)) +
#   geom_histogram(color = "white") +
#   labs(x = "log10 price (USD)", title = "House price: After")




## ----tell-your-story-with-data-hist-white-border-v2, eval=FALSE---------------
# # Before log10 transformation:
# ggplot(house_prices, aes(x = sqft_living)) +
#   geom_histogram(color = "white") +
#   labs(x = "living space (square feet)", title = "House size: Before")
# 
# # After log10 transformation:
# ggplot(house_prices, aes(x = log10_size)) +
#   geom_histogram(color = "white") +
#   labs(x = "log10 living space (square feet)", title = "House size: After")



## ----tell-your-story-with-data-scatter-price, eval=FALSE----------------------
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



## ----tell-your-story-with-data-facet-scatter-price, eval=FALSE----------------
# ggplot(house_prices,
#        aes(x = log10_size, y = log10_price, col = condition)) +
#   geom_point(alpha = 0.4) +
#   geom_smooth(method = "lm", se = FALSE) +
#   labs(y = "log10 price",
#        x = "log10 size",
#        title = "House prices in Seattle") +
#   facet_wrap(~ condition)


## ----tell-your-story-with-data-v16--------------------------------------------
house_prices |> 
  count(condition)




## ----tell-your-story-with-data-lm-price, eval=FALSE---------------------------
# price_interaction <- lm(log10_price ~ log10_size * condition, data = house_prices)
# get_regression_table(price_interaction)









## ----tell-your-story-with-data-v20--------------------------------------------
2.45 + 1 * log10(1900)


## ----tell-your-story-with-data-conditional-text-dup1, echo=FALSE, results="asis"----
if(!is_latex_output()) 
  cat("This described in [Appendix A online](https://moderndive.com/v2/appendixa).")


## ----tell-your-story-with-data-v22--------------------------------------------
10^(2.45 + 1 * log10(1900))


## ----tell-your-story-with-data-assign-price_interaction, eval=FALSE-----------
# price_interaction <- lm(log10_price ~ log10_size * condition, data = house_prices)
# get_regression_table(price_interaction)



## ----tell-your-story-with-data-specify----------------------------------------
observed_fit_coefficients <- house_prices |>
  specify(
    log10_price ~ log10_size * condition
    ) |>
  fit()
observed_fit_coefficients


## ----tell-your-story-with-data-null-dist, eval=FALSE--------------------------
# null_distribution_housing <- house_prices |>
#   specify(
#     log10_price ~ log10_size * condition
#     ) |>
#   hypothesize(null = "independence") |>
#   generate(reps = 1000, type = "permute") |>
#   fit()


## ----tell-your-story-with-data-null-dist-sized, echo=FALSE--------------------
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


## ----tell-your-story-with-data-viz-pvalue, eval=FALSE-------------------------
# visualize(null_distribution_housing) +
#   shade_p_value(obs_stat = observed_fit_coefficients,
#                 direction = "two-sided")


## ----tell-your-story-with-data-viz-pvalue-alt, echo=FALSE, message=FALSE------
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


## ----tell-your-story-with-data-show-null-housing-shaded, echo=FALSE, out.width="90%"----
if(is_latex_output())
  knitr::include_graphics("images/null_housing_shaded.png")


## ----tell-your-story-with-data-conditional, echo=FALSE, fig.height=12---------
if(is_html_output())
  null_housing_shaded


## ----tell-your-story-with-data-v31--------------------------------------------
null_distribution_housing |>
  get_p_value(obs_stat = observed_fit_coefficients, direction = "two-sided")






## ----tell-your-story-with-data-glimpse-US_births_1994_20----------------------
glimpse(US_births_1994_2003)


## ----tell-your-story-with-data-create-US_births_1999--------------------------
US_births_1999 <- US_births_1994_2003 |>
  filter(year == 1999)


## ----us-births, fig.cap="Number of births in the US in 1999.", fig.height=ifelse(knitr::is_latex_output(), 6.4, 7)----
ggplot(US_births_1999, aes(x = date, y = births)) +
  geom_line() +
  labs(x = "Date", 
       y = "Number of births", 
       title = "US Births in 1999")


## ----tell-your-story-with-data-arrange-desc-----------------------------------
US_births_1999 |> 
  arrange(desc(births))










## ----tell-your-story-with-data-create-package_versions, echo=FALSE------------
package_versions <- sessioninfo::package_info(c(needed_CRAN_pkgs)) |> 
  as_tibble() |> 
  filter(attached == TRUE | package %in% c("bookdown")) |> 
  select(package, version = ondiskversion)
readr::write_rds(package_versions, "rds/package_versions.rds")


## ----tell-your-story-with-data-conditional-text-v2, echo=FALSE, results='asis'----
if(!is_latex_output()){
  cat("# (APPENDIX) Appendix {-}")
} else {
  cat("\\appendix")
}

