## ----message=FALSE------------------------------------------------------------
library(tidyverse)
library(moderndive)
library(infer)




## -----------------------------------------------------------------------------
evals_ch5 <- evals %>%
  select(ID, score, bty_avg, age)
glimpse(evals_ch5)



## ----regline, fig.cap="Relationship with regression line.", fig.height=3.2, message=FALSE----
ggplot(evals_ch5, 
       aes(x = bty_avg, y = score)) +
  geom_point() +
  labs(x = "Beauty Score", 
       y = "Teaching Score",
       title = "Relationship between teaching and beauty scores") +  
  geom_smooth(method = "lm", se = FALSE)


## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## score_model <- lm(score ~ bty_avg, data = evals_ch5)
## # Get regression table:
## get_regression_table(score_model)















## -----------------------------------------------------------------------------
# Fit regression model:
score_model <- lm(score ~ bty_avg, data = evals_ch5)
# Get regression points:
regression_points <- get_regression_points(score_model)
regression_points




## -----------------------------------------------------------------------------
evals %>% 
  select(ID, prof_ID, score, bty_avg)


## ----eval=FALSE---------------------------------------------------------------
## ggplot(regression_points, aes(x = residual)) +
##   geom_histogram(binwidth = 0.25, color = "white") +
##   labs(x = "Residual")





## ----eval=FALSE---------------------------------------------------------------
## ggplot(regression_points, aes(x = bty_avg, y = residual)) +
##   geom_point() +
##   labs(x = "Beauty Score", y = "Residual") +
##   geom_hline(yintercept = 0, col = "blue", size = 1)









## ----eval=FALSE---------------------------------------------------------------
## bootstrap_distn_slope <- evals_ch5 %>%
##   specify(formula = score ~ bty_avg) %>%
##   generate(reps = 1000, type = "bootstrap") %>%
##   calculate(stat = "slope")
## bootstrap_distn_slope



## ----bootstrap-distribution-slope, fig.show="hold", fig.cap="Bootstrap distribution of slope.", fig.height=2.2----
visualize(bootstrap_distn_slope)


## -----------------------------------------------------------------------------
percentile_ci <- bootstrap_distn_slope %>% 
  get_confidence_interval(type = "percentile", level = 0.95)
percentile_ci


## -----------------------------------------------------------------------------
observed_slope <- evals %>% 
  specify(score ~ bty_avg) %>% 
  calculate(stat = "slope")
observed_slope


## -----------------------------------------------------------------------------
se_ci <- bootstrap_distn_slope %>% 
  get_ci(level = 0.95, type = "se", point_estimate = observed_slope)
se_ci


## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_distn_slope) +
##   shade_confidence_interval(endpoints = percentile_ci, fill = NULL,
##                             linetype = "solid", color = "grey90") +
##   shade_confidence_interval(endpoints = se_ci, fill = NULL,
##                             linetype = "dashed", color = "grey60") +
##   shade_confidence_interval(endpoints = c(0.035, 0.099), fill = NULL,
##                             linetype = "dotted", color = "black")




## ----eval=FALSE---------------------------------------------------------------
## null_distn_slope <- evals %>%
##   specify(score ~ bty_avg) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute") %>%
##   calculate(stat = "slope")







## -----------------------------------------------------------------------------
null_distn_slope %>% 
  get_p_value(obs_stat = observed_slope, direction = "both")

