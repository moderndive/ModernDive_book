## ----regression-load-packages, message=FALSE----------------------------------
library(tidyverse)
library(moderndive)






## ----regression-create-UN_data_ch5--------------------------------------------
UN_data_ch5 <- un_member_states_2024 |>
  select(iso, 
         life_exp = life_expectancy_2022, 
         fert_rate = fertility_rate_2022, 
         obes_rate = obesity_rate_2016)|>
  na.omit()


## ----regression-create-n_demo_ch5, include=FALSE------------------------------
n_demo_ch5 <- nrow(UN_data_ch5)


## ----regression-glimpse-UN_data_ch5-------------------------------------------
glimpse(UN_data_ch5)


## ----regression-create-sample_size, echo=FALSE--------------------------------
sample_size <- 5


## ----regression-sample-rows, eval=FALSE---------------------------------------
# UN_data_ch5 |>
#   slice_sample(n = 5)




## ----regression-compute-mean, eval=FALSE--------------------------------------
# UN_data_ch5 |>
#   summarize(mean_life_exp = mean(life_exp),
#             mean_fert_rate = mean(fert_rate),
#             median_life_exp = median(life_exp),
#             median_fert_rate = median(fert_rate))


## ----regression-compute-mean-sized, echo=FALSE--------------------------------
UN_data_ch5 |>
  summarize(mean_life_exp = mean(life_exp), 
            mean_fert_rate = mean(fert_rate),
            median_life_exp = median(life_exp), 
            median_fert_rate = median(fert_rate)) |> 
  kbl() |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 10, 16),
    latex_options = c("HOLD_position")
  )


## ----regression-select-vars, eval=FALSE---------------------------------------
# UN_data_ch5 |>
#   select(fert_rate, life_exp) |>
#   tidy_summary()


## ----regression-select-vars-sized, echo=FALSE---------------------------------
UN_data_ch5 |> 
  select(fert_rate, life_exp) |> 
  tidy_summary() |> 
  kbl() |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 10, 16),
    latex_options = c("HOLD_position")
  )


## ----regression-alt, eval=FALSE-----------------------------------------------
# UN_data_ch5 |>
#   tidy_summary(columns = c(fert_rate, life_exp))


## ----regression-conditional, echo=FALSE---------------------------------------
UN_data_ch5 |> 
  tidy_summary(columns = c(fert_rate, life_exp)) |> 
  kbl() |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 10, 16),
    latex_options = c("HOLD_position")
  )


## ----regression-create-summary_df, echo=FALSE---------------------------------
summary_df <- UN_data_ch5 |> 
  select(fert_rate, life_exp) |> 
  tidy_summary() |> 
  filter(type == "numeric")
fert_summary_df <- summary_df  |> 
  filter(column == "fert_rate")
life_summary_df <- summary_df  |>
  filter(column == "life_exp")




## ----regression-demo-code-----------------------------------------------------
UN_data_ch5 |> 
  get_correlation(formula = fert_rate ~ life_exp)


## ----regression-summarize, eval=FALSE-----------------------------------------
# UN_data_ch5 |>
#   summarize(correlation = cor(fert_rate, life_exp))




## ----numxplot1, fig.cap="Scatterplot of relationship of life expectancy and fertility rate.", fig.height=ifelse(knitr::is_latex_output(), 4.5, 5)----
ggplot(UN_data_ch5, 
       aes(x = life_exp, y = fert_rate)) +
  geom_point(alpha = 0.1) +
  labs(x = "Life Expectancy", y = "Fertility Rate")


## ----numxplot3, fig.cap="Scatterplot of life expectancy and fertility rate with regression line.", message=FALSE, fig.height=ifelse(knitr::is_latex_output(), 4, 5)----
ggplot(UN_data_ch5, aes(x = life_exp, y = fert_rate)) +
  geom_point(alpha = 0.1) +
  labs(x = "Life Expectancy", 
    y = "Fertility Rate",
    title = "Relationship of life expectancy and fertility rate") +
  geom_smooth(method = "lm", se = FALSE)






## ----regression-lm-fertility, eval=FALSE--------------------------------------
# # Fit regression model:
# demographics_model <- lm(fert_rate ~ life_exp, data = UN_data_ch5)
# # Get regression coefficients
# coef(demographics_model)



## ----regression-lm-fertility-alt2, eval=FALSE---------------------------------
# # Fit regression model:
# demographics_model <- lm(fert_rate ~ life_exp, data = UN_data_ch5)
# # Get regression coefficients:
# coef(demographics_model)










## ----regression-reg-points, eval=FALSE----------------------------------------
# regression_points <- get_regression_points(demographics_model)
# regression_points










## ----regression-create-gapminder2022, message=FALSE---------------------------
gapminder2022 <- un_member_states_2024 |>
  select(country, life_exp = life_expectancy_2022, continent, gdp_per_capita) |> 
  na.omit()




## ----regression-glimpse-gapminder2022-----------------------------------------
glimpse(gapminder2022)


## ----regression-alt2, eval=FALSE----------------------------------------------
# gapminder2022 |> sample_n(size = 3)



## ----regression-select-vars-alt, eval=FALSE-----------------------------------
# gapminder2022 |> select(life_exp, continent) |> tidy_summary()


