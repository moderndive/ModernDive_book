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


## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.
library(knitr)
library(tidyr)
library(kableExtra)
library(patchwork)
# Add back in if needed later
#library(gapminder)
#library(ISLR)


## ------------------------------------------------------------------------
evals_ch6 <- evals %>%
  select(ID, score, bty_avg, age)
glimpse(evals_ch6)


## ----regline, fig.cap="Relationship with regression line"----------------
ggplot(evals_ch6, aes(x = bty_avg, y = score)) +
  geom_point() +
  labs(x = "Beauty Score", y = "Teaching Score",
       title = "Relationship between teaching and beauty scores") +  
  geom_smooth(method = "lm", se = FALSE)


## ------------------------------------------------------------------------
# Fit regression model:
score_model <- lm(score ~ bty_avg, data = evals_ch6)
# Get regression table:
get_regression_table(score_model)


## ----echo=FALSE----------------------------------------------------------
slope_row <- get_regression_table(score_model) %>% 
  filter(term == "bty_avg")
b1 <- slope_row %>% pull(estimate)
se1 <- slope_row %>% pull(std_error)
t1 <- slope_row %>% pull(statistic)
lower1 <- slope_row %>% pull(lower_ci)
upper1 <- slope_row %>% pull(upper_ci)


## ----numxplot-ch11, echo=FALSE, warning=FALSE, fig.cap="Example of observed value, fitted value, and residual"----
best_fit_plot <- ggplot(evals_ch6, aes(x = bty_avg, y = score)) +
  geom_point() +
  labs(x = "Beauty Score", y = "Teaching Score",
       title = "Relationship of teaching and beauty scores") +
  geom_smooth(method = "lm", se = FALSE)
best_fit_plot


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


## ---- eval=FALSE, echo=TRUE----------------------------------------------
## ggplot(regression_points, aes(x = residual)) +
##   geom_histogram(binwidth = 0.25, color = "white") +
##   labs(x = "Residual")

## ----model1residualshist, echo=FALSE, warning=FALSE, fig.cap="Histogram of residuals"----
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


## ----numxplot6-again, echo=FALSE, warning=FALSE, fig.cap="Plot of residuals over beauty score"----
ggplot(regression_points, aes(x = bty_avg, y = residual)) +
  geom_point() +
  labs(x = "Beauty Score", y = "Residual") +
  geom_hline(yintercept = 0, col = "blue", size = 1)






## ------------------------------------------------------------------------
# Fit regression model:
score_model <- lm(score ~ bty_avg, data = evals_ch6)
# Get regression table:
get_regression_table(score_model)


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
visualize(null_slope_distn) + 
  shade_p_value(obs_stat = slope_obs, direction = "greater")


## ----fig.cap="Shaded histogram to show p-value"--------------------------
null_slope_distn %>% 
  get_pvalue(obs_stat = slope_obs, direction = "greater")


## ----echo=FALSE----------------------------------------------------------
get_regression_table(score_model)






## ----eval=FALSE----------------------------------------------------------
## null_slope_distn <- evals %>%
##   specify(score ~ bty_avg) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 10000, type = "permute") %>%
##   calculate(stat = "slope")


## ----eval=FALSE----------------------------------------------------------
## bootstrap_slope_distn <- evals %>%
##   specify(score ~ bty_avg) %>%
##   generate(reps = 10000, type = "bootstrap") %>%
##   calculate(stat = "slope")


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

