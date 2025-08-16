**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Conduct a new exploratory data analysis with the same outcome variable $y$ being `score` but with `age` as the new explanatory variable $x$. Remember, this involves three things: (a) Looking at the raw data values. (a) Computing summary statistics. (a) Creating data visualizations. What can you say about the relationship between age and teaching scores based on this exploration?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Fit a new simple linear regression using `lm(score ~ age, data = evals_ch5)` where `age` is the new explanatory variable $x$. Get information about the "best-fitting" line from the regression table by applying the `get_regression_table()` function. How do the regression results match up with the results from your earlier exploratory data analysis?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Generate a data frame of the residuals of the model where you used `age` as the explanatory $x$ variable.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Conduct a new exploratory data analysis with the same explanatory variable $x$ being `continent` but with `gdpPercap` as the new outcome variable $y$. What can you say about the differences in GDP per capita between continents based on this exploration?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Fit a new linear regression using `lm(gdpPercap ~ continent, data = gapminder2007)` where `gdpPercap` is the new outcome variable $y$. Get information about the "best-fitting" line from the regression table by applying the `get_regression_table()` function. How do the regression results match up with the results from your previous exploratory data analysis?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Using either the sorting functionality of RStudio's spreadsheet viewer or using the data wrangling tools you learned in Chapter \@ref(wrangling), identify the five countries with the five smallest (most negative) residuals? What do these negative residuals say about their life expectancy relative to their continents' life expectancy?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Repeat this process, but identify the five countries with the five largest (most positive) residuals. What do these positive residuals say about their life expectancy relative to their continents' life expectancy?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Note in Figure \@ref(fig:three-lines) there are 3 points marked with dots and: * The "best" fitting solid regression line `r if_else(is_latex_output(), "", "in blue")` * An arbitrarily chosen dotted `r if_else(is_latex_output(), "", "red")` line * Another arbitrarily chosen dashed `r if_else(is_latex_output(), "", "green")` line example <- tibble( x = c(0, 0.5, 1), y = c(2, 1, 3) ) ggplot(example, aes(x = x, y = y)) + geom_smooth(method = "lm", se = FALSE, fullrange = TRUE) + geom_hline(yintercept = 2.5, col = "red", linetype = "dotted", size = 1) + geom_abline( intercept = 2, slope = -1, col = "forestgreen", linetype = "dashed", size = 1 ) + geom_point(size = 4) Compute the sum of squared residuals by hand for each line and show that of these three lines, the regression line `r if_else(is_latex_output(), "", "in blue")` has the smallest value.

**Solution**:


