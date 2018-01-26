## ---- message=FALSE, warning=FALSE---------------------------------------
library(remotes)
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

## ---- warning=FALSE, message=FALSE---------------------------------------
library(ISLR)
Credit <- Credit %>%
  select(Balance, Limit, Income, Rating, Age, Education)

## ---- eval=FALSE---------------------------------------------------------
## View(Credit)

## ----model3-data-preview, echo=FALSE-------------------------------------
Credit %>%
  sample_n(5) %>%
  knitr::kable(
    digits = 3,
    caption = "Random sample of 5 credit card holders",
    booktabs = TRUE
  )

## ------------------------------------------------------------------------
glimpse(Credit)

## ------------------------------------------------------------------------
summary(Credit)

## ---- eval=FALSE---------------------------------------------------------
## cor(Credit$Balance, Credit$Limit)
## cor(Credit$Balance, Credit$Income)

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
    caption = "Correlations between credit card balance, credit limit, and credit rating", 
    booktabs = TRUE
  )

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
  geom_smooth(method = "lm", se = FALSE)
grid.arrange(model3_balance_vs_limit_plot, model3_balance_vs_income_plot, nrow = 1)

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
## plot_ly(showscale=FALSE) %>%
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
  )

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
  )

## ---- eval=FALSE---------------------------------------------------------
## regression_points <- regression_points %>%
##   mutate(Balance_hat_2 = -385.179 + 0.264 * Limit - 7.663 * Income) %>%
##   mutate(residual_2 = Balance - Balance_hat_2)
## regression_points

## ---- echo=FALSE---------------------------------------------------------
set.seed(76)
regression_points <- regression_points %>% 
  mutate(Balance_hat_2 = -385.179 + 0.264 * Limit - 7.663 * Income) %>% 
  mutate(residual_2 = Balance - Balance_hat_2)
regression_points %>%
  slice(1:5) %>%
  knitr::kable(
    digits = 3,
    caption = "Regression points (first five rows)",
    booktabs = TRUE
  )

## ---- eval=FALSE---------------------------------------------------------
## ggplot(regression_points, aes(x = Limit, y = residual)) +
##   geom_point() +
##   labs(x = "Credit limit (in $)", y = "Residual", title = "Residuals vs credit limit")
## 
## ggplot(regression_points, aes(x = Income, y = residual)) +
##   geom_point() +
##   labs(x = "Income (in $1000)", y = "Residual", title = "Residuals vs income")

## ---- echo=FALSE, fig.height=4, fig.cap="Residuals vs credit limit and income"----
model3_residual_vs_limit_plot <- ggplot(regression_points, aes(x = Limit, y = residual)) +
  geom_point() +
  labs(x = "Credit limit (in $)", y = "Residual", 
       title = "Residuals vs credit limit")
model3_residual_vs_income_plot <- ggplot(regression_points, aes(x = Income, y = residual)) +
  geom_point() +
  labs(x = "Income (in $1000)", y = "Residual", 
       title = "Residuals vs income")
grid.arrange(model3_residual_vs_limit_plot, model3_residual_vs_income_plot, nrow = 1)

## ----model3_residuals_hist, warning=FALSE, fig.cap="Plot of residuals over continent"----
ggplot(regression_points, aes(x = residual)) +
  geom_histogram(color = "white") +
  labs(x = "Residual")

## ------------------------------------------------------------------------
load(url("http://www.openintro.org/stat/data/evals.RData"))
evals <- evals %>%
  select(score, bty_avg, age, gender)

## ------------------------------------------------------------------------
evals %>% 
  select(age, gender) %>% 
  summary()

## ------------------------------------------------------------------------
cor(evals$score, evals$age)

## ----numxcatxplot1, warning=FALSE, fig.cap="Instructor evaluation scores at UT Austin split by gender: Jittered"----
ggplot(evals, aes(x = age, y = score, col = gender)) +
  geom_jitter() +
  labs(x = "Age", y = "Teaching Score", color = "Gender") +
  geom_smooth(method = "lm", se = FALSE)

## ---- eval=FALSE---------------------------------------------------------
## score_model_2 <- lm(score ~ age + gender, data = evals)
## get_regression_table(score_model_2)

## ---- echo=FALSE---------------------------------------------------------
score_model_2 <- lm(score ~ age + gender, data = evals)
get_regression_table(score_model_2) %>% 
  knitr::kable(
    digits = 3,
    caption = "Regression table", 
    booktabs = TRUE
  )

## ----numxcatxplot2, echo=FALSE, warning=FALSE, fig.cap="Instructor evaluation scores at UT Austin by gender: same slope"----
coeff <- lm(score ~ age + gender, data = evals) %>% 
  coef() %>%
  as.numeric()
slopes <- evals %>%
  group_by(gender) %>%
  summarise(min = min(age), max = max(age)) %>%
  mutate(intercept = coeff[1]) %>%
  mutate(intercept = ifelse(gender == "male", intercept + coeff[3], intercept)) %>%
  gather(point, age, -c(gender, intercept)) %>%
  mutate(y_hat = intercept + age * coeff[2])

ggplot(evals, aes(x = age, y = score, col = gender)) +
  geom_jitter() +
  labs(x = "Age", y = "Teaching Score", color = "Gender") +
  geom_line(data = slopes, aes(y = y_hat), size = 1)

