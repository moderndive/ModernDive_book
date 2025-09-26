**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why does the following code produce an error? In other words, what about the response and predictor variables make this not a possible computation with the `infer` package? library(moderndive) library(infer) null_distribution_mean <- promotions %>% specify(formula = decision ~ gender, success = "promoted") %>% hypothesize(null = "independence") %>% generate(reps = 1000, type = "permute") %>% calculate(stat = "diff in means", order = c("male", "female"))

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why are we relatively confident that the distributions of the sample proportions will be good approximations of the population distributions of promotion proportions for the two genders?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Using the definition of _p-value_, write in words what the $p$-value represents for the hypothesis test comparing the promotion rates for males and females.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Describe in a paragraph how we used Allen Downey's diagram to conclude if a statistical difference existed between the promotion rate of males and females using this study.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What is wrong about saying, "The defendant is innocent." based on the US system of criminal trials?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What is the purpose of hypothesis testing?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What are some flaws with hypothesis testing? How could we alleviate them?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Consider two $\alpha$ significance levels of 0.1 and 0.01. Of the two, which would lead to a more *liberal* hypothesis testing procedure? In other words, one that will, all things being equal, lead to more rejections of the null hypothesis $H_0$.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Conduct the same analysis comparing action movies versus romantic movies using the median rating instead of the mean rating. What was different and what was the same?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What conclusions can you make from viewing the faceted histogram looking at `rating` versus `genre` that you couldn't see when looking at the boxplot?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Describe in a paragraph how we used Allen Downey's diagram to conclude if a statistical difference existed between mean movie ratings for action and romance movies.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why are we relatively confident that the distributions of the sample ratings will be good approximations of the population distributions of ratings for the two genres?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Using the definition of $p$-value, write in words what the $p$-value represents for the hypothesis test comparing the mean rating of romance to action movies.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What is the value of the $p$-value for the hypothesis test comparing the mean rating of romance to action movies?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Test your data wrangling knowledge and EDA skills: - Use `dplyr` and `tidyr` to create the necessary data frame focused on only action and romance movies (but not both) from the `movies` data frame in the `ggplot2movies` package. - Make a boxplot and a faceted histogram of this population data comparing ratings of action and romance movies from IMDb. - Discuss how these plots compare to the similar plots produced for the `movies_sample` data.

**Solution**:


