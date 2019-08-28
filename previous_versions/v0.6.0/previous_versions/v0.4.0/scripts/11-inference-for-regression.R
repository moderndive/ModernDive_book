## ----setup_inference_regression, include=FALSE---------------------------
chap <- 11
lc <- 0
rq <- 0
# **`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`**
# **`r paste0("(RQ", chap, ".", (rq <- rq + 1), ")")`**

knitr::opts_chunk$set(
  tidy = FALSE, 
  out.width = '\\textwidth'
  )

# This bit of code is a bug fix on asis blocks, which we use to show/not show LC
# solutions, which are written like markdown text. In theory, it shouldn't be
# necessary for knitr versions <=1.11.6, but I've found I still need to for
# everything to knit properly in asis blocks. More info here: 
# https://stackoverflow.com/questions/32944715/conditionally-display-block-of-markdown-text-using-knitr
library(knitr)
knit_engines$set(asis = function(options) {
  if (options$echo && options$eval) knit_child(text = options$code)
})

# This controls which LC solutions to show. Options for solutions_shown: "ALL"
# (to show all solutions), or subsets of c('11-1', '11-2'), including the
# null vector c('') to show no solutions.
solutions_shown <- c('')
show_solutions <- function(section){
  return(solutions_shown == "ALL" | section %in% solutions_shown)
  }

## ---- message=FALSE, warning=FALSE---------------------------------------
library(ggplot2)
library(dplyr)
library(moderndive)
library(infer)

## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.
library(knitr)

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

## ----echo=FALSE----------------------------------------------------------
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

## ---- echo=FALSE---------------------------------------------------------
score_model_2 <- lm(score ~ age + gender, data = evals_multiple)
get_regression_table(score_model_2) %>% 
  knitr::kable(
    digits = 3,
    caption = "Model 1: Regression table with no interaction effect included", 
    booktabs = TRUE
  )

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
  )

