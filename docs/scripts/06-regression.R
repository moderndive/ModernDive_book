## ---- message=FALSE, warning=FALSE, include=FALSE------------------------
# library(remotes)
# remotes::install_github("moderndive/moderndive")

## ---- message=FALSE, warning=FALSE---------------------------------------
library(ggplot2)
library(dplyr)
library(moderndive)

## ---- message=FALSE, warning=FALSE, echo=FALSE---------------------------
# Packages needed internally, but not in text.
library(mvtnorm)
library(tidyr)
library(forcats)
library(gridExtra)

## ------------------------------------------------------------------------
load(url("http://www.openintro.org/stat/data/evals.RData"))
evals <- evals %>%
  select(score, bty_avg)

## ---- echo=FALSE---------------------------------------------------------
set.seed(76)
evals %>%
  sample_n(5) %>%
  knitr::kable(
    digits = 3,
    caption = "Random sample of 5 instructors",
    booktabs = TRUE
  )

## ------------------------------------------------------------------------
glimpse(evals)

## ------------------------------------------------------------------------
evals %>% 
  summary()

## ----correlation1, echo=FALSE, fig.cap="Different correlation coefficients"----
correlation <- c(-0.9999, -0.75, 0, 0.75, 0.9999)
n_sim <- 100

values <- NULL
for(i in 1:length(correlation)){
  rho <- correlation[i]
  sigma <- matrix(c(5, rho * sqrt(50), rho * sqrt(50), 10), 2, 2) 
  sim <- rmvnorm(
    n = n_sim,
    mean = c(20,40),
    sigma = sigma
    ) %>%
    as_data_frame() %>% 
    mutate(correlation = round(rho, 2))
  
  values <- bind_rows(values, sim)
}

ggplot(data = values, mapping = aes(V1, V2)) +
  geom_point() +
  facet_wrap(~ correlation, nrow = 2) +
  labs(x = "x", y = "y") + 
  theme(
    axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks = element_blank()
  )

## ------------------------------------------------------------------------
cor(evals$score, evals$bty_avg)

## ----numxplot1, warning=FALSE, fig.cap="Instructor evaluation scores at UT Austin"----
ggplot(evals, aes(x = bty_avg, y = score)) +
  geom_point() +
  labs(x = "Beauty Score", y = "Teaching Score", title = "Relationship of teaching and beauty scores")

## ----numxplot2, warning=FALSE, fig.cap="Instructor evaluation scores at UT Austin: Jittered"----
ggplot(evals, aes(x = bty_avg, y = score)) +
  geom_jitter() +
  labs(x = "Beauty Score", y = "Teaching Score", title = "Relationship of teaching and beauty scores")

## ----numxplot3, warning=FALSE, fig.cap="Regression line"-----------------
ggplot(evals, aes(x = bty_avg, y = score)) +
  geom_jitter() +
  labs(x = "Beauty Score", y = "Teaching Score", title = "Relationship of teaching and beauty scores") +  
  geom_smooth(method = "lm")

## ----numxplot4, warning=FALSE, fig.cap="Regression line without error bands"----
ggplot(evals, aes(x = bty_avg, y = score)) +
  geom_jitter() +
  labs(x = "Beauty Score", y = "Teaching Score", title = "Relationship of teaching and beauty scores") +
  geom_smooth(method = "lm", se = FALSE)

## ---- eval=FALSE---------------------------------------------------------
## lm(score ~ bty_avg, data = evals) %>%
##   get_regression_table(digits = 2)

## ---- echo=FALSE---------------------------------------------------------
score_model <- lm(score ~ bty_avg, data = evals)
evals_line <- score_model %>% 
  get_regression_table() %>%
  pull(estimate)

## ----numxplot4b, echo=FALSE----------------------------------------------
score_model %>% 
  get_regression_table() %>%
  knitr::kable(
    digits = 3,
    caption = "Linear regression table",
    booktabs = TRUE
  )

## ---- echo=FALSE---------------------------------------------------------
index <- which(evals$bty_avg == 7.333 & evals$score == 4.9)
target_point <- score_model %>% 
  get_regression_points() %>% 
  slice(index)
x <- target_point$bty_avg
y <- target_point$score
y_hat <- target_point$score_hat
resid <- target_point$residual
evals %>%
  slice(index) %>%
  knitr::kable(
    digits = 3,
    caption = "Data for 21st instructor",
    booktabs = TRUE
  )

## ----numxplot5, echo=FALSE, warning=FALSE, fig.cap="Example of observed value, fitted value, and residual"----
best_fit_plot <- ggplot(evals, aes(x = bty_avg, y = score)) +
  geom_point() +
  labs(x = "Beauty Score", y = "Teaching Score", title = "Relationship of teaching and beauty scores") + 
  geom_smooth(method = "lm", se = FALSE) +
  annotate("point", x = x, y = y, col = "red", size = 3) +
  annotate("point", x = x, y = y_hat, col = "red", shape = 15, size = 3) +
  annotate("segment", x = x, xend = x, y = y, yend = y_hat, color = "blue",
           arrow = arrow(type = "closed", length = unit(0.02, "npc")))
best_fit_plot

## ---- eval=FALSE---------------------------------------------------------
## regression_points <- get_regression_points(score_model)
## regression_points

## ---- echo=FALSE---------------------------------------------------------
set.seed(76)
regression_points <- get_regression_points(score_model) 
regression_points %>%
  slice(c(index, sample(1:nrow(evals), 4))) %>%
  knitr::kable(
    digits = 3,
    caption = "Regression points (5 arbitrarily chosen rows out of 463)",
    booktabs = TRUE
  )

## ---- eval=FALSE---------------------------------------------------------
## regression_points <- regression_points %>%
##   mutate(score_hat_2 = 3.880 + 0.067 * bty_avg) %>%
##   mutate(residual_2 = score - score_hat_2)
## regression_points

## ---- echo=FALSE---------------------------------------------------------
set.seed(76)
regression_points <- regression_points %>% 
  mutate(score_hat_2 = 3.880 + 0.067 * bty_avg) %>% 
  mutate(residual_2 = score - score_hat_2)
regression_points %>%
  slice(c(index, sample(1:nrow(evals), 4))) %>%
  knitr::kable(
    digits = 3,
    caption = "Regression points (5 arbitrarily chosen rows out of 463)",
    booktabs = TRUE
  )

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
resid_ex <- evals
resid_ex$ex_1 <- ((evals$bty_avg - 5) ^ 2 - 6 + rnorm(nrow(evals), 0, 0.5)) * 0.4
resid_ex$ex_2 <- (rnorm(nrow(evals), 0, 0.075 * evals$bty_avg ^ 2)) * 0.4
  
resid_ex <- resid_ex %>%
  select(bty_avg, ex_1, ex_2) %>%
  gather(type, eps, -bty_avg) %>% 
  mutate(type = ifelse(type == "ex_1", "Example 1", "Example 2"))

ggplot(resid_ex, aes(x = bty_avg, y = eps)) +
  geom_point() +
  labs(x = "Beauty Score", y = "Residual") +
  geom_hline(yintercept = 0, col = "blue", size = 1) +
  facet_wrap(~type)

## ----model1_residuals_hist, warning=FALSE, fig.cap="Histogram of residuals"----
ggplot(regression_points, aes(x = residual)) +
  geom_histogram(binwidth = 0.25, color = "white") +
  labs(x = "Residual")

## ----numxplot9, echo=FALSE, warning=FALSE, fig.cap="Examples of ideal and less than ideal residual patterns"----
resid_ex <- evals
resid_ex$`Ideal` <- rnorm(nrow(resid_ex), 0, sd = sd(regression_points$residual))
resid_ex$`Less than ideal` <-
  rnorm(nrow(resid_ex), 0, sd = sd(regression_points$residual))^2

resid_ex <- resid_ex %>%
  select(bty_avg, `Ideal`, `Less than ideal`) %>%
  gather(type, eps, -bty_avg)

ggplot(resid_ex, aes(x = eps)) +
  geom_histogram(binwidth = 0.25, color = "white") +
  labs(x = "Residual") +
  facet_wrap( ~ type, scales = "free")

## ------------------------------------------------------------------------
load(url("http://www.openintro.org/stat/data/evals.RData"))
evals <- evals %>%
  select(score, age)

## ---- warning=FALSE, message=FALSE---------------------------------------
library(gapminder)
gapminder2007 <- gapminder %>%
  filter(year == 2007) %>% 
  select(country, continent, lifeExp, gdpPercap)

## ---- eval=FALSE---------------------------------------------------------
## View(gapminder2007)

## ----model2-data-preview, echo=FALSE-------------------------------------
gapminder2007 %>%
  sample_n(5) %>%
  knitr::kable(
    digits = 3,
    caption = "Random sample of 5 countries",
    booktabs = TRUE
  )

## ------------------------------------------------------------------------
glimpse(gapminder2007)

## ------------------------------------------------------------------------
summary(gapminder2007$continent)

## ---- eval=TRUE----------------------------------------------------------
lifeExp_worldwide <- gapminder2007 %>%
  summarize(median = median(lifeExp), mean = mean(lifeExp))

## ---- echo=FALSE---------------------------------------------------------
lifeExp_worldwide %>%
  knitr::kable(
    digits = 3,
    caption = "Worldwide life expectancy",
    booktabs = TRUE
  )

## ------------------------------------------------------------------------
ggplot(gapminder2007, aes(x = lifeExp)) +
  geom_histogram(binwidth = 5, color = "white") +
  labs(x = "Life expectancy", y = "Number of countries", title = "Worldwide life expectancy")

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

## ---- echo=FALSE---------------------------------------------------------
median_africa <- lifeExp_by_continent %>%
  filter(continent == "Africa") %>%
  pull(median)
mean_africa <- lifeExp_by_continent %>%
  filter(continent == "Africa") %>%
  pull(mean)
n_countries <- gapminder2007 %>% nrow()
n_countries_africa <- gapminder2007 %>% filter(continent == "Africa") %>% nrow()

## ----catxplot0b, warning=FALSE, fig.cap="Life expectancy in 2007"--------
ggplot(gapminder2007, aes(x = lifeExp)) +
  geom_histogram(binwidth = 5, color = "white") +
  labs(x = "Life expectancy", y = "Number of countries", title = "Life expectancy by continent") +
  facet_wrap(~continent, nrow = 2)

## ----catxplot1, warning=FALSE, fig.cap="Life expectancy in 2007"---------
ggplot(gapminder2007, aes(x = continent, y = lifeExp)) +
  geom_boxplot() +
  labs(x = "Continent", y = "Life expectancy (years)", title = "Life expectancy by continent") 

## ----catxplot1b, warning=FALSE, fig.cap="Life expectancy in 2007"--------
ggplot(gapminder2007, aes(x = continent, y = lifeExp)) +
  geom_boxplot() +
  labs(x = "Continent", y = "Life expectancy (years)", title = "Life expectancy by continent") +
  geom_hline(yintercept = 52.93, color = "red")

## ----catxplot2, warning=FALSE, fig.cap="Difference in life expectancy relative to African median of 52.93 years"----
ggplot(gapminder2007, aes(x = continent, y = lifeExp - 52.93)) +
  geom_boxplot() +
  geom_hline(yintercept = 52.93 - 52.93, col = "red") +
  labs(x = "Continent", y = "Difference in life expectancy vs Africa (years)",
       title = "Life expectancy relative to Africa")

## ----continent-mean-life-expectancies, echo=FALSE------------------------
gapminder2007 %>%
  group_by(continent) %>%
  summarize(mean = mean(lifeExp)) %>%
  mutate(`mean vs Africa` = mean - mean_africa) %>% 
  knitr::kable(
    digits = 3,
    caption = "Mean life expectancy by continent",
    booktabs = TRUE
  )

## ---- eval=FALSE---------------------------------------------------------
## lifeExp_model <- lm(lifeExp ~ continent, data = gapminder2007)
## get_regression_table(lifeExp_model)

## ---- echo=FALSE---------------------------------------------------------
lifeExp_model <- lm(lifeExp ~ continent, data = gapminder2007)
evals_line <- get_regression_table(lifeExp_model) %>%
  pull(estimate)

## ----catxplot4b, echo=FALSE----------------------------------------------
get_regression_table(lifeExp_model) %>%
  knitr::kable(
    digits = 3,
    caption = "Linear regression table",
    booktabs = TRUE
  )

## ---- echo=FALSE---------------------------------------------------------
gapminder2007 %>%
  slice(1:10) %>%
  knitr::kable(
    digits = 3,
    caption = "First 10 out of 142 countries",
    booktabs = TRUE
  )

## ---- eval=FALSE---------------------------------------------------------
## regression_points <- get_regression_points(lifeExp_model)
## regression_points

