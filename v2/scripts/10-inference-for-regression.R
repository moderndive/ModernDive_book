## ----inference-for-regression-load-packages, message=FALSE--------------------
library(tidyverse)
library(moderndive)
library(infer)
library(gridExtra)
library(GGally)




## ----inference-for-regression-create-UN_data_ch10-----------------------------
UN_data_ch10 <- un_member_states_2024 |>
  select(country,
         life_exp = life_expectancy_2022, 
         fert_rate = fertility_rate_2022)|>
  na.omit()


## ----inference-for-regression-demo-code, eval=FALSE---------------------------
# UN_data_ch10


## ----inference-for-regression-create-n_UN_data_ch10, echo=FALSE---------------
n_UN_data_ch10 <- nrow(UN_data_ch10)


## ----inference-for-regression-select-vars, echo=FALSE-------------------------
un_member_states_2024 |>
  select(life_exp = life_expectancy_2022, 
         fert_rate = fertility_rate_2022)|>
  na.omit() |>
  tidy_summary() |> 
  kbl() |> 
  kable_styling(
    font_size = ifelse(is_latex_output(), 10, 16),
    latex_options = c("HOLD_position")
  )


## ----inference-for-regression-lm-fertility, eval=FALSE------------------------
# simple_model <- lm(fert_rate ~ life_exp, data = UN_data_ch10)
# coef(simple_model)




## ----regline-ch10, fig.cap="Relationship with regression line.", fig.height=ifelse(knitr::is_latex_output(), 3, 4), message=FALSE----
ggplot(UN_data_ch10, aes(x = life_exp, y = fert_rate)) +
  geom_point() +
  labs(x = "Life Expectancy (x)", 
       y = "Fertility Rate (y)",
       title = "Relationship between fertility rate and life expectancy") +  
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.5)


## ----inference-for-regression-filter, eval=FALSE------------------------------
# UN_data_ch10 |>
#   rowid_to_column() |>
#   filter(country == "France")|>
#   pull(rowid)


## ----inference-for-regression-create-france_id, echo=FALSE--------------------
france_id <- UN_data_ch10 |>
  rowid_to_column() |>
  filter(country == "France")|>
  pull(rowid)
france_id


## ----inference-for-regression-filter-alt, eval=FALSE--------------------------
# UN_data_ch10 |>
#   filter(country == "France")


## ----inference-for-regression-create-france_data, echo=FALSE------------------
france_data <- UN_data_ch10 |>
  filter(country == "France")
france_data


## ----inference-for-regression-create-actual_france, echo=FALSE----------------
actual_france <- france_data$fert_rate[1]
fitted_france <- lm_data$Values[1] - abs(lm_data$Values[2]) * france_data$life_exp[1]
resid_france <- actual_france - fitted_france


## ----inference-for-regression-filter-alt2, eval=FALSE-------------------------
# simple_model |>
#   get_regression_points() |>
#   filter(ID == 57)




## ----fittedtable-ch10-all-----------------------------------------------------
simple_model |>
  get_regression_points()


## ----inference-for-regression-demo-code-v2------------------------------------
old_faithful_2024


## ----inference-for-regression-demo-code-v2-dup1, eval=FALSE-------------------
# old_faithful_2024 |>
#   select(duration, waiting) |>
#   tidy_summary()


## ----inference-for-regression-select-vars-alt, echo=FALSE---------------------
old_faithful_2024 |>
  select(duration, waiting) |> 
  tidy_summary() |> 
  kbl() |> 
  kable_styling(
    font_size = ifelse(is_latex_output(), 10, 16),
    latex_options = c("HOLD_position")
  )


## ----inference-for-regression-dynamic-text, echo=FALSE------------------------
# This code is used for dynamic non-static in-line text output purposes
n_old_faithful <- dim(old_faithful_2024)[1]


## ----geyserplot1, echo=F, fig.cap="Scatterplot of relationship of eruption duration and waiting time.", fig.height=ifelse(knitr::is_latex_output(), 3, 4)----
ggplot(old_faithful_2024, 
       aes(x = duration, y = waiting)) +
  geom_point(alpha = 0.3) +
  labs(x = "duration", y = "waiting")


## ----inference-for-regression-fit-lm, eval=FALSE------------------------------
# # Fit regression model:
# model_1 <- lm(waiting ~ duration, data = old_faithful_2024)
# 
# # Get the coefficients and standard deviation for the model
# coef(model_1)
# sigma(model_1)




## ----inference-for-regression-assign-mod_diff_means, eval=FALSE---------------
# mod_diff_means <- lm(rating ~ genre, data = movies_sample)
# get_regression_table(mod_diff_means)


## ----diff-means-reg, echo=FALSE-----------------------------------------------
mod_diff_means <- lm(rating ~ genre, data = movies_sample)
get_regression_table(mod_diff_means) |> 
  kbl(caption = "Regression table for two-sample difference in means example") |> 
  kable_styling(
    font_size = ifelse(is_latex_output(), 8, 16),
    latex_options = c("HOLD_position")
  )


## ----inference-for-regression-create-spotify_for_anova, echo=-1---------------
set.seed(6)
spotify_for_anova <- spotify_by_genre |> 
  select(artists, track_name, popularity, track_genre) |> 
  filter(track_genre %in% c("country", "hip-hop", "rock")) 


## ----inference-for-regression-sample-rows, eval=FALSE-------------------------
# spotify_for_anova |>
#   slice_sample(n = 5)


## ----spotify-for-anova-slice-five, echo=FALSE---------------------------------
spotify_for_anova |> 
  slice_sample(n = 5) |> 
  kbl(caption = "(ref:spotify-for-anova-slice)") |> 
  kable_styling(
    font_size = ifelse(is_latex_output(), 8, 16),
    latex_options = c("HOLD_position")
  )


## ----pop-by-genre-plot, fig.cap="Boxplot of popularity by genre.", fig.height=ifelse(knitr::is_latex_output(), 3.2, 4)----
ggplot(spotify_for_anova, aes(x = track_genre, y = popularity)) +
  geom_boxplot() +
  labs(x = "Genre", y = "Popularity")


## ----inference-for-regression-grouped-summary---------------------------------
mean_popularities_by_genre <- spotify_for_anova |> 
  group_by(track_genre) |>
  summarize(mean_popularity = mean(popularity))
mean_popularities_by_genre


## ----inference-for-regression-assign-mod_anova, eval=FALSE--------------------
# mod_anova <- lm(popularity ~ track_genre, data = spotify_for_anova)
# get_regression_table(mod_anova)


## ----anova-reg-table, echo=FALSE----------------------------------------------
mod_anova <- lm(popularity ~ track_genre, data = spotify_for_anova)
get_regression_table(mod_anova) |> 
  kbl(caption = "Regression table for ANOVA example") |> 
  kable_styling(
    font_size = ifelse(is_latex_output(), 10, 16),
    latex_options = c("HOLD_position")
  )


## ----inference-for-regression-demo-code-v2-dup2-------------------------------
aov(popularity ~ track_genre, data = spotify_for_anova) |> 
  anova()






## ----inference-for-regression-demo-code-v2-dup3-------------------------------
old_faithful_2024 |>
  slice(c(49, 51))




## ----inference-for-regression-dynamic-text-alt, echo=FALSE--------------------
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
p_value <- round(2*(1 - pt(abs(t_stat), n_old_faithful-2)), 3)


## ----pvalue1, echo=FALSE, fig.height=ifelse(knitr::is_latex_output(), 2, 4), fig.cap="Illustration of a two-sided p-value for a t-test."----
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






## ----inference-for-regression-reg-table, eval=FALSE---------------------------
# get_regression_table(model_1)






## ----inference-for-regression-fit-lm-alt--------------------------------------
# Fit regression model:
model_1 <- lm(waiting ~ duration, data = old_faithful_2024)
# Get regression points:
fitted_and_residuals <- get_regression_points(model_1)
fitted_and_residuals


## ----inference-for-regression-scatter, eval=FALSE-----------------------------
# ggplot(fitted_and_residuals, aes(x = waiting_hat, y = residual)) +
#   geom_point() +
#   labs(x = "duration", y = "residual") +
#   geom_hline(yintercept = 0, col = "blue")








## ----inference-for-regression-hist, eval=FALSE--------------------------------
# ggplot(fitted_and_residuals, aes(residual)) +
#   geom_histogram(binwidth = 10, color = "white")


## ----inference-for-regression-plot, eval = FALSE------------------------------
# fitted_and_residuals |>
#   ggplot(aes(sample = residual)) +
#   geom_qq() +
#   geom_qq_line()


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




## ----residual-plot, fig.cap="Plot of residuals against the regressor.", message=FALSE, fig.height=ifelse(knitr::is_latex_output(), 1.5, 4)----
ggplot(fitted_and_residuals, aes(x = duration, y = residual)) +
  geom_point(alpha = 0.6) +
  labs(x = "duration", y = "residual") +
  geom_hline(yintercept = 0)




## ----inference-for-regression-conditional-text, echo=FALSE, results="asis"----
if(!is_latex_output()) 
  cat("An example of such a transformation is given in [Appendix A online](https://moderndive.com/v2/appendixa).")






## ----inference-for-regression-create-n_reps, echo=FALSE-----------------------
n_reps <- 1000


## ----inference-for-regression-bootstrap, eval=FALSE---------------------------
# bootstrap_distn_slope <- old_faithful_2024 |>
#   specify(formula = waiting ~ duration) |>
#   generate(reps = 1000, type = "bootstrap") |>
#   calculate(stat = "slope")
# bootstrap_distn_slope




## ----bootstrap-distribution-slope, fig.cap="Bootstrap distribution of slope.", fig.height=ifelse(knitr::is_latex_output(), 2.2, 4)----
visualize(bootstrap_distn_slope)


## ----inference-for-regression-conf-interval-----------------------------------
percentile_ci <- bootstrap_distn_slope |> 
  get_confidence_interval(type = "percentile", level = 0.95)
percentile_ci


## ----inference-for-regression-specify-----------------------------------------
observed_slope <- old_faithful_2024 |> 
  specify(waiting ~ duration) |> 
  calculate(stat = "slope")
observed_slope


## ----inference-for-regression-assign-se_ci------------------------------------
se_ci <- bootstrap_distn_slope |> 
  get_ci(level = 0.95, type = "se", point_estimate = observed_slope)
se_ci


## ----inference-for-regression-null-dist, eval=FALSE---------------------------
# null_distn_slope <- old_faithful_2024 |>
#   specify(waiting ~ duration) |>
#   hypothesize(null = "independence") |>
#   generate(reps = 1000, type = "permute") |>
#   calculate(stat = "slope")






## ----inference-for-regression-specify-alt-------------------------------------
# Observed slope
b1 <- old_faithful_2024 |> 
  specify(waiting ~ duration) |>
  calculate(stat = "slope")
b1




## ----inference-for-regression-alt---------------------------------------------
null_distn_slope |> 
  get_p_value(obs_stat = b1, direction = "both")






## ----inference-for-regression-create-coffee_data------------------------------
coffee_data <- coffee_quality |>
  select(aroma, 
         flavor, 
         moisture_percentage, 
         continent_of_origin, 
         total_cup_points) |>
  mutate(continent_of_origin = as.factor(continent_of_origin))


## ----inference-for-regression-alt2--------------------------------------------
coffee_data


## ----inference-for-regression-demo-code-v2-dup4, eval=FALSE-------------------
# coffee_data |>
#   tidy_summary()


## ----coffee-tidy-summary, echo=FALSE------------------------------------------
coffee_data |>
  tidy_summary()  |> 
  kbl(
    digits = 3,
    caption = "Summary of coffee data",
    booktabs = TRUE,
    linesep = ""
  ) |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 7, 16),
    latex_options = c("HOLD_position")
  )


