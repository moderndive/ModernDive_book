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
n_UN_data_ch10 <- nrow(UN_data_ch10)


## ----echo=FALSE---------------------------------------------------------------
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
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.5)


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


## ----eval=FALSE---------------------------------------------------------------
## simple_model |>
##   get_regression_points() |>
##   filter(ID == 57)




## ----eval=FALSE---------------------------------------------------------------
## simple_model |>
##   get_regression_points()




## -----------------------------------------------------------------------------
old_faithful_2024


## -----------------------------------------------------------------------------
old_faithful_2024 |>
  select(duration, waiting) |> 
  tidy_summary()


## ----echo=FALSE---------------------------------------------------------------
# This code is used for dynamic non-static in-line text output purposes
n_old_faithful <- dim(old_faithful_2024)[1]


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
# Fit regression model
mod_diff_means <- lm(rating ~ genre, 
                     data = movies_sample)
# Get regression table
get_regression_table(mod_diff_means)


## -----------------------------------------------------------------------------
set.seed(6)
spotify_for_anova <- spotify_by_genre |> 
  select(artists, track_name, popularity, track_genre) |> 
  filter(track_genre %in% c("country", "hip-hop", "rock")) 
spotify_for_anova |> 
  slice_sample(n = 10)


## -----------------------------------------------------------------------------
ggplot(spotify_for_anova, aes(x = track_genre, y = popularity)) +
  geom_boxplot() +
  labs(x = "Genre", y = "Popularity")


## -----------------------------------------------------------------------------
mean_popularities_by_genre <- spotify_for_anova |> 
  group_by(track_genre) |>
  summarize(mean_popularity = mean(popularity))
mean_popularities_by_genre


## -----------------------------------------------------------------------------
mod_anova <- lm(popularity ~ track_genre, 
                data = spotify_for_anova)
get_regression_table(mod_anova)


## -----------------------------------------------------------------------------
aov(popularity ~ track_genre, data = spotify_for_anova) |> 
  anova()


## -----------------------------------------------------------------------------
old_faithful_2024 |>
  slice(c(49, 51))




## ----echo=FALSE---------------------------------------------------------------
# This code is used for dynamic non-static in-line text output purposes
q = round(qt(p = (1 - (1-0.95)/2), df = 114 - 2),3)
s <- round(sigma(model_1),3)
x <- old_faithful_2024$duration
n_old_faithful <- length(x)
#beta1
b1 <- round(coef(model_1)[[2]],3)
denom_se_b1 <- round(sqrt(sum((x - mean(x))^2)),3)
se_b1 <- round(s/denom_se_b1,3)
lb1 <- round(b1 - q*se_b1,3)
ub1 <- round(b1 + q*se_b1,3)
# beta0
b0 <- round(coef(model_1)[[1]],3)
se_b0 <- round(s*sqrt(1/n_old_faithful + mean(x)^2/sum((x - mean(x))^2)),3)
lb0 <- round(b1 - q*se_b0,3)
ub0 <- round(b1 + q*se_b0,3)
# t
t_stat <- round(b1/se_b1,3)
p_value <- round(2*(1 - pt(abs(t_stat), n_old_faithful-2)),3)


## ----pvalue1, echo=FALSE, fig.height=3, fig.cap="Illustration of a two-sided p-value for a t-test"----
n <- n_old_faithful
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
model_1 <- lm(waiting ~ duration, data = old_faithful_2024)
# Get regression points:
fitted_and_residuals <- get_regression_points(model_1)
fitted_and_residuals


## ----eval=FALSE---------------------------------------------------------------
## fitted_and_residuals |>
##   ggplot(aes(x = waiting_hat, y = residual)) +
##   geom_point() +
##   labs(x = "duration", y = "residual") +
##   geom_hline(yintercept = 0, col = "blue")








## ----eval=FALSE---------------------------------------------------------------
## ggplot(fitted_and_residuals, aes(residual)) +
##   geom_histogram(binwidth = 10, color = "white")


## ----eval = FALSE-------------------------------------------------------------
## fitted_and_residuals |>
##   ggplot(aes(sample = residual)) +
##   geom_qq() +
##   geom_qq_line()


## ----model1residualshist, echo=FALSE, warning=FALSE, fig.cap="Histogram of residuals."----
g1 <- ggplot(fitted_and_residuals, aes(x = residual)) +
  geom_histogram(aes(y=after_stat(density)), binwidth = 10, color = "white") + 
  stat_function(fun = dnorm,  args = list(mean = 0, sd = s), col="blue") + 
  xlim(-50,50) +
  labs(x = "residual")

