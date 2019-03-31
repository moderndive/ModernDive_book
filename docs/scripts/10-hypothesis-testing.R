## ----message=FALSE, warning=FALSE----------------------------------------
library(tidyverse)
library(janitor)
library(infer)
library(moderndive)
library(ggplot2movies)
library(nycflights13)


## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in text.
library(knitr)
library(kableExtra)
library(gt)
#library(nycflights13)
#library(broom)


## ----eval=FALSE, echo=FALSE----------------------------------------------
## gender_promotions <- readRDS("rds/gender.discrimination.rds") %>%
##   sample_n(size = 48, replace = FALSE) %>%
##   mutate(id = 1:nrow(gender_promotions)) %>%
##   select(id, decision, gender) %>%
##   mutate(decision = factor(decision, levels = c("promoted", "not")),
##          gender = factor(gender, levels = c("male", "female"))) %>%
##   as_tibble()
## readr::write_rds(gender_promotions, "rds/gender_promotions.rds")


## ----echo=FALSE----------------------------------------------------------
gender_promotions <- read_rds("rds/gender_promotions.rds")


## ------------------------------------------------------------------------
gender_promotions
glimpse(gender_promotions)


## ------------------------------------------------------------------------
gender_promotions %>% 
  tabyl(gender, decision) %>% 
  adorn_percentages() %>% 
  adorn_pct_formatting() %>% 
  # To show original counts
  adorn_ns()


## ----compare-first-10, echo=FALSE----------------------------------------
set.seed(2019)
one_permute <- gender_promotions %>%
  mutate(gender = sample(gender)) %>% 
  select(id, decision, gender)
first_10 <- list(gender_promotions %>% slice(1:10),
                 one_permute %>% slice(1:10))
