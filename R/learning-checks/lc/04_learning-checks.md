**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What are common characteristics of "tidy" data frames?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** What makes "tidy" data frames useful for organizing data?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Take a look at the `airline_safety` data frame included in the `fivethirtyeight` data package. Run the following: airline_safety After reading the help file by running `?airline_safety`, we see that `airline_safety` is a data frame containing information on different airline companies' safety records. This data was originally reported on the data journalism website, FiveThirtyEight.com, in Nate Silver's article, ["Should Travelers Avoid Flying Airlines That Have Had Crashes in the Past?"](https://fivethirtyeight.com/features/should-travelers-avoid-flying-airlines-that-have-had-crashes-in-the-past/). Let's only consider the variables `airline` and those relating to fatalities for simplicity: airline_safety_smaller <- airline_safety |> select(airline, starts_with("fatalities")) airline_safety_smaller This data frame is not in "tidy" format. How would you convert this data frame to be in "tidy" format, in particular so that it has a variable `fatalities_years` indicating the incident year and a variable `count` of the fatality counts?

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Convert the `dem_score` data frame into a "tidy" data frame and assign the name of `dem_score_tidy` to the resulting long-formatted data frame.

**Solution**:


**`r paste0("(LC", chap, ".", (lc <- lc + 1), ")")`** Read in the life expectancy data stored at <https://moderndive.com/data/le_mess.csv> and convert it to a "tidy" data frame.

**Solution**:


