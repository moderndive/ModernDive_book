## ----setup_inference_regression, include=FALSE---------------------------
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

# Set random number generator see value for replicable pseudorandomness. Why 76?
# https://www.youtube.com/watch?v=xjJ7FheCkCU
set.seed(76)




## ---- message=FALSE, warning=FALSE---------------------------------------
library(ggplot2)
library(dplyr)
library(moderndive)
library(infer)
library(gapminder)
library(ISLR)


## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.
library(knitr)
library(kableExtra)
library(patchwork)


## ------------------------------------------------------------------------
evals %>% 
  specify(score ~ bty_avg)


## ------------------------------------------------------------------------
slope_obs <- evals %>% 
  specify(score ~ bty_avg) %>% 
  calculate(stat = "slope")


## ----eval=FALSE----------------------------------------------------------
## null_slope_distn <- evals %>%
##   specify(score ~ bty_avg) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 10000) %>%
##   calculate(stat = "slope")


## ----echo=FALSE----------------------------------------------------------
if(!file.exists("rds/null_slope_distn.rds")){
  null_slope_distn <- evals %>% 
    specify(score ~ bty_avg) %>%
    hypothesize(null = "independence") %>% 
    generate(reps = 10000) %>% 
    calculate(stat = "slope")
   saveRDS(object = null_slope_distn, 
           "rds/null_slope_distn.rds")
} else {
   null_slope_distn <- readRDS("rds/null_slope_distn.rds")
}


## ------------------------------------------------------------------------
null_slope_distn %>% 
  visualize(obs_stat = slope_obs, direction = "greater")


## ----fig.cap="Shaded histogram to show p-value"--------------------------
null_slope_distn %>% 
  get_pvalue(obs_stat = slope_obs, direction = "greater")






## ----eval=FALSE----------------------------------------------------------
## null_slope_distn <- evals %>%
##   specify(score ~ bty_avg) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 10000, type = "permute") %>%
##   calculate(stat = "slope")


## ------------------------------------------------------------------------
bootstrap_slope_distn <- evals %>% 
  specify(score ~ bty_avg) %>%
  generate(reps = 10000, type = "bootstrap") %>% 
  calculate(stat = "slope")


## ----echo=FALSE----------------------------------------------------------
if(!file.exists("rds/bootstrap_slope_distn.rds")){
  bootstrap_slope_distn <- evals %>% 
    specify(score ~ bty_avg) %>%
    generate(reps = 10000, type = "bootstrap") %>% 
    calculate(stat = "slope")
  saveRDS(object = bootstrap_slope_distn, 
           "rds/bootstrap_slope_distn.rds")
} else {
  bootstrap_slope_distn <- readRDS("rds/bootstrap_slope_distn.rds")
}


## ------------------------------------------------------------------------
bootstrap_slope_distn %>% visualize()


## ------------------------------------------------------------------------
percentile_slope_ci <- bootstrap_slope_distn %>% 
  get_ci(level = 0.99, type = "percentile")
percentile_slope_ci


## ------------------------------------------------------------------------
se_slope_ci <- bootstrap_slope_distn %>% 
  get_ci(level = 0.99, type = "se", point_estimate = slope_obs)
se_slope_ci


## ---- echo=FALSE---------------------------------------------------------
library(tidyr)


## ------------------------------------------------------------------------
library(ggplot2)
library(dplyr)
library(moderndive)

evals_multiple <- evals %>%
  select(score, ethnicity, gender, language, age, bty_avg, rank)


## ----model1, echo=FALSE, warning=FALSE, fig.cap="Model 1: no interaction effect included"----
coeff <- lm(score ~ age + gender, data = evals_multiple) %>% coef() %>% as.numeric()
slopes <- evals_multiple %>%
  group_by(gender) %>%
  summarise(min = min(age), max = max(age)) %>%
  mutate(intercept = coeff[1]) %>%
  mutate(intercept = ifelse(gender == "male", intercept + coeff[3], intercept)) %>%
  gather(point, age, -c(gender, intercept)) %>%
  mutate(y_hat = intercept + age * coeff[2])
  
  ggplot(evals_multiple, aes(x = age, y = score, col = gender)) +
  geom_jitter() +
  labs(x = "Age", y = "Teaching Score", color = "Gender") +
  geom_line(data = slopes, aes(y = y_hat), size = 1)


## ----model2, echo=FALSE, warning=FALSE, fig.cap="Model 2: interaction effect included"----
ggplot(evals_multiple, aes(x = age, y = score, col = gender)) +
  geom_jitter() +
  labs(x = "Age", y = "Teaching Score", color = "Gender") +
  geom_smooth(method = "lm", se = FALSE)


## ---- eval=FALSE---------------------------------------------------------
## score_model_2 <- lm(score ~ age + gender, data = evals_multiple)
## get_regression_table(score_model_2)

## ----modelmultireg, echo=FALSE-------------------------------------------
score_model_2 <- lm(score ~ age + gender, data = evals_multiple)
get_regression_table(score_model_2) %>% 
  knitr::kable(
    digits = 3,
    caption = "Model 1: Regression table with no interaction effect included", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ---- eval=FALSE---------------------------------------------------------
## score_model_3 <- lm(score ~ age * gender, data = evals_multiple)
## get_regression_table(score_model_3)

## ---- echo=FALSE---------------------------------------------------------
score_model_3 <- lm(score ~ age * gender, data = evals_multiple)
get_regression_table(score_model_3) %>% 
  knitr::kable(
    digits = 3,
    caption = "Model 2: Regression table with interaction effect included", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16), 
                latex_options = c("HOLD_position"))


## ---- eval=TRUE, echo=TRUE-----------------------------------------------
# Get data
evals_ch6 <- evals %>%
  select(score, bty_avg, age)
# Fit regression model:
score_model <- lm(score ~ bty_avg, data = evals_ch6)
# Get regression table:
get_regression_table(score_model)
# Get regression points
regression_points <- get_regression_points(score_model)


## ---- echo=FALSE---------------------------------------------------------
index <- which(evals_ch6$bty_avg == 7.333 & evals_ch6$score == 4.9)
target_point <- score_model %>% 
  get_regression_points() %>% 
  slice(index)
x <- target_point$bty_avg
y <- target_point$score
y_hat <- target_point$score_hat
resid <- target_point$residual


## ---- eval=FALSE, echo=TRUE----------------------------------------------
## ggplot(regression_points, aes(x = bty_avg, y = residual)) +
##   geom_point() +
##   labs(x = "Beauty Score", y = "Residual") +
##   geom_hline(yintercept = 0, col = "blue", size = 1)

## ----numxplot6, echo=FALSE, warning=FALSE, fig.cap="Plot of residuals over beauty score"----
ggplot(regression_points, aes(x = bty_avg, y = residual)) +
  geom_point() +
  labs(x = "Beauty Score", y = "Residual") +
  geom_hline(yintercept = 0, col = "blue", size = 1) +
  annotate("point", x = x, y = resid, col = "red", size = 3) +
  annotate("point", x = x, y = 0, col = "red", shape = 15, size = 3) +
  annotate("segment", x = x, xend = x, y = resid, yend = 0, color = "blue",
           arrow = arrow(type = "closed", length = unit(0.02, "npc")))


## ----numxplot7, echo=FALSE, warning=FALSE, fig.cap="Examples of less than ideal residual patterns"----
resid_ex <- evals_ch6
resid_ex$ex_1 <- ((evals_ch6$bty_avg - 5) ^ 2 - 6 + rnorm(nrow(evals_ch6), 0, 0.5)) * 0.4
resid_ex$ex_2 <- (rnorm(nrow(evals_ch6), 0, 0.075 * evals_ch6$bty_avg ^ 2)) * 0.4
  
resid_ex <- resid_ex %>%
  select(bty_avg, ex_1, ex_2) %>%
  gather(type, eps, -bty_avg) %>% 
  mutate(type = ifelse(type == "ex_1", "Example 1", "Example 2"))

ggplot(resid_ex, aes(x = bty_avg, y = eps)) +
  geom_point() +
  labs(x = "Beauty Score", y = "Residual") +
  geom_hline(yintercept = 0, col = "blue", size = 1) +
  facet_wrap(~type)


## ---- eval=FALSE, echo=TRUE----------------------------------------------
## ggplot(regression_points, aes(x = residual)) +
##   geom_histogram(binwidth = 0.25, color = "white") +
##   labs(x = "Residual")

## ----model1residualshist, echo=FALSE, warning=FALSE, fig.cap= "Histogram of residuals"----
ggplot(regression_points, aes(x = residual)) +
  geom_histogram(binwidth = 0.25, color = "white") +
  labs(x = "Residual")


## ----numxplot9, echo=FALSE, warning=FALSE, fig.cap="Examples of ideal and less than ideal residual patterns"----
resid_ex <- evals_ch6
resid_ex$`Ideal` <- rnorm(nrow(resid_ex), 0, sd = sd(regression_points$residual))
resid_ex$`Less than ideal` <-
  rnorm(nrow(resid_ex), 0, sd = sd(regression_points$residual))^2
