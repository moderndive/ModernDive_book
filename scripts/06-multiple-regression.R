## ----eval=FALSE---------------------------------------------------------------
## library(tidyverse)
## library(moderndive)
## library(skimr)
## library(ISLR)

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
library(gapminder)




## -----------------------------------------------------------------------------
evals_ch6 <- evals %>%
  select(ID, score, age, gender)


## -----------------------------------------------------------------------------
glimpse(evals_ch6)




## ----eval=FALSE---------------------------------------------------------------
## evals_ch6 %>% sample_n(size = 5)



## ----eval=FALSE---------------------------------------------------------------
## evals_ch6 %>% select(score, age, gender) %>% skim()


## -----------------------------------------------------------------------------
evals_ch6 %>% 
  get_correlation(formula = score ~ age)


## ----eval=FALSE---------------------------------------------------------------
## ggplot(evals_ch6, aes(x = age, y = score, color = gender)) +
##   geom_point() +
##   labs(x = "Age", y = "Teaching Score", color = "Gender") +
##   geom_smooth(method = "lm", se = FALSE)








## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## score_model_interaction <- lm(score ~ age * gender, data = evals_ch6)
## 
## # Get regression table:
## get_regression_table(score_model_interaction)





## ----eval=FALSE---------------------------------------------------------------
## ggplot(evals_ch6, aes(x = age, y = score, color = gender)) +
##   geom_point() +
##   labs(x = "Age", y = "Teaching Score", color = "Gender") +
##   geom_parallel_slopes(se = FALSE)




## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## score_model_parallel_slopes <- lm(score ~ age + gender, data = evals_ch6)
## # Get regression table:
## get_regression_table(score_model_parallel_slopes)



## ----echo=FALSE---------------------------------------------------------------
age_coef <- get_regression_table(score_model_parallel_slopes) %>%
  filter(term == "age") %>%
  pull(estimate)










## ----eval=FALSE---------------------------------------------------------------
## regression_points <- get_regression_points(score_model_interaction)
## regression_points







## ----message=FALSE------------------------------------------------------------
library(ISLR)
credit_ch6 <- Credit %>% as_tibble() %>% 
  select(ID, debt = Balance, credit_limit = Limit, 
         income = Income, credit_rating = Rating, age = Age)


## -----------------------------------------------------------------------------
glimpse(credit_ch6)




## ----eval=FALSE---------------------------------------------------------------
## credit_ch6 %>% sample_n(size = 5)



## ----eval=FALSE---------------------------------------------------------------
## credit_ch6 %>% select(debt, credit_limit, income) %>% skim()


## ----eval=FALSE---------------------------------------------------------------
## credit_ch6 %>% get_correlation(debt ~ credit_limit)
## credit_ch6 %>% get_correlation(debt ~ income)


## ----eval=FALSE---------------------------------------------------------------
## credit_ch6 %>%
##   select(debt, credit_limit, income) %>%
##   cor()



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
## # Fit regression model:
## debt_model <- lm(debt ~ credit_limit + income, data = credit_ch6)
## # Get regression table:
## get_regression_table(debt_model)







## ----eval=FALSE---------------------------------------------------------------
## get_regression_points(debt_model)





## ----eval=FALSE---------------------------------------------------------------
## # Interaction model
## ggplot(MA_schools,
##        aes(x = perc_disadvan, y = average_sat_math, color = size)) +
##   geom_point(alpha = 0.25) +
##   geom_smooth(method = "lm", se = FALSE) +
##   labs(x = "Percent economically disadvantaged", y = "Math SAT Score",
##        color = "School size", title = "Interaction model")


## ----eval=FALSE---------------------------------------------------------------
## # Parallel slopes model
## ggplot(MA_schools,
##        aes(x = perc_disadvan, y = average_sat_math, color = size)) +
##   geom_point(alpha = 0.25) +
##   geom_parallel_slopes(se = FALSE) +
##   labs(x = "Percent economically disadvantaged", y = "Math SAT Score",
##        color = "School size", title = "Parallel slopes model")



## ----eval=FALSE---------------------------------------------------------------
## model_2_interaction <- lm(average_sat_math ~ perc_disadvan * size,
##                           data = MA_schools)
## get_regression_table(model_2_interaction)


## ----eval=FALSE---------------------------------------------------------------
## model_2_parallel_slopes <- lm(average_sat_math ~ perc_disadvan + size,
##                               data = MA_schools)
## get_regression_table(model_2_parallel_slopes)



## -----------------------------------------------------------------------------
get_regression_points(model_2_interaction) 


## -----------------------------------------------------------------------------
get_regression_points(model_2_interaction) %>% 
  summarize(var_y = var(average_sat_math), 
                      var_y_hat = var(average_sat_math_hat), 
                      var_residual = var(residual))


## ----model2-r-squared, echo=FALSE---------------------------------------------
variances_interaction <- get_regression_points(model_2_interaction) %>% 
  summarize(var_y = var(average_sat_math), 
                      var_y_hat = var(average_sat_math_hat), 
                      var_residual = var(residual)) %>% 
  mutate(model = "Interaction", r_squared = var_y_hat/var_y)
variances_parallel_slopes <- get_regression_points(model_2_parallel_slopes) %>% 
  summarize(var_y = var(average_sat_math), 
                      var_y_hat = var(average_sat_math_hat), 
                      var_residual = var(residual)) %>% 
  mutate(model = "Parallel slopes", r_squared = var_y_hat/var_y)

bind_rows(
  variances_interaction,
  variances_parallel_slopes
) %>% 
  select(model, var_y, var_y_hat, var_residual, r_squared) %>% 
  knitr::kable(
    digits = 3,
    caption = "Comparing variances from interaction and parallel slopes models for MA school data", 
    booktabs = TRUE,
    linesep = ""
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))


## ----model1-r-squared, echo=FALSE---------------------------------------------
variances_interaction <- get_regression_points(score_model_interaction) %>% 
  summarize(var_y = var(score), var_y_hat = var(score_hat), var_residual = var(residual)) %>% 
  mutate(model = "Interaction", r_squared = var_y_hat/var_y)
variances_parallel_slopes <- get_regression_points(score_model_parallel_slopes) %>% 
  summarize(var_y = var(score), var_y_hat = var(score_hat), var_residual = var(residual)) %>% 
  mutate(model = "Parallel slopes", r_squared = var_y_hat/var_y)

bind_rows(
  variances_interaction,
  variances_parallel_slopes
) %>% 
  select(model, var_y, var_y_hat, var_residual, r_squared) %>% 
  knitr::kable(
    digits = 3,
    caption = "Comparing variances from interaction and parallel slopes models for UT Austin data", 
    booktabs = TRUE,
    linesep = ""
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))


## -----------------------------------------------------------------------------
# R-squared for interaction model:
get_regression_summaries(model_2_interaction)
# R-squared for parallel slopes model:
get_regression_summaries(model_2_parallel_slopes)


## ----eval=FALSE---------------------------------------------------------------
## credit_ch6 %>% select(debt, income) %>%
##   mutate(income = income * 1000) %>%
##   cor()

