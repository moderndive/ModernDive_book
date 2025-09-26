**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What's another way of using the "not" operator `!` to filter only the rows that are not going to Burlington, VT nor Seattle, WA in the `flights` data frame? Test this out using the previous code.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Say a doctor is studying the effect of smoking on lung cancer for a large number of patients who have records measured at five-year intervals. She notices that a large number of patients have missing data points because the patient has died, so she chooses to ignore these patients in her analysis. What is wrong with this doctor's approach?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Modify the earlier `summarize()` function code that creates the `summary_windspeed` data frame to also use the `n()` summary function: `summarize(... , count = n())`. What does the returned value correspond to?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why doesn't the following code work? Run the code line-by-line instead of all at once, and then look at the data. In other words, select and then run `summary_windspeed <- weather |> summarize(mean = mean(wind_speed, na.rm = TRUE))` first. summary_windspeed <- weather |> summarize(mean = mean(wind_speed, na.rm = TRUE)) |> summarize(std_dev = sd(wind_speed, na.rm = TRUE))

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Recall from Chapter \@ref(viz) when we looked at wind speeds by months in NYC. What does the standard deviation column in the `summary_monthly_temp` data frame tell us about temperatures in NYC throughout the year?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What code would be required to get the mean and standard deviation wind speed for each day in 2023 for NYC?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Recreate `by_monthly_origin`, but instead of grouping via `group_by(origin, month)`, group variables in a different order `group_by(month, origin)`. What differs in the resulting dataset?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** How could we identify how many flights left each of the three airports for each `carrier`?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** How does the `filter()` operation differ from a `group_by()` followed by a `summarize()`?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What do positive values of the `gain` variable in `flights` correspond to? What about negative values? And what about a zero value?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Could we create the `dep_delay` and `arr_delay` columns by simply subtracting `dep_time` from `sched_dep_time` and similarly for arrivals? Try the code out and explain any differences between the result and what actually appears in `flights`.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What can we say about the distribution of `gain`? Describe it in a few sentences using the plot and the `gain_summary` data frame values.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Looking at Figure \@ref(fig:reldiagram), when joining `flights` and `weather` (or, in other words, matching the hourly weather values with each flight), why do we need to join by all of `year`, `month`, `day`, `hour`, and `origin`, and not just `hour`?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What surprises you about the top 10 destinations from NYC in 2023?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What are some advantages of data in normal forms? What are some disadvantages?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What are some ways to select all three of the `dest`, `air_time`, and `distance` variables from `flights`? Give the code showing how to do this in at least three different ways.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** How could one use `starts_with()`, `ends_with()`, and `contains()` to select columns from the `flights` data frame? Provide three different examples in total: one for `starts_with()`, one for `ends_with()`, and one for `contains()`.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Why might we want to use the `select()` function on a data frame?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Create a new data frame that shows the top 5 airports with the largest arrival delays from NYC in 2023.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Let's now put your newly acquired data-wrangling skills to the test! An airline industry measure of a passenger airline's capacity is the [available seat miles](https://en.wikipedia.org/wiki/Available_seat_miles), which is equal to the number of seats available multiplied by the number of miles or kilometers flown summed over all flights. For example, let's consider the scenario in Figure \@ref(fig:available-seat-miles). Since the airplane has 4 seats and it travels 200 miles, the available seat miles are $4 \times 200 = 800$. include_graphics("images/flowcharts/flowchart/flowchart.012.png") Extending this idea, let's say an airline had 2 flights using a plane with 10 seats that flew 500 miles and 3 flights using a plane with 20 seats that flew 1000 miles, the available seat miles would be $2 \times 10 \times 500 + 3 \times 20 \times 1000 = 70,000$ seat miles. Using the datasets included in the `nycflights23` package, compute the available seat miles for each airline sorted in descending order. After completing all the necessary data-wrangling steps, the resulting data frame should have `r nrow(nycflights23::airlines)` rows (one for each airline) and 2 columns (airline name and available seat miles). Here are some hints: 1. **Crucial**: Unless you are very confident in what you are doing, it is worthwhile not starting to code right away. Rather, first sketch out on paper all the necessary data wrangling steps not using exact code, but rather high-level *pseudocode* that is informal yet detailed enough to articulate what you are doing. This way you won't confuse *what* you are trying to do (the algorithm) with *how* you are going to do it (writing `dplyr` code). 1. Take a close look at all the datasets using the `View()` function: `flights`, `weather`, `planes`, `airports`, and `airlines` to identify which variables are necessary to compute available seat miles. 1. Figure \@ref(fig:reldiagram) showing how the various datasets can be joined will also be useful. 1. Consider the data-wrangling verbs in Table \@ref(tab:wrangle-summary-table) as your toolbox!

**Solution**:


