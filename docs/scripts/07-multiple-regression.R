## ---- eval=FALSE---------------------------------------------------------
## library(tidyverse)
## library(moderndive)
## library(skimr)
## library(ISLR)


## ---- echo=FALSE, message=FALSE, warning=FALSE---------------------------
library(tidyverse)
library(moderndive)
# DO NOT load the skimr package as a whole as it will break all kable() code for the
# remaining chapters in the book:
# library(skimr)
library(ISLR)


## ---- message=FALSE, warning=FALSE, echo=FALSE---------------------------
# Packages needed internally, but not in text:
library(kableExtra)
library(patchwork)
library(gapminder)


## ------------------------------------------------------------------------
evals_ch7 <- evals %>%
  select(ID, score, age, gender)


## ------------------------------------------------------------------------
glimpse(evals_ch7)


## ---- eval=FALSE---------------------------------------------------------
## evals_ch7 %>%
##   sample_n(size = 5)

## ----model4-data-preview, echo=FALSE-------------------------------------
evals_ch7 %>%
  sample_n(5) %>%
  knitr::kable(
    digits = 3,
    caption = "A random sample of 5 out of the 463 courses at UT Austin",
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ---- eval =FALSE--------------------------------------------------------
## evals_ch7 %>%
##   select(score, age, gender) %>%
##   skim()

## ----echo=FALSE----------------------------------------------------------
evals_ch7 %>% 
  select(score, age, gender) %>% 
  skimr::skim()


## ------------------------------------------------------------------------
evals_ch7 %>% 
  get_correlation(formula = score ~ age)


## ----numxcatxplot1, warning=FALSE, fig.cap="Colored scatterplot of relationship of teaching and beauty scores"----
ggplot(evals_ch7, aes(x = age, y = score, color = gender)) +
  geom_point() +
  labs(x = "Age", y = "Teaching Score", color = "Gender") +
  geom_smooth(method = "lm", se = FALSE)


## ---- echo=FALSE---------------------------------------------------------
# Wrangle data
gapminder2007 <- gapminder %>%
  filter(year == 2007) %>%
  select(country, lifeExp, continent, gdpPercap)

# Fit regression model:
lifeExp_model <- lm(lifeExp ~ continent, data = gapminder2007)

# Get regression table and kable output
get_regression_table(lifeExp_model) %>%
  knitr::kable(
    digits = 3,
    caption = "Regression table for life expectancy as a function of continent.",
    booktabs = TRUE
  ) %>%
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ---- eval=FALSE---------------------------------------------------------
## # Fit regression model:
## score_model_interaction <- lm(score ~ age * gender, data = evals_ch7)
## # Get regression table:
## get_regression_table(score_model_interaction)

## ----regtable-interaction, echo=FALSE------------------------------------
score_model_interaction <- lm(score ~ age * gender, data = evals_ch7)
get_regression_table(score_model_interaction) %>% 
  knitr::kable(
    digits = 3,
    caption = "Regression table for interaction model.", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ----interaction-summary, echo=FALSE-------------------------------------
tibble(
  Gender = c("Female instructors", "Male instructors"),
  Intercept = c(4.883, 4.437),
  `Slope for age` = c(-0.018, -0.004)
) %>% 
  knitr::kable(
    digits = 3,
    caption = "Comparison of female and male intercepts and age slopes", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ----numxcatx-parallel, warning=FALSE, fig.cap="Parallel slopes model of relationship of score with age and gender."----
gg_parallel_slopes(y = "score", num_x = "age", cat_x = "gender", 
                   data = evals_ch7)


## ---- eval=FALSE---------------------------------------------------------
## # Fit regression model:
## score_model_parallel_slopes <- lm(score ~ age + gender, data = evals_ch7)
## # Get regression table:
## get_regression_table(score_model_parallel_slopes)

## ----regtable-parallel-slopes, echo=FALSE--------------------------------
score_model_parallel_slopes <- lm(score ~ age + gender, data = evals_ch7)
get_regression_table(score_model_parallel_slopes) %>% 
  knitr::kable(
    digits = 3,
    caption = "Regression table for parallel slopes model.", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ----numxcatx-comparison, fig.width = 8, echo = FALSE, warning=FALSE, fig.cap="Comparison of interaction and parallel slopes models."----
interaction_plot <- ggplot(evals_ch7, aes(x = age, y = score, color = gender), show.legend = FALSE) +
  geom_point() +
  labs(x = "Age", y = "Teaching Score", title = "Interaction model") +
  geom_smooth(method = "lm", se = FALSE) +
  theme(legend.position = "none")
parallel_slopes_plot <- gg_parallel_slopes(y = "score", num_x = "age", cat_x = "gender", data = evals_ch7) +
  labs(x = "Age", y = "Teaching Score", title = "Parallel slopes model") +
  theme(axis.title.y = element_blank())
interaction_plot + parallel_slopes_plot


## ----fitted-values, echo = FALSE, warning=FALSE, fig.cap="Fitted values for two new professors"----
newpoints <- evals_ch7 %>% 
  slice(c(1, 5)) %>% 
  get_regression_points(score_model_interaction, newdata = .)

ggplot(evals_ch7, aes(x = age, y = score, color = gender), show.legend = FALSE) +
  geom_point() +
  labs(x = "Age", y = "Teaching Score", title = "Interaction model") +
  geom_smooth(method = "lm", se = FALSE) +
  geom_vline(data = newpoints, aes(xintercept = age, col = gender), linetype = "dashed", size = 1, show.legend = FALSE) +
  geom_point(data = newpoints, aes(x= age, y = score_hat), size = 6, show.legend = FALSE)


## ---- eval=FALSE---------------------------------------------------------
## regression_points <- get_regression_points(score_model_interaction)
## regression_points

## ----model4-points-table, echo=FALSE-------------------------------------
regression_points <- get_regression_points(score_model_interaction)
regression_points %>%
  slice(1:10) %>%
  knitr::kable(
    digits = 3,
    caption = "Regression points (First 10 out of 463 courses)",
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))






## ---- warning=FALSE, message=FALSE---------------------------------------
library(ISLR)
credit_ch7 <- Credit %>%
  as_tibble() %>% 
  select(ID, debt = Balance, credit_limit = Limit, 
         income = Income, credit_rating = Rating, age = Age)


## ------------------------------------------------------------------------
glimpse(credit_ch7)


## ---- eval=FALSE---------------------------------------------------------
## credit_ch7 %>%
##   sample_n(size = 5)

## ----model3-data-preview, echo=FALSE-------------------------------------
credit_ch7 %>%
  sample_n(5) %>%
  knitr::kable(
    digits = 3,
    caption = "Random sample of 5 credit card holders.",
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ---- eval = FALSE-------------------------------------------------------
## credit_ch7 %>%
##   select(debt, credit_limit, income) %>%
##   skim()

## ---- echo=FALSE---------------------------------------------------------
credit_ch7 %>% 
  select(debt, credit_limit, income) %>% 
  skimr::skim()


## ---- eval=FALSE---------------------------------------------------------
## credit_ch7 %>%
##   get_correlation(debt ~ credit_limit)
## credit_ch7 %>%
##   get_correlation(debt ~ income)


## ---- eval=FALSE---------------------------------------------------------
## credit_ch7 %>%
##   select(debt, credit_limit, income) %>%
##   cor()

## ----model3-correlation, echo=FALSE--------------------------------------
credit_ch7 %>% 
  select(debt, credit_limit, income) %>% 
  cor() %>% 
  knitr::kable(
    digits = 3,
    caption = "Correlation coefficients between credit card debt, credit limit, and income.", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ---- eval=FALSE---------------------------------------------------------
## ggplot(credit_ch7, aes(x = credit_limit, y = debt)) +
##   geom_point() +
##   labs(x = "Credit limit (in $)", y = "Credit card debt (in $)",
##        title = "Debt and credit limit") +
##   geom_smooth(method = "lm", se = FALSE)
## 
## ggplot(credit_ch7, aes(x = income, y = debt)) +
##   geom_point() +
##   labs(x = "Income (in $1000)", y = "Credit card debt (in $)",
##        title = "Debt and income") +
##   geom_smooth(method = "lm", se = FALSE)


## ----2numxplot1, echo=FALSE, fig.width = 8, fig.cap="Relationship between credit card debt and credit limit/income"----
model3_balance_vs_limit_plot <- ggplot(credit_ch7, aes(x = credit_limit, y = debt)) +
  geom_point() +
  labs(x = "Credit limit (in $)", y = "Credit card debt (in $)", 
       title = "Debt and credit limit") +
  geom_smooth(method = "lm", se = FALSE) +
  scale_y_continuous(limits = c(0, 2000))

model3_balance_vs_income_plot <- ggplot(credit_ch7, aes(x = income, y = debt)) +
  geom_point() +
  labs(x = "Income (in $1000)", y = "Credit card debt (in $)", 
       title = "Debt and income") +
  geom_smooth(method = "lm", se = FALSE) +
  scale_y_continuous(limits = c(0, 2000)) +
  theme(axis.title.y = element_blank())

model3_balance_vs_limit_plot + model3_balance_vs_income_plot


## ----echo=FALSE----------------------------------------------------------
if(knitr:::is_html_output())
  cat("Click on the following image to open an interactive version of this plot in your browser:") 




## ---- eval=FALSE, echo=FALSE---------------------------------------------
## # Source code for above 3D scatterplot & regression plane.
## library(ISLR)
## library(plotly)
## library(tidyverse)
## 
## # setup hideous grid required by plotly
## model_lm <- lm(debt ~ income + credit_limit, data=credit_ch7)
## x_grid <- seq(from = min(credit_ch7$income), to = max(credit_ch7$income), length = 100)
## y_grid <- seq(from = min(credit_ch7$credit_limit), to = max(credit_ch7$credit_limit), length = 200)
## z_grid <- expand.grid(x_grid, y_grid) %>%
##   tbl_df() %>%
##   rename(x_grid = Var1, y_grid = Var2) %>%
##   mutate(z = coef(model_lm)[1] + coef(model_lm)[2]*x_grid + coef(model_lm)[3]*y_grid) %>%
##   .[["z"]] %>%
##   matrix(nrow=length(x_grid)) %>%
##   t()
## 
## # Plot points
## plot_ly() %>%
##   add_markers(
##     x = credit_ch7$income,
##     y = credit_ch7$credit_limit,
##     z = credit_ch7$debt,
##     hoverinfo = 'text',
##     text = ~paste("x1 - Income: ",
##                   credit_ch7$income,
##                   "</br> x2 - Credit Limit: ",
##                   credit_ch7$credit_limit,
##                   "</br> y - Debt: ",
##                   credit_ch7$debt)
##   ) %>%
##   # Label axes
##   layout(
##     scene = list(
##       xaxis = list(title = "x1 - Income (in $10K)"),
##       yaxis = list(title = "x2 - Credit Limit ($)"),
##       zaxis = list(title = "y - Debt ($)")
##     )
##   ) %>%
##   # Add regression plane
##   add_surface(
##     x = x_grid,
##     y = y_grid,
##     z = z_grid
##   )






## ---- eval=FALSE---------------------------------------------------------
## # Fit regression model:
## debt_model <- lm(debt ~ credit_limit + income, data = credit_ch7)
## # Get regression table:
## get_regression_table(debt_model)

## ----model3-table-output, echo=FALSE-------------------------------------
debt_model <- lm(debt ~ credit_limit + income, data = credit_ch7)
credit_line <- get_regression_table(debt_model) %>%
  pull(estimate)
get_regression_table(debt_model) %>% 
  knitr::kable(
    digits = 3,
    caption = "Multiple regression table", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))






## ---- eval=FALSE---------------------------------------------------------
## regression_points <- get_regression_points(debt_model)
## regression_points

## ----model3-points-table, echo=FALSE-------------------------------------
set.seed(76)
regression_points <- get_regression_points(debt_model)
regression_points %>%
  slice(1:10) %>%
  knitr::kable(
    digits = 3,
    caption = "Regression points (First 10 card holders of 400)",
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ---- fig.width = 8, echo = FALSE, warning=FALSE-------------------------
interaction_plot <- ggplot(evals_ch7, aes(x = age, y = score, color = gender), show.legend = FALSE) +
  geom_point() +
  labs(x = "Age", y = "Teaching Score", title = "Interaction model") +
  geom_smooth(method = "lm", se = FALSE) +
  theme(legend.position = "none")
parallel_slopes_plot <- gg_parallel_slopes(y = "score", num_x = "age", cat_x = "gender", data = evals_ch7) +
  labs(x = "Age", y = "Teaching Score", title = "Parallel slopes model") +
  theme(axis.title.y = element_blank())
interaction_plot + parallel_slopes_plot


## ---- eval = FALSE-------------------------------------------------------
## # Interaction model
## ggplot(MA_schools, aes(x = perc_disadvan, y = average_sat_math, color = size)) +
##   geom_point(alpha = 0.25) +
##   geom_smooth(method = "lm", se = FALSE ) +
##   labs(x = "Percent economically disadvantaged", y = "Math SAT Score",
##        color = "School size", title = "Interaction model")
## 
## # Parallel slopes model
## gg_parallel_slopes(y = "average_sat_math", num_x = "perc_disadvan",
##                    cat_x = "size", data = MA_schools, alpha = 0.25) +
##   labs(x = "Percent economically disadvantaged", y = "Math SAT Score",
##        color = "School size", title = "Parallel slopes model")

## ----numxcatx-comparison-2, fig.width = 8, echo = FALSE, warning=FALSE, fig.cap="Comparison of interaction and parallel slopes models."----
p1 <- ggplot(MA_schools, aes(x = perc_disadvan, y = average_sat_math, color = size))+
  geom_point(alpha = 0.25) +
  geom_smooth(method = "lm", se = FALSE ) +
  labs(x = "Percent economically disadvantaged", y = "Math SAT Score", 
       color = "School size", title = "Interaction model") + 
  theme(legend.position = "none")
p2 <- gg_parallel_slopes(y = "average_sat_math", num_x = "perc_disadvan", 
                         cat_x = "size", data = MA_schools, alpha = 0.25) + 
  labs(x = "Percent economically disadvantaged", y = "Math SAT Score", 
       color = "School size", title = "Parallel slopes model")  +
  theme(axis.title.y = element_blank())
p1 + p2


## ---- eval = FALSE-------------------------------------------------------
## model_2_interaction <- lm(average_sat_math ~ perc_disadvan * size,
##                           data = MA_schools)
## get_regression_table(model_2_interaction)

## ----model2-interaction, echo = FALSE------------------------------------
model_2_interaction <- lm(average_sat_math ~ perc_disadvan * size, 
                          data = MA_schools)
get_regression_table(model_2_interaction) %>% 
  knitr::kable(
    digits = 3,
    caption = "Interaction model regression table", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))

## ---- eval = FALSE-------------------------------------------------------
## model_2_parallel_slopes <- lm(average_sat_math ~ perc_disadvan + size,
##                               data = MA_schools)
## get_regression_table(model_2_parallel_slopes)

## ----model2-parallel-slopes, echo = FALSE--------------------------------
model_2_parallel_slopes <- lm(average_sat_math ~ perc_disadvan + size, 
                              data = MA_schools)
get_regression_table(model_2_parallel_slopes) %>% 
  knitr::kable(
    digits = 3,
    caption = "Parallel slopes regression table", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ---- eval=FALSE---------------------------------------------------------
## library(ISLR)
## credit_ch7 %>%
##   select(debt, income) %>%
##   mutate(income = income * 1000) %>%
##   cor()

## ----cor-credit-2, echo=FALSE--------------------------------------------
library(ISLR)
credit_ch7 %>% 
  select(debt, income) %>% 
  mutate(income = income * 1000) %>% 
  cor() %>% 
  knitr::kable(
    digits = 3,
    caption = "Correlation between income (in dollars) and credit card debt", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ----echo=FALSE, fig.height=4, fig.cap="Relationship between credit card debt and credit limit/income"----
model3_balance_vs_limit_plot + model3_balance_vs_income_plot


## ----credit-limit-quartiles, echo=FALSE, fig.height=4, fig.cap="Histogram of credit limits and quartiles", message=FALSE----
ggplot(credit_ch7, aes(x = credit_limit)) +
  geom_histogram(color = "white") +
  geom_vline(xintercept = quantile(credit_ch7$credit_limit, probs = c(0.25, 0.5, 0.75)), col = "red", linetype = "dashed") +
  labs(x = "Credit limit", title = "Credit limit quartiles")


## ---- 2numxplot4, fig.width=8, echo=FALSE, fig.cap="Relationship between credit card debt and income for different credit limit groups"----
credit_ch7 <- credit_ch7 %>% 
  mutate(limit_bracket = cut_number(credit_limit, 4)) %>% 
  mutate(limit_bracket = fct_recode(limit_bracket,
    "low" =  "[855,3.09e+03]",
    "medium-low" = "(3.09e+03,4.62e+03]", 
    "medium-high" = "(4.62e+03,5.87e+03]", 
    "high" = "(5.87e+03,1.39e+04]"
  ))

model3_balance_vs_income_plot <- ggplot(credit_ch7, aes(x = income, y = debt)) +
  geom_point() +
  labs(x = "Income (in $1000)", y = "Credit card debt (in $)", 
       title = "Debt vs income (overall)") +
  geom_smooth(method = "lm", se = FALSE) +
  scale_y_continuous(limits = c(0, NA))

model3_balance_vs_income_plot_colored <- ggplot(credit_ch7, aes(x = income, y = debt, col = limit_bracket)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(x = "Income (in $1000)", y = "Credit card debt (in $)", 
       color = "Credit limit", title = "Debt vs income (colored by credit limit)") + 
  scale_y_continuous(limits = c(0, NA)) +
  theme(axis.title.y = element_blank())
  
model3_balance_vs_income_plot + model3_balance_vs_income_plot_colored

