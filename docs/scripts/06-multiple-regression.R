## ----eval=FALSE---------------------------------------------------------------
## library(tidyverse)
## library(moderndive)
## library(ISLR2)


## ----echo=FALSE, message=FALSE, purl=TRUE-------------------------------------
library(tidyverse)
library(moderndive)
library(gapminder)




## -----------------------------------------------------------------------------
UN_data_ch6 <- un_member_states_2024 |>
  select(country, 
         life_expectancy_2022, 
         fertility_rate_2022, 
         income_group_2024)|>
  na.omit()|>
  rename(life_exp = life_expectancy_2022, 
         fert_rate = fertility_rate_2022, 
         income = income_group_2024)|>
  mutate(income = factor(income, 
                         levels = c("Low income", "Lower middle income", 
                                    "Upper middle income", "High income")))


## -----------------------------------------------------------------------------
glimpse(UN_data_ch6)




## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch6 |> sample_n(size = 10)




## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch6 |>
##   select(life_exp, fert_rate, income) |>
##   tidy_summary()


## ----echo=FALSE---------------------------------------------------------------
UN_data_ch6 |> 
  select(life_exp, fert_rate, income) |> 
  tidy_summary() |> 
  kbl() |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 8, 16),
    latex_options = c("hold_position")
  ) 


## -----------------------------------------------------------------------------
UN_data_ch6 |> 
  get_correlation(formula = fert_rate ~ life_exp)


## ----eval=FALSE---------------------------------------------------------------
## ggplot(UN_data_ch6, aes(x = life_exp, y = fert_rate, color = income)) +
##   geom_point() +
##   labs(x = "Life Expectancy", y = "Fertility Rate", color = "Income group") +
##   geom_smooth(method = "lm", se = FALSE)




## ----eval=FALSE---------------------------------------------------------------
## one_factor_model <- lm(fert_rate ~ income, data = UN_data_ch6)
## coef(one_factor_model)




## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## model_int <- lm(fert_rate ~ life_exp * income, data = UN_data_ch6)
## 
## # Get the coefficients of the model
## coef(model_int)




## ----eval=FALSE---------------------------------------------------------------
## ggplot(UN_data_ch6, aes(x = life_exp, y = fert_rate, color = income)) +
##   geom_point() +
##   labs(x = "Life expectancy", y = "Fertility rate", color = "Income group") +
##   geom_parallel_slopes(se = FALSE)




## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## model_no_int <- lm(fert_rate ~ life_exp + income, data = UN_data_ch6)
## 
## # Get the coefficients of the model
## coef(model_no_int)












## ----eval=FALSE---------------------------------------------------------------
## regression_points <- get_regression_points(model_int)
## regression_points








## ----message=FALSE------------------------------------------------------------
library(ISLR2)
credit_ch6 <- Credit |> as_tibble() |> 
  select(debt = Balance, credit_limit = Limit, 
         income = Income, credit_rating = Rating, age = Age)


## -----------------------------------------------------------------------------
glimpse(credit_ch6)




## ----eval=FALSE---------------------------------------------------------------
## credit_ch6 |> sample_n(size = 5)




## -----------------------------------------------------------------------------
credit_ch6 |> 
  select(debt, credit_limit, income) |> 
  tidy_summary()


## ----eval=FALSE---------------------------------------------------------------
## ggplot(credit_ch6, aes(x = credit_limit, y = debt)) +
##   geom_point() +
##   labs(x = "Credit limit (in $)", y = "Credit card debt (in $)",
##        title = "Debt and credit limit") +
##   geom_smooth(method = "lm", se = FALSE)
## 
## ggplot(credit_ch6, aes(x = income, y = debt)) +
##   geom_point() +
##   labs(x = "Income (in $1000)", y = "Credit card debt (in $)",
##        title = "Debt and income") +
##   geom_smooth(method = "lm", se = FALSE)




## ----eval=FALSE---------------------------------------------------------------
## credit_ch6 |> get_correlation(debt ~ credit_limit)
## credit_ch6 |> get_correlation(debt ~ income)


## ----eval=FALSE---------------------------------------------------------------
## credit_ch6 |>
##   select(debt, credit_limit, income) |>
##   cor()




## ----eval=FALSE---------------------------------------------------------------
## credit_ch6 |> get_correlation(debt ~ 1000 * income)


## ----echo=FALSE---------------------------------------------------------------
credit_ch6 |> 
  get_correlation(debt ~ 1000 * income)|> 
  kbl()|>
  kable_styling(
    font_size = ifelse(is_latex_output(), 10, 16),
    latex_options = c("hold_position")
  )












## ----eval=FALSE---------------------------------------------------------------
## debt_model <- lm(debt ~ credit_limit + income, data = credit_ch6)
## coef(debt_model)




## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## simple_model <- lm(debt ~ income, data = credit_ch6)
## 
## # Get the coefficients of the model
## coef(simple_model)








## ----eval=FALSE---------------------------------------------------------------
## get_regression_points(debt_model)

