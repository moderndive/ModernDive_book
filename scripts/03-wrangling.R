## ----message=FALSE------------------------------------------------------------
library(dplyr)
library(ggplot2)
library(nycflights23)








## ----eval=FALSE---------------------------------------------------------------
# envoy_flights <- flights |>
#   filter(carrier == "AS")




## ----eval=FALSE---------------------------------------------------------------
# phoenix_flights <- flights |>
#   filter(dest == "PHX")
# View(phoenix_flights)


## ----eval=FALSE---------------------------------------------------------------
# btv_sea_flights_fall <- flights |>
#   filter(origin == "JFK" & (dest == "BTV" | dest == "SEA") & month >= 10)
# View(btv_sea_flights_fall)


## ----eval=FALSE---------------------------------------------------------------
# btv_sea_flights_fall <- flights |>
#   filter(origin == "JFK", (dest == "BTV" | dest == "SEA"), month >= 10)
# View(btv_sea_flights_fall)


## ----eval=FALSE---------------------------------------------------------------
# not_BTV_SEA <- flights |>
#   filter(!(dest == "BTV" | dest == "SEA"))
# View(not_BTV_SEA)


## ----eval=FALSE---------------------------------------------------------------
# flights |> filter(!dest == "BTV" | dest == "SEA")


## ----eval=FALSE---------------------------------------------------------------
# many_airports <- flights |>
#   filter(dest == "SEA" | dest == "SFO" | dest == "PHX" |
#          dest == "BTV" | dest == "BDL")


## ----eval=FALSE---------------------------------------------------------------
# many_airports <- flights |>
#   filter(dest %in% c("SEA", "SFO", "PHX", "BTV", "BDL"))
# View(many_airports)






## ----echo=FALSE, results="asis"-----------------------------------------------
if(!is_latex_output()) 
  cat("See [Appendix A online](https://moderndive.com/v2/appendixa) for a glossary of such summary statistics.")






## -----------------------------------------------------------------------------
summary_windspeed <- weather |> 
  summarize(mean = mean(wind_speed), std_dev = sd(wind_speed))
summary_windspeed


## -----------------------------------------------------------------------------
summary_windspeed <- weather |> 
  summarize(mean = mean(wind_speed, na.rm = TRUE), 
            std_dev = sd(wind_speed, na.rm = TRUE))
summary_windspeed




## ----eval=FALSE---------------------------------------------------------------
# summary_windspeed <- weather |>
#   summarize(mean = mean(wind_speed, na.rm = TRUE)) |>
#   summarize(std_dev = sd(wind_speed, na.rm = TRUE))






## -----------------------------------------------------------------------------
summary_temp <- weather |> 
  summarize(mean = mean(wind_speed, na.rm = TRUE), 
            std_dev = sd(wind_speed, na.rm = TRUE))
summary_temp


## -----------------------------------------------------------------------------
summary_monthly_windspeed <- weather |> 
  group_by(month) |> 
  summarize(mean = mean(wind_speed, na.rm = TRUE), 
            std_dev = sd(wind_speed, na.rm = TRUE))
summary_monthly_windspeed


## -----------------------------------------------------------------------------
diamonds


## -----------------------------------------------------------------------------
diamonds |> 
  group_by(cut)




## -----------------------------------------------------------------------------
diamonds |> 
  group_by(cut) |> 
  summarize(avg_price = mean(price))


## -----------------------------------------------------------------------------
diamonds |> 
  group_by(cut) |> 
  ungroup()


## -----------------------------------------------------------------------------
by_origin <- flights |> 
  group_by(origin) |> 
  summarize(count = n())
by_origin


## -----------------------------------------------------------------------------
by_origin_monthly <- flights |> 
  group_by(origin, month) |> 
  summarize(count = n())


## -----------------------------------------------------------------------------
by_origin_monthly


## -----------------------------------------------------------------------------
by_origin_monthly_incorrect <- flights |> 
  group_by(origin) |> 
  group_by(month) |> 
  summarize(count = n())
