**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Compute the observed values, fitted values, and residuals not for the interaction model as we just did, but rather for the parallel slopes model we saved in `score_model_parallel_slopes`.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Conduct a new exploratory data analysis with the same outcome variable $y$ `debt` but with `credit_rating` and `age` as the new explanatory variables $x_1$ and $x_2$. What can you say about the relationship between a credit card holder's debt and their credit rating and age?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Fit a new simple linear regression using `lm(debt ~ credit_rating + age, data = credit_ch6)` where `credit_rating` and `age` are the new numerical explanatory variables $x_1$ and $x_2$. Get information about the "best-fitting" regression plane from the regression table by applying the `get_regression_table()` function. How do the regression results match up with the results from your previous exploratory data analysis?

**Solution**:


