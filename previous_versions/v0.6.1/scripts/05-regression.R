## ---- eval=FALSE---------------------------------------------------------
## library(tidyverse)
## library(moderndive)
## library(skimr)
## library(gapminder)

## ---- echo=FALSE, message=FALSE, warning=FALSE---------------------------
library(tidyverse)
library(moderndive)
# DO NOT load the skimr package as a whole as it will break all kable() code for 
# the remaining chapters in the book.
# Furthermore all skimr::skim() output in this Chapter has been hard coded. 
# library(skimr)
library(gapminder)


## ---- message=FALSE, warning=FALSE, echo=FALSE---------------------------
# Packages needed internally, but not in text.
library(mvtnorm)
library(broom)
library(kableExtra)
library(patchwork)


## ------------------------------------------------------------------------
evals_ch6 <- evals %>%
  select(ID, score, bty_avg, age)


## ------------------------------------------------------------------------
glimpse(evals_ch6)


## ---- eval=FALSE---------------------------------------------------------
## evals_ch6 %>%
##   sample_n(size = 5)

## ----five-random-courses, echo=FALSE-------------------------------------
evals_ch6 %>%
  sample_n(5) %>%
  knitr::kable(
    digits = 3,
    caption = "A random sample of 5 out of the 463 courses at UT Austin",
    booktabs = TRUE
  ) %>%
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))


## ----eval=TRUE-----------------------------------------------------------
evals_ch6 %>%
  summarize(mean_bty_avg = mean(bty_avg), mean_score = mean(score),
            median_bty_avg = median(bty_avg), median_score = median(score))


## ----eval=FALSE----------------------------------------------------------
## evals_ch6 %>%
##   select(score, bty_avg) %>%
##   skim()


## ----correlation1, echo=FALSE, fig.cap="Different correlation coefficients."----
correlation <- c(-0.9999, -0.9, -0.75, -0.3, 0, 0.3, 0.75, 0.9, 0.9999)
n_sim <- 100
values <- NULL
for(i in seq_len(length(correlation))){
  rho <- correlation[i]
  sigma <- matrix(c(5, rho * sqrt(50), rho * sqrt(50), 10), 2, 2)
  sim <- rmvnorm(
    n = n_sim,
    mean = c(20,40),
    sigma = sigma
    ) %>%
    as.data.frame() %>% 
    as_tibble() %>%
    mutate(correlation = round(rho,2))

  values <- bind_rows(values, sim)
}

ggplot(data = values, mapping = aes(V1, V2)) +
  geom_point() +
  facet_wrap(~ correlation, ncol = 3) +
  labs(x = "x", y = "y") +
  theme(
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank()
  )


## ------------------------------------------------------------------------
evals_ch6 %>%
  get_correlation(formula = score ~ bty_avg)


## ------------------------------------------------------------------------
evals_ch6 %>%
  summarize(correlation = cor(score, bty_avg))


## ---- echo=FALSE---------------------------------------------------------
cor_ch6 <- evals_ch6 %>%
  summarize(correlation = cor(score, bty_avg)) %>%
  pull(correlation) %>%
  round(3)


## ---- eval=FALSE---------------------------------------------------------
## ggplot(evals_ch6, aes(x = bty_avg, y = score)) +
##   geom_point() +
##   labs(x = "Beauty Score", y = "Teaching Score",
##        title = "Scatterplot of relationship of teaching and beauty scores")

## ----numxplot1, warning=FALSE, echo=FALSE, fig.cap="Instructor evaluation scores at UT Austin."----
# Define orange box
margin_x <- 0.15
margin_y <- 0.075
box <- tibble(
  x = c(7.83, 8.17, 8.17, 7.83, 7.83) + c(-1, 1, 1, -1, -1) * margin_x,
  y = c(4.6, 4.6, 5, 5, 4.6) + c(-1, -1, 1, 1, -1) * margin_y
  )