resid_ex$`Less than ideal` <- resid_ex$`Less than ideal` - mean(resid_ex$`Less than ideal` )

resid_ex <- resid_ex %>%
  select(bty_avg, `Ideal`, `Less than ideal`) %>%
  gather(type, eps, -bty_avg)

ggplot(resid_ex, aes(x = eps)) +
  geom_histogram(binwidth = 0.25, color = "white") +
  labs(x = "Residual") +
  facet_wrap( ~ type, scales = "free")






## ---- eval=TRUE, echo=TRUE-----------------------------------------------
# Get data:
gapminder2007 <- gapminder %>%
  filter(year == 2007) %>% 
  select(country, continent, lifeExp, gdpPercap)
# Fit regression model:
lifeExp_model <- lm(lifeExp ~ continent, data = gapminder2007)
# Get regression table:
get_regression_table(lifeExp_model)
# Get regression points
regression_points <- get_regression_points(lifeExp_model)


## ----catxplot7, warning=FALSE, fig.cap="Plot of residuals over continent"----
ggplot(regression_points, aes(x = continent, y = residual)) +
  geom_jitter(width = 0.1) + 
  labs(x = "Continent", y = "Residual") +
  geom_hline(yintercept = 0, col = "blue")


## ---- eval=FALSE---------------------------------------------------------
## gapminder2007 %>%
##   filter(continent == "Asia") %>%
##   arrange(lifeExp)

## ---- echo=FALSE---------------------------------------------------------
gapminder2007 %>%
  filter(continent == "Asia") %>%
  arrange(lifeExp) %>%
  slice(1:5) %>%
  knitr::kable(
    digits = 3,
    caption = "Countries in Asia with shortest life expectancy",
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16), 
                latex_options = c("HOLD_position"))


## ----catxplot8, warning=FALSE, fig.cap="Histogram of residuals"----------
ggplot(regression_points, aes(x = residual)) +
  geom_histogram(binwidth = 5, color = "white") +
  labs(x = "Residual")






## ---- eval=TRUE, echo=TRUE-----------------------------------------------
# Get data:
Credit <- Credit %>%
  select(Balance, Limit, Income, Rating, Age)
# Fit regression model:
Balance_model <- lm(Balance ~ Limit + Income, data = Credit)
# Get regression table:
get_regression_table(Balance_model)
# Get regression points
regression_points <- get_regression_points(Balance_model)


## ---- eval=FALSE---------------------------------------------------------
## ggplot(regression_points, aes(x = Limit, y = residual)) +
##   geom_point() +
##   labs(x = "Credit limit (in $)",
##        y = "Residual",
##        title = "Residuals vs credit limit")
## 
## ggplot(regression_points, aes(x = Income, y = residual)) +
##   geom_point() +
##   labs(x = "Income (in $1000)",
##        y = "Residual",
##        title = "Residuals vs income")


## ---- echo=FALSE, fig.height=4, fig.cap="Residuals vs credit limit and income"----
model3_residual_vs_limit_plot <- ggplot(regression_points, aes(x = Limit, y = residual)) +
  geom_point() +
  labs(x = "Credit limit (in $)", y = "Residual", 
       title = "Residuals vs credit limit")
model3_residual_vs_income_plot <- ggplot(regression_points, aes(x = Income, y = residual)) +
  geom_point() +
  labs(x = "Income (in $1000)", y = "Residual", 
       title = "Residuals vs income")
model3_residual_vs_limit_plot + model3_residual_vs_income_plot


## ----model3-residuals-hist, fig.height=4, fig.cap="Relationship between credit card balance and credit limit/income"----
ggplot(regression_points, aes(x = residual)) +
  geom_histogram(color = "white") +
  labs(x = "Residual")






## ---- eval=TRUE, echo=TRUE-----------------------------------------------
# Get data:
evals_ch7 <- evals %>%
  select(score, age, gender)
# Fit regression model:
score_model_2 <- lm(score ~ age + gender, data = evals_ch7)
# Get regression table:
get_regression_table(score_model_2)
# Get regression points
regression_points <- get_regression_points(score_model_2)


## ----residual1, warning=FALSE, fig.cap="Interaction model histogram of residuals"----
ggplot(regression_points, aes(x = residual)) +
  geom_histogram(binwidth = 0.25, color = "white") +
  labs(x = "Residual") +
  facet_wrap(~gender)


## ----residual2, warning=FALSE, fig.cap="Interaction model residuals vs predictor"----
ggplot(regression_points, aes(x = age, y = residual)) +
  geom_point() +
  labs(x = "age", y = "Residual") +
  geom_hline(yintercept = 0, col = "blue", size = 1) +
  facet_wrap(~ gender)