## ----inference-for-regression-dynamic-text-alt2, echo=FALSE-------------------
# This code is used for dynamic non-static in-line text output purposes
n_coffee <- length(coffee_data$total_cup_points)
table_coffee <- coffee_data |> tidy_summary()
tcp <- table_coffee[1,]
aroma <- table_coffee[2,]
flavor <- table_coffee[3,]




## ----inference-for-regression-create-corr_table, echo=FALSE-------------------
# This code is used for dynamic non-static in-line text output purposes
corr_table <- coffee_data |>
  select(-continent_of_origin) |>
  cor() |>
  round(digits = 2)


## ----inference-for-regression-fit-lm-alt2, eval=FALSE-------------------------
# # Fit regression model:
# mod_mult <- lm(
#   total_cup_points ~ aroma + flavor + moisture_percentage + continent_of_origin,
#   data = coffee_data
# )
# 
# # Get the coefficients of the model
# coef(mod_mult)
# 
# # Get the standard deviation of the model
# sigma(mod_mult)




## ----inference-for-regression-select-vars-alt2, eval=FALSE--------------------
# coffee_data |>
#   select(aroma, flavor, moisture_percentage) |>
#   tidy_summary() |>
#   select(column, min, max)








## ----inference-for-regression-demo-code-v2-dup5, eval=FALSE-------------------
# get_regression_table(mod_mult)




## ----inference-for-regression-fit-lm-alt2-dup1, eval=FALSE--------------------
# # Fit regression model:
# mod_mult_1 <- lm(
#   total_cup_points ~ aroma + flavor + moisture_percentage,
#   data = coffee_data)
# 
# # Get the coefficients of the model
# coef(mod_mult_1)
# sigma(mod_mult_1)




## ----inference-for-regression-fit-lm-alt2-dup2, eval=FALSE--------------------
# # Fit regression model:
# mod_mult_2 <- lm(
#   total_cup_points ~ aroma + moisture_percentage, data = coffee_data)
# 
# # Get the coefficients of the model
# coef(mod_mult_2)
# sigma(mod_mult_2)




## ----inference-for-regression-dynamic-text-alt2-dup1, echo=FALSE--------------
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


## ----inference-for-regression-reg-table-alt, eval=FALSE-----------------------
# get_regression_table(mod_mult, conf.level = 0.98)




## ----inference-for-regression-demo-code-v2-dup6, eval=FALSE-------------------
# get_regression_table(mod_mult_1)




## ----inference-for-regression-alt2-dup1, eval=FALSE---------------------------
# anova(mod_mult_2, mod_mult_1)




## ----inference-for-regression-demo-code-v2-dup7, eval=FALSE-------------------
# anova(mod_mult_1, mod_mult)




## ----inference-for-regression-fit-lm-alt2-dup3--------------------------------
# Fit regression model:
mod_mult_final <- lm(total_cup_points ~ aroma + flavor + continent_of_origin, 
                     coffee_data)
# Get fitted values and residuals:
fit_and_res_mult <- get_regression_points(mod_mult_final)


## ----inference-for-regression-arrange, grid-arrange-plot-check, fig.cap="Residuals vs. fitted values plot and QQ-plot for the multiple regression model.", fig.height=ifelse(knitr::is_latex_output(), 2, 4)----
g1 <- fit_and_res_mult |>
  ggplot(aes(x = total_cup_points_hat, y = residual)) +
  geom_point() +
  labs(x = "fitted values (total cup points)", y = "residual") +
  geom_hline(yintercept = 0, col = "blue")
g2 <- ggplot(fit_and_res_mult, aes(sample = residual)) +
  geom_qq() +
  geom_qq_line(col="blue", linewidth = 0.5)
grid.arrange(g1, g2, ncol=2)






## ----inference-for-regression-specify-alt2------------------------------------
observed_fit <- coffee_data |> 
  specify(
    total_cup_points ~ aroma + flavor + moisture_percentage + continent_of_origin
  ) |>
  fit()
observed_fit


## ----inference-for-regression-alt2-dup2, eval=FALSE---------------------------
# mod_mult_table


## ----mod-mult-table-again, echo=FALSE-----------------------------------------
mod_mult_table |> 
  kbl(
    digits = 3,
    caption = "(ref:mod-mult-again)",
    booktabs = TRUE,
    linesep = ""
  ) |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 8, 16),
    latex_options = c("HOLD_position")
  )


## ----inference-for-regression-bootstrap-alt2, eval=FALSE----------------------
# coffee_data |>
#   specify(
#     total_cup_points ~ continent_of_origin + aroma + flavor + moisture_percentage
#   ) |>
#   generate(reps = 1000, type = "bootstrap")


## ----inference-for-regression-bootstrap-alt2-dup1, echo=FALSE-----------------
# Fix the width for the explanatory variable output
#options(width = 150)
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
# Reset width
#options(width = 80)


## ----inference-for-regression-bootstrap-alt2-dup2, eval=FALSE-----------------
# boot_distribution_mlr <- coffee_quality |>
#   specify(
#     total_cup_points ~ continent_of_origin + aroma + flavor + moisture_percentage
#   ) |>
#   generate(reps = 1000, type = "bootstrap") |>
#   fit()
# boot_distribution_mlr


## ----inference-for-regression-alt2-dup3, echo=FALSE---------------------------
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


## ----inference-for-regression-viz-dist, eval=FALSE----------------------------
# visualize(boot_distribution_mlr)


## ----inference-for-regression-viz-dist-alt, echo=FALSE------------------------
boot_mlr_viz <- visualize(boot_distribution_mlr)
if (!file.exists("images/boot_mlr_viz.png")) {
  ggsave(
    filename = "images/boot_mlr_viz.png",
    plot = boot_mlr_viz,
    width = 6,
    height = 11,
    dpi = 320
  )
}


## ----boot-distn-slopes, echo=FALSE, out.width="68%", fig.height=12, fig.cap="Bootstrap distributions of partial slopes."----
if(is_latex_output()) {
  knitr::include_graphics("images/boot_mlr_viz.png")
} else {
  boot_mlr_viz
}


## ----inference-for-regression-conf-interval-alt-------------------------------
confidence_intervals_mlr <- boot_distribution_mlr |> 
  get_confidence_interval(
    level = 0.95,
    type = "percentile",
    point_estimate = observed_fit)
confidence_intervals_mlr


## ----ci-slopes-multiple, fig.cap="95% confidence intervals for the partial slopes.", fig.height=8.5, fig.width=6----
visualize(boot_distribution_mlr) +
  shade_confidence_interval(endpoints = confidence_intervals_mlr)


## ----inference-for-regression-null-dist-alt-----------------------------------
set.seed(2024)
null_distribution_mlr <- coffee_quality |>
  specify(total_cup_points ~ continent_of_origin + aroma + 
      flavor + moisture_percentage) |>
  hypothesize(null = "independence") |>
  generate(reps = 1000, type = "permute") |>
  fit()
null_distribution_mlr


## ----inference-for-regression-viz-pvalue, eval=FALSE--------------------------
# visualize(null_distribution_mlr) +
#   shade_p_value(obs_stat = observed_fit, direction = "two-sided")


## ----inference-for-regression-viz-pvalue-alt, echo=FALSE----------------------
mlr_pvalue_viz <- visualize(null_distribution_mlr) +
  shade_p_value(obs_stat = observed_fit, direction = "two-sided")
if (!file.exists("images/mlr_pvalue_viz.png")) {
  ggsave(
    filename = "images/mlr_pvalue_viz.png",
    plot = mlr_pvalue_viz,
    width = 6,
    height = 11,
    dpi = 320
  )
}


## ----shaded-p-values-partial, echo=FALSE, out.width="55%", fig.height=12, fig.cap="Shaded p-values for the partial slopes in this multiple regression."----
if(is_latex_output()) {
  knitr::include_graphics("images/mlr_pvalue_viz.png")
} else {
  mlr_pvalue_viz
}


## ----inference-for-regression-alt2-dup4---------------------------------------
null_distribution_mlr |>
  get_p_value(obs_stat = observed_fit, direction = "two-sided")