ggplot(evals_ch6, aes(x = bty_avg, y = score)) +
  geom_point() +
  labs(x = "Beauty Score", y = "Teaching Score",
       title = "Scatterplot of relationship of teaching and beauty scores") +
  geom_path(data = box, aes(x=x, y=y), col = "orange", size = 1)


## ---- eval=FALSE---------------------------------------------------------
## ggplot(evals_ch6, aes(x = bty_avg, y = score)) +
##   geom_jitter() +
##   labs(x = "Beauty Score", y = "Teaching Score",
##        title = "Scatterplot of relationship of teaching and beauty scores")

## ----numxplot2, warning=FALSE, echo=FALSE, fig.cap="Instructor evaluation scores at UT Austin."----
ggplot(evals_ch6, aes(x = bty_avg, y = score)) +
  geom_jitter() +
  labs(x = "Beauty Score", y = "Teaching Score",
       title = "(Jittered) Scatterplot of relationship of teaching and beauty scores") +
  geom_path(data = box, aes(x=x, y=y), col = "orange", size = 1)


## ----numxplot3, warning=FALSE, fig.cap="Regression line."----------------
ggplot(evals_ch6, aes(x = bty_avg, y = score)) +
  geom_point() +
  labs(x = "Beauty Score", y = "Teaching Score",
       title = "Relationship between teaching and beauty scores") +  
  geom_smooth(method = "lm", se = FALSE)






## ---- eval=FALSE---------------------------------------------------------
## # Fit regression model:
## score_model <- lm(score ~ bty_avg, data = evals_ch6)
## # Get regression table:
## get_regression_table(score_model)

## ---- echo=FALSE---------------------------------------------------------
score_model <- lm(score ~ bty_avg, data = evals_ch6)
evals_line <- score_model %>%
  get_regression_table() %>%
  pull(estimate)

## ----regtable, echo=FALSE------------------------------------------------
get_regression_table(score_model) %>%
  knitr::kable(
    digits = 3,
    caption = "Linear regression table",
    booktabs = TRUE
  ) %>%
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))


## ---- eval=FALSE---------------------------------------------------------
## # Fit regression model:
## score_model <- lm(score ~ bty_avg, data = evals_ch6)
## # Get regression table:
## get_regression_table(score_model)


## ----moderndive-figure-wrapper, echo=FALSE, fig.align='center', fig.cap="The concept of a wrapper function."----
knitr::include_graphics("images/shutterstock/wrapper_function.png")






## ----instructor-21, echo=FALSE-------------------------------------------
index <- which(evals_ch6$bty_avg == 7.333 & evals_ch6$score == 4.9)
target_point <- score_model %>%
  get_regression_points() %>%
  slice(index)
x <- target_point$bty_avg
y <- target_point$score
y_hat <- target_point$score_hat
resid <- target_point$residual
evals_ch6 %>%
  slice(index) %>%
  knitr::kable(
    digits = 4,
    caption = "Data for the 21st course out of 463",
    booktabs = TRUE
  ) %>%
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))


## ----numxplot4, echo=FALSE, warning=FALSE, fig.cap="Example of observed value, fitted value, and residual."----
best_fit_plot <- ggplot(evals_ch6, aes(x = bty_avg, y = score)) +
  geom_point(color = "grey") +
  labs(x = "Beauty Score", y = "Teaching Score",
       title = "Relationship of teaching and beauty scores") +
  geom_smooth(method = "lm", se = FALSE) +
  annotate("point", x = x, y = y_hat, col = "red", shape = 15, size = 4) +
  annotate("segment", x = x, xend = x, y = y, yend = y_hat, color = "blue",
           arrow = arrow(type = "closed", length = unit(0.04, "npc"))) +
  annotate("point", x = x, y = y, col = "red", size = 4)
best_fit_plot


## ---- eval=FALSE---------------------------------------------------------
## regression_points <- get_regression_points(score_model)
## regression_points