## ---- echo=FALSE---------------------------------------------------------
regression_points <- get_regression_points(lifeExp_model)
regression_points %>%
  slice(1:10) %>%
  knitr::kable(
    digits = 3,
    caption = "Regression points (First 10 out of 142 countries)",
    booktabs = TRUE
  )

## ----catxplot7, warning=FALSE, fig.cap="Plot of residuals over continent"----
ggplot(regression_points, aes(x = continent, y = residual)) +
  geom_jitter(width = 0.5) + 
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
  )

## ----catxplot8, warning=FALSE, fig.cap="Histogram of residuals"----------
ggplot(regression_points, aes(x = residual)) +
  geom_histogram(binwidth = 5, color = "white") +
  labs(x = "Residual")

## ----correlation2, echo=FALSE, fig.cap="Different Correlation Coefficients"----
correlation <- c(-0.9999, -0.9, -0.75, -0.3, 0, 0.3, 0.75, 0.9, 0.9999)
n_sim <- 100

values <- NULL
for(i in 1:length(correlation)){
  rho <- correlation[i]
  sigma <- matrix(c(5, rho * sqrt(50), rho * sqrt(50), 10), 2, 2) 
  sim <- rmvnorm(
    n = n_sim,
    mean = c(20,40),
    sigma = sigma
    ) %>%
    as_data_frame() %>% 
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

## ----cor-credit, eval=FALSE----------------------------------------------
## library(ISLR)
## Credit %>%
##   select(Balance, Limit, Income) %>%
##   mutate(Income = Income * 1000) %>%
##   cor()

## ----cor-credit-2, echo=FALSE--------------------------------------------
library(ISLR)
Credit %>% 
  select(Balance, Limit, Income) %>% 
  mutate(Income = Income * 1000) %>% 
  cor() %>% 
  knitr::kable(
    digits = 3,
    caption = "Correlation between income (in $) and credit card balance", 
    booktabs = TRUE
  )

## ----echo=FALSE----------------------------------------------------------
load(url("http://www.openintro.org/stat/data/evals.RData"))
evals <- evals %>%
  select(score, bty_avg)
index <- which(evals$bty_avg == 2.333 & evals$score == 2.7)
target_point <- get_regression_points(score_model) %>% 
  slice(index)
x <- target_point$bty_avg
y <- target_point$score
y_hat <- target_point$score_hat
resid <- target_point$residual

best_fit_plot <- best_fit_plot +
  annotate("point", x = x, y = y, col = "red", size = 3) +
  annotate("point", x = x, y = y_hat, col = "red", shape = 15, size = 3) +
  annotate("segment", x = x, xend = x, y = y, yend = y_hat, color = "blue",
           arrow = arrow(type = "closed", length = unit(0.02, "npc")))
best_fit_plot

## ---- echo=FALSE---------------------------------------------------------
index <- which(evals$bty_avg == 3.667 & evals$score == 4.4)
score_model <- lm(score ~ bty_avg, data = evals)
target_point <- get_regression_points(score_model) %>% 
  slice(index)
x <- target_point$bty_avg
y <- target_point$score
y_hat <- target_point$score_hat
resid <- target_point$residual

best_fit_plot <- best_fit_plot +
  annotate("point", x = x, y = y, col = "red", size = 3) +
  annotate("point", x = x, y = y_hat, col = "red", shape = 15, size = 3) +
  annotate("segment", x = x, xend = x, y = y, yend = y_hat,
           color = "blue", 
           arrow = arrow(type = "closed", length = unit(0.02, "npc")))
best_fit_plot

## ----here, echo=FALSE----------------------------------------------------
index <- which(evals$bty_avg == 6 & evals$score == 3.8)
score_model <- lm(score ~ bty_avg, data = evals)
target_point <- get_regression_points(score_model) %>%
  slice(index)
x <- target_point$bty_avg
y <- target_point$score
y_hat <- target_point$score_hat
resid <- target_point$residual

best_fit_plot <- best_fit_plot +
  annotate("point", x = x, y = y, col = "red", size = 3) +
  annotate("point", x = x, y = y_hat, col = "red", shape = 15, size = 3) +
  annotate("segment", x = x, xend = x, y = y, yend = y_hat, color = "blue",
           arrow = arrow(type = "closed", length = unit(0.02, "npc")))
best_fit_plot

