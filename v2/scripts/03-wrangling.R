## ----wrangling-load-packages, message=FALSE-----------------------------------
library(dplyr)
library(ggplot2)
library(nycflights23)








## ----wrangling-filter-alaska, eval=FALSE--------------------------------------
# envoy_flights <- flights |>
#   filter(carrier == "AS")




## ----wrangling-view-phoenix_flights, eval=FALSE-------------------------------
# phoenix_flights <- flights |>
#   filter(dest == "PHX")
# View(phoenix_flights)


## ----wrangling-view-btv_sea_flights_fall, eval=FALSE--------------------------
# btv_sea_flights_fall <- flights |>
#   filter(origin == "JFK" & (dest == "BTV" | dest == "SEA") & month >= 10)
# View(btv_sea_flights_fall)


## ----wrangling-assign-btv_sea_flights_fa, eval=FALSE--------------------------
# btv_sea_flights_fall <- flights |>
#   filter(origin == "JFK", (dest == "BTV" | dest == "SEA"), month >= 10)
# View(btv_sea_flights_fall)


## ----wrangling-view-not_BTV_SEA, eval=FALSE-----------------------------------
# not_BTV_SEA <- flights |>
#   filter(!(dest == "BTV" | dest == "SEA"))
# View(not_BTV_SEA)


## ----wrangling-filter, eval=FALSE---------------------------------------------
# flights |> filter(!dest == "BTV" | dest == "SEA")


## ----wrangling-create-many_airports, eval=FALSE-------------------------------
# many_airports <- flights |>
#   filter(dest == "SEA" | dest == "SFO" | dest == "PHX" |
#          dest == "BTV" | dest == "BDL")


## ----wrangling-view-many_airports, eval=FALSE---------------------------------
# many_airports <- flights |>
#   filter(dest %in% c("SEA", "SFO", "PHX", "BTV", "BDL"))
# View(many_airports)






## ----wrangling-conditional-text, echo=FALSE, results="asis"-------------------
if(!is_latex_output()) 
  cat("See [Appendix A online](https://moderndive.com/v2/appendixa) for a glossary of such summary statistics.")






## ----wrangling-mean-and-sd----------------------------------------------------
summary_windspeed <- weather |> 
  summarize(mean = mean(wind_speed), std_dev = sd(wind_speed))
summary_windspeed


## ----wrangling-mean-sd-wind---------------------------------------------------
summary_windspeed <- weather |> 
  summarize(mean = mean(wind_speed, na.rm = TRUE), 
            std_dev = sd(wind_speed, na.rm = TRUE))
summary_windspeed




## ----wrangling-assign-summary_windspeed, eval=FALSE---------------------------
# summary_windspeed <- weather |>
#   summarize(mean = mean(wind_speed, na.rm = TRUE)) |>
#   summarize(std_dev = sd(wind_speed, na.rm = TRUE))






## ----wrangling-mean-sd-temp---------------------------------------------------
summary_temp <- weather |> 
  summarize(mean = mean(wind_speed, na.rm = TRUE), 
            std_dev = sd(wind_speed, na.rm = TRUE))
summary_temp


## ----wrangling-summary-by-month-----------------------------------------------
summary_monthly_windspeed <- weather |> 
  group_by(month) |> 
  summarize(mean = mean(wind_speed, na.rm = TRUE), 
            std_dev = sd(wind_speed, na.rm = TRUE))
summary_monthly_windspeed


## ----wrangling-show-diamonds--------------------------------------------------
diamonds


## ----wrangling-demo-code------------------------------------------------------
diamonds |> 
  group_by(cut)




## ----wrangling-grouped-summary------------------------------------------------
diamonds |> 
  group_by(cut) |> 
  summarize(avg_price = mean(price))


## ----wrangling-ungroup-data---------------------------------------------------
diamonds |> 
  group_by(cut) |> 
  ungroup()


## ----wrangling-summary-by-origin----------------------------------------------
by_origin <- flights |> 
  group_by(origin) |> 
  summarize(count = n())
by_origin


## ----wrangling-assign-by_origin_monthly---------------------------------------
by_origin_monthly <- flights |> 
  group_by(origin, month) |> 
  summarize(count = n())


## ----wrangling-v26------------------------------------------------------------
by_origin_monthly


## ----wrangling-count-by-origin------------------------------------------------
by_origin_monthly_incorrect <- flights |> 
  group_by(origin) |> 
  group_by(month) |> 
  summarize(count = n())
by_origin_monthly_incorrect








## ----wrangling-create-weather, eval=TRUE--------------------------------------
weather <- weather |> 
  mutate(temp_in_C = (temp - 32) / 1.8)


## ----wrangling-summary-by-month-v4--------------------------------------------
summary_monthly_temp <- weather |> 
  group_by(month) |> 
  summarize(mean_temp_in_F = mean(temp, na.rm = TRUE), 
            mean_temp_in_C = mean(temp_in_C, na.rm = TRUE))
summary_monthly_temp


## ----wrangling-mutate-gain----------------------------------------------------
flights <- flights |> 
  mutate(gain = dep_delay - arr_delay)






## ----wrangling-mean-sd-narm---------------------------------------------------
gain_summary <- flights |> 
  summarize(
    min = min(gain, na.rm = TRUE),
    q1 = quantile(gain, 0.25, na.rm = TRUE),
    median = quantile(gain, 0.5, na.rm = TRUE),
    q3 = quantile(gain, 0.75, na.rm = TRUE),
    max = max(gain, na.rm = TRUE),
    mean = mean(gain, na.rm = TRUE),
    sd = sd(gain, na.rm = TRUE),
    missing = sum(is.na(gain))
  )
gain_summary


## ----gain-hist, fig.cap="Histogram of gain variable.", message=FALSE, fig.height=ifelse(knitr::is_latex_output(), 3, 4)----
ggplot(data = flights, mapping = aes(x = gain)) +
  geom_histogram(color = "white", bins = 20)


## ----wrangling-mutate-gain-demo-----------------------------------------------
flights <- flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    hours = air_time / 60,
    gain_per_hour = gain / hours
  )






## ----wrangling-count-by-dest--------------------------------------------------
freq_dest <- flights |> 
  group_by(dest) |> 
  summarize(num_flights = n())
freq_dest


## ----wrangling-arrange--------------------------------------------------------
freq_dest |> 
  arrange(num_flights)


## ----wrangling-arrange-desc---------------------------------------------------
freq_dest |> 
  arrange(desc(num_flights))


## ----wrangling-view-airlines, eval=FALSE--------------------------------------
# View(airlines)




## ----wrangling-view-flights, eval=FALSE---------------------------------------
# flights_joined <- flights |>
#   inner_join(airlines, by = "carrier")
# View(flights)
# View(flights_joined)




## ----wrangling-view-airports, eval=FALSE--------------------------------------
# View(airports)


## ----wrangling-view-flights_with_airport, eval=FALSE--------------------------
# flights_with_airport_names <- flights |>
#   inner_join(airports, by = c("dest" = "faa"))
# View(flights_with_airport_names)


## ----wrangling-count-by-dest2-------------------------------------------------
named_dests <- flights |>
  group_by(dest) |>
  summarize(num_flights = n()) |>
  arrange(desc(num_flights)) |>
  inner_join(airports, by = c("dest" = "faa")) |>
  rename(airport_name = name)
named_dests


## ----wrangling-view-flights_weather_join, eval=FALSE--------------------------
# flights_weather_joined <- flights |>
#   inner_join(weather, by = c("year", "month", "day", "hour", "origin"))
# View(flights_weather_joined)






## ----wrangling-view-joined_flights, eval=FALSE--------------------------------
# joined_flights <- flights |>
#   inner_join(airlines, by = "carrier")
# View(joined_flights)










## ----wrangling-glimpse-flights, eval=FALSE------------------------------------
# glimpse(flights)


## ----wrangling-select-vars, eval=FALSE----------------------------------------
# flights |>
#   select(carrier, flight)


## ----wrangling-create-flights_no_year, eval=FALSE-----------------------------
# flights_no_year <- flights |> select(-year)


## ----wrangling-create-flight_arr_times, eval=FALSE----------------------------
# flight_arr_times <- flights |> select(month:day, arr_time:sched_arr_time)
# flight_arr_times


## ----wrangling-select-vars-alt, eval=FALSE------------------------------------
# flights |> select(starts_with("a"))
# flights |> select(ends_with("delay"))
# flights |> select(contains("time"))


## ----wrangling-glimpse-flights_reorder, eval=FALSE----------------------------
# flights_reorder <- flights |>
#   select(year, month, day, hour, minute, time_hour, everything())
# glimpse(flights_reorder)


## ----wrangling-glimpse-flights_relocate, eval=FALSE---------------------------
# flights_relocate <- flights |>
#   relocate(hour, minute, time_hour, .after = day)
# glimpse(flights_relocate)


## ----wrangling-glimpse-flights_time_new, eval=FALSE---------------------------
# flights_time_new <- flights |>
#   select(dep_time, arr_time) |>
#   rename(departure_time = dep_time, arrival_time = arr_time)
# glimpse(flights_time_new)


## ----wrangling-demo-code-v2, eval=FALSE---------------------------------------
# named_dests |> top_n(n = 10, wt = num_flights)


## ----wrangling-demo-code-v2-dup1, eval=FALSE----------------------------------
# named_dests |>
#   top_n(n = 10, wt = num_flights) |>
#   arrange(desc(num_flights))


















## ----wrangling-conditional-text-v2, echo=FALSE, results="asis"----------------
if(!is_latex_output()) 
  cat("In the online [Appendix C](https://moderndive.com/v2/appendixc.html), we provide a page of data wrangling 'tips and tricks' consisting of the most common data wrangling questions we've encountered in student projects (shout out to [Dr. Jenny Smetzer](https://www.scsparkscience.org/fellow/jennifer-smetzer/) for her work setting this up!):

* Dealing with missing values
* Reordering bars in a barplot
* Showing money on an axis
* Changing values inside cells
* Converting a numerical variable to a categorical one
* Computing proportions
* Dealing with %, commas, and dollar signs

However, to provide a tips and tricks page covering all possible data wrangling questions would be too long to be useful!")