## ----regression-points-1, echo=FALSE-------------------------------------
set.seed(76)
regression_points <- get_regression_points(score_model)
regression_points %>%
  slice(c(index, index + 1, index + 2, index + 3)) %>%
  knitr::kable(
    digits = 3,
    caption = "Regression points (for only the 21st through 24th courses)",
    booktabs = TRUE
  )






## ---- warning=FALSE, message=FALSE---------------------------------------
library(gapminder)
gapminder2007 <- gapminder %>%
  filter(year == 2007) %>%
  select(country, lifeExp, continent, gdpPercap)


## ---- echo=FALSE---------------------------------------------------------
# Hidden: internally compute mean and median life expectancy
lifeExp_worldwide <- gapminder2007 %>%
  summarize(median = median(lifeExp), mean = mean(lifeExp))
mean_africa <- gapminder2007 %>%
  filter(continent == "Africa") %>%
  summarize(mean_africa = mean(lifeExp)) %>%
  pull(mean_africa)


## ------------------------------------------------------------------------
glimpse(gapminder2007)


## ---- eval=FALSE---------------------------------------------------------
## gapminder2007 %>%
##   sample_n(size = 5)

## ----model2-data-preview, echo=FALSE-------------------------------------
gapminder2007 %>%
  sample_n(5) %>%
  knitr::kable(
    digits = 3,
    caption = "Random sample of 5 out of 142 countries",
    booktabs = TRUE
  ) %>%
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))


## ----eval=FALSE----------------------------------------------------------
## gapminder2007 %>%
##   select(lifeExp, continent) %>%
##   skim()


## ----lifeExp2007hist, echo=TRUE, warning=FALSE, fig.cap="Histogram of Life Expectancy in 2007."----
ggplot(gapminder2007, aes(x = lifeExp)) +
  geom_histogram(binwidth = 5, color = "white") +
  labs(x = "Life expectancy", y = "Number of countries",
       title = "Histogram of distribution of worldwide life expectancies")


## ----catxplot0b, warning=FALSE, fig.cap="Life expectancy in 2007."-------
ggplot(gapminder2007, aes(x = lifeExp)) +
  geom_histogram(binwidth = 5, color = "white") +
  labs(x = "Life expectancy", y = "Number of countries",
       title = "Histogram of distribution of worldwide life expectancies") +
  facet_wrap(~ continent, nrow = 2)


## ----catxplot1, warning=FALSE, fig.cap="Life expectancy in 2007."--------
ggplot(gapminder2007, aes(x = continent, y = lifeExp)) +
  geom_boxplot() +
  labs(x = "Continent", y = "Life expectancy (years)",
       title = "Life expectancy by continent")


## ---- eval=TRUE----------------------------------------------------------
lifeExp_by_continent <- gapminder2007 %>%
  group_by(continent) %>%
  summarize(median = median(lifeExp), mean = mean(lifeExp))

## ----catxplot0, echo=FALSE-----------------------------------------------
lifeExp_by_continent %>%
  knitr::kable(
    digits = 3,
    caption = "Life expectancy by continent",
    booktabs = TRUE
  )


## ----continent-mean-life-expectancies, echo=FALSE------------------------
gapminder2007 %>%
  group_by(continent) %>%
  summarize(mean = mean(lifeExp)) %>%
  mutate(`Difference versus Africa` = mean - mean_africa) %>%
  knitr::kable(
    digits = 3,
    caption = "Mean life expectancy by continent and relative differences from mean for Africa.",
    booktabs = TRUE
  ) %>%
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))






## ---- eval=FALSE---------------------------------------------------------
## # Fit regression model:
## lifeExp_model <- lm(lifeExp ~ continent, data = gapminder2007)
## # Get regression table:
## get_regression_table(lifeExp_model)