## ----lifeexp-cont, echo=FALSE-------------------------------------------------
gapminder2022 |>
  select(life_exp, continent) |>
  tidy_summary() |> 
  kbl(
    caption = "Summary of life expectancy and continent variables",
    booktabs = TRUE,
    linesep = ""
  ) |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 9, 16),
    latex_options = c("HOLD_position")
  )


## ----regression-alt2-dup1, include=FALSE--------------------------------------
# For discussion in bullet points below
gapminder2022 |> count(continent)




## ----lifeexp2022hist, echo=TRUE, fig.cap="Histogram of life expectancy in 2022.", fig.height=ifelse(knitr::is_latex_output(), 3, 4)----
ggplot(gapminder2022, aes(x = life_exp)) +
  geom_histogram(binwidth = 5, color = "white") +
  labs(x = "Life expectancy", 
       y = "Number of countries",
       title = "Histogram of distribution of worldwide life expectancies")


## ----regression-facet-hist-lifeexp, eval=FALSE--------------------------------
# ggplot(gapminder2022, aes(x = life_exp)) +
#   geom_histogram(binwidth = 5, color = "white") +
#   labs(x = "Life expectancy",
#        y = "Number of countries",
#        title = "Histogram of distribution of worldwide life expectancies") +
#   facet_wrap(~ continent, nrow = 2)




## ----catxplot1, fig.cap="Life expectancy in 2022 by continent (boxplot).", fig.height=ifelse(knitr::is_latex_output(), 2.5, 4)----
ggplot(gapminder2022, aes(x = continent, y = life_exp)) +
  geom_boxplot() +
  labs(x = "Continent", y = "Life expectancy",
       title = "Life expectancy by continent")


## ----regression-grouped-summary, eval=TRUE, results='hide'--------------------
life_exp_by_continent <- gapminder2022 |>
  group_by(continent) |>
  summarize(median = median(life_exp), mean = mean(life_exp))
life_exp_by_continent











## ----regression-fit-lm--------------------------------------------------------
life_exp_model <- lm(life_exp ~ continent, data = gapminder2022)
coef(life_exp_model)






## ----regression-reg-points-alt, eval=FALSE------------------------------------
# get_regression_points(life_exp_model, ID = "country")













## ----regression-scatter-lifeexp, fig.height=1.5-------------------------------
ggplot(data = un_member_states_2024, 
       aes(x = hdi_2022, y = life_expectancy_2022)) +
  geom_point() +
  labs(x = "Human Development Index (HDI)", y = "Life Expectancy")


## ----regression-scatter, fig.height=1.5---------------------------------------
ggplot(data = un_member_states_2024, 
       aes(x = hdi_2022, y = fertility_rate_2022)) +
  geom_point() +
  labs(x = "Human Development Index (HDI)", y = "Fertility Rate")


## ----regression-alt2-dup2-----------------------------------------------------
un_member_states_2024 |> 
  get_correlation(life_expectancy_2022 ~ hdi_2022, na.rm = TRUE)


## ----regression-alt2-dup3-----------------------------------------------------
un_member_states_2024 |> 
  get_correlation(fertility_rate_2022 ~ hdi_2022, na.rm = TRUE)




## ----regression-create-four_countries, include=FALSE--------------------------
four_countries <- c("BIH", "TCD", "IND", "SLB")
country_lookup_table <- UN_data_ch5 |>
  filter(iso %in% four_countries) |>
  select(iso, life_exp, fert_rate)
bosnia <- country_lookup_table |> 
  filter(iso == "BIH") |> 
  mutate(residual = resid_bosnia,
         fert_rate_hat = y_bosnia_hat)
chad <- country_lookup_table |>
  filter(iso == "TCD") |> 
  mutate(residual = resid_chad,
         fert_rate_hat = y_chad_hat)
india <- country_lookup_table |>
  filter(iso == "IND") |> 
  mutate(residual = resid_india,
         fert_rate_hat = y_india_hat)
solomon <- country_lookup_table |>
  filter(iso == "SLB") |> 
  mutate(residual = resid_sol,
         fert_rate_hat = y_sol_hat)


## ----regression-create-demographics_model, eval=FALSE-------------------------
# # Fit regression model and regression points
# demographics_model <- lm(fert_rate ~ life_exp, data = UN_data_ch5)
# regression_points <- get_regression_points(demographics_model)
# 
# # Compute sum of squared residuals
# regression_points |>
#   mutate(squared_residuals = residual^2) |>
#   summarize(sum_of_squared_residuals = sum(squared_residuals))


## ----regression-create-demographics_model-alt, echo=FALSE---------------------
# Fit regression model:
demographics_model <- lm(fert_rate ~ life_exp, data = UN_data_ch5)

# Get regression points:
regression_points <- get_regression_points(demographics_model)

# Compute sum of squared residuals
SSR <- regression_points |>
  mutate(squared_residuals = residual^2) |>
  summarize(sum_of_squared_residuals = sum(squared_residuals)) |> 
  pull()
SSR








## ----regression-load-packages-alt, eval=FALSE---------------------------------
# library(broom)
# library(janitor)
# demographics_model |>
#   augment() |>
#   mutate_if(is.numeric, round, digits = 3) |>
#   clean_names() |>
#   select(-c("std_resid", "hat", "sigma", "cooksd", "std_resid"))