g2 <- ggplot(fitted_and_residuals, aes(sample = residual)) +
  geom_qq() +
  geom_qq_line(col="blue", linewidth = 0.5)

grid.arrange(g1, g2, ncol=2)


## ----not-normal-residuals, echo = FALSE, fig.cap="Histogram of residuals."----
set.seed(3)
g1 <- fitted_and_residuals |>
  mutate(
    `Not normal` = rnorm(n = n(), mean = 0, sd = s)^2/40 - mean(rnorm(n = n(), 0, sd = s))-10)|>
  ggplot(aes(x = `Not normal`)) +
  geom_histogram(aes(y=after_stat(density)), binwidth = 10, color = "white") + 
  stat_function(fun = dnorm,  args = list(mean = 0, sd = s), col="blue") + xlim(-50,50) +
  labs(x = "residual")

g2 <- fitted_and_residuals |>
  mutate(
    `Not normal` = rnorm(n = n(), mean = 0, sd = s)^2/40 - mean(rnorm(n = n(), 0, sd = s))-10)|>
  ggplot(aes(sample = `Not normal`)) +
  geom_qq() +
  geom_qq_line(col="blue", linewidth = 0.5)

gridExtra::grid.arrange(g1, g2, ncol=2)


## ----residual-plot, fig.cap="Plot of residuals against the regressor.", message=FALSE----
ggplot(fitted_and_residuals, aes(x = duration, y = residual)) +
  geom_point(alpha = 0.6) +
  labs(x = "duration", y = "residual") +
  geom_hline(yintercept = 0)








## -----------------------------------------------------------------------------
coffee_data <- coffee_quality |>
  select(aroma, flavor, moisture_percentage, 
         continent_of_origin, total_cup_points) |>
  mutate(continent_of_origin = as.factor(continent_of_origin))


## -----------------------------------------------------------------------------
coffee_data


## -----------------------------------------------------------------------------
coffee_data |>
  tidy_summary()


## ----echo=FALSE---------------------------------------------------------------
# This code is used for dynamic non-static in-line text output purposes
n_coffee <- length(coffee_data$total_cup_points)
table_coffee <- coffee_data |> tidy_summary()
tcp <- table_coffee[1,]
aroma <- table_coffee[2,]
flavor <- table_coffee[3,]




## ----echo=FALSE---------------------------------------------------------------
# This code is used for dynamic non-static in-line text output purposes
corr_table <- coffee_data |>
  select(-continent_of_origin) |>
  cor() |>
  round(digits = 2)


## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## mod_mult <- lm(
##   total_cup_points ~ aroma + flavor + moisture_percentage + continent_of_origin,
##   data = coffee_data)
## 
## # Get the coefficients of the model
## coef(mod_mult)
## sigma(mod_mult)




## ----eval=FALSE---------------------------------------------------------------
## coffee_data |>
##   select(aroma, flavor, moisture_percentage)|>
##   tidy_summary() |>
##   select(column, min, max)




## ----eval=FALSE---------------------------------------------------------------
## get_regression_table(mod_mult)




## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## mod_mult_1 <- lm(
##   total_cup_points ~ aroma + flavor + moisture_percentage,
##   data = coffee_data)
## 
## # Get the coefficients of the model
## coef(mod_mult_1)
## sigma(mod_mult_1)




## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## mod_mult_2 <- lm(
##   total_cup_points ~ aroma + moisture_percentage, data = coffee_data)
## 
## # Get the coefficients of the model
## coef(mod_mult_2)
## sigma(mod_mult_2)




## ----echo=FALSE---------------------------------------------------------------
# This code is used for dynamic non-static in-line text output purposes
n_coffee <- dim(coffee_data)[1]
s_mult <- summary(mod_mult)$sigma
p_mult <- summary(mod_mult)$df[1]
df_mult <- summary(mod_mult)$df[2]

b1_mult <- summary(mod_mult)$coef[2,1]
se_b1_mult <- summary(mod_mult)$coef[2,2]

q_mult = qt(p = (1 - (1-0.95)/2), df = n_coffee - p_mult)
lb_mult <- b1_mult - q*se_b1_mult 
ub_mult <- b1_mult + q*se_b1_mult