## ---- echo=FALSE---------------------------------------------------------
lifeExp_model <- lm(lifeExp ~ continent, data = gapminder2007)

## ----catxplot4b, echo=FALSE----------------------------------------------
get_regression_table(lifeExp_model) %>%
  knitr::kable(
    digits = 3,
    caption = "Linear regression table",
    booktabs = TRUE
  ) %>%
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))






## ---- eval=FALSE---------------------------------------------------------
## regression_points <- get_regression_points(lifeExp_model, ID = "country")
## regression_points

## ----model2-residuals, echo=FALSE----------------------------------------
regression_points <- get_regression_points(lifeExp_model, ID = "country")
regression_points %>%
  slice(1:10) %>%
  knitr::kable(
    digits = 3,
    caption = "Regression points (First 10 out of 142 countries)",
    booktabs = TRUE
  ) %>%
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))






## ----moderndive-figure-causal-graph-2, echo=FALSE, fig.align='center', fig.cap="Does sleeping with shoes on cause headaches?"----
knitr::include_graphics("images/shutterstock/shoes_headache.png")


## ----moderndive-figure-causal-graph, echo=FALSE, fig.align='center', fig.cap="Causal graph."----
knitr::include_graphics("images/flowcharts/flowchart.009-cropped.png")


## ----best-fitting-line, fig.height = 8, fig.width = 8, echo=FALSE, warning=FALSE, fig.cap="Example of observed value, fitted value, and residual."----
# First residual
best_fit_plot <- ggplot(evals_ch6, aes(x = bty_avg, y = score)) +
  geom_point(size = 0.8, color = "grey") +
  labs(x = "Beauty Score", y = "Teaching Score") +
  geom_smooth(method = "lm", se = FALSE) +
  annotate("point", x = x, y = y, col = "red", size = 2) +
  annotate("point", x = x, y = y_hat, col = "red", shape = 15, size = 2) +
  annotate("segment", x = x, xend = x, y = y, yend = y_hat, color = "blue",
           arrow = arrow(type = "closed", length = unit(0.02, "npc")))
p1 <- best_fit_plot + labs(title = "First instructor's residual")

# Second residual
index <- which(evals_ch6$bty_avg == 2.333 & evals_ch6$score == 2.7)
target_point <- get_regression_points(score_model) %>%
  slice(index)
x <- target_point$bty_avg
y <- target_point$score
y_hat <- target_point$score_hat
resid <- target_point$residual

best_fit_plot <- best_fit_plot +
  annotate("point", x = x, y = y, col = "red", size = 2) +
  annotate("point", x = x, y = y_hat, col = "red", shape = 15, size = 2) +
  annotate("segment", x = x, xend = x, y = y, yend = y_hat, color = "blue",
           arrow = arrow(type = "closed", length = unit(0.02, "npc")))
p2 <- best_fit_plot + labs(title = "Adding second instructor's residual")

# Third residual
index <- which(evals_ch6$bty_avg == 3.667 & evals_ch6$score == 4.4)
score_model <- lm(score ~ bty_avg, data = evals_ch6)
target_point <- get_regression_points(score_model) %>%
  slice(index)
x <- target_point$bty_avg
y <- target_point$score
y_hat <- target_point$score_hat
resid <- target_point$residual

best_fit_plot <- best_fit_plot +
  annotate("point", x = x, y = y, col = "red", size = 2) +
  annotate("point", x = x, y = y_hat, col = "red", shape = 15, size = 2) +
  annotate("segment", x = x, xend = x, y = y, yend = y_hat,
           color = "blue",
           arrow = arrow(type = "closed", length = unit(0.02, "npc")))
p3 <- best_fit_plot + labs(title = "Adding third instructor's residual")

index <- which(evals_ch6$bty_avg == 6 & evals_ch6$score == 3.8)
score_model <- lm(score ~ bty_avg, data = evals_ch6)
target_point <- get_regression_points(score_model) %>%
  slice(index)