## ---- eval=FALSE---------------------------------------------------------
## score_model_2 <- lm(score ~ age * gender, data = evals)
## get_regression_table(score_model_2)

## ---- echo=FALSE---------------------------------------------------------
get_regression_table(score_model_2) %>% 
  knitr::kable(
    digits = 3,
    caption = "Regression table", 
    booktabs = TRUE
  )

## ------------------------------------------------------------------------
library(fivethirtyeight)
biopics <- biopics %>%
  select(title, box_office, person_of_color, subject_sex) %>%
  # Remove those that are missing
  filter(!is.na(box_office))

## ---- echo=FALSE---------------------------------------------------------
biopics %>%
  sample_n(5) %>%
  knitr::kable(digits = 1)

## ----logtransform1, echo=TRUE, message=FALSE, warning=FALSE, fig.cap="Histogram of box office revenue"----
ggplot(biopics, aes(x = box_office)) +
  geom_histogram(color = "white") +
  labs(x = "Box office revenue")

## ---- echo=FALSE---------------------------------------------------------
biopics %>%
  arrange(desc(box_office)) %>%
  slice(1:5) %>% 
  knitr::kable(
    digits = 3,
    caption = "Top 5 grossing movies in data", 
    booktabs = TRUE
  )

## ---- echo=FALSE---------------------------------------------------------
biopics %>%
  arrange(box_office) %>%
  slice(1:5) %>% 
  knitr::kable(
    digits = 3,
    caption = "Bottom 5 grossing movies in data", 
    booktabs = TRUE
  )

## ----logtransform2, echo=TRUE, message=FALSE, warning=FALSE, fig.cap="Histogram of log10(box office revenue)"----
ggplot(biopics, aes(x = log10(box_office))) +
  geom_histogram(color = "white") +
  labs(x = "log10(Box office revenue)")

## ----logtransform3, echo=TRUE, message=FALSE, warning=FALSE, fig.cap="Histogram of box office revenue (log-10 scale)"----
ggplot(biopics, aes(x = box_office)) +
  geom_histogram(color = "white") +
  scale_x_log10() +
  labs(x = "Box office revenue (log10-scale))")

## ----2catxplot, echo=TRUE, warning=FALSE, fig.cap="Box office revenue vs biopic subject info"----
ggplot(biopics, aes(x = subject_sex, y = box_office)) +
  facet_wrap(~person_of_color, nrow = 1) +
  scale_y_log10() +
  geom_boxplot() +
  labs(x = "Subject sex", y = "Box office revenue (log10-scale)", title =
  "Person of color?")

## ---- eval=FALSE---------------------------------------------------------
## biopics %>%
##   group_by(person_of_color, subject_sex) %>%
##   summarise(mean_box_office = mean(box_office)) %>%
##   arrange(desc(mean_box_office))

## ---- echo=FALSE---------------------------------------------------------
biopics %>%
  group_by(person_of_color, subject_sex) %>%
  summarise(mean_box_office = mean(box_office)) %>%
  arrange(desc(mean_box_office)) %>% 
  knitr::kable(
    digits = 3,
    caption = "Group means", 
    booktabs = TRUE
  )

## ---- eval=FALSE---------------------------------------------------------
## biopics %>%
##   group_by(person_of_color, subject_sex) %>%
##   summarise(n = n()) %>%
##   arrange(desc(n))

## ---- echo=FALSE---------------------------------------------------------
biopics %>%
  group_by(person_of_color, subject_sex) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>% 
  knitr::kable(
    digits = 3,
    caption = "Number of movies of each type in dataset", 
    booktabs = TRUE
  )

## ---- eval=FALSE---------------------------------------------------------
## box_office_model <- lm(box_office ~ person_of_color * subject_sex, data = biopics)
## get_regression_table(box_office_model)

## ---- echo=FALSE---------------------------------------------------------
box_office_model <- lm(box_office ~ person_of_color * subject_sex, data = biopics)
get_regression_table(box_office_model) %>% 
  knitr::kable(
    digits = 3,
    caption = "Regression table", 
    booktabs = TRUE
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

## ----echo=FALSE, fig.height=4, fig.cap="Relationship between credit card balance and credit limit/income"----
grid.arrange(model3_balance_vs_limit_plot, model3_balance_vs_income_plot, nrow = 1)

## ---- credit_limit_quartiles, echo=FALSE, fig.cap="Histogram of credit limits and quartiles"----
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

model3_balance_vs_income_plot_colored <- ggplot(Credit, aes(x = Income, y = Balance, col = limit_bracket)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(x = "Income (in $1000)", y = "Credit card balance (in $)", 
       color = "Credit limit\nbracket", title = "Balance vs income") + 
  theme(legend.position = "bottom")
  
grid.arrange(model3_balance_vs_income_plot, model3_balance_vs_income_plot_colored, nrow = 1)
#cowplot::plot_grid(model3_balance_vs_income_plot, model3_balance_vs_income_plot_colored, nrow = 1, rel_widths = c(2/5, 3/5))

## ---- 2numxplot5, echo=FALSE, warning=FALSE, fig.cap="Relationship between credit card balance and income for different credit limit brackets"----
ggplot(Credit, aes(x = Income, y = Balance)) +
  geom_point() +
  facet_wrap(~limit_bracket) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(x = "Income (in $1000)", y = "Credit card balance (in $)")