first_10 %>% 
  kable(
    caption = "\\label{tab:compare-first-10}First 10 rows of original (left) and permuted (right) data", 
    booktabs = TRUE,
    longtable = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position", "repeat_header"))


## ----echo=FALSE----------------------------------------------------------
one_permute %>% 
  tabyl(gender, decision) %>% 
  adorn_percentages() %>% 
  adorn_pct_formatting() %>% 
  # To show original counts
  adorn_ns()


## ------------------------------------------------------------------------
obs_diff_prop <- gender_promotions %>% 
  specify(decision ~ gender, success = "promoted") %>% 
  calculate(stat = "diff in props", order = c("male", "female"))
obs_diff_prop


## ----echo=FALSE----------------------------------------------------------
set.seed(2019)
tactile_permutes <- gender_promotions %>% 
  specify(decision ~ gender, success = "promoted") %>% 
  hypothesize(null = "independence") %>% 
  generate(reps = 33, type = "permute") %>% 
  calculate(stat = "diff in props", order = c("male", "female"))
ggplot(data = tactile_permutes, aes(x = stat)) +
  geom_histogram(binwidth = 0.05, boundary = -0.2, color = "white") +
  geom_vline(xintercept = pull(obs_diff_prop), color = "blue", size = 2) +
  scale_y_continuous(breaks = 0:10)




## ----eval=FALSE----------------------------------------------------------
## gender_promotions %>%
##   specify(formula = decision ~ gender, success = "promoted")


## ----echo=FALSE----------------------------------------------------------
specify_ht <- gender_promotions %>% 
  specify(formula = decision ~ gender, success = "promoted")
specify_ht


## ----eval=FALSE----------------------------------------------------------
## gender_promotions %>%
##   specify(formula = decision ~ gender, success = "promoted")
##   hypothesize(null = "independence")


## ----echo=FALSE----------------------------------------------------------
hypothesize_ht <- specify_ht %>% 
  hypothesize(null = "independence")
hypothesize_ht


## ----eval=FALSE----------------------------------------------------------
## gender_promotions %>%
##   specify(formula = decision ~ gender, success = "promoted")
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute")


## ----echo=FALSE----------------------------------------------------------
generate_ht <- hypothesize_ht %>% 
  generate(reps = 1000, type = "permute")
generate_ht


## ----eval=FALSE----------------------------------------------------------
## null_distribution_two_props <- gender_promotions %>%
##   specify(formula = decision ~ gender, success = "promoted")
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute") %>%
##   calculate(stat = "diff in props", order = c("male", "female"))
## null_distribution_two_props


## ----echo=FALSE----------------------------------------------------------
null_distribution_two_props <- generate_ht %>% 
  calculate(stat = "diff in props", order = c("male", "female"))
null_distribution_two_props


## ----echo=FALSE----------------------------------------------------------
ggplot(null_distribution_two_props, aes(x = stat)) +
  geom_histogram(bins = 10, color = "white") +
  geom_vline(xintercept = pull(obs_diff_prop), color = "blue", size = 2)




## ----fig.cap="Shaded histogram to show p-value"--------------------------
visualize(null_distribution_two_props, bins = 10) + 
  shade_p_value(obs_stat = obs_diff_prop, direction = "right")


## ------------------------------------------------------------------------
p_value <- null_distribution_two_props %>% 
  get_p_value(obs_stat = obs_diff_prop, direction = "both")
p_value


## ----eval=FALSE----------------------------------------------------------
## null_distribution_two_props <- gender_promotions %>%
##   specify(formula = decision ~ gender, success = "promoted") %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 1000, type = "permute") %>%
##   calculate(stat = "diff in props", order = c("male", "female"))


## ------------------------------------------------------------------------
percentile_ci_two_props <- gender_promotions %>% 
  specify(formula = decision ~ gender, success = "promoted") %>% 
  #  hypothesize(null = "independence") %>% 
  generate(reps = 1000, type = "bootstrap") %>% 
  calculate(stat = "diff in props", order = c("male", "female")) %>% 
  get_ci()






## ----trial-errors-table, echo=FALSE, fig.cap="Type I and Type II errors"----
if(knitr:::is_html_output()){
  verdict <- c("Guilty verdict", "Not guilty verdict")
  Guilty <- c("True Positive (Correct result)", 
              "False Negative (Type II Error)")
  `Not guilty` <- c("False Positive (Type I Error)", 
                    "True Negative (Correct result)")
  
  table_entries <- tibble(verdict, Guilty, `Not guilty`)
  
  table_entries %>% 
    gt(rowname_col = "verdict") %>% 
    tab_header(title = "Type I and Type II errors for US trials") %>% 
    tab_row_group(group = "Verdict")   %>% 
    tab_spanner(label = "Actual result",
                columns = vars(Guilty, `Not guilty`)) %>% 
    cols_align(align = "center") %>% 
    tab_options(table.width = pct(30))
} else {
  knitr::include_graphics("images/error-types.png")
}










## ----message=FALSE, warning=FALSE----------------------------------------
movies_trimmed <- movies %>% 
  select(title, year, rating, Action, Romance)


## ------------------------------------------------------------------------
movies_trimmed <- movies_trimmed %>%
  filter(!(Action == 1 & Romance == 1))


## ------------------------------------------------------------------------
movies_trimmed <- movies_trimmed %>%
  mutate(genre = case_when( (Action == 1) ~ "Action",
                            (Romance == 1) ~ "Romance",
                            TRUE ~ "Neither")) %>%
  filter(genre != "Neither") %>%
  select(-Action, -Romance)






## ----fig.cap="Rating vs genre in the population"-------------------------
ggplot(data = movies_trimmed, aes(x = genre, y = rating)) +
  geom_boxplot()


## ----movie-hist, warning=FALSE, fig.cap="Faceted histogram of genre vs rating"----
ggplot(data = movies_trimmed, mapping = aes(x = rating)) +
  geom_histogram(binwidth = 1, color = "white") +
  facet_grid(genre ~ .)






## ------------------------------------------------------------------------
set.seed(2017)
movies_genre_sample <- movies_trimmed %>% 
  group_by(genre) %>%
  sample_n(34) %>% 
  ungroup()


## ----fig.cap="Genre vs rating for our sample"----------------------------
ggplot(data = movies_genre_sample, aes(x = genre, y = rating)) +
  geom_boxplot()


## ----warning=FALSE, fig.cap="Genre vs rating for our sample as faceted histogram"----
ggplot(data = movies_genre_sample, mapping = aes(x = rating)) +
  geom_histogram(binwidth = 1, color = "white") +
  facet_grid(genre ~ .)






## ------------------------------------------------------------------------
summary_ratings <- movies_genre_sample %>% 
  group_by(genre) %>%
  summarize(mean = mean(rating),
            std_dev = sd(rating),
            n = n())
summary_ratings










## ------------------------------------------------------------------------
obs_diff <- movies_genre_sample %>% 
  specify(formula = rating ~ genre) %>% 
  calculate(stat = "diff in means", order = c("Romance", "Action"))
obs_diff


## ----include=FALSE-------------------------------------------------------
set.seed(2018)


## ----message=FALSE, warning=FALSE, include=FALSE, eval=FALSE-------------
## shuffled_ratings_old <- #movies_trimmed %>%
##   movies_genre_sample %>%
##      mutate(genre = mosaic::shuffle(genre)) %>%
##      group_by(genre) %>%
##      summarize(mean = mean(rating))
## diff(shuffled_ratings_old$mean)


## ----message=FALSE, warning=FALSE----------------------------------------
movies_genre_sample %>% 
  specify(formula = rating ~ genre) %>%
  hypothesize(null = "independence") %>% 
  generate(reps = 1) %>% 
  calculate(stat = "diff in means", order = c("Romance", "Action"))






## ----include=FALSE-------------------------------------------------------
if(!file.exists("rds/generated_samples.rds")){
  generated_samples <- movies_genre_sample %>% 
    specify(formula = rating ~ genre) %>% 
    hypothesize(null = "independence") %>% 
    generate(reps = 5000)
   saveRDS(object = generated_samples, 
           "rds/generated_samples.rds")
} else {
   generated_samples <- readRDS("rds/generated_samples.rds")
}


## ----eval=FALSE----------------------------------------------------------
## generated_samples <- movies_genre_sample %>%
##   specify(formula = rating ~ genre) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 5000)


## ----include=FALSE-------------------------------------------------------
null_distribution_two_means <- generated_samples %>% 
  calculate(stat = "diff in means", order = c("Romance", "Action"))


## ----eval=FALSE----------------------------------------------------------
## null_distribution_two_means <- movies_genre_sample %>%
##   specify(formula = rating ~ genre) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 5000) %>%
##   calculate(stat = "diff in means", order = c("Romance", "Action"))


## ----fig.cap="Simulated differences in means histogram"------------------
null_distribution_two_means %>% visualize()


## ----fig.cap="Shaded histogram to show p-value"--------------------------
visualize(null_distribution_two_means) + 
  shade_p_value(obs_stat = obs_diff, direction = "both")


## ----fig.cap="Histogram with vertical lines corresponding to observed statistic"----
visualize(null_distribution_two_means, bins = 100) + 
  shade_p_value(bins = 100, obs_stat = obs_diff, direction = "both")


## ------------------------------------------------------------------------
pvalue <- null_distribution_two_means %>% 
  get_p_value(obs_stat = obs_diff, direction = "both")
pvalue


## ----eval=FALSE----------------------------------------------------------
## null_distribution_two_means <- movies_genre_sample %>%
##   specify(formula = rating ~ genre) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 5000) %>%
##   calculate(stat = "diff in means", order = c("Romance", "Action"))


## ------------------------------------------------------------------------
percentile_ci_two_means <- movies_genre_sample %>% 
  specify(formula = rating ~ genre) %>% 
#  hypothesize(null = "independence") %>% 
  generate(reps = 5000) %>% 
  calculate(stat = "diff in means", order = c("Romance", "Action")) %>% 
  get_ci()


## ------------------------------------------------------------------------
percentile_ci_two_means






## ------------------------------------------------------------------------
bos_sfo <- flights %>% 
  na.omit() %>% 
  filter(dest %in% c("BOS", "SFO")) %>% 
  group_by(dest) %>% 
  sample_n(100)


## ------------------------------------------------------------------------
bos_sfo_summary <- bos_sfo %>% group_by(dest) %>% 
  summarize(mean_time = mean(air_time),
            sd_time = sd(air_time))
bos_sfo_summary






## ------------------------------------------------------------------------
ggplot(data = bos_sfo, mapping = aes(x = dest, y = air_time)) +
  geom_boxplot()


## ----summarytable-ch10, echo=FALSE, message=FALSE------------------------
# The following Google Doc is published to CSV and loaded below using read_csv() below:
# https://docs.google.com/spreadsheets/d/1QkOpnBGqOXGyJjwqx1T2O5G5D72wWGfWlPyufOgtkk4/edit#gid=0

"https://docs.google.com/spreadsheets/d/e/2PACX-1vRd6bBgNwM3z-AJ7o4gZOiPAdPfbTp_V15HVHRmOH5Fc9w62yaG-fEKtjNUD2wOSa5IJkrDMaEBjRnA/pub?gid=0&single=true&output=csv" %>% 
  read_csv(na = "") %>% 
  kable(
    caption = "\\label{tab:summarytable-ch9}Scenarios of sampling for inference", 
    booktabs = TRUE,
    escape = FALSE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position")) %>%
  column_spec(1, width = "0.5in") %>% 
  column_spec(2, width = "0.7in") %>%
  column_spec(3, width = "1in") %>%
  column_spec(4, width = "1.1in") %>% 
  column_spec(5, width = "1in")


## ----echo=FALSE----------------------------------------------------------
ggplot(data.frame(x = c(-4, 4)), aes(x)) + stat_function(fun = dnorm) +
  ylab("") +
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank())


## ----fig.cap="Simulated differences in means histogram"------------------
ggplot(data = null_distribution_two_means, aes(x = stat)) +
  geom_histogram(color = "white", bins = 20)


## ----eval=FALSE----------------------------------------------------------
## generated_samples <- movies_genre_sample %>%
##   specify(formula = rating ~ genre) %>%
##   hypothesize(null = "independence") %>%
##   generate(reps = 5000)


## ------------------------------------------------------------------------
null_distribution_t <- generated_samples %>% 
  calculate(stat = "t", order = c("Romance", "Action"))
null_distribution_t %>% visualize()


## ------------------------------------------------------------------------
null_distribution_t %>% 
  visualize(method = "both")


## ------------------------------------------------------------------------
obs_t <- movies_genre_sample %>% 
  specify(formula = rating ~ genre) %>% 
  calculate(stat = "t", order = c("Romance", "Action"))


## ----warning=TRUE, message=TRUE------------------------------------------
visualize(null_distribution_t, method = "both") +
  shade_p_value(obs_stat = obs_t, direction = "both")