x <- target_point$bty_avg
y <- target_point$score
y_hat <- target_point$score_hat
resid <- target_point$residual

best_fit_plot <- best_fit_plot +
  annotate("point", x = x, y = y, col = "red", size = 2) +
  annotate("point", x = x, y = y_hat, col = "red", shape = 15, size = 2) +
  annotate("segment", x = x, xend = x, y = y, yend = y_hat, color = "blue",
           arrow = arrow(type = "closed", length = unit(0.02, "npc")))
p4 <- best_fit_plot + labs(title = "Adding fourth instructor's residual")

p1 + p2 + p3 + p4 + plot_layout(nrow = 2)


## ------------------------------------------------------------------------
# Fit regression model:
score_model <- lm(score ~ bty_avg, data = evals_ch6)

# Get regression points:
regression_points <- get_regression_points(score_model)
regression_points

# Compute sum of squared residuals
regression_points %>%
  mutate(squared_residuals = residual^2) %>%
  summarize(sum_of_squared_residuals = sum(squared_residuals))




## ----three-lines, fig.cap="Regression line and two others.", out.width="80%", echo=FALSE----
example <- tibble(
  x = c(0, 0.5, 1),
  y = c(2, 1, 3)
)
ggplot(example, aes(x = x, y = y)) +
  geom_smooth(method = "lm", se = FALSE, fullrange = TRUE) +
  geom_hline(yintercept = 2.5, col = "red", linetype = "dashed", size = 1) +
  geom_abline(intercept = 2, slope = -1, col = "forestgreen", linetype = "dashed", size = 1) +
  geom_point(size = 4)
# model_example <- lm(y ~ x, data = example)
# get_regression_table(model_example)




## ---- eval=FALSE---------------------------------------------------------
## # Fit regression model:
## score_model <- lm(score ~ bty_avg, data = evals_ch6)
## # Get regression table:
## get_regression_table(score_model)

## ----recall-table, echo=FALSE--------------------------------------------
score_model <- lm(score ~ bty_avg, data = evals_ch6)
get_regression_table(score_model) %>%
  knitr::kable(
    digits = 3,
    caption = "Regression table.",
    booktabs = TRUE
  ) %>%
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))


## ---- eval=FALSE---------------------------------------------------------
## library(broom)
## library(janitor)
## score_model %>%
##   tidy(conf.int = TRUE) %>%
##   mutate_if(is.numeric, round, digits = 3) %>%
##   clean_names() %>%
##   rename(lower_ci = conf_low,
##          upper_ci = conf_high)

## ----regtable-broom, echo=FALSE, message=FALSE, warning=FALSE------------
library(broom)
library(janitor)
score_model %>%
  tidy(conf.int = TRUE) %>%
  mutate_if(is.numeric, round, digits = 3) %>%
  clean_names() %>%
  rename(lower_ci = conf_low,
         upper_ci = conf_high) %>%
  knitr::kable(
    digits = 3,
    caption = "Regression table using tidy() from broom package.",
    booktabs = TRUE
  ) %>%
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))


## ---- eval=FALSE---------------------------------------------------------
## library(broom)
## library(janitor)
## score_model %>%
##   augment() %>%
##   mutate_if(is.numeric, round, digits = 3) %>%
##   clean_names() %>%
##   select(-c("se_fit", "hat", "sigma", "cooksd", "std_resid"))

## ----regpoints-augment, echo=FALSE---------------------------------------
library(broom)
library(janitor)
score_model %>%
  augment() %>%
  mutate_if(is.numeric, round, digits = 3) %>%
  clean_names() %>%
  select(-c("se_fit", "hat", "sigma", "cooksd", "std_resid")) %>%
  slice(1:10) %>%
  knitr::kable(
    digits = 3,
    caption = "Regression points using augment() from broom package.",
    booktabs = TRUE
  ) %>%
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))

