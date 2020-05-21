## ----appendixb, echo=FALSE, results="asis"------------------------------------
if(!knitr::is_latex_output()){
  cat("If you'd like more practice or you're curious to see how this framework applies to different scenarios, you can find fully-worked out examples for many common hypothesis tests and their corresponding confidence intervals in Appendix B. ")
  cat("We recommend that you carefully review these examples as they also cover how the general frameworks apply to traditional theory-based methods like the $t$-test and normal-theory confidence intervals.  You'll see there that these traditional methods are just approximations for the computer-based methods we've been focusing on. However, they also require conditions to be met for their results to be valid. Computer-based methods using randomization, simulation, and bootstrapping have much fewer restrictions. Furthermore, they help develop your computational thinking, which is one big reason they are emphasized throughout this book.")
}


## ----message=FALSE, warning=FALSE---------------------------------------------
library(tidyverse)
library(infer)
library(moderndive)
library(nycflights13)
library(ggplot2movies)


## ----message=FALSE, warning=FALSE, echo=FALSE---------------------------------
# Packages needed internally, but not in text.
library(knitr)
library(kableExtra)
library(patchwork)
library(scales)
library(viridis)


## ----echo=FALSE---------------------------------------------------------------
set.seed(2102)


## -----------------------------------------------------------------------------
promotions %>% 
  sample_n(size = 6) %>% 
  arrange(id)


## ----eval=FALSE---------------------------------------------------------------
## ggplot(promotions, aes(x = gender, fill = decision)) +
##   geom_bar() +
##   labs(x = "Gender of name on résumé")


## ----promotions-barplot, echo=FALSE, fig.cap="Barplot relating gender to promotion decision.", fig.height=1.6----
promotions_barplot <- ggplot(promotions, aes(x = gender, fill = decision)) +
  geom_bar() +
  labs(x = "Gender of name on résumé")
if(knitr::is_html_output()){
  promotions_barplot
} else {
  promotions_barplot + scale_fill_grey()
}


## -----------------------------------------------------------------------------
promotions %>% 
  group_by(gender, decision) %>% 
  tally()


## ---- echo=FALSE--------------------------------------------------------------
observed_test_statistic <- promotions %>% 
  specify(decision ~ gender, success = "promoted") %>% 
  calculate(stat = "diff in props", order = c("male", "female")) %>% 
  pull(stat) %>% 
  round(3)


## ----compare-six, echo=FALSE--------------------------------------------------
set.seed(2019)
# Pick out 6 rows
promotions_sample <- promotions %>%
  slice(c(36, 39, 40, 1, 2, 22)) %>% 
  mutate(`shuffled gender` = sample(gender)) %>% 
  select(-id) %>% 
  mutate(`résumé number` = 1:n()) %>% 
  select(`résumé number`, everything())

promotions_sample  %>% 
  kable(
    caption = "One example of shuffling gender variable", 
    booktabs = TRUE,
    longtable = TRUE,
    linesep = ""
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position", "repeat_header"))






## ---- eval=FALSE--------------------------------------------------------------
## promotions_shuffled %>% slice(c(11, 26, 28, 36, 37, 46))


## ---- eval=FALSE--------------------------------------------------------------
## ggplot(promotions_shuffled,
##        aes(x = gender, fill = decision)) +
##   geom_bar() +
##   labs(x = "Gender of résumé name")

## ----promotions-barplot-permuted, fig.cap="Barplots of relationship of promotion with gender (left) and shuffled gender (right).", fig.height=4.7, echo=FALSE----
height1 <- promotions %>% 
  group_by(gender, decision) %>% 
  summarize(n = n()) %>% 
  pull(n) %>% 
  max()
height2 <- promotions_shuffled %>% 
  group_by(gender, decision) %>% 
  summarize(n = n()) %>% 
  pull(n) %>% 
  max()
height <- max(height1, height2)

plot1 <- ggplot(promotions, aes(x = gender, fill = decision)) +
  geom_bar() +
  labs(x = "Gender of résumé name", title = "Original") +
  theme(legend.position = "none") +
  coord_cartesian(ylim= c(0, height))
plot2 <- ggplot(promotions_shuffled, aes(x = gender, fill = decision)) +
  geom_bar() +
  labs(x = "Gender of résumé name", y ="", title = "Shuffled") +
  coord_cartesian(ylim= c(0, height))
if(knitr::is_html_output()){
  plot1 + plot2
} else {
    (plot1 + scale_fill_grey()) + (plot2 + scale_fill_grey())
}


## -----------------------------------------------------------------------------
promotions_shuffled %>% 
  group_by(gender, decision) %>% 
  tally() # Same as summarize(n = n())

## ---- echo=FALSE--------------------------------------------------------------
# male stats
n_men_promoted <- promotions_shuffled %>% 
  filter(decision == "promoted", gender == "male") %>% 
  nrow()
n_men_not_promoted <- promotions_shuffled %>% 
  filter(decision == "not", gender == "male") %>% 
  nrow()
prop_men_promoted <- n_men_promoted/(n_men_promoted + n_men_not_promoted)

# female stats  
n_women_promoted <- promotions_shuffled %>% 
  filter(decision == "promoted", gender == "female") %>% 
  nrow()
n_women_not_promoted <- promotions_shuffled %>% 
  filter(decision == "not", gender == "female") %>% 
  nrow()
prop_women_promoted <- n_women_promoted/(n_women_promoted + n_women_not_promoted)

# diff
diff_prop <- round(prop_men_promoted - prop_women_promoted, 3)

# round propotions post difference
prop_men_promoted <- round(prop_men_promoted, 3)
prop_women_promoted <- round(prop_women_promoted, 3)




## ---- eval=TRUE, echo=FALSE, message=FALSE, warning=FALSE---------------------
# https://docs.google.com/spreadsheets/d/1Q-ENy3o5IrpJshJ7gn3hJ5A0TOWV2AZrKNHMsshQtiE/edit#gid=0
if(!file.exists("rds/shuffled_data.rds")){
  shuffled_data <- read_csv("https://docs.google.com/spreadsheets/d/e/2PACX-1vQXLJxwSp1ALEJ1JRNn3o8K3jVdqRG_5yxpoOhIFYflbFIkb2ttH73w8mljptn12CsDyIvjr5p0IGUe/pub?gid=0&single=true&output=csv")
  write_rds(shuffled_data, "rds/shuffled_data.rds")
} else {
  shuffled_data <- read_rds("rds/shuffled_data.rds")
}
n_replicates <- ncol(shuffled_data) - 2

shuffled_data_tidy <- shuffled_data %>% 
  gather(team, gender, -c(id, decision)) %>% 
  mutate(replicate = rep(1:n_replicates, each = 48))

# Sanity check results
# shuffled_data_tidy %>% group_by(replicate) %>% count(gender) %>% filter(n != 24) %>% View()

shuffled_data_tidy <- shuffled_data_tidy %>% 
  group_by(replicate) %>% 
  count(gender, decision) %>% 
  filter(decision == "promoted") %>% 
  mutate(prop = n/24) %>% 
  select(replicate, gender, prop) %>% 
  spread(gender, prop) %>% 
  mutate(stat = m - f) 




## ---- eval=FALSE--------------------------------------------------------------
## obs_diff_prop <- promotions %>%
##   specify(decision ~ gender, success = "promoted") %>%
##   calculate(stat = "diff in props", order = c("male", "female"))
## obs_diff_prop


## ----echo=FALSE, eval=FALSE---------------------------------------------------
## set.seed(2019)
## tactile_permutes <- promotions %>%
##   specify(decision ~ gender, success = "promoted") %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 33, type = "permute") %>%
##   calculate(stat = "diff in props", order = c("male", "female"))
## ggplot(data = tactile_permutes, aes(x = stat)) +
##   geom_histogram(binwidth = 0.05, boundary = -0.2, color = "white") +
##   geom_vline(xintercept = pull(obs_diff_prop), color = "blue", size = 2) +
##   scale_y_continuous(breaks = 0:10)


## ----table-diff-prop, echo=FALSE, message=FALSE-------------------------------
# The following Google Doc is published to CSV and loaded using read_csv():
# https://docs.google.com/spreadsheets/d/1QkOpnBGqOXGyJjwqx1T2O5G5D72wWGfWlPyufOgtkk4/edit#gid=0

if(!file.exists("rds/sampling_scenarios.rds")){
  sampling_scenarios <- "https://docs.google.com/spreadsheets/d/e/2PACX-1vRd6bBgNwM3z-AJ7o4gZOiPAdPfbTp_V15HVHRmOH5Fc9w62yaG-fEKtjNUD2wOSa5IJkrDMaEBjRnA/pub?gid=0&single=true&output=csv" %>% 
    read_csv(na = "") %>% 
    slice(1:5)
  write_rds(sampling_scenarios, "rds/sampling_scenarios.rds")
} else {
  sampling_scenarios <- read_rds("rds/sampling_scenarios.rds")
}

sampling_scenarios %>% 
  # Only first two scenarios
  filter(Scenario <= 3) %>% 
  kable(
    caption = "Scenarios of sampling for inference", 
    booktabs = TRUE,
    escape = FALSE,
    linesep = ""
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position")) %>%
  column_spec(1, width = "0.5in") %>% 
  column_spec(2, width = "0.7in") %>%
  column_spec(3, width = "1in") %>%
  column_spec(4, width = "1.1in") %>% 
  column_spec(5, width = "1in")




## ---- echo=FALSE--------------------------------------------------------------
num <- sum(shuffled_data_tidy$stat >= observed_test_statistic)
denom <- nrow(shuffled_data_tidy)
p_val <- round((num + 1)/(denom + 1),3)






## ---- echo=FALSE--------------------------------------------------------------
alpha <- 0.05


## -----------------------------------------------------------------------------
promotions %>% 
  specify(formula = decision ~ gender, success = "promoted") 


## -----------------------------------------------------------------------------
promotions %>% 
  specify(formula = decision ~ gender, success = "promoted") %>% 
  hypothesize(null = "independence")


## ----eval=FALSE---------------------------------------------------------------
## promotions_generate <- promotions %>%
##   specify(formula = decision ~ gender, success = "promoted") %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute")
## nrow(promotions_generate)




## ----eval=FALSE---------------------------------------------------------------
## null_distribution <- promotions %>%
##   specify(formula = decision ~ gender, success = "promoted") %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute") %>%
##   calculate(stat = "diff in props", order = c("male", "female"))
## null_distribution




## -----------------------------------------------------------------------------
obs_diff_prop <- promotions %>% 
  specify(decision ~ gender, success = "promoted") %>% 
  calculate(stat = "diff in props", order = c("male", "female"))
obs_diff_prop


## ----null-distribution-infer, fig.show='hold', fig.cap="Null distribution.", fig.height=1.8----
visualize(null_distribution, bins = 10)


## ----null-distribution-infer-2, fig.cap="Shaded histogram to show $p$-value."----
visualize(null_distribution, bins = 10) + 
  shade_p_value(obs_stat = obs_diff_prop, direction = "right")


## -----------------------------------------------------------------------------
null_distribution %>% 
  get_p_value(obs_stat = obs_diff_prop, direction = "right")

## ---- echo=FALSE--------------------------------------------------------------
p_value <- null_distribution %>% 
  get_p_value(obs_stat = obs_diff_prop, direction = "right") %>% 
  mutate(p_value = round(p_value, 3))


## ----eval=FALSE---------------------------------------------------------------
## null_distribution <- promotions %>%
##   specify(formula = decision ~ gender, success = "promoted") %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute") %>%
##   calculate(stat = "diff in props", order = c("male", "female"))


## ----eval=FALSE---------------------------------------------------------------
## bootstrap_distribution <- promotions %>%
##   specify(formula = decision ~ gender, success = "promoted") %>%
##   # Change 1 - Remove hypothesize():
##   # hypothesize(null = "independence") %>%
##   # Change 2 - Switch type from "permute" to "bootstrap":
##   generate(reps = 1000, type = "bootstrap") %>%
##   calculate(stat = "diff in props", order = c("male", "female"))




## -----------------------------------------------------------------------------
percentile_ci <- bootstrap_distribution %>% 
  get_confidence_interval(level = 0.95, type = "percentile")
percentile_ci


## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_confidence_interval(endpoints = percentile_ci)



## -----------------------------------------------------------------------------
se_ci <- bootstrap_distribution %>% 
  get_confidence_interval(level = 0.95, type = "se", 
                          point_estimate = obs_diff_prop)
se_ci


## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_confidence_interval(endpoints = se_ci)













## ----eval=FALSE, echo=FALSE---------------------------------------------------
## tibble(
##   verdict = c("Not guilty verdict", "Guilty verdict"),
##   `Truly not guilty` = c("Correct", "Type I error"),
##   `Truly guilty` = c("Type II error", "Correct")
## ) %>%
##   gt(rowname_col = "verdict") %>%
## #  tab_header(title = "Type I and Type II errors in US trials",
## #             label="tab:trial-errors-table") %>%
##   tab_row_group(group = "Verdict")   %>%
##   tab_spanner(
##     label = "Truth",
##     columns = vars(`Truly not guilty`, `Truly guilty`)
##   ) %>%
##   cols_align(align = "center") %>%
##   tab_options(table.width = pct(90))


## ----trial-errors-table, echo=FALSE, fig.cap="Type I and Type II errors in criminal trials."----
knitr::include_graphics("images/gt_error_table.png")


## ----hypo-test-errors, eval=FALSE, echo=FALSE---------------------------------
## tibble(
##   Decision = c("Fail to reject H0", "Reject H0"),
##   `H0 true` = c("Correct", "Type I error"),
##   `HA true` = c("Type II error", "Correct")
## ) %>%
##   gt(rowname_col = "Decision") %>%
## #  tab_header(title = "Type I and Type II errors hypothesis tests",
## #                          label="tab:trial-errors-table-ht") %>%
##   tab_row_group(group = "Verdict") %>%
##   tab_spanner(
##     label = "Truth",
##     columns = vars(`H0 true`, `HA true`)
##   ) %>%
##   cols_align(align = "center") %>%
##   tab_options(table.width = pct(90))


## ----trial-errors-table-ht, echo=FALSE, fig.cap="Type I and Type II errors in hypothesis tests."----
knitr::include_graphics("images/gt_error_table_ht.png")






## -----------------------------------------------------------------------------
movies


## -----------------------------------------------------------------------------
movies_sample


## ----action-romance-boxplot, fig.cap="Boxplot of IMDb rating vs. genre.", fig.height=2.7----
ggplot(data = movies_sample, aes(x = genre, y = rating)) +
  geom_boxplot() +
  labs(y = "IMDb rating")


## -----------------------------------------------------------------------------
movies_sample %>% 
  group_by(genre) %>% 
  summarize(n = n(), mean_rating = mean(rating), std_dev = sd(rating))

## ---- echo=FALSE--------------------------------------------------------------
movies_genre_summaries <- movies_sample %>% 
  group_by(genre) %>% 
  summarize(n = n(), mean_rating = mean(rating), std_dev = sd(rating))

x_bar_action <- movies_genre_summaries %>% 
  filter(genre == "Action") %>% 
  pull(mean_rating)
x_bar_romance <- movies_genre_summaries %>% 
  filter(genre == "Romance") %>% 
  pull(mean_rating)
n_action <- movies_genre_summaries %>% 
  filter(genre == "Action") %>% 
  pull(n)
n_romance <- movies_genre_summaries %>% 
  filter(genre == "Romance") %>% 
  pull(n)


## ----summarytable-ch10, echo=FALSE, message=FALSE-----------------------------
# The following Google Doc is published to CSV and loaded using read_csv():
# https://docs.google.com/spreadsheets/d/1QkOpnBGqOXGyJjwqx1T2O5G5D72wWGfWlPyufOgtkk4/edit#gid=0

if(!file.exists("rds/sampling_scenarios.rds")){
  sampling_scenarios <- "https://docs.google.com/spreadsheets/d/e/2PACX-1vRd6bBgNwM3z-AJ7o4gZOiPAdPfbTp_V15HVHRmOH5Fc9w62yaG-fEKtjNUD2wOSa5IJkrDMaEBjRnA/pub?gid=0&single=true&output=csv" %>% 
    read_csv(na = "") %>% 
    slice(1:5)
  write_rds(sampling_scenarios, "rds/sampling_scenarios.rds")
} else {
  sampling_scenarios <- read_rds("rds/sampling_scenarios.rds")
}

sampling_scenarios %>% 
  filter(Scenario %in% c(1:4)) %>% 
  kable(
    caption = "Scenarios of sampling for inference", 
    booktabs = TRUE,
    escape = FALSE,
    linesep = ""
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position")) %>%
  column_spec(1, width = "0.5in") %>% 
  column_spec(2, width = "0.7in") %>%
  column_spec(3, width = "1in") %>%
  column_spec(4, width = "1.1in") %>% 
  column_spec(5, width = "1in")


## -----------------------------------------------------------------------------
movies_sample %>% 
  specify(formula = rating ~ genre)


## -----------------------------------------------------------------------------
movies_sample %>% 
  specify(formula = rating ~ genre) %>% 
  hypothesize(null = "independence")


## ----eval=FALSE---------------------------------------------------------------
## movies_sample %>%
##   specify(formula = rating ~ genre) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute") %>%
##   View()


## ----echo=FALSE---------------------------------------------------------------
set.seed(76)
if(!file.exists("rds/movies_sample_generate.rds")){
  movies_sample_generate <- movies_sample %>% 
    specify(formula = rating ~ genre) %>% 
    hypothesize(null = "independence") %>% 
    generate(reps = 1000, type = "permute")
  write_rds(movies_sample_generate, "rds/movies_sample_generate.rds")
} else {
  movies_sample_generate <- read_rds("rds/movies_sample_generate.rds")
}


## ----eval=FALSE---------------------------------------------------------------
## null_distribution_movies <- movies_sample %>%
##   specify(formula = rating ~ genre) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute") %>%
##   calculate(stat = "diff in means", order = c("Action", "Romance"))
## null_distribution_movies




## -----------------------------------------------------------------------------
obs_diff_means <- movies_sample %>% 
  specify(formula = rating ~ genre) %>% 
  calculate(stat = "diff in means", order = c("Action", "Romance"))
obs_diff_means


## ----eval=FALSE---------------------------------------------------------------
## visualize(null_distribution_movies, bins = 10) +
##   shade_p_value(obs_stat = obs_diff_means, direction = "both")


## ----null-distribution-movies-2, echo=FALSE, fig.cap="Null distribution, observed test statistic, and $p$-value.", fig.height=1.8----
if(knitr::is_html_output()){
  visualize(null_distribution_movies, bins = 10) + 
    shade_p_value(obs_stat = obs_diff_means, direction = "both")
} else {
  visualize(null_distribution_movies, bins = 10) + 
    shade_p_value(obs_stat = obs_diff_means, direction = "both",
                              fill = "grey40", color = "grey30") 
}


## -----------------------------------------------------------------------------
null_distribution_movies %>% 
  get_p_value(obs_stat = obs_diff_means, direction = "both")

## ---- echo=FALSE--------------------------------------------------------------
p_value_movies <- null_distribution_movies %>% 
  get_p_value(obs_stat = obs_diff_means, direction = "both") %>% 
  mutate(p_value = round(p_value, 3))






## ----zcurve, echo=FALSE, out.width="100%", fig.cap="Standard normal z curve.", fig.height=1.3----
ggplot(data.frame(x = c(-4, 4)), aes(x)) + stat_function(fun = dnorm) +
  labs(x = "z", y = "") + 
  theme_light() +
  theme(
    axis.title.y = element_blank(),
    axis.title.x = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank()
  )




## -----------------------------------------------------------------------------
movies_sample %>% 
  group_by(genre) %>% 
  summarize(n = n(), mean_rating = mean(rating), std_dev = sd(rating))

## ---- echo=FALSE--------------------------------------------------------------
t_stat <- movies_sample %>% 
  specify(formula = rating ~ genre) %>% 
  calculate(stat = "t", order = c("Action", "Romance")) %>% 
  pull(stat) %>% 
  round(3)


## ---- eval=FALSE--------------------------------------------------------------
## # Construct null distribution of xbar_a - xbar_r:
## null_distribution_movies <- movies_sample %>%
##   specify(formula = rating ~ genre) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute") %>%
##   calculate(stat = "diff in means", order = c("Action", "Romance"))
## visualize(null_distribution_movies, bins = 10)


## ----eval=FALSE---------------------------------------------------------------
## # Construct null distribution of t:
## null_distribution_movies_t <- movies_sample %>%
##   specify(formula = rating ~ genre) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute") %>%
##   # Notice we switched stat from "diff in means" to "t"
##   calculate(stat = "t", order = c("Action", "Romance"))
## visualize(null_distribution_movies_t, bins = 10)




## ----comparing-diff-means-t-stat, fig.align='center', fig.height=3, fig.cap="Comparing the null distributions of two test statistics.", echo=FALSE----
# Visualize:
null_dist_1 <- visualize(null_distribution_movies, bins = 10) +
  labs(title = "Difference in means")
null_dist_2 <- visualize(null_distribution_movies_t, bins = 10) +
  labs(title = "Two-sample t-statistic")
null_dist_1 + null_dist_2


## ----t-stat-3, fig.align='center', fig.cap="Null distribution using t-statistic and t-distribution.", fig.height=2.2----
visualize(null_distribution_movies_t, bins = 10, method = "both")


## -----------------------------------------------------------------------------
obs_two_sample_t <- movies_sample %>% 
  specify(formula = rating ~ genre) %>% 
  calculate(stat = "t", order = c("Action", "Romance"))
obs_two_sample_t


## ----t-stat-4, fig.align='center', fig.cap="Null distribution using t-statistic and t-distribution with $p$-value shaded.", warning=TRUE, fig.height=1.7----
visualize(null_distribution_movies_t, method = "both") +
  shade_p_value(obs_stat = obs_two_sample_t, direction = "both")


## -----------------------------------------------------------------------------
null_distribution_movies_t %>% 
  get_p_value(obs_stat = obs_two_sample_t, direction = "both")


## -----------------------------------------------------------------------------
flights_sample <- flights %>% 
  filter(carrier %in% c("HA", "AS"))


## ----ha-as-flights-boxplot, fig.cap="Air time for Hawaiian and Alaska Airlines flights departing NYC in 2013.", fig.height=2.8----
ggplot(data = flights_sample, mapping = aes(x = carrier, y = air_time)) +
  geom_boxplot() +
  labs(x = "Carrier", y = "Air Time")


## -----------------------------------------------------------------------------
flights_sample %>% 
  group_by(carrier, dest) %>% 
  summarize(n = n(), mean_time = mean(air_time, na.rm = TRUE))


## ----echo=FALSE, results="asis"-----------------------------------------------
if(knitr::is_latex_output()){
  cat("Solutions to all *Learning checks* can be found online in [Appendix D](https://moderndive.com/D-appendixD.html).")
} 






## ---- eval=FALSE--------------------------------------------------------------
## # Fit regression model:
## score_model <- lm(score ~ bty_avg, data = evals)
## 
## # Get regression table:
## get_regression_table(score_model)


## ----regression-table-inference, echo=FALSE-----------------------------------
# Fit regression model:
score_model <- lm(score ~ bty_avg, data = evals)
# Get regression table:
get_regression_table(score_model) %>%
  knitr::kable(
    digits = 3,
    caption = "Linear regression table",
    booktabs = TRUE,
    linesep = ""
  ) %>%
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))