by_origin_monthly_incorrect








## ----eval=TRUE----------------------------------------------------------------
weather <- weather |> 
  mutate(temp_in_C = (temp - 32) / 1.8)


## -----------------------------------------------------------------------------
summary_monthly_temp <- weather |> 
  group_by(month) |> 
  summarize(mean_temp_in_F = mean(temp, na.rm = TRUE), 
            mean_temp_in_C = mean(temp_in_C, na.rm = TRUE))
summary_monthly_temp


## -----------------------------------------------------------------------------
flights <- flights |> 
  mutate(gain = dep_delay - arr_delay)






## -----------------------------------------------------------------------------
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


## -----------------------------------------------------------------------------
flights <- flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    hours = air_time / 60,
    gain_per_hour = gain / hours
  )






## -----------------------------------------------------------------------------
freq_dest <- flights |> 
  group_by(dest) |> 
  summarize(num_flights = n())
freq_dest


## -----------------------------------------------------------------------------
freq_dest |> 
  arrange(num_flights)


## -----------------------------------------------------------------------------
freq_dest |> 
  arrange(desc(num_flights))


## ----eval=FALSE---------------------------------------------------------------
# View(airlines)




## ----eval=FALSE---------------------------------------------------------------
# flights_joined <- flights |>
#   inner_join(airlines, by = "carrier")
# View(flights)
# View(flights_joined)




## ----eval=FALSE---------------------------------------------------------------
# View(airports)


## ----eval=FALSE---------------------------------------------------------------
# flights_with_airport_names <- flights |>
#   inner_join(airports, by = c("dest" = "faa"))
# View(flights_with_airport_names)


## -----------------------------------------------------------------------------
named_dests <- flights |>
  group_by(dest) |>
  summarize(num_flights = n()) |>
  arrange(desc(num_flights)) |>
  inner_join(airports, by = c("dest" = "faa")) |>
  rename(airport_name = name)
named_dests


## ----eval=FALSE---------------------------------------------------------------
# flights_weather_joined <- flights |>
#   inner_join(weather, by = c("year", "month", "day", "hour", "origin"))
# View(flights_weather_joined)






## ----eval=FALSE---------------------------------------------------------------
# joined_flights <- flights |>
#   inner_join(airlines, by = "carrier")
# View(joined_flights)










## ----eval=FALSE---------------------------------------------------------------
# glimpse(flights)


## ----eval=FALSE---------------------------------------------------------------
# flights |>
#   select(carrier, flight)


## ----eval=FALSE---------------------------------------------------------------
# flights_no_year <- flights |> select(-year)


## ----eval=FALSE---------------------------------------------------------------
# flight_arr_times <- flights |> select(month:day, arr_time:sched_arr_time)
# flight_arr_times


## ----eval=FALSE---------------------------------------------------------------
# flights |> select(starts_with("a"))
# flights |> select(ends_with("delay"))
# flights |> select(contains("time"))


## ----eval=FALSE---------------------------------------------------------------
# flights_reorder <- flights |>
#   select(year, month, day, hour, minute, time_hour, everything())
# glimpse(flights_reorder)


## ----eval=FALSE---------------------------------------------------------------
# flights_relocate <- flights |>
#   relocate(hour, minute, time_hour, .after = day)
# glimpse(flights_relocate)


## ----eval=FALSE---------------------------------------------------------------
# flights_time_new <- flights |>
#   select(dep_time, arr_time) |>
#   rename(departure_time = dep_time, arrival_time = arr_time)
# glimpse(flights_time_new)


## ----eval=FALSE---------------------------------------------------------------
# named_dests |> top_n(n = 10, wt = num_flights)


## ----eval=FALSE---------------------------------------------------------------
# named_dests |>
#   top_n(n = 10, wt = num_flights) |>
#   arrange(desc(num_flights))


















## ----echo=FALSE, results="asis"-----------------------------------------------
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

