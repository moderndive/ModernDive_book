## ---- eval=FALSE---------------------------------------------------------
## library(ggplot2)
## library(dplyr)
## library(moderndive)
## library(ISLR)
## library(skimr)


## ---- message=FALSE, warning=FALSE, echo=FALSE---------------------------
library(ggplot2)
library(dplyr)
library(moderndive)
library(ISLR)
# library(skimr) (Causes problems with table linking)


## ---- message=FALSE, warning=FALSE, echo=FALSE---------------------------
# Packages needed internally, but not in text:
library(mvtnorm)
library(kableExtra)
library(tidyr)
library(forcats)
library(gridExtra)
library(patchwork)


## ---- warning=FALSE, message=FALSE---------------------------------------
library(ISLR)
Credit <- Credit %>%
  select(Balance, Limit, Income, Rating, Age)


## ---- eval=FALSE---------------------------------------------------------
## View(Credit)


## ----model3-data-preview, echo=FALSE-------------------------------------
Credit %>%
  sample_n(5) %>%
  knitr::kable(
    digits = 3,
    caption = "Random sample of 5 credit card holders",
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ------------------------------------------------------------------------
glimpse(Credit)


## ----eval=FALSE----------------------------------------------------------
## Credit %>%
##   select(Balance, Limit, Income) %>%
##   skim()


## ----echo=FALSE----------------------------------------------------------
Credit %>% 
  select(Balance, Limit, Income) %>% 
  skimr::skim()


## ---- eval=FALSE---------------------------------------------------------
## Credit %>%
##   get_correlation(Balance ~ Limit)
## Credit %>%
##   get_correlation(Balance ~ Income)


## ---- eval=FALSE---------------------------------------------------------
## Credit %>%
##   select(Balance, Limit, Income) %>%
##   cor()

## ----model3-correlation, echo=FALSE--------------------------------------
Credit %>% 
  select(Balance, Limit, Income) %>% 
  cor() %>% 
  knitr::kable(
    digits = 3,
    caption = "Correlations between credit card balance, credit limit, and income", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ---- eval=FALSE---------------------------------------------------------
## ggplot(Credit, aes(x = Limit, y = Balance)) +
##   geom_point() +
##   labs(x = "Credit limit (in $)", y = "Credit card balance (in $)",
##        title = "Relationship between balance and credit limit") +
##   geom_smooth(method = "lm", se = FALSE)
## 
## ggplot(Credit, aes(x = Income, y = Balance)) +
##   geom_point() +
##   labs(x = "Income (in $1000)", y = "Credit card balance (in $)",
##        title = "Relationship between balance and income") +
##   geom_smooth(method = "lm", se = FALSE)


## ----2numxplot1, echo=FALSE, fig.height=4, fig.cap="Relationship between credit card balance and credit limit/income"----
model3_balance_vs_limit_plot <- ggplot(Credit, aes(x = Limit, y = Balance)) +
  geom_point() +
  labs(x = "Credit limit (in $)", y = "Credit card balance (in $)", 
       title = "Balance vs credit limit") +
  geom_smooth(method = "lm", se = FALSE)
model3_balance_vs_income_plot <- ggplot(Credit, aes(x = Income, y = Balance)) +
  geom_point() +
  labs(x = "Income (in $1000)", y = "Credit card balance (in $)", 
       title = "Balance vs income") +
  geom_smooth(method = "lm", se = FALSE) +
  scale_y_continuous(limits = c(0, NA))
model3_balance_vs_limit_plot + model3_balance_vs_income_plot




## ---- eval=FALSE, echo=FALSE---------------------------------------------
## # Save as 798 x 562 images/credit_card_balance_3D_scatterplot.png
## library(ISLR)
## library(plotly)
## plot_ly(showscale=FALSE) %>%
##   add_markers(
##     x = Credit$Income,
##     y = Credit$Limit,
##     z = Credit$Balance,
##     hoverinfo = 'text',
##     text = ~paste("x1 - Income: ", Credit$Income,
##                   "</br> x2 - Limit: ", Credit$Limit,
##                   "</br> y - Balance: ", Credit$Balance)
##   ) %>%
##   layout(
##     scene = list(
##       xaxis = list(title = "x1 - Income (in $10K)"),
##       yaxis = list(title = "x2 - Limit ($)"),
##       zaxis = list(title = "y - Balance ($)")
##     )
##   )


## ----echo=FALSE, fig.cap="Regression plane", fig.align='center'----------
knitr::include_graphics("images/credit_card_balance_regression_plane.png")


## ---- eval=FALSE, echo=FALSE---------------------------------------------
## # Save as 798 x 562 images/credit_card_balance_regression_plane.png
## library(ISLR)
## library(plotly)
## library(tidyverse)
## 
## # setup hideous grid required by plotly
## model_lm <- lm(Balance ~ Income + Limit, data=Credit)
## x_grid <- seq(from=min(Credit$Income), to=max(Credit$Income), length=100)
## y_grid <- seq(from=min(Credit$Limit), to=max(Credit$Limit), length=200)
## z_grid <- expand.grid(x_grid, y_grid) %>%
##   tbl_df() %>%
##   rename(
##     x_grid = Var1,
##     y_grid = Var2
##   ) %>%
##   mutate(z = coef(model_lm)[1] + coef(model_lm)[2]*x_grid + coef(model_lm)[3]*y_grid) %>%
##   .[["z"]] %>%
##   matrix(nrow=length(x_grid)) %>%
##   t()
## 
## # plot points and plane
## plot_ly(showscale = FALSE) %>%
##   add_markers(
##     x = Credit$Income,
##     y = Credit$Limit,
##     z = Credit$Balance,
##     hoverinfo = 'text',
##     text = ~paste("x1 - Income: ", Credit$Income, "</br> x2 - Limit: ",
##                   Credit$Limit, "</br> y - Balance: ", Credit$Balance)
##   ) %>%
##   layout(
##     scene = list(
##       xaxis = list(title = "x1 - Income (in $10K)"),
##       yaxis = list(title = "x2 - Limit ($)"),
##       zaxis = list(title = "y - Balance ($)")
##     )
##   ) %>%
##   add_surface(
##     x = x_grid,
##     y = y_grid,
##     z = z_grid
##   )






## ---- eval=FALSE---------------------------------------------------------
## Balance_model <- lm(Balance ~ Limit + Income, data = Credit)
## get_regression_table(Balance_model)

## ---- echo=FALSE---------------------------------------------------------
Balance_model <- lm(Balance ~ Limit + Income, data = Credit)
Credit_line <- get_regression_table(Balance_model) %>%
  pull(estimate)

## ----model3-table-output, echo=FALSE-------------------------------------
get_regression_table(Balance_model) %>% 
  knitr::kable(
    digits = 3,
    caption = "Multiple regression table", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))






## ---- eval=FALSE---------------------------------------------------------
## regression_points <- get_regression_points(Balance_model)
## regression_points

## ----model3-points-table, echo=FALSE-------------------------------------
set.seed(76)
regression_points <- get_regression_points(Balance_model)
regression_points %>%
  slice(1:5) %>%
  knitr::kable(
    digits = 3,
    caption = "Regression points (first 5 rows of 400)",
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ------------------------------------------------------------------------
evals_ch7 <- evals %>%
  select(score, age, gender)


## ---- eval=FALSE---------------------------------------------------------
## View(evals_ch7)


## ----model4-data-preview, echo=FALSE-------------------------------------
evals_ch7 %>%
  sample_n(5) %>%
  knitr::kable(
    digits = 3,
    caption = "Random sample of 5 instructors",
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ----eval=FALSE----------------------------------------------------------
## evals_ch7 %>%
##   skim()


## ----echo=FALSE----------------------------------------------------------
evals_ch7 %>% 
  skimr::skim()


## ------------------------------------------------------------------------
evals_ch7 %>% 
  get_correlation(formula = score ~ age)


## ----numxcatxplot1, warning=FALSE, fig.cap="Instructor evaluation scores at UT Austin split by gender (jittered)"----
ggplot(evals_ch7, aes(x = age, y = score, color = gender)) +
  geom_jitter() +
  labs(x = "Age", y = "Teaching Score", color = "Gender") +
  geom_smooth(method = "lm", se = FALSE)


## ---- eval=FALSE---------------------------------------------------------
## score_model_2 <- lm(score ~ age + gender, data = evals_ch7)
## get_regression_table(score_model_2)

## ---- echo=FALSE---------------------------------------------------------
score_model_2 <- lm(score ~ age + gender, data = evals_ch7)
get_regression_table(score_model_2) %>% 
  knitr::kable(
    digits = 3,
    caption = "Regression table", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ----numxcatxplot2, echo=FALSE, warning=FALSE, fig.cap="Instructor evaluation scores at UT Austin by gender: same slope"----
coeff <- lm(score ~ age + gender, data = evals_ch7) %>% 
  coef() %>%
  as.numeric()
slopes <- evals_ch7 %>%
  group_by(gender) %>%
  summarise(min = min(age), max = max(age)) %>%
  mutate(intercept = coeff[1]) %>%
  mutate(intercept = ifelse(gender == "male", intercept + coeff[3], intercept)) %>%
  gather(point, age, -c(gender, intercept)) %>%
  mutate(y_hat = intercept + age * coeff[2])

ggplot(evals_ch7, aes(x = age, y = score, col = gender)) +
  geom_jitter() +
  labs(x = "Age", y = "Teaching Score", color = "Gender") +
  geom_line(data = slopes, aes(y = y_hat), size = 1)


## ---- eval=FALSE---------------------------------------------------------
## score_model_interaction <- lm(score ~ age * gender, data = evals_ch7)
## get_regression_table(score_model_interaction)

## ---- echo=FALSE---------------------------------------------------------
score_model_interaction <- lm(score ~ age * gender, data = evals_ch7)
get_regression_table(score_model_interaction) %>% 
  knitr::kable(
    digits = 3,
    caption = "Regression table", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ---- echo=FALSE---------------------------------------------------------
data_frame(
  Gender = c("Male instructors", "Female instructors"),
  Intercept = c(4.437, 4.883),
  `Slope for age` = c(-0.004, -0.018)
) %>% 
  knitr::kable(
    caption = "Comparison of male and female intercepts and age slopes", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ---- eval=FALSE---------------------------------------------------------
## regression_points <- get_regression_points(score_model_interaction)
## regression_points

## ----model4-points-table, echo=FALSE-------------------------------------
set.seed(76)
regression_points <- get_regression_points(score_model_interaction)
regression_points %>%
  slice(1:5) %>%
  knitr::kable(
    digits = 3,
    caption = "Regression points (first 5 rows of 463)",
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ---- eval=FALSE---------------------------------------------------------
## library(ISLR)
## data(Credit)
## Credit %>%
##   select(Balance, Income) %>%
##   mutate(Income = Income * 1000) %>%
##   cor()

## ----cor-credit-2, echo=FALSE--------------------------------------------
library(ISLR)
data(Credit)
Credit %>% 
  select(Balance, Income) %>% 
  mutate(Income = Income * 1000) %>% 
  cor() %>% 
  knitr::kable(
    digits = 3,
    caption = "Correlation between income (in dollars) and credit card balance", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("HOLD_position"))


## ----echo=FALSE, fig.height=4, fig.cap="Relationship between credit card balance and credit limit/income"----
model3_balance_vs_limit_plot + model3_balance_vs_income_plot


## ----credit-limit-quartiles, echo=FALSE, fig.height=4, fig.cap="Histogram of credit limits and quartiles"----
ggplot(Credit, aes(x = Limit)) +
  geom_histogram(color = "white") +
  geom_vline(xintercept = quantile(Credit$Limit, probs = c(0.25, 0.5, 0.75)), col = "red", linetype = "dashed")


## ---- 2numxplot4, fig.height=4, echo=FALSE, fig.cap="Relationship between credit card balance and income for different credit limit brackets"----
Credit <- Credit %>% 
  mutate(limit_bracket = cut_number(Limit, 4)) %>% 
  mutate(limit_bracket = fct_recode(limit_bracket,
    "low" =  "[855,3.09e+03]",
    "medium-low" = "(3.09e+03,4.62e+03]", 
    "medium-high" = "(4.62e+03,5.87e+03]", 
    "high" = "(5.87e+03,1.39e+04]"
  ))

model3_balance_vs_income_plot <- ggplot(Credit, aes(x = Income, y = Balance)) +
  geom_point() +
  labs(x = "Income (in $1000)", y = "Credit card balance (in $)", 
       title = "Balance vs income\n(overall)") +
  geom_smooth(method = "lm", se = FALSE) +
  scale_y_continuous(limits = c(0, NA))

model3_balance_vs_income_plot_colored <- ggplot(Credit, aes(x = Income, y = Balance, col = limit_bracket)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(x = "Income (in $1000)", y = "Credit card balance (in $)", 
       color = "Credit limit\nbracket", title = "Balance vs income\n(colored by credit limit bracket)") + 
  theme(legend.position = "none") +
  scale_y_continuous(limits = c(0, NA))
  
model3_balance_vs_income_plot + model3_balance_vs_income_plot_colored


## ---- 2numxplot5, echo=FALSE, warning=FALSE, fig.cap="Relationship between credit card balance and income for different credit limit brackets"----
ggplot(Credit, aes(x = Income, y = Balance)) +
  geom_point() +
  facet_wrap(~limit_bracket) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(x = "Income (in $1000)", y = "Credit card balance (in $)")

