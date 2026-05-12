**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What does the error term $\epsilon$ in the linear model $Y = \beta_0 + \beta_1 \cdot X + \epsilon$ represent? - A. The exact value of the response variable. - B. The predicted value of the response variable based on the model. - C. The part of the response variable not explained by the line. - D. The slope of the linear relationship between $X$ and $Y$.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Which of the following is a property of the least squares estimators $b_0$ and $b_1$? - A. They are biased estimators of the population parameters $\beta_0$ and $\beta_1$. - B. They are linear combinations of the observed responses $y_1, y_2, \ldots, y_n$. - C. They are always equal to the population parameters $\beta_0$ and $\beta_1$. - D. They depend on the specific values of the explanatory variable $X$ only.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** How can the difference in means between two groups be represented in a linear regression model? - A. By adding an interaction term between the groups and the response variable. - B. By fitting separate regression lines for each group and comparing their slopes. - C. By including a dummy variable to represent the groups. - D. By subtracting the mean of one group from the mean of the other and using this difference as the predictor.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** In the context of a linear regression model, what does the null hypothesis $H_0: \beta_1 = 0$ represent? - A. There is no linear association between the response and the explanatory variable. - B. The difference between the observed and predicted values is zero. - C. The linear association between response and explanatory variable crosses the origin. - D. The probability of committing a Type II Error is zero. <!-- question above was repeated. I changed it -->

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Which of the following is an assumption of the linear regression model? - A. The error terms $\epsilon_i$ are normally distributed with constant variance. - B. The error terms $\epsilon_i$ have a non-zero mean. - C. The error terms $\epsilon_i$ are dependent on each other. - D. The explanatory variable must be normally distributed.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What does it mean when we say that the slope estimator $b_1$ is a random variable? - A. $b_1$ will be the same for every sample taken from the population. - B. $b_1$ is a fixed value that does not change with different samples. - C. $b_1$ can vary from sample to sample due to sampling variation. - D. $b_1$ is always equal to the population slope $\beta_1$.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Use the the `un_member_states_2024` data frame included in the `moderndive` package with response variable fertility rate (`fert_rate`) and the regressor life expectancy (`life_exp`). - Use the `get_regression_points()` function to get the observed values, fitted values, and residuals for all UN member countries. - Perform a residual analysis and look for any systematic patterns in the residuals. Ideally, there should be little to no pattern but comment on what you find here.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** In the context of linear regression, a `p_value` of near zero for the slope coefficient suggests which of the following? - A. The intercept is statistically significant at a 95% confidence level. - B. There is strong evidence against the null hypothesis that the slope coefficient is zero, suggesting there exists a linear relationship between the explanatory and response variables. - C. The variance of the response variable is significantly greater than the variance of the explanatory variable. - D. The residuals are normally distributed with mean zero and constant variance.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Explain whether or not the residual plot helps assess each one of the following assumptions. - Linearity of the relationship between variables - Independence of the error terms - Normality of the error terms - Equality or constancy of variance

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** If the residual plot against fitted values shows a "U-shaped" pattern, what does this suggest? - A. The variance of the residuals is constant. - B. The linearity assumption is violated. - C. The independence assumption is violated. - D. The normality assumption is satisfied.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Repeat the inference but this time for the correlation coefficient instead of the slope. Note the implementation of `stat = "correlation"` in the `calculate()` function of the `infer` package.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why is it appropriate to use the bootstrap percentile method to construct a 95% confidence interval for the population slope $\beta_1$ in the Old Faithful data? - A. Because it assumes the slope follows a perfect normal distribution. - B. Because it relies on resampling the residuals instead of the original data points. - C. Because it requires the original data to be uniformly distributed. - D. Because it does not require the bootstrap distribution to be normally shaped.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What is the role of the permutation test in the hypothesis testing for the population slope $\beta_1$? - A. It generates new samples to confirm the confidence interval boundaries. - B. It assesses whether the observed slope could have occurred by chance under the null hypothesis of no relationship. - C. It adjusts the sample size to reduce sampling variability. - D. It ensures the residuals of the regression model are normally distributed.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** After generating a null distribution for the slope using `infer`, you find the $p$-value to be near 0. What does this indicate about the relationship between `waiting` and `duration` in the Old Faithful data? - A. There is no evidence of a relationship between `waiting` and `duration`. - B. The observed slope is likely due to random variation under the null hypothesis. - C. The observed slope is significantly different from zero, suggesting a meaningful relationship between `waiting` and `duration`. - D. The null hypothesis cannot be rejected because the $p$-value is too small.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** In a multiple linear regression model, what does the coefficient $\beta_j$ represent? - A. The intercept of the model. - B. The standard error of the estimate. - C. The total variance explained by the model. - D. The partial slope related to the regressor $X_j$, accounting for all other regressors.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why is it necessary to convert `continent_of_origin` to a factor when preparing the `coffee_data` data frame for regression analysis? - A. To allow the regression model to interpret `continent_of_origin` as a numerical variable. - B. To create dummy variables that represent different categories of `continent_of_origin`. - C. To reduce the number of observations in the dataset. - D. To ensure the variable is included in the correlation matrix.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What is the purpose of creating a scatterplot matrix in the context of multiple linear regression? - A. To identify outliers that need to be removed from the dataset. - B. To test for normality of the residuals. - C. To examine linear relationships between all variable pairs and identify multicollinearity among regressors. - D. To determine the appropriate number of dummy variables.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** In the multiple regression model for the `coffee_data`, what is the role of dummy variables for `continent_of_origin`? - A. They are used to predict the values of the numerical regressors. - B. They modify the intercept based on the specific category of `continent_of_origin`. - C. They serve to test the independence of residuals. - D. They indicate which observations should be excluded from the model.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why is it essential to know that the estimators ($b_0, b_1, \dots, b_p$) in multiple linear regression are unbiased? - A. It ensures that the variance of the estimators is always zero. - B. It means that, on average, the estimators will equal the true population parameters they estimate. - C. It implies that the estimators have a standard error of zero. - D. It suggests that the regression model will always have a perfect fit.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why do the least-squares estimates of coefficients change when different sets of regressors are used in multiple linear regression? - A. Because the coefficients are recalculated each time, irrespective of the regressors. - B. Because the residuals are always zero when regressors are changed. - C. Because the value of each coefficient depends on the specific combination of regressors included in the model. - D. Because all models with different regressors will produce identical estimates.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** How is a 95% confidence interval for a coefficient in multiple linear regression constructed? - A. By using the point estimate, the critical value from the t-distribution, and the standard error of the coefficient. - B. By taking the standard deviation of the coefficients only. - C. By resampling the data without replacement. - D. By calculating the mean of all the coefficients.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What does the ANOVA test for comparing two models in multiple linear regression evaluate? - A. Whether all regressors in both models have the same coefficients. - B. Whether the reduced model is adequate or if the full model is needed. - C. Whether the residuals of the two models follow a normal distribution. - D. Whether the regression coefficients of one model are unbiased estimators.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why might one prefer to use simulation-based methods (e.g., bootstrapping) for inference in multiple linear regression? - A. Because simulation-based methods require larger sample sizes than theory-based methods. - B. Because simulation-based methods are always faster to compute than theory-based methods. - C. Because simulation-based methods guarantee the correct model is used. - D. Because simulation-based methods do not rely on the assumptions of normality or large sample sizes.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What is the purpose of constructing a bootstrap distribution for the partial slopes in multiple linear regression? - A. To replace the original data with random numbers. - B. To approximate the sampling distribution of the partial slopes by resampling with replacement. - C. To calculate the exact values of the coefficients in the population. - D. To test if the model assumptions are violated.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** If a 95% confidence interval for a partial slope in multiple linear regression includes 0, what does this suggest about the variable? - A. The variable does not have a statistically significant relationship with the response variable. - B. The variable is statistically significant. - C. The variable's coefficient estimate is always negative. - D. The variable was removed from the model during bootstrapping.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** In hypothesis testing for the partial slopes using permutation tests, what does it mean if an observed test statistic falls far to the right of the null distribution? - A. The variable is likely to have no effect on the response. - B. The null hypothesis should be accepted. - C. The variable is likely statistically significant, and we should reject the null. - D. The observed data should be discarded.

**Solution**:


