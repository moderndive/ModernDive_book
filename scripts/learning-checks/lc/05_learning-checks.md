**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Conduct a new exploratory data analysis with the same outcome variable $y$ being `fert_rate` but with `obes_rate` as the new explanatory variable $x$. Remember, this involves three things: (a) Looking at the raw data values. (a) Computing summary statistics. (a) Creating data visualizations. What can you say about the relationship between obesity rate and fertility rate based on this exploration?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What is the main purpose of performing an exploratory data analysis (EDA) before fitting a regression model? - A. To predict future values. - B. To understand the relationship between variables and detect potential issues. - C. To create more variables. - D. To generate random samples.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Which of the following is correct about the correlation coefficient? - A. It ranges from -2 to 2. - B. It only measures the strength of non-linear relationships. - C. It ranges from -1 to 1 and measures the strength of linear relationships. - D. It is always zero.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Fit a simple linear regression using `lm(fert_rate ~ obes_rate, data = UN_data_ch5)` where `obes_rate` is the new explanatory variable $x$. Learn about the "best-fitting" line from the regression coefficients by applying the `coef()` function. How do the regression results match up with your earlier exploratory data analysis?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What does the intercept term $b_0$ represent in simple linear regression? - A. The change in the outcome for a one-unit change in the explanatory variable. - B. The predicted value of the outcome when the explanatory variable is zero. - C. The standard error of the regression. - D. The correlation between the outcome and explanatory variables.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What best describes the "slope" of a simple linear regression line? - A. The increase in the explanatory variable for a one-unit increase in the outcome. - B. The average of the explanatory variable. - C. The change in the outcome for a one-unit increase in the explanatory variable. - D. The minimum value of the outcome variable.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What does a negative slope in a simple linear regression indicate? - A. The outcome variable decreases as the explanatory variable increases. - B. The explanatory variable remains constant as the outcome variable increases. - C. The correlation coefficient is zero. - D. The outcome variable increases as the explanatory variable increases.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What is a "wrapper function" in the context of statistical modeling in R? - A. A function that directly fits a regression model without using any other functions. - B. A function that combines other functions to simplify complex operations and provide a user-friendly interface. - C. A function that removes missing values from a dataset before analysis. - D. A function that only handles categorical data in regression models.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Generate a data frame of the residuals of the *Learning check* model where you used `obes_rate` as the explanatory $x$ variable.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Which of the following statements is true about the regression line in a simple linear regression model? - A. The regression line represents the average of the outcome variable. - B. The regression line minimizes the sum of squared differences between the observed and predicted values. - C. The regression line always has a slope of zero. - D. The regression line is only useful when there is no correlation between variables.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Conduct a new exploratory data analysis with the same explanatory variable $x$ being `continent` but with `gdp_per_capita` as the new outcome variable $y$. What can you say about the differences in GDP per capita between continents based on this exploration?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** When using a categorical explanatory variable in regression, what does the baseline group represent? - A. The group with the highest mean - B. The group chosen for comparison with all other groups - C. The group with the most data points - D. The group with the lowest standard deviation

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Fit a linear regression using `lm(gdp_per_capita ~ continent, data = gapminder2022)` where `gdp_per_capita` is the new outcome variable. Get information about the "best-fitting" line from the regression coefficients. How do the regression results match up with the results from your previous exploratory data analysis?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** How many "offsets" or differences from the baseline will a regression model output for a categorical variable with 4 levels? - A. 1 - B. 2 - C. 3 - D. 4

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Which interpretation is correct for a positive coefficient in a regression model with a categorical explanatory variable? - A. It indicates the baseline group. - B. It represents the mean value of the baseline group. - C. The corresponding group has a higher response mean than the baseline's. - D. The corresponding group has a lower response mean than the baseline's.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Which of the following statements about residuals in regression is true? - A. Residuals are the differences between the fitted and observed response values. - B. Residuals are always positive. - C. Residuals are not important for model evaluation. - D. Residuals are the predicted values in the model.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Using either the sorting functionality of RStudio's spreadsheet viewer or using the data wrangling tools you learned in Chapter \@ref(wrangling), identify the five countries with the five smallest (most negative) residuals? What do these negative residuals say about their life expectancy relative to their continents' life expectancy?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Repeat this process, but identify the five countries with the five largest (most positive) residuals. What do these positive residuals say about their life expectancy relative to their continents' life expectancy?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Note in Figure \@ref(fig:three-lines) there are 3 points marked with dots and: * The "best" fitting solid regression line `r if_else(is_latex_output(), "", "in blue")` * An arbitrarily chosen dotted `r if_else(is_latex_output(), "", "red")` line * Another arbitrarily chosen dashed `r if_else(is_latex_output(), "", "green")` line example <- tibble( x = c(0, 0.5, 1), y = c(2, 1, 3) ) ggplot(example, aes(x = x, y = y)) + geom_smooth(method = "lm", se = FALSE, fullrange = TRUE) + geom_hline(yintercept = 2.5, col = "red", linetype = "dotted", size = 1) + geom_abline( intercept = 2, slope = -1, col = "forestgreen", linetype = "dashed", linewidth = 1 ) + geom_point(size = 4) Compute the sum of squared residuals by hand for each line. Show that the regression line `r if_else(is_latex_output(), "", "in blue")` has the smallest value of these three lines.

**Solution**:


