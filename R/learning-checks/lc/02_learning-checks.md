**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Take a look at both the `flights` data frame from the `nycflights23` package and the `envoy_flights` data frame from the `moderndive` package by running `View(flights)` and `View(envoy_flights)`. In what respect do these data frames differ? For example, think about the number of rows in each dataset.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What are practical reasons why `dep_delay` and `arr_delay` have a positive relationship?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What variables in the `weather` data frame would you expect to have a negative correlation (i.e., a negative relationship) with `dep_delay`? Why? Remember that we are focusing on numerical variables here. Hint: Explore the `weather` dataset by using the `View()` function.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why do you believe there is a cluster of points near (0, 0)? What does (0, 0) correspond to in terms of the Envoy Air flights?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What are some other features of the plot that stand out to you?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Create a new scatterplot using different variables in the `envoy_flights` data frame by modifying the example given.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why is setting the `alpha` argument value useful with scatterplots? What further information does it give you that a regular scatterplot cannot?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** After viewing Figure \@ref(fig:alpha), give an approximate range of arrival delays and departure delays that occur most frequently. How has that region changed compared to when you observed the same plot without `alpha = 0.2` set in Figure \@ref(fig:noalpha)?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Take a look at both the `weather` data frame from the `nycflights23` package and the `early_january_2023_weather` data frame from the `moderndive` package by running `View(weather)` and `View(early_january_2023_weather)`. In what respect do these data frames differ?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** `View()` the `flights` data frame again. Why does the `time_hour` variable uniquely identify the hour of the measurement, whereas the `hour` variable does not?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why should linegraphs be avoided when there is not a clear ordering of the horizontal axis?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why are linegraphs frequently used when time is the explanatory variable on the x-axis?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Plot a time series of a variable other than `wind_speed` for Newark Airport in the first 15 days of January 2023. Try to select a variable that doesn't have a lot of missing (`NA`) values.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What does changing the number of bins from 30 to 20 tell us about the distribution of wind speeds?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Would you classify the distribution of wind speeds as symmetric or skewed in one direction or another?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What would you guess is the "center" value in this distribution? Why did you make that choice?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Is this data spread out greatly from the center or is it close? Why?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What other things do you notice about this faceted plot? How does a faceted plot help us see relationships between two variables?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What do the numbers 1-12 correspond to in the plot? What about 10, 20, and 30?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** For which types of datasets would faceted plots not work well in comparing relationships between variables? Give an example describing the nature of these variables and other important characteristics.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Does the `wind_speed` variable in the `weather` dataset have a lot of variability? Why do you say that?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What do the dots at the top of the plot for January correspond to? Explain what might have occurred in January to produce these points.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Which months seem to have the highest variability in wind speed? What reasons can you give for this?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** We looked at the distribution of the numerical variable `wind_speed` split by the numerical variable `month` that we converted using the `factor()` function in order to make a side-by-side boxplot. Why would a boxplot of `wind_speed` split by the numerical variable `pressure` similarly converted to a categorical variable using the `factor()` not be informative?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Boxplots provide a simple way to identify outliers. Why may outliers be easier to identify when looking at a boxplot instead of a faceted histogram?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why are histograms inappropriate for categorical variables?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What is the difference between histograms and barplots?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** How many Alaska Air flights departed NYC in 2023?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What was the 7th highest airline for departed flights from NYC in 2023? How could we better present the table to get this answer quickly? ### Must avoid pie charts! One of the most common plots used to visualize the distribution of categorical data is the \index{pie charts} pie chart. While they may seem harmless enough, pie charts actually present a problem in that humans are unable to judge angles well. As Naomi Robbins describes in her book, *Creating More Effective Graphs* [@robbins2013], we overestimate angles greater than 90 degrees and we underestimate angles less than 90 degrees. In other words, it is difficult for us to determine the relative size of one piece of the pie compared to another. Let's examine the same data used in our previous barplot of the number of flights departing NYC by airline in Figure \@ref(fig:flightsbar), but this time we will use a pie chart in Figure \@ref(fig:carrierpie). Try to answer the following questions: * How much smaller is the portion of the pie for Hawaiian Airlines Inc. (`HA`) compared to United Airlines (`UA`)? * What is the third largest carrier in terms of departing flights? * How many carriers have fewer flights than Delta Air Lines Inc. (`DL`)? if (is_html_output()) { ggplot(flights, mapping = aes(x = factor(1), fill = carrier)) + geom_bar(width = 1) + coord_polar(theta = "y") + theme( axis.title.x = element_blank(), axis.title.y = element_blank(), axis.ticks = element_blank(), axis.text.y = element_blank(), axis.text.x = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank() ) + guides(fill = guide_legend(keywidth = 0.8, keyheight = 0.8)) } else { ggplot(flights, mapping = aes(x = factor(1), fill = carrier)) + geom_bar(width = 1) + coord_polar(theta = "y") + theme_light() + theme( axis.title.x = element_blank(), axis.title.y = element_blank(), axis.ticks = element_blank(), axis.text.y = element_blank(), axis.text.x = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank() ) + guides(fill = guide_legend(keywidth = 0.8, keyheight = 0.8)) + scale_fill_grey() } While it is quite difficult to answer these questions when looking at the pie chart in Figure \@ref(fig:carrierpie), we can much more easily answer these questions using the barchart in Figure \@ref(fig:flightsbar). This is true since barplots present the information in a way such that comparisons between categories can be made with single horizontal lines, whereas pie charts present the information in a way such that comparisons must be made by \index{pie charts!problems with} comparing angles.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why should pie charts be avoided and replaced by barplots?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why do you think people continue to use pie charts?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What kinds of questions are not easily answered by looking at Figure \@ref(fig:flights-stacked-bar)?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What can you say, if anything, about the relationship between airline and airport in NYC in 2023 in regard to the number of departing flights?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why might the side-by-side barplot be preferable to a stacked barplot in this case?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What are the disadvantages of using a dodged barplot, in general?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why is the faceted barplot preferred to the side-by-side and stacked barplots in this case?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What information about the different carriers at different airports is more easily seen in the faceted barplot?

**Solution**:


