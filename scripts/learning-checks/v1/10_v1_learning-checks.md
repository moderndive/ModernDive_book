**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Continuing with our regression using `age` as the explanatory variable and teaching `score` as the outcome variable. - Use the `get_regression_points()` function to get the observed values, fitted values, and residuals for all `r n_evals_ch5` instructors. - Perform a residual analysis and look for any systematic patterns in the residuals. Ideally, there should be little to no pattern but comment on what you find here.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Repeat the inference but this time for the correlation coefficient instead of the slope. Note the implementation of `stat = "correlation"` in the `calculate()` function of the `infer` package.

**Solution**:


