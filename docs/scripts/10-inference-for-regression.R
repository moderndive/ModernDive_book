## ----message=FALSE------------------------------------------------------------
library(tidyverse)
library(moderndive)
library(infer)




## -----------------------------------------------------------------------------
UN_data_ch10 <- un_member_states_2024 |>
  select(country,
         life_exp = life_expectancy_2022, 
         fert_rate = fertility_rate_2022)|>
  na.omit()


## ----echo=FALSE---------------------------------------------------------------
n_ch10_un <- nrow(UN_data_ch10)
n_UN_data_ch10 <- n_ch10_un


## ----echo=F-------------------------------------------------------------------
un_member_states_2024 |>
  select(life_exp = life_expectancy_2022, 
         fert_rate = fertility_rate_2022)|>
  na.omit() |>
  tidy_summary()


## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## simple_model <- lm(fert_rate ~ life_exp,
##                    data = UN_data_ch10)
## # Get regression coefficients
## coef(simple_model)




## ----regline-ch10, fig.cap="Relationship with regression line.", fig.height=3.2, message=FALSE----
ggplot(UN_data_ch10, 
       aes(x = life_exp, y = fert_rate)) +
  geom_point() +
  labs(x = "Life Expectancy (x)", 
       y = "Fertility Rate (y)",
       title = "Relationship between fertility rate and life expectancy") +  
  geom_smooth(method = "lm", se = FALSE)


## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch10 |>
##   rowid_to_column() |>
##   filter(country == "France")|>
##   pull(rowid)


## ----echo=FALSE---------------------------------------------------------------
france_id <- UN_data_ch10 |>
  rowid_to_column() |>
  filter(country == "France")|>
  pull(rowid)
france_id


## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch10 |>
##   filter(country == "France")


## ----echo=FALSE---------------------------------------------------------------
france_data <- UN_data_ch10 |>
  filter(country == "France")
france_data


## ----echo=FALSE---------------------------------------------------------------
actual_france <- france_data$fert_rate[1]
fitted_france <- lm_data$Values[1] - abs(lm_data$Values[2]) * france_data$life_exp[1]
resid_france <- actual_france - fitted_france


## ----eval=F-------------------------------------------------------------------
## simple_model |>
##   get_regression_points() |>
##   filter(ID == 57)




## ----eval=F-------------------------------------------------------------------
## simple_model |>
##   get_regression_points()




## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## simple_model <- lm(fert_rate ~ life_exp, data = UN_data_ch10)
## # Get regression table:
## get_regression_table(simple_model)



## -----------------------------------------------------------------------------
old_faithful_2024


## -----------------------------------------------------------------------------
old_faithful_2024 |>
  select(duration, waiting) |> 
  tidy_summary()


## ----geyserplot1, echo=F, fig.cap="Scatterplot of relationship of eruption duration and waiting time", fig.height=4.5----
ggplot(old_faithful_2024, 
       aes(x = duration, y = waiting)) +
  geom_point(alpha = 0.3) +
  labs(x = "duration", y = "waiting")


## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## model_1 <- lm(waiting ~ duration, data = old_faithful_2024)
## 
## # Get the coefficients of the model
## coef(model_1)
## sigma(model_1)




## -----------------------------------------------------------------------------
old_faithful_2024 |>
  slice(c(49, 51))




## ----echo=F-------------------------------------------------------------------
# This code is used for dynamic non-static in-line text output purposes
q = round(qt(p = (1 - (1-0.95)/2), df = 114 - 2),3)
s <- round(sigma(model_1),3)
x <- old_faithful_2024$duration
n <- length(x)
n_eruptions <- n
#beta1
b1 <- round(coef(model_1)[[2]],3)
denom_se_b1 <- round(sqrt(sum((x - mean(x))^2)),3)
se_b1 <- round(s/denom_se_b1,3)
lb1 <- round(b1 - q*se_b1,3)
ub1 <- round(b1 + q*se_b1,3)
# beta0
b0 <- round(coef(model_1)[[1]],3)
se_b0 <- round(s*sqrt(1/n + mean(x)^2/sum((x - mean(x))^2)),3)
lb0 <- round(b1 - q*se_b0,3)
ub0 <- round(b1 + q*se_b0,3)
# t
t_stat <- round(b1/se_b1,3)
p_value <- round(2*(1 - pt(abs(t_stat), n-2)),3)


## ----pvalue1, echo=F, fig.height=3, fig.cap="Illustration of the p-value for a two-sided test"----
shade <- function(t, a,b) {
  z = dt(t, df = n-2)
  z[abs(t) < b & -abs(t)>a] <- NA
  return(z)
}

ggplot(data.frame(x = c(-4, 4)), aes(x = x)) + 
  stat_function(fun = dt, args = list(df = n-2)) + 
  stat_function(fun = shade, args = list(a = -2, b = 2), 
                geom = "area", fill = "blue", alpha = .2)+
  scale_x_continuous(name = "t", breaks = seq(-4, 4, 2))+
  scale_y_continuous(labels = NULL)+
  theme(axis.title.y = element_blank(), axis.ticks.y = element_blank())


## ----eval=FALSE---------------------------------------------------------------
## get_regression_table(model_1)






## -----------------------------------------------------------------------------
# Fit regression model:
simple_model <- lm(waiting ~ duration, data = old_faithful_2024)
# Get regression points:
regression_points <- get_regression_points(simple_model)
regression_points




## ----model1residualshist, fig.cap="Histogram of residuals."-------------------
ggplot(regression_points, aes(x = residual)) +
  geom_histogram(bins = 12, color = "white") +
  labs(x = "Residual")




## ----numxplot6, fig.cap="Plot of residuals over beauty score."----------------
ggplot(regression_points, aes(x = duration, y = residual)) +
  geom_point() +
  labs(x = "Duration", y = "Residual") +
  geom_hline(yintercept = 0, col = "blue", linewidth = 1)








## -----------------------------------------------------------------------------
n_reps <- 1000


## ----eval=FALSE---------------------------------------------------------------
## bootstrap_distn_slope <- old_faithful_2024 %>%
##   specify(formula = waiting ~ duration) %>%
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
observed_slope <- old_faithful_2024 %>% 
  specify(waiting ~ duration) %>% 
  calculate(stat = "slope")
observed_slope


## -----------------------------------------------------------------------------
se_ci <- bootstrap_distn_slope %>% 
  get_ci(level = 0.95, type = "se", point_estimate = observed_slope)
se_ci


## ----eval=FALSE---------------------------------------------------------------
## null_distn_slope <- old_faithful_2024 |>
##   specify(waiting ~ duration) |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute") |>
##   calculate(stat = "slope")





## -----------------------------------------------------------------------------
# Observed slope
b1 <- old_faithful_2024 |> 
  specify(waiting ~ duration) |>
  calculate(stat = "slope")
b1




## -----------------------------------------------------------------------------
null_distn_slope |> 
  get_p_value(obs_stat = b1, direction = "both")

