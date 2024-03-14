## ----eval=FALSE---------------------------------------------------------------
## library(tidyverse)
## library(moderndive)
## library(skimr)
## library(gapminder)

## ----echo=FALSE, message=FALSE, purl=TRUE-------------------------------------
# The code presented to the reader in the chunk above is different than the code
# in this chunk that is actually run to build the book. In particular we do not
# load the skimr package.
# 
# This is because skimr v1.0.6 which we used for the book causes all
# kable() code to break for the remaining chapters in the book. v2 might
# fix these issues:
# https://github.com/moderndive/ModernDive_book/issues/271

# As a workaround for v1 of ModernDive, all skimr::skim() output in this chapter
# has been hard coded.
library(tidyverse)
library(moderndive)
# library(skimr)
library(gapminder)






## -----------------------------------------------------------------------------
evals_ch5 <- evals %>%
  select(ID, score, bty_avg, age)


## -----------------------------------------------------------------------------
glimpse(evals_ch5)




## ----eval=FALSE---------------------------------------------------------------
## evals_ch5 %>%
##   sample_n(size = 5)



## -----------------------------------------------------------------------------
evals_ch5 %>%
  summarize(mean_bty_avg = mean(bty_avg), mean_score = mean(score),
            median_bty_avg = median(bty_avg), median_score = median(score))


## ----eval=FALSE---------------------------------------------------------------
## evals_ch5 %>% select(score, bty_avg) %>% skim()




## -----------------------------------------------------------------------------
evals_ch5 %>% 
  get_correlation(formula = score ~ bty_avg)


## ----eval=FALSE---------------------------------------------------------------
## evals_ch5 %>%
##   summarize(correlation = cor(score, bty_avg))




## ----eval=FALSE---------------------------------------------------------------
## ggplot(evals_ch5, aes(x = bty_avg, y = score)) +
##   geom_point() +
##   labs(x = "Beauty Score",
##        y = "Teaching Score",
##        title = "Scatterplot of relationship of teaching and beauty scores")




## ----eval=FALSE---------------------------------------------------------------
## ggplot(evals_ch5, aes(x = bty_avg, y = score)) +
##   geom_jitter() +
##   labs(x = "Beauty Score", y = "Teaching Score",
##        title = "Scatterplot of relationship of teaching and beauty scores")



## ----numxplot3, fig.cap="Regression line.", message=FALSE---------------------
ggplot(evals_ch5, aes(x = bty_avg, y = score)) +
  geom_point() +
  labs(x = "Beauty Score", y = "Teaching Score",
       title = "Relationship between teaching and beauty scores") +  
  geom_smooth(method = "lm", se = FALSE)






## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## score_model <- lm(score ~ bty_avg, data = evals_ch5)
## # Get regression table:
## get_regression_table(score_model)




## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## score_model <- lm(score ~ bty_avg, data = evals_ch5)
## # Get regression table:
## get_regression_table(score_model)












## ----eval=FALSE---------------------------------------------------------------
## regression_points <- get_regression_points(score_model)
## regression_points










## ----message=FALSE------------------------------------------------------------
library(gapminder)
gapminder2007 <- gapminder %>%
  filter(year == 2007) %>%
  select(country, lifeExp, continent, gdpPercap)




## -----------------------------------------------------------------------------
glimpse(gapminder2007)


## ----eval=FALSE---------------------------------------------------------------
## gapminder2007 %>% sample_n(size = 5)



## ----eval=FALSE---------------------------------------------------------------
## gapminder2007 %>%
##   select(lifeExp, continent) %>%
##   skim()




## ----lifeExp2007hist, echo=TRUE, fig.cap="Histogram of life expectancy in 2007.", fig.height=5.2----
ggplot(gapminder2007, aes(x = lifeExp)) +
  geom_histogram(binwidth = 5, color = "white") +
  labs(x = "Life expectancy", y = "Number of countries",
       title = "Histogram of distribution of worldwide life expectancies")


## ----eval=FALSE---------------------------------------------------------------
## ggplot(gapminder2007, aes(x = lifeExp)) +
##   geom_histogram(binwidth = 5, color = "white") +
##   labs(x = "Life expectancy",
##        y = "Number of countries",
##        title = "Histogram of distribution of worldwide life expectancies") +
##   facet_wrap(~ continent, nrow = 2)




## ----catxplot1, fig.cap="Life expectancy in 2007.", fig.height=3.4------------
ggplot(gapminder2007, aes(x = continent, y = lifeExp)) +
  geom_boxplot() +
  labs(x = "Continent", y = "Life expectancy",
       title = "Life expectancy by continent")


## ----eval=TRUE----------------------------------------------------------------
lifeExp_by_continent <- gapminder2007 %>%
  group_by(continent) %>%
  summarize(median = median(lifeExp), 
            mean = mean(lifeExp))











## ----eval=FALSE---------------------------------------------------------------
## lifeExp_model <- lm(lifeExp ~ continent, data = gapminder2007)
## get_regression_table(lifeExp_model)








## ----eval=FALSE---------------------------------------------------------------
## regression_points <- get_regression_points(lifeExp_model, ID = "country")
## regression_points















## -----------------------------------------------------------------------------
# Fit regression model:
score_model <- lm(score ~ bty_avg, 
                  data = evals_ch5)

# Get regression points:
regression_points <- get_regression_points(score_model)
regression_points
# Compute sum of squared residuals
regression_points %>%
  mutate(squared_residuals = residual^2) %>%
  summarize(sum_of_squared_residuals = sum(squared_residuals))








## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## score_model <- lm(formula = score ~ bty_avg, data = evals_ch5)
## # Get regression table:
## get_regression_table(score_model)




## ----eval=FALSE---------------------------------------------------------------
## library(broom)
## library(janitor)
## score_model %>%
##   tidy(conf.int = TRUE) %>%
##   mutate_if(is.numeric, round, digits = 3) %>%
##   clean_names() %>%
##   rename(lower_ci = conf_low, upper_ci = conf_high)



## ----eval=FALSE---------------------------------------------------------------
## library(broom)
## library(janitor)
## score_model %>%
##   augment() %>%
##   mutate_if(is.numeric, round, digits = 3) %>%
##   clean_names() %>%
##   select(-c("std_resid", "hat", "sigma", "cooksd", "std_resid"))

