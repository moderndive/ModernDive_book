## ---- echo=FALSE---------------------------------------------------------
library(tidyr)

## ------------------------------------------------------------------------
library(ggplot2)
library(dplyr)
library(moderndive)

load(url("http://www.openintro.org/stat/data/evals.RData"))
evals <- evals %>%
  select(score, ethnicity, gender, language, age, bty_avg, rank)

## ----model1, echo=FALSE, warning=FALSE, fig.cap="Model 1: no interaction effect included"----
coeff <- lm(score ~ age + gender, data = evals) %>% coef() %>% as.numeric()
slopes <- evals %>%
  group_by(gender) %>%
  summarise(min = min(age), max = max(age)) %>%
  mutate(intercept = coeff[1]) %>%
  mutate(intercept = ifelse(gender == "male", intercept + coeff[3], intercept)) %>%
  gather(point, age, -c(gender, intercept)) %>%
  mutate(y_hat = intercept + age * coeff[2])
  
  ggplot(evals, aes(x = age, y = score, col = gender)) +
  geom_jitter() +
  labs(x = "Age", y = "Teaching Score", color = "Gender") +
  geom_line(data = slopes, aes(y = y_hat), size = 1)

## ----model2, echo=FALSE, warning=FALSE, fig.cap="Model 2: interaction effect included"----
ggplot(evals, aes(x = age, y = score, col = gender)) +
  geom_jitter() +
  labs(x = "Age", y = "Teaching Score", color = "Gender") +
  geom_smooth(method = "lm", se = FALSE)

## ---- eval=FALSE---------------------------------------------------------
## score_model_2 <- lm(score ~ age + gender, data = evals)
## get_regression_table(score_model_2)

## ---- echo=FALSE---------------------------------------------------------
score_model_2 <- lm(score ~ age + gender, data = evals)
get_regression_table(score_model_2) %>% 
  knitr::kable(
    digits = 3,
    caption = "Model 1: Regression table with no interaction effect included", 
    booktabs = TRUE
  )

## ---- eval=FALSE---------------------------------------------------------
## score_model_3 <- lm(score ~ age * gender, data = evals)
## get_regression_table(score_model_3)

## ---- echo=FALSE---------------------------------------------------------
score_model_3 <- lm(score ~ age * gender, data = evals)
get_regression_table(score_model_3) %>% 
  knitr::kable(
    digits = 3,
    caption = "Model 2: Regression table with interaction effect included", 
    booktabs = TRUE
  )

## ----residual0, warning=FALSE--------------------------------------------
regression_points <- get_regression_points(score_model_3)
regression_points

## ----residual1, warning=FALSE, fig.cap="Model 2 (with interaction) histogram of residual"----
ggplot(regression_points, aes(x = residual)) +
  geom_histogram(binwidth = 0.25, color = "white") +
  labs(x = "Residual")

## ----residual2, warning=FALSE, fig.cap="Model 2 (with interaction) residuals vs predictor"----
ggplot(regression_points, aes(x = age, y = residual)) +
  geom_point() +
  labs(x = "age", y = "Residual") +
  geom_hline(yintercept = 0, col = "blue", size = 1) +
  facet_wrap(~ gender)

