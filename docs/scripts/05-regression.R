## ----message=FALSE------------------------------------------------------------
library(tidyverse)
library(moderndive)






## -----------------------------------------------------------------------------
UN_data_ch5 <- un_member_states_2024 |>
  select(iso, 
         life_exp = life_expectancy_2022, 
         fert_rate = fertility_rate_2022, 
         obes_rate = obesity_rate_2016)|>
  na.omit()


## ----include=FALSE------------------------------------------------------------
n_demo_ch5 <- nrow(UN_data_ch5)


## -----------------------------------------------------------------------------
glimpse(UN_data_ch5)


## ----echo=FALSE---------------------------------------------------------------
sample_size <- 5


## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch5 |>
##   slice_sample(n = 5)




## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch5 |>
##   summarize(mean_life_exp = mean(life_exp),
##             mean_fert_rate = mean(fert_rate),
##             median_life_exp = median(life_exp),
##             median_fert_rate = median(fert_rate))


## ----echo=FALSE---------------------------------------------------------------
UN_data_ch5 |>
  summarize(mean_life_exp = mean(life_exp), 
            mean_fert_rate = mean(fert_rate),
            median_life_exp = median(life_exp), 
            median_fert_rate = median(fert_rate)) |> 
  kbl() |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 10, 16),
    latex_options = c("hold_position")
  )


## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch5 |>
##   select(fert_rate, life_exp) |>
##   tidy_summary()


## ----echo=FALSE---------------------------------------------------------------
UN_data_ch5 |> 
  select(fert_rate, life_exp) |> 
  tidy_summary() |> 
  kbl() |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 10, 16),
    latex_options = c("hold_position")
  )


## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch5 |>
##   tidy_summary(columns = c(fert_rate, life_exp))


## ----echo=FALSE---------------------------------------------------------------
UN_data_ch5 |> 
  tidy_summary(columns = c(fert_rate, life_exp)) |> 
  kbl() |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 10, 16),
    latex_options = c("hold_position")
  )


## ----echo=FALSE---------------------------------------------------------------
summary_df <- UN_data_ch5 |> 
  select(fert_rate, life_exp) |> 
  tidy_summary() |> 
  filter(type == "numeric")
fert_summary_df <- summary_df  |> 
  filter(column == "fert_rate")
life_summary_df <- summary_df  |>
  filter(column == "life_exp")




## -----------------------------------------------------------------------------
UN_data_ch5 |> 
  get_correlation(formula = fert_rate ~ life_exp)


## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch5 |>
##   summarize(correlation = cor(fert_rate, life_exp))




## ----numxplot1, fig.cap="Scatterplot of relationship of life expectancy and fertility rate", fig.height=ifelse(knitr::is_latex_output(), 4.5, 7)----
ggplot(UN_data_ch5, 
       aes(x = life_exp, y = fert_rate)) +
  geom_point(alpha = 0.1) +
  labs(x = "Life Expectancy", y = "Fertility Rate")


## ----numxplot3, fig.cap="Scatterplot of life expectancy and fertility rate with regression line.", message=FALSE, fig.height=ifelse(knitr::is_latex_output(), 4, 7)----
ggplot(UN_data_ch5, aes(x = life_exp, y = fert_rate)) +
  geom_point(alpha = 0.1) +
  labs(x = "Life Expectancy", 
    y = "Fertility Rate",
    title = "Relationship of life expectancy and fertility rate") +
  geom_smooth(method = "lm", se = FALSE)






## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## demographics_model <- lm(fert_rate ~ life_exp,
##                          data = UN_data_ch5)
## # Get regression coefficients
## coef(demographics_model)



## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## demographics_model <- lm(fert_rate ~ life_exp,
##                          data = UN_data_ch5)
## # Get regression coefficients:
## coef(demographics_model)










## ----eval=FALSE---------------------------------------------------------------
## regression_points <- get_regression_points(demographics_model)
## regression_points










## ----message=FALSE------------------------------------------------------------
gapminder2022 <- un_member_states_2024 |>
  select(country, life_exp = life_expectancy_2022, continent, gdp_per_capita) |> 
  na.omit()




## -----------------------------------------------------------------------------
glimpse(gapminder2022)


## ----eval=FALSE---------------------------------------------------------------
## gapminder2022 |> sample_n(size = 3)



## ----eval=FALSE---------------------------------------------------------------
## gapminder2022 |> select(life_exp, continent) |> tidy_summary()


## ----echo=FALSE---------------------------------------------------------------
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
    latex_options = c("hold_position")
  )


## ----include=FALSE------------------------------------------------------------
# For discussion in bullet points below
gapminder2022 |> count(continent)




## ----lifeexp2022hist, echo=TRUE, fig.cap="Histogram of life expectancy in 2022.", fig.height=ifelse(knitr::is_latex_output(), 5.2, 7)----
ggplot(gapminder2022, aes(x = life_exp)) +
  geom_histogram(binwidth = 5, color = "white") +
  labs(x = "Life expectancy", 
       y = "Number of countries",
       title = "Histogram of distribution of worldwide life expectancies")


## ----eval=FALSE---------------------------------------------------------------
## ggplot(gapminder2022, aes(x = life_exp)) +
##   geom_histogram(binwidth = 5, color = "white") +
##   labs(x = "Life expectancy",
##        y = "Number of countries",
##        title = "Histogram of distribution of worldwide life expectancies") +
##   facet_wrap(~ continent, nrow = 2)




## ----catxplot1, fig.cap="Life expectancy in 2022 by continent (boxplot).", fig.height=ifelse(knitr::is_latex_output(), 2.5, 7)----
ggplot(gapminder2022, aes(x = continent, y = life_exp)) +
  geom_boxplot() +
  labs(x = "Continent", 
       y = "Life expectancy",
       title = "Life expectancy by continent")


## ----eval=TRUE, results='hide'------------------------------------------------
life_exp_by_continent <- gapminder2022 |>
  group_by(continent) |>
  summarize(median = median(life_exp), mean = mean(life_exp))
life_exp_by_continent











## -----------------------------------------------------------------------------
life_exp_model <- lm(life_exp ~ continent, data = gapminder2022)
coef(life_exp_model)






## ----eval=FALSE---------------------------------------------------------------
## regression_points <- get_regression_points(life_exp_model, ID = "country")
## regression_points













## -----------------------------------------------------------------------------
ggplot(data = un_member_states_2024, 
       aes(x = hdi_2022, y = life_expectancy_2022)) +
  geom_point() +
  labs(x = "Human Development Index (HDI)", y = "Life Expectancy")


## -----------------------------------------------------------------------------
ggplot(data = un_member_states_2024, 
       aes(x = hdi_2022, y = fertility_rate_2022)) +
  geom_point() +
  labs(x = "Human Development Index (HDI)", y = "Fertility Rate")


## -----------------------------------------------------------------------------
un_member_states_2024 |> 
  get_correlation(life_expectancy_2022 ~ hdi_2022, na.rm = TRUE)


## -----------------------------------------------------------------------------
un_member_states_2024 |> 
  get_correlation(fertility_rate_2022 ~ hdi_2022, na.rm = TRUE)




## ----include=FALSE------------------------------------------------------------
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


## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## demographics_model <- lm(fert_rate ~ life_exp, data = UN_data_ch5)
## 
## # Get regression points:
## regression_points <- get_regression_points(demographics_model)
## regression_points
## 
## # Compute sum of squared residuals
## regression_points |>
##   mutate(squared_residuals = residual^2) |>
##   summarize(sum_of_squared_residuals = sum(squared_residuals))


## ----echo=FALSE---------------------------------------------------------------
# Fit regression model:
demographics_model <- lm(fert_rate ~ life_exp, data = UN_data_ch5)

# Get regression points:
regression_points <- get_regression_points(demographics_model)
regression_points

# Compute sum of squared residuals
SSR <- regression_points |>
  mutate(squared_residuals = residual^2) |>
  summarize(sum_of_squared_residuals = sum(squared_residuals)) |> 
  pull()
SSR








## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## demographics_model <- lm(formula = fert_rate ~ life_exp, data = UN_data_ch5)
## # Get regression table:
## get_regression_table(demographics_model)




## ----eval=FALSE---------------------------------------------------------------
## library(broom)
## library(janitor)
## demographics_model |>
##   tidy(conf.int = TRUE) |>
##   mutate_if(is.numeric, round, digits = 3) |>
##   clean_names() |>
##   rename(lower_ci = conf_low, upper_ci = conf_high)



## ----eval=FALSE---------------------------------------------------------------
## library(broom)
## library(janitor)
## demographics_model |>
##   augment() |>
##   mutate_if(is.numeric, round, digits = 3) |>
##   clean_names() |>
##   select(-c("std_resid", "hat", "sigma", "cooksd", "std_resid"))