## ----eval=FALSE---------------------------------------------------------------
## get_regression_table(mod_mult, conf.level = 0.98)




## ----eval=FALSE---------------------------------------------------------------
## get_regression_table(mod_mult_1)




## -----------------------------------------------------------------------------
anova(mod_mult_2, mod_mult_1) 




## -----------------------------------------------------------------------------
anova(mod_mult_1, mod_mult) 




## -----------------------------------------------------------------------------
# Fit regression model:
mod_mult_final <- lm(total_cup_points ~ aroma + flavor + continent_of_origin, 
                     coffee_data)
# Get fitted values and residuals:
fit_and_res_mult <- get_regression_points(mod_mult_final)


## -----------------------------------------------------------------------------
g1 <- fit_and_res_mult |>
  ggplot(aes(x = total_cup_points_hat, y = residual)) +
  geom_point() +
  labs(x = "fitted values (total cup points)", y = "residual") +
  geom_hline(yintercept = 0, col = "blue")
g2 <- ggplot(fit_and_res_mult, aes(sample = residual)) +
  geom_qq() +
  geom_qq_line(col="blue", linewidth = 0.5)
grid.arrange(g1, g2, ncol=2)


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






## -----------------------------------------------------------------------------
observed_fit <- coffee_data |>
  specify(
    total_cup_points ~ aroma + flavor + moisture_percentage + continent_of_origin
  ) |>
  fit()
observed_fit


## -----------------------------------------------------------------------------
mod_mult_table


## ----eval=FALSE---------------------------------------------------------------
## coffee_data |>
##   specify(
##     total_cup_points ~ continent_of_origin + aroma + flavor + moisture_percentage
##   ) |>
##   generate(reps = 1000, type = "bootstrap")


## ----echo=FALSE---------------------------------------------------------------
if (!file.exists("rds/generated_distn_slopes.rds")) {
  set.seed(76)
  generated_distn_slopes <- coffee_data |>
    specify(
      total_cup_points ~ continent_of_origin + aroma + flavor + moisture_percentage
    ) |>
    generate(reps = 1000, type = "bootstrap")
  saveRDS(
    object = generated_distn_slopes,
    "rds/generated_distn_slopes.rds"
  )
} else {
  generated_distn_slopes <- readRDS("rds/generated_distn_slopes.rds")
}
generated_distn_slopes


## ----eval=FALSE---------------------------------------------------------------
## boot_distribution_mlr <- coffee_quality |>
##   specify(
##     total_cup_points ~ continent_of_origin + aroma + flavor + moisture_percentage
##   ) |>
##   generate(reps = 1000, type = "bootstrap") |>
##   fit()
## boot_distribution_mlr


## ----echo=FALSE---------------------------------------------------------------
if (!file.exists("rds/boot_distn_slopes.rds")) {
  set.seed(76)
  boot_distribution_mlr <- generated_distn_slopes |> 
    fit()
  saveRDS(
    object = boot_distribution_mlr,
    "rds/boot_distn_slopes.rds"
  )
} else {
  boot_distribution_mlr <- readRDS("rds/boot_distn_slopes.rds")
}
boot_distribution_mlr


## ----boot-distn-slopes, fig.cap="Bootstrap distribution of partial slopes."----
visualize(boot_distribution_mlr)


## -----------------------------------------------------------------------------
confidence_intervals_mlr <- boot_distribution_mlr |> 
  get_confidence_interval(
    level = 0.95,
    type = "percentile",
    point_estimate = observed_fit)
confidence_intervals_mlr


## ----ci-slopes-multiple, fig.cap="95% confidence intervals for the partial slopes."----
visualize(boot_distribution_mlr) +
  shade_confidence_interval(endpoints = confidence_intervals_mlr)


## -----------------------------------------------------------------------------
set.seed(2024)
null_distribution_mlr <- coffee_quality |>
  specify(total_cup_points ~ continent_of_origin + aroma + flavor + moisture_percentage) |>
  hypothesize(null = "independence") |>
  generate(reps = 1000, type = "permute") |>
  fit()
null_distribution_mlr


## -----------------------------------------------------------------------------
visualize(null_distribution_mlr) +
  shade_p_value(obs_stat = observed_fit, direction = "two-sided")


## -----------------------------------------------------------------------------
null_distribution_mlr |>
  get_p_value(obs_stat = observed_fit, direction = "two-sided")

