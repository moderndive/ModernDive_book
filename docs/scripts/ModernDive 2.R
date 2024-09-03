## ----include=FALSE------------------------------------------------------------
# Install CRAN packages needed
needed_CRAN_pkgs <- c(
  # Packages used by book reader
  "dygraphs", "fivethirtyeight", "gapminder", "ggplot2movies", "infer", "ISLR2", 
  "janitor", "knitr", "moderndive", 
  "nycflights23", "scales", "tidyverse", "broom", "bookdown",
  
  # Packages only used internally for bookdown book building
  "devtools", "ggrepel", "here", "kableExtra", "mvtnorm", "patchwork", 
  "remotes", "rmarkdown", "sessioninfo", "viridis", "webshot"
)
new_pkgs <- needed_CRAN_pkgs[!(needed_CRAN_pkgs %in% installed.packages())]
if (length(new_pkgs)) {
  install.packages(new_pkgs, repos = "http://cran.rstudio.com")
}

# Used in 95-appendixE.Rmd
needed_pkgs <- unique(c(
  needed_CRAN_pkgs, "bookdown"
))

# Automatically create a bib database for R packages
write_bib(
  c(
    .packages(), 
    "bookdown", "broom", "dplyr", "dygraphs", "fivethirtyeight", "ggplot2", 
    "ggplot2movies", "infer", "janitor", "kableExtra", "knitr", "moderndive", 
#    "nycflights13", 
    "nycflights23",
    "readr", "rmarkdown", "skimr", "tibble", "tidyr", "tidyverse", "webshot"
  ),
  here::here("bib", "packages.bib")
)

# Check that phantomjs is installed to create screenshots of apps
if (is.null(webshot:::find_phantom())) {
  webshot::install_phantomjs()
}

# Add all simulation results here
if (!dir.exists("rds")) {
  dir.create("rds")
}

# Create empty docs folder which will ultimately contain output
if (!dir.exists("docs")) {
  dir.create("docs")
}

# Make sure all images copy to docs folder
if (!dir.exists(here::here("docs", "images"))) {
  dir.create(here::here("docs", "images"))
}
file.copy(from = "images", to = "docs", recursive = TRUE)

# These steps are only needed for generating the moderndive.com page
# with relevant links. Not needed for PDF generation.
if (is_html_output()) {
  # Add all purl()'ed chapter R scripts here
  if (dir.exists(here::here("docs", "scripts"))) {
    unlink(here::here("docs", "scripts"), recursive = TRUE)
  }
  if (!dir.exists(here::here("docs", "scripts"))) {
    dir.create(here::here("docs", "scripts"))
  }
}




















## ----fig.align="center", echo=FALSE, out.width="70%"--------------------------
include_graphics("images/ModernDive_heart.png")


## ----echo=FALSE, results="asis"-----------------------------------------------
if (is_latex_output()) {
  cat("\\begin{flushright}
      \\textit{Kelly S.\ McConville, Bucknell University}
      \\end{flushright}")
} else {
  cat("<br>*Kelly S. McConville, Bucknell University*</br>")
}










## ----eval=FALSE---------------------------------------------------------------
## remotes::install_version(package = "moderndive", version = "0.6.1")


## ----book-package-versions, echo=FALSE----------------------------------------
# This will be a build behind because it needs to load all the packages
# throughout the book in Chapter 11. This was the reason
# why this used to be in the Appendices
readr::read_rds("rds/package_versions.rds") |> 
  kbl(
    booktabs = TRUE, 
    linesep = "",
    longtable = TRUE
  ) |> 
  kable_styling(font_size = ifelse(is_latex_output(), 9, 16))




















## ----eval=FALSE---------------------------------------------------------------
## library(ggplot2)






## ----message=FALSE------------------------------------------------------------
library(nycflights23)
library(dplyr)
library(knitr)




## ----load_flights-------------------------------------------------------------
flights






## -----------------------------------------------------------------------------
glimpse(flights)






## ----eval=FALSE---------------------------------------------------------------
## airlines
## kable(airlines)


## ----eval=FALSE---------------------------------------------------------------
## airlines$name


## -----------------------------------------------------------------------------
glimpse(airports)






## ----eval=FALSE---------------------------------------------------------------
## ?flights
















## ----message=FALSE------------------------------------------------------------
library(nycflights23)
library(ggplot2)
library(moderndive)
library(tibble)


















## ----echo=FALSE---------------------------------------------------------------
envoy_flights <- flights |> 
  filter(carrier == "MQ")


## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = envoy_flights, mapping = aes(x = dep_delay, y = arr_delay)) +
##   geom_point()




## ----nolayers, fig.cap="A plot with no layers.", fig.height=ifelse(knitr::is_latex_output(), 2, 7)----
ggplot(data = envoy_flights, mapping = aes(x = dep_delay, y = arr_delay))






## ----alpha, fig.cap="Arrival vs. departure delays scatterplot with alpha = 0.2.", fig.height=ifelse(knitr::is_latex_output(), 3.8, 7)----
ggplot(data = envoy_flights, mapping = aes(x = dep_delay, y = arr_delay)) + 
  geom_point(alpha = 0.2)




## ----jitter, fig.cap="Arrival versus departure delays jittered scatterplot.", fig.height=ifelse(knitr::is_latex_output(), 4.7, 7)----
ggplot(data = envoy_flights, mapping = aes(x = dep_delay, y = arr_delay)) + 
  geom_jitter(width = 30, height = 30)










## ----early-january, echo=FALSE------------------------------------------------
# Need to save `early_january_data` to {moderndive} for 2023 data
early_january_2023_weather <- weather |> 
  filter(origin == "EWR" & month == 1 & day <= 15)


## ----hourlytemp, fig.cap="Hourly wind speed in Newark for January 1-15, 2023."----
ggplot(data = early_january_2023_weather, 
       mapping = aes(x = time_hour, y = wind_speed)) +
  geom_line()






## ----windspeed-on-line, echo=FALSE, fig.height=ifelse(knitr::is_latex_output(), 0.8, 7), fig.cap="Plot of hourly wind speed recordings from NYC in 2023."----
ggplot(data = weather, mapping = aes(x = wind_speed, y = factor("A"))) +
  geom_point() +
  theme(
    axis.ticks.y = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y = element_blank()
  )




## ----weather-histogram, warning=TRUE, fig.cap="Histogram of hourly wind speeds at three NYC airports.", fig.height=ifelse(knitr::is_latex_output(), 2.3, 7)----
ggplot(data = weather, mapping = aes(x = wind_speed)) +
  geom_histogram()


## ----weather-histogram-2, message=FALSE, fig.cap="Histogram of hourly wind speeds at three NYC airports with white borders.", fig.height=ifelse(knitr::is_latex_output(), 3, 7)----
ggplot(data = weather, mapping = aes(x = wind_speed)) +
  geom_histogram(color = "white")


## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = weather, mapping = aes(x = wind_speed)) +
##   geom_histogram(color = "white", fill = "steelblue")


## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = weather, mapping = aes(x = wind_speed)) +
##   geom_histogram(bins = 20, color = "white")


## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = weather, mapping = aes(x = wind_speed)) +
##   geom_histogram(binwidth = 5, color = "white")








## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = weather, mapping = aes(x = wind_speed)) +
##   geom_histogram(binwidth = 5, color = "white") +
##   facet_wrap(~ month)




## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = weather, mapping = aes(x = wind_speed)) +
##   geom_histogram(binwidth = 5, color = "white") +
##   facet_wrap(~ month, nrow = 4)


















## ----badbox, fig.cap="Invalid boxplot specification.", fig.height=ifelse(knitr::is_latex_output(), 1.9, 7)----
ggplot(data = weather, mapping = aes(x = month, y = wind_speed)) +
  geom_boxplot()


## ----monthtempbox, fig.cap="Side-by-side boxplot of wind speed split by month.", fig.height=ifelse(knitr::is_latex_output(), 4, 7)----
ggplot(data = weather, mapping = aes(x = factor(month), y = wind_speed)) +
  geom_boxplot()






## -----------------------------------------------------------------------------
fruits <- tibble(fruit = c("apple", "apple", "orange", "apple", "orange"))
fruits_counted <- tibble(
  fruit = c("apple", "orange"),
  number = c(3, 2))






## ----geombar, fig.cap="Barplot when counts are not pre-counted.", fig.height=ifelse(knitr::is_latex_output(), 1.8, 7)----
ggplot(data = fruits, mapping = aes(x = fruit)) +
  geom_bar()


## ----geomcol, fig.cap="Barplot when counts are pre-counted.", fig.height=ifelse(knitr::is_latex_output(), 1.8, 7)----
ggplot(data = fruits_counted, mapping = aes(x = fruit, y = number)) +
  geom_col()


## ----flightsbar, fig.cap="(ref:geombar)", fig.height=ifelse(knitr::is_latex_output(), 1.4, 7)----
ggplot(data = flights, mapping = aes(x = carrier)) +
  geom_bar()














## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier)) +
##   geom_bar()


## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier, fill = origin)) +
##   geom_bar()




## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier, color = origin)) +
##   geom_bar()




## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier), fill = origin) +
##   geom_bar()


## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier, fill = origin)) +
##   geom_bar(position = "dodge")




## ----eval=FALSE---------------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier)) +
##   geom_bar() +
##   facet_wrap(~ origin, ncol = 1)










## ----eval=FALSE---------------------------------------------------------------
## # Segment 1:
## ggplot(data = flights, mapping = aes(x = carrier)) +
##   geom_bar()
## 
## # Segment 2:
## ggplot(flights, aes(x = carrier)) +
##   geom_bar()










## ----eval=FALSE---------------------------------------------------------------
## library(dplyr)
## 
## envoy_flights <- flights |>
##   filter(carrier == "MQ")
## 
## ggplot(data = envoy_flights, mapping = aes(x = dep_delay, y = arr_delay)) +
##   geom_point()


## ----eval=FALSE---------------------------------------------------------------
## early_january_2023_weather <- weather |>
##   filter(origin == "EWR" & month == 1 & day <= 15)
## 
## ggplot(data = early_january_2023_weather, mapping = aes(x = time_hour, y = temp)) +
##   geom_line()




## ----message=FALSE------------------------------------------------------------
library(dplyr)
library(ggplot2)
library(nycflights23)








## ----eval=FALSE---------------------------------------------------------------
## envoy_flights <- flights |>
##   filter(carrier == "AS")




## ----eval=FALSE---------------------------------------------------------------
## phoenix_flights <- flights |>
##   filter(dest == "PHX")
## View(phoenix_flights)


## ----eval=FALSE---------------------------------------------------------------
## btv_sea_flights_fall <- flights |>
##   filter(origin == "JFK" & (dest == "BTV" | dest == "SEA") & month >= 10)
## View(btv_sea_flights_fall)


## ----eval=FALSE---------------------------------------------------------------
## btv_sea_flights_fall <- flights |>
##   filter(origin == "JFK", (dest == "BTV" | dest == "SEA"), month >= 10)
## View(btv_sea_flights_fall)


## ----eval=FALSE---------------------------------------------------------------
## not_BTV_SEA <- flights |>
##   filter(!(dest == "BTV" | dest == "SEA"))
## View(not_BTV_SEA)


## ----eval=FALSE---------------------------------------------------------------
## flights |> filter(!dest == "BTV" | dest == "SEA")


## ----eval=FALSE---------------------------------------------------------------
## many_airports <- flights |>
##   filter(dest == "SEA" | dest == "SFO" | dest == "PHX" |
##          dest == "BTV" | dest == "BDL")


## ----eval=FALSE---------------------------------------------------------------
## many_airports <- flights |>
##   filter(dest %in% c("SEA", "SFO", "PHX", "BTV", "BDL"))
## View(many_airports)






## ----echo=FALSE, results="asis"-----------------------------------------------
if(!is_latex_output()) 
  cat("See [Appendix A online](https://moderndive.com/A-appendixA.html) for a glossary of such summary statistics.")






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
## summary_windspeed <- weather |>
##   summarize(mean = mean(wind_speed, na.rm = TRUE)) |>
##   summarize(std_dev = sd(wind_speed, na.rm = TRUE))






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


## ----gain-hist, fig.cap="Histogram of gain variable.", message=FALSE, fig.height=ifelse(knitr::is_latex_output(), 3, 7)----
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
## View(airlines)




## ----eval=FALSE---------------------------------------------------------------
## flights_joined <- flights |>
##   inner_join(airlines, by = "carrier")
## View(flights)
## View(flights_joined)




## ----eval=FALSE---------------------------------------------------------------
## View(airports)


## ----eval=FALSE---------------------------------------------------------------
## flights_with_airport_names <- flights |>
##   inner_join(airports, by = c("dest" = "faa"))
## View(flights_with_airport_names)


## -----------------------------------------------------------------------------
named_dests <- flights |>
  group_by(dest) |>
  summarize(num_flights = n()) |>
  arrange(desc(num_flights)) |>
  inner_join(airports, by = c("dest" = "faa")) |>
  rename(airport_name = name)
named_dests


## ----eval=FALSE---------------------------------------------------------------
## flights_weather_joined <- flights |>
##   inner_join(weather, by = c("year", "month", "day", "hour", "origin"))
## View(flights_weather_joined)






## ----eval=FALSE---------------------------------------------------------------
## joined_flights <- flights |>
##   inner_join(airlines, by = "carrier")
## View(joined_flights)










## ----eval=FALSE---------------------------------------------------------------
## glimpse(flights)


## ----eval=FALSE---------------------------------------------------------------
## flights |>
##   select(carrier, flight)


## ----eval=FALSE---------------------------------------------------------------
## flights_no_year <- flights |> select(-year)


## ----eval=FALSE---------------------------------------------------------------
## flight_arr_times <- flights |> select(month:day, arr_time:sched_arr_time)
## flight_arr_times


## ----eval=FALSE---------------------------------------------------------------
## flights |> select(starts_with("a"))
## flights |> select(ends_with("delay"))
## flights |> select(contains("time"))


## ----eval=FALSE---------------------------------------------------------------
## flights_reorder <- flights |>
##   select(year, month, day, hour, minute, time_hour, everything())
## glimpse(flights_reorder)


## ----eval=FALSE---------------------------------------------------------------
## flights_relocate <- flights |>
##   relocate(hour, minute, time_hour, .after = day)
## glimpse(flights_relocate)


## ----eval=FALSE---------------------------------------------------------------
## flights_time_new <- flights |>
##   select(dep_time, arr_time) |>
##   rename(departure_time = dep_time, arrival_time = arr_time)
## glimpse(flights_time_new)


## ----eval=FALSE---------------------------------------------------------------
## named_dests |> top_n(n = 10, wt = num_flights)


## ----eval=FALSE---------------------------------------------------------------
## named_dests |>
##   top_n(n = 10, wt = num_flights) |>
##   arrange(desc(num_flights))


















## ----echo=FALSE, results="asis"-----------------------------------------------
if(!is_latex_output()) 
  cat("In the online [Appendix C](https://moderndive.com/C-appendixC.html), we provide a page of data wrangling 'tips and tricks' consisting of the most common data wrangling questions we've encountered in student projects (shout out to [Dr. Jenny Smetzer](https://www.scsparkscience.org/fellow/jennifer-smetzer/) for her work setting this up!):

* Dealing with missing values
* Reordering bars in a barplot
* Showing money on an axis
* Changing values inside cells
* Converting a numerical variable to a categorical one
* Computing proportions
* Dealing with %, commas, and dollar signs

However, to provide a tips and tricks page covering all possible data wrangling questions would be too long to be useful!")






## ----message=FALSE------------------------------------------------------------
library(dplyr)
library(ggplot2)
library(readr)
library(tidyr)
library(nycflights23)
library(fivethirtyeight)




## ----message=FALSE, eval=FALSE------------------------------------------------
## library(readr)
## dem_score <- read_csv("https://moderndive.com/data/dem_score.csv")
## dem_score







## -----------------------------------------------------------------------------
drinks_smaller <- drinks |> 
  filter(country %in% c("USA", "China", "Italy", "Saudi Arabia")) |> 
  select(-total_litres_of_pure_alcohol) |> 
  rename(beer = beer_servings, spirit = spirit_servings, wine = wine_servings)
drinks_smaller




















## -----------------------------------------------------------------------------
drinks_smaller


## -----------------------------------------------------------------------------
drinks_smaller_tidy <- drinks_smaller |> 
  pivot_longer(names_to = "type", 
               values_to = "servings", 
               cols = -country)
drinks_smaller_tidy


## ----eval=FALSE---------------------------------------------------------------
## drinks_smaller |>
##   pivot_longer(names_to = "type",
##                values_to = "servings",
##                cols = c(beer, spirit, wine))


## ----eval=FALSE---------------------------------------------------------------
## drinks_smaller |>
##   pivot_longer(names_to = "type",
##                values_to = "servings",
##                cols = beer:wine)


## ----eval=FALSE---------------------------------------------------------------
## ggplot(drinks_smaller_tidy, aes(x = country, y = servings, fill = type)) +
##   geom_col(position = "dodge")








## -----------------------------------------------------------------------------
airline_safety_smaller <- airline_safety |> 
  select(airline, starts_with("fatalities"))
airline_safety_smaller




## -----------------------------------------------------------------------------
guat_dem <- dem_score |> 
  filter(country == "Guatemala")
guat_dem


## -----------------------------------------------------------------------------
guat_dem_tidy <- guat_dem |> 
  pivot_longer(names_to = "year", 
               values_to = "democracy_score", 
               cols = -country,
               names_transform = list(year = as.integer)) 
guat_dem_tidy


## ----guat-dem-tidy, fig.cap="Democracy scores in Guatemala 1952-1992.", fig.height=ifelse(knitr::is_latex_output(), 3, 7)----
ggplot(guat_dem_tidy, aes(x = year, y = democracy_score)) +
  geom_line() +
  labs(x = "Year", y = "Democracy Score")


























## ----message=FALSE------------------------------------------------------------
library(tidyverse)
library(moderndive)






## -----------------------------------------------------------------------------
UN_data_ch5 <- un_member_states_2024 |>
  select(iso, 
         life_exp = life_expectancy_2022, 
         fert_rate = fertility_rate_2022, 
         obes_rate = obesity_rate_2016)|>
  na.omit()


## ----include=FALSE------------------------------------------------------------
n_demo_ch5 <- nrow(UN_data_ch5)


## -----------------------------------------------------------------------------
glimpse(UN_data_ch5)


## ----echo=FALSE---------------------------------------------------------------
sample_size <- 5


## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch5 |>
##   slice_sample(n = 5)




## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch5 |>
##   summarize(mean_life_exp = mean(life_exp),
##             mean_fert_rate = mean(fert_rate),
##             median_life_exp = median(life_exp),
##             median_fert_rate = median(fert_rate))


## ----echo=FALSE---------------------------------------------------------------
UN_data_ch5 |>
  summarize(mean_life_exp = mean(life_exp), 
            mean_fert_rate = mean(fert_rate),
            median_life_exp = median(life_exp), 
            median_fert_rate = median(fert_rate)) |> 
  kbl() |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 10, 16),
    latex_options = c("HOLD_position")
  )


## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch5 |>
##   select(fert_rate, life_exp) |>
##   tidy_summary()


## ----echo=FALSE---------------------------------------------------------------
UN_data_ch5 |> 
  select(fert_rate, life_exp) |> 
  tidy_summary() |> 
  kbl() |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 10, 16),
    latex_options = c("HOLD_position")
  )


## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch5 |>
##   tidy_summary(columns = c(fert_rate, life_exp))


## ----echo=FALSE---------------------------------------------------------------
UN_data_ch5 |> 
  tidy_summary(columns = c(fert_rate, life_exp)) |> 
  kbl() |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 10, 16),
    latex_options = c("HOLD_position")
  )


## ----echo=FALSE---------------------------------------------------------------
summary_df <- UN_data_ch5 |> 
  select(fert_rate, life_exp) |> 
  tidy_summary() |> 
  filter(type == "numeric")
fert_summary_df <- summary_df  |> 
  filter(column == "fert_rate")
life_summary_df <- summary_df  |>
  filter(column == "life_exp")




## -----------------------------------------------------------------------------
UN_data_ch5 |> 
  get_correlation(formula = fert_rate ~ life_exp)


## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch5 |>
##   summarize(correlation = cor(fert_rate, life_exp))




## ----numxplot1, fig.cap="Scatterplot of relationship of life expectancy and fertility rate", fig.height=ifelse(knitr::is_latex_output(), 4.5, 7)----
ggplot(UN_data_ch5, 
       aes(x = life_exp, y = fert_rate)) +
  geom_point(alpha = 0.1) +
  labs(x = "Life Expectancy", y = "Fertility Rate")


## ----numxplot3, fig.cap="Scatterplot of life expectancy and fertility rate with regression line.", message=FALSE, fig.height=ifelse(knitr::is_latex_output(), 4, 7)----
ggplot(UN_data_ch5, aes(x = life_exp, y = fert_rate)) +
  geom_point(alpha = 0.1) +
  labs(x = "Life Expectancy", 
    y = "Fertility Rate",
    title = "Relationship of life expectancy and fertility rate") +
  geom_smooth(method = "lm", se = FALSE)






## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## demographics_model <- lm(fert_rate ~ life_exp,
##                          data = UN_data_ch5)
## # Get regression coefficients
## coef(demographics_model)



## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## demographics_model <- lm(fert_rate ~ life_exp,
##                          data = UN_data_ch5)
## # Get regression coefficients:
## coef(demographics_model)










## ----eval=FALSE---------------------------------------------------------------
## regression_points <- get_regression_points(demographics_model)
## regression_points










## ----message=FALSE------------------------------------------------------------
gapminder2022 <- un_member_states_2024 |>
  select(country, life_exp = life_expectancy_2022, continent, gdp_per_capita) |> 
  na.omit()




## -----------------------------------------------------------------------------
glimpse(gapminder2022)


## ----eval=FALSE---------------------------------------------------------------
## gapminder2022 |> sample_n(size = 3)



## ----eval=FALSE---------------------------------------------------------------
## gapminder2022 |> select(life_exp, continent) |> tidy_summary()


## ----echo=FALSE---------------------------------------------------------------
gapminder2022 |>
  select(life_exp, continent) |>
  tidy_summary() |> 
  kbl(
    caption = "Summary of life expectancy and continent variables",
    booktabs = TRUE,
    linesep = ""
  ) |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 9, 16),
    latex_options = c("HOLD_position")
  )


## ----include=FALSE------------------------------------------------------------
# For discussion in bullet points below
gapminder2022 |> count(continent)




## ----lifeexp2022hist, echo=TRUE, fig.cap="Histogram of life expectancy in 2022.", fig.height=ifelse(knitr::is_latex_output(), 3.4, 7)----
ggplot(gapminder2022, aes(x = life_exp)) +
  geom_histogram(binwidth = 5, color = "white") +
  labs(x = "Life expectancy", 
       y = "Number of countries",
       title = "Histogram of distribution of worldwide life expectancies")


## ----eval=FALSE---------------------------------------------------------------
## ggplot(gapminder2022, aes(x = life_exp)) +
##   geom_histogram(binwidth = 5, color = "white") +
##   labs(x = "Life expectancy",
##        y = "Number of countries",
##        title = "Histogram of distribution of worldwide life expectancies") +
##   facet_wrap(~ continent, nrow = 2)




## ----catxplot1, fig.cap="Life expectancy in 2022 by continent (boxplot).", fig.height=ifelse(knitr::is_latex_output(), 3, 7)----
ggplot(gapminder2022, aes(x = continent, y = life_exp)) +
  geom_boxplot() +
  labs(x = "Continent", 
       y = "Life expectancy",
       title = "Life expectancy by continent")


## ----eval=TRUE, results='hide'------------------------------------------------
life_exp_by_continent <- gapminder2022 |>
  group_by(continent) |>
  summarize(median = median(life_exp), mean = mean(life_exp))
life_exp_by_continent











## -----------------------------------------------------------------------------
life_exp_model <- lm(life_exp ~ continent, data = gapminder2022)
coef(life_exp_model)






## ----eval=FALSE---------------------------------------------------------------
## regression_points <- get_regression_points(life_exp_model, ID = "country")
## regression_points













## -----------------------------------------------------------------------------
ggplot(data = un_member_states_2024, 
       aes(x = hdi_2022, y = life_expectancy_2022)) +
  geom_point() +
  labs(x = "Human Development Index (HDI)", y = "Life Expectancy")


## -----------------------------------------------------------------------------
ggplot(data = un_member_states_2024, 
       aes(x = hdi_2022, y = fertility_rate_2022)) +
  geom_point() +
  labs(x = "Human Development Index (HDI)", y = "Fertility Rate")


## -----------------------------------------------------------------------------
un_member_states_2024 |> 
  get_correlation(life_expectancy_2022 ~ hdi_2022, na.rm = TRUE)


## -----------------------------------------------------------------------------
un_member_states_2024 |> 
  get_correlation(fertility_rate_2022 ~ hdi_2022, na.rm = TRUE)




## ----include=FALSE------------------------------------------------------------
four_countries <- c("BIH", "TCD", "IND", "SLB")
country_lookup_table <- UN_data_ch5 |>
  filter(iso %in% four_countries) |>
  select(iso, life_exp, fert_rate)
bosnia <- country_lookup_table |> 
  filter(iso == "BIH") |> 
  mutate(residual = resid_bosnia,
         fert_rate_hat = y_bosnia_hat)
chad <- country_lookup_table |>
  filter(iso == "TCD") |> 
  mutate(residual = resid_chad,
         fert_rate_hat = y_chad_hat)
india <- country_lookup_table |>
  filter(iso == "IND") |> 
  mutate(residual = resid_india,
         fert_rate_hat = y_india_hat)
solomon <- country_lookup_table |>
  filter(iso == "SLB") |> 
  mutate(residual = resid_sol,
         fert_rate_hat = y_sol_hat)


## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model and regression points
## demographics_model <- lm(fert_rate ~ life_exp, data = UN_data_ch5)
## regression_points <- get_regression_points(demographics_model)
## 
## # Compute sum of squared residuals
## regression_points |>
##   mutate(squared_residuals = residual^2) |>
##   summarize(sum_of_squared_residuals = sum(squared_residuals))


## ----echo=FALSE---------------------------------------------------------------
# Fit regression model:
demographics_model <- lm(fert_rate ~ life_exp, data = UN_data_ch5)

# Get regression points:
regression_points <- get_regression_points(demographics_model)

# Compute sum of squared residuals
SSR <- regression_points |>
  mutate(squared_residuals = residual^2) |>
  summarize(sum_of_squared_residuals = sum(squared_residuals)) |> 
  pull()
SSR








## ----eval=FALSE---------------------------------------------------------------
## library(broom)
## library(janitor)
## demographics_model |>
##   augment() |>
##   mutate_if(is.numeric, round, digits = 3) |>
##   clean_names() |>
##   select(-c("std_resid", "hat", "sigma", "cooksd", "std_resid"))











## ----eval=FALSE---------------------------------------------------------------
## library(tidyverse)
## library(moderndive)
## library(ISLR2)


## ----echo=FALSE, message=FALSE, purl=TRUE-------------------------------------
library(tidyverse)
library(moderndive)
library(ISLR2)




## -----------------------------------------------------------------------------
UN_data_ch6 <- un_member_states_2024 |>
  select(country, 
         life_expectancy_2022, 
         fertility_rate_2022, 
         income_group_2024)|>
  na.omit()|>
  rename(life_exp = life_expectancy_2022, 
         fert_rate = fertility_rate_2022, 
         income = income_group_2024)|>
  mutate(income = factor(income, 
                         levels = c("Low income", "Lower middle income", 
                                    "Upper middle income", "High income")))


## -----------------------------------------------------------------------------
glimpse(UN_data_ch6)




## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch6 |> sample_n(size = 10)




## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch6 |>
##   select(life_exp, fert_rate, income) |>
##   tidy_summary()


## ----echo=FALSE---------------------------------------------------------------
UN_data_ch6 |> 
  select(life_exp, fert_rate, income) |> 
  tidy_summary() |> 
  kbl() |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 8, 16),
    latex_options = c("HOLD_position")
  ) 


## -----------------------------------------------------------------------------
UN_data_ch6 |> 
  get_correlation(formula = fert_rate ~ life_exp)


## ----eval=FALSE---------------------------------------------------------------
## ggplot(UN_data_ch6, aes(x = life_exp, y = fert_rate, color = income)) +
##   geom_point() +
##   labs(x = "Life Expectancy", y = "Fertility Rate", color = "Income group") +
##   geom_smooth(method = "lm", se = FALSE)




## ----eval=FALSE---------------------------------------------------------------
## one_factor_model <- lm(fert_rate ~ income, data = UN_data_ch6)
## coef(one_factor_model)




## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model and get the coefficients of the model
## model_int <- lm(fert_rate ~ life_exp * income, data = UN_data_ch6)
## coef(model_int)








## ----eval=FALSE---------------------------------------------------------------
## ggplot(UN_data_ch6, aes(x = life_exp, y = fert_rate, color = income)) +
##   geom_point() +
##   labs(x = "Life expectancy", y = "Fertility rate", color = "Income group") +
##   geom_parallel_slopes(se = FALSE)




## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## model_no_int <- lm(fert_rate ~ life_exp + income, data = UN_data_ch6)
## 
## # Get the coefficients of the model
## coef(model_no_int)
















## ----eval=FALSE---------------------------------------------------------------
## regression_points <- get_regression_points(model_int)
## regression_points








## ----message=FALSE------------------------------------------------------------
library(ISLR2)
credit_ch6 <- Credit |> as_tibble() |> 
  select(debt = Balance, credit_limit = Limit, 
         income = Income, credit_rating = Rating, age = Age)


## -----------------------------------------------------------------------------
glimpse(credit_ch6)




## ----eval=FALSE---------------------------------------------------------------
## credit_ch6 |> sample_n(size = 5)




## ----eval=FALSE---------------------------------------------------------------
## credit_ch6 |> select(debt, credit_limit, income) |> tidy_summary()


## ----echo=FALSE---------------------------------------------------------------
credit_ch6 |> 
  select(debt, credit_limit, income) |> 
  tidy_summary() |> 
    kbl(
    digits = 3,
    caption = "Summary of credit data",
    booktabs = TRUE,
    linesep = ""
  ) |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 8, 16),
    latex_options = c("HOLD_position")
  )


## ----eval=FALSE---------------------------------------------------------------
## ggplot(credit_ch6, aes(x = credit_limit, y = debt)) +
##   geom_point() +
##   labs(x = "Credit limit (in $)", y = "Credit card debt (in $)",
##        title = "Debt and credit limit") +
##   geom_smooth(method = "lm", se = FALSE)
## 
## ggplot(credit_ch6, aes(x = income, y = debt)) +
##   geom_point() +
##   labs(x = "Income (in $1000)", y = "Credit card debt (in $)",
##        title = "Debt and income") +
##   geom_smooth(method = "lm", se = FALSE)




## ----eval=FALSE---------------------------------------------------------------
## credit_ch6 |> get_correlation(debt ~ credit_limit)
## credit_ch6 |> get_correlation(debt ~ income)


## ----eval=FALSE---------------------------------------------------------------
## credit_ch6 |> select(debt, credit_limit, income) |> cor()




## -----------------------------------------------------------------------------
credit_ch6 |> get_correlation(debt ~ 1000 * income)












## ----eval=FALSE---------------------------------------------------------------
## debt_model <- lm(debt ~ credit_limit + income, data = credit_ch6)
## coef(debt_model)




## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model and get the coefficients of the model
## simple_model <- lm(debt ~ income, data = credit_ch6)
## coef(simple_model)








## ----eval=FALSE---------------------------------------------------------------
## get_regression_points(debt_model)














## ----message=FALSE------------------------------------------------------------
library(tidyverse)
library(moderndive)
library(infer)






## -----------------------------------------------------------------------------
bowl


## -----------------------------------------------------------------------------
bowl |> 
  mutate(is_red = (color == "red"))


## -----------------------------------------------------------------------------
bowl |> 
  mutate(is_red = (color == "red")) |> 
  summarize(num_red = sum(is_red))


## -----------------------------------------------------------------------------
bowl |> 
  mutate(is_red = (color == "red")) |> 
  summarize(prop_red = mean(is_red))


## -----------------------------------------------------------------------------
bowl |> 
  summarize(prop_red = mean(color == "red"))












## -----------------------------------------------------------------------------
tactile_prop_red


## ----eval=FALSE---------------------------------------------------------------
## ggplot(tactile_prop_red, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of red balls in each sample",
##        title = "Histogram of 33 proportions")







## ----echo=-1------------------------------------------------------------------
set.seed(76)
virtual_shovel <- bowl |> 
  rep_slice_sample(n = 50)
virtual_shovel


## ----echo=-c(1, 2)------------------------------------------------------------
# Neat way to remove from output particular code pieces!
prop_red_sample1 <- virtual_shovel |> 
  summarize(prop_red = mean(color == "red")) |> 
  pull(prop_red)
virtual_shovel |> 
 summarize(prop_red = mean(color == "red"))


## ----echo=-1------------------------------------------------------------------
set.seed(76)
virtual_samples <- bowl |> 
  rep_slice_sample(n = 50, reps = 33)
virtual_samples


## -----------------------------------------------------------------------------
virtual_prop_red <- virtual_samples |> 
  group_by(replicate) |> 
  summarize(prop_red = mean(color == "red")) 
virtual_prop_red


## ----echo=-1------------------------------------------------------------------
set.seed(76)
virtual_prop_red <- bowl |> 
  rep_slice_sample(n = 50, reps = 33) |>
  summarize(prop_red = mean(color == "red"))
virtual_prop_red


## ----eval=FALSE---------------------------------------------------------------
## ggplot(virtual_prop_red, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Sample proportion",
##        title = "Histogram of 33 sample proportions")









## ----echo=-1------------------------------------------------------------------
set.seed(76)
virtual_prop_red <- bowl |> 
  rep_slice_sample(n = 50, reps = 1000) |> 
  summarize(prop_red = mean(color == "red"))
virtual_prop_red


## ----eval=FALSE---------------------------------------------------------------
## ggplot(virtual_prop_red, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.04, boundary = 0.4, color = "white") +
##   labs(x = "Sample proportion", title = "Histogram of 1000 sample proportions")



## ----echo=FALSE, results="asis"-----------------------------------------------
if(!is_latex_output()) 
  cat('Please read the "Normal distribution" section of ([Appendix A online](https://moderndive.com/A-appendixA.html)) for a brief discussion of this distribution and its properties.')








## ----eval=FALSE---------------------------------------------------------------
## # Segment 1: sample size = 25 ------------------------------
## # 1.a) Compute sample proportions for 1000 samples, each sample of size 25
## virtual_prop_red_25 <- bowl |>
##   rep_slice_sample(n = 25, reps = 1000) |>
##   summarize(prop_red = mean(color == "red"))
## 
## # 1.b) Plot a histogram to represent the distribution of the sample proportions
## ggplot(virtual_prop_red_25, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of 25 balls that were red", title = "25")
## 
## 
## # Segment 2: sample size = 50 ------------------------------
## # 2.a) Compute sample proportions for 1000 samples, each sample of size 50
## virtual_prop_red_50 <- bowl |>
##   rep_slice_sample(n = 50, reps = 1000) |>
##   summarize(prop_red = mean(color == "red"))
## 
## # 2.b) Plot a histogram to represent the distribution of the sample proportions
## ggplot(virtual_prop_red_50, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of 50 balls that were red", title = "50")
## 
## 
## # Segment 3: sample size = 100 ------------------------------
## # 2.a) Compute sample proportions for 1000 samples, each sample of size 100
## virtual_prop_red_100 <- bowl |>
##   rep_slice_sample(n = 100, reps = 1000) |>
##   summarize(prop_red = mean(color == "red"))
## 
## # 3.b) Plot a histogram to represent the distribution of the sample proportions
## ggplot(virtual_prop_red_100, aes(x = prop_red)) +
##   geom_histogram(binwidth = 0.05, boundary = 0.4, color = "white") +
##   labs(x = "Proportion of 100 balls that were red", title = "100")














## -----------------------------------------------------------------------------
virtual_prop_red_25
virtual_prop_red_25 |> 
  summarize(E_Xbar_25 = mean(prop_red))


## ----eval=FALSE---------------------------------------------------------------
## virtual_prop_red_50 |>
##   summarize(E_Xbar_50 = mean(prop_red))
## virtual_prop_red_100 |>
##   summarize(E_Xbar_100 = mean(prop_red))


## ----echo=FALSE---------------------------------------------------------------
e_xbar_50 <- virtual_prop_red_50 |> 
  summarize(E_Xbar_50 = mean(prop_red))
e_xbar_100 <- virtual_prop_red_100 |> 
  summarize(E_Xbar_100 = mean(prop_red))
e_xbar_50_pull <- e_xbar_50 |> pull(E_Xbar_50)
e_xbar_100_pull <- e_xbar_100 |> pull(E_Xbar_100)
e_xbar_50
e_xbar_100






## -----------------------------------------------------------------------------
bowl |> 
  mutate(is_red = color == "red") |> 
  summarize(p = mean(is_red), st_dev = sd(is_red))


## -----------------------------------------------------------------------------
p <- 0.375
sqrt(p * (1 - p))


## -----------------------------------------------------------------------------
bowl |>
  rep_slice_sample(n = 100, replace = TRUE, reps = 10000) |>
  summarize(prop_red = mean(color == "red")) |>
  summarize(p = mean(prop_red), SE_Xbar = sd(prop_red))


## -----------------------------------------------------------------------------
p <- 0.375
sqrt(p*(1-p)/100)


## -----------------------------------------------------------------------------
virtual_prop_red_25 |> 
  summarize(SE_Xbar_50 = sd(prop_red))
virtual_prop_red_50 |> 
  summarize(SE_Xbar_100 = sd(prop_red))


## -----------------------------------------------------------------------------
sqrt(p * (1 - p) / 25)
sqrt(p * (1 - p) / 50)
















## ----echo=1-------------------------------------------------------------------
almonds_bowl
num_pop_almonds <- length(almonds_bowl$weight)


## -----------------------------------------------------------------------------
almonds_bowl |> 
  summarize(mean_weight = mean(weight), 
            sd_weight = sd(weight), 
            length = n())


## ----almonds-bowl-histogram, fig.cap="Distribution of weights for the entire bowl of almonds."----
ggplot(almonds_bowl, aes(x = weight)) +
  geom_histogram(binwidth = 0.1, color = "white")






## ----echo=2:4, eval=FALSE-----------------------------------------------------
## set.seed(2024)
## almonds_sample <- almonds_bowl |>
##   rep_slice_sample(n = 25, reps = 1)
## almonds_sample


## ----echo=FALSE---------------------------------------------------------------
num_almonds <- length(almonds_sample$weight)


## ----almonds-sample-histogram, fig.cap="Distribution of weight for a sample of 25 almonds."----
ggplot(almonds_sample, aes(x = weight)) +
  geom_histogram(binwidth = 0.1, color = "white")


## -----------------------------------------------------------------------------
almonds_sample |> summarize(sample_mean_weight = mean(weight))


## -----------------------------------------------------------------------------
virtual_samples_almonds <- almonds_bowl |> 
  rep_slice_sample(n = 25, reps = 1000)
virtual_samples_almonds


## -----------------------------------------------------------------------------
virtual_mean_weight <- virtual_samples_almonds |> 
  summarize(mean_weight = mean(weight))
virtual_mean_weight


## ----eval=FALSE---------------------------------------------------------------
## ggplot(virtual_mean_weight, aes(x = mean_weight)) +
##   geom_histogram(binwidth = 0.04, boundary = 3.5, color = "white") +
##   labs(x = "Sample mean", title = "Histogram of 1000 sample means")




## -----------------------------------------------------------------------------
almonds_sample


## -----------------------------------------------------------------------------
almonds_sample |>
  summarize(sample_mean_weight = mean(weight))


## ----eval=FALSE---------------------------------------------------------------
## # Segment 1: sample size = 25 ------------------------------
## # 1.a) Calculating the 1000 sample means, each from random samples of size 25
## virtual_mean_weight_25 <- almonds_bowl |>
##   rep_slice_sample(n = 25, reps = 1000)|>
##   summarize(mean_weight = mean(weight), n = n())
## 
## # 1.b) Plot distribution via a histogram
## ggplot(virtual_mean_weight_25, aes(x = mean_weight)) +
##   geom_histogram(binwidth = 0.02, boundary = 3.6, color = "white") +
##   labs(x = "Sample mean weights for random samples of 25 almonds", title = "25")
## 
## # Segment 2: sample size = 50 ------------------------------
## # 2.a) Calculating the 1000 sample means, each from random samples of size 50
## virtual_mean_weight_50 <- almonds_bowl |>
##   rep_slice_sample(n = 50, reps = 1000)|>
##   summarize(mean_weight = mean(weight), n = n())
## 
## # 2.b) Plot distribution via a histogram
## ggplot(virtual_mean_weight_50, aes(x = mean_weight)) +
##   geom_histogram(binwidth = 0.02, boundary = 3.6, color = "white") +
##   labs(x = "Sample mean weights for random samples of 50 almonds", title = "50")
## 
## # Segment 3: sample size = 100 ------------------------------
## # 3.a) Calculating the 1000 sample means, each from random samples of size 100
## virtual_mean_weight_100 <- almonds_bowl |>
##   rep_slice_sample(n = 100, reps = 1000)|>
##   summarize(mean_weight = mean(weight), n = n())
## 
## # 3.b) Plot distribution via a histogram
## ggplot(virtual_mean_weight_100, aes(x = mean_weight)) +
##   geom_histogram(binwidth = 0.02, boundary = 3.6, color = "white") +
##   labs(x = "Sample mean weights for random samples of 100 almonds", title = "100")




## -----------------------------------------------------------------------------
almonds_bowl |>
  summarize(mu = mean(weight), sigma = sd(weight))


## ----eval=FALSE---------------------------------------------------------------
## # n = 25
## virtual_mean_weight_25 |>
##   summarize(E_Xbar_25 = mean(mean_weight), sd = sd(mean_weight))
## 
## # n = 50
## virtual_mean_weight_50 |>
##   summarize(E_Xbar_50 = mean(mean_weight), sd = sd(mean_weight))
## 
## # n = 100
## virtual_mean_weight_100 |>
##   summarize(E_Xbar_100 = mean(mean_weight), sd = sd(mean_weight))




















## ----echo=-(1:3)--------------------------------------------------------------
set.seed(76)
n1 <- 50
n2 <- 60
virtual_prop_red <- bowl |> 
  rep_slice_sample(n = 50, reps = 1000) |> 
  summarize(prop_red = mean(color == "red"))
virtual_prop_almond <- almonds_bowl |>
  rep_slice_sample(n = 60, reps = 1000) |>
  summarize(prop_almond = mean(weight > 3.8))
prop_joined <- virtual_prop_red |>
  inner_join(virtual_prop_almond, by = "replicate") |>
  mutate(prop_diff = prop_red - prop_almond)


## -----------------------------------------------------------------------------
prop_joined


## ----eval=FALSE---------------------------------------------------------------
## ggplot(prop_joined, aes(x = prop_diff)) +
##   geom_histogram(binwidth = 0.04, boundary = 0, color = "white") +
##   labs(x = "Difference in sample proportions",
##        title = "Histogram of 1000 differences in sample proportions")









## ----echo=FALSE, results='asis'-----------------------------------------------
if (is_latex_output())
  cat("Check the online version of the book for a table that also includes the sampling distribution of each of these statistics using the Central Limit Theorem.")












## ----message=FALSE------------------------------------------------------------
library(tidyverse)
library(moderndive)
library(infer)




## ----echo=FALSE---------------------------------------------------------------
almonds_sample_100 <- moderndive::almonds_sample_100


## -----------------------------------------------------------------------------
almonds_sample_100




## -----------------------------------------------------------------------------
almonds_sample_100 |>
  summarize(sample_mean = mean(weight))


## ----echo=FALSE---------------------------------------------------------------
xbar <- mean(almonds_sample_100$weight)






## ----echo=FALSE---------------------------------------------------------------
num_almonds <- nrow(almonds_bowl)
mu <- mean(almonds_bowl$weight)
sigma <- pop_sd(almonds_bowl$weight)


## -----------------------------------------------------------------------------
almonds_bowl |> 
  summarize(population_mean = mean(weight), 
            population_sd = pop_sd(weight))


## -----------------------------------------------------------------------------
almonds_sample_100 |> 
  summarize(mean_weight = mean(weight), 
            sd_weight = sd(weight), 
            sample_size = n())






## ----echo=FALSE, results="asis"-----------------------------------------------
if(!is_latex_output()) 
  cat('Please review [Appendix A online](https://moderndive.com/A-appendixA.html) where we provide R code to work with different areas, probabilities, and values under a normal density curve. Here, we place focus on the insights of specific values and areas without dedicating time to those calculations.')


## ----normal-curve-shaded-1a, echo=FALSE, fig.height=ifelse(knitr::is_latex_output(), 1.5, 7), fig.width=3, fig.cap="Normal area within one standard deviation"----
ggplot(NULL, aes(c(-4,4))) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(-4, -1)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey80", xlim = c(-1, 1)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(1, 4)) +
  labs(x = "z", y = "") +
  scale_y_continuous(breaks = NULL) +
  scale_x_continuous(breaks = c(-1,1)) 


## ----normal-curve-shaded-2a, echo=FALSE, fig.height=ifelse(knitr::is_latex_output(), 1.5, 7), fig.width=3, fig.cap="Normal area within two standard deviations"----
ggplot(NULL, aes(c(-4,4))) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(-4, -2)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey80", xlim = c(-2, 2)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(2, 4)) +
  labs(x = "z", y = "") +
  scale_y_continuous(breaks = NULL) +
  scale_x_continuous(breaks = c(-2,2))


## ----echo=FALSE, results="asis"-----------------------------------------------
if(!is_latex_output()) 
  cat('Please see [Appendix A online](https://moderndive.com/A-appendixA.html) to produce these or other calculations in R. ')






## ----echo=FALSE---------------------------------------------------------------
se_xbar <- sigma / sqrt(num_almonds_sample)




## ----echo=FALSE---------------------------------------------------------------
sample_mean <- mean(almonds_sample_100$weight)
deviance <- sample_mean - mu
z_almond <- deviance / se_xbar


## ----echo=FALSE---------------------------------------------------------------
lower_bound <- sample_mean - 1.96 * sigma / sqrt(100)
upper_bound <- sample_mean + 1.96 * sigma / sqrt(100)


## -----------------------------------------------------------------------------
almonds_sample_100 |>
  summarize(
    sample_mean = mean(weight),
    lower_bound = mean(weight) - 1.96 * sigma / sqrt(length(weight)),
    upper_bound = mean(weight) + 1.96 * sigma / sqrt(length(weight))
  )










## ----echo=FALSE, results="asis"-----------------------------------------------
if(!is_latex_output()) 
  cat("Please see [Appendix A online](https://moderndive.com/A-appendixA.html) for calculations of probabilities for $t$ density curves with different degrees of freedom.")


## -----------------------------------------------------------------------------
almonds_sample_100 |>
  summarize(sample_mean = mean(weight), sample_sd = sd(weight))


## ----echo=FALSE---------------------------------------------------------------
sample_s <- sd(almonds_sample_100$weight)
lower_bound_t <- with(almonds_sample,
                     mean(weight) - 1.98*sd(weight)/sqrt(length(weight)))
upper_bound_t <- with(almonds_sample,
                     mean(weight) + 1.98*sd(weight)/sqrt(length(weight)))


## -----------------------------------------------------------------------------
almonds_sample_100 |>
  summarize(sample_mean = mean(weight), sample_sd = sd(weight),
            lower_bound = mean(weight) - 1.98*sd(weight)/sqrt(length(weight)),
            upper_bound = mean(weight) + 1.98*sd(weight)/sqrt(length(weight)))








## ----normal-curve-shaded-3a, echo=FALSE, fig.cap="Normal curve with the shaded middle area being 0.95", fig.height=ifelse(knitr::is_latex_output(), 2, 7), fig.width=3----
ggplot(NULL, aes(c(-4, 4))) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(-4, -1.96)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey80", xlim = c(-1.96, 1.96)) +
  geom_area(stat = "function", fun = dnorm, fill = "grey100", xlim = c(1.96, 4)) +
  labs(x = "z", y = "") +
  scale_y_continuous(breaks = NULL) +scale_x_continuous(breaks = NULL) + 
  geom_point(aes(x=0, y=0), color="red") +
  geom_point(aes(x=-1.96, y=0), color="red") +
  geom_point(aes(x=1.96, y=0), color="red") +
  annotate(geom="text", x=-1.96, y=-0.03, label = bquote("-q"),
           color="red") +
  annotate(geom="text", x=1.96, y=-0.03, label = bquote("q"),
           color="red") +
  annotate(geom="text", x=0, y=-0.04, label = bquote("0"),
           color="red")


## -----------------------------------------------------------------------------
qnorm(0.025)


## -----------------------------------------------------------------------------
qnorm(0.975)


## ----eval=FALSE---------------------------------------------------------------
## qnorm(0.95)


## ----echo=FALSE---------------------------------------------------------------
round(qnorm(0.95), 3)


## -----------------------------------------------------------------------------
almonds_sample_100 |>
  summarize(sample_mean = mean(weight),
            lower_bound = mean(weight) - qnorm(0.95)*sigma/sqrt(length(weight)),
            upper_bound = mean(weight) + qnorm(0.95)*sigma/sqrt(length(weight)))


## ----eval=FALSE---------------------------------------------------------------
## qnorm(0.9)


## ----echo=FALSE---------------------------------------------------------------
round(qnorm(0.9), 3)


## -----------------------------------------------------------------------------
almonds_sample_100






## -----------------------------------------------------------------------------
almonds_sample_100 <- almonds_sample_100 |> 
  ungroup() |> 
  select(-replicate)
almonds_sample_100


## ----echo=-1------------------------------------------------------------------
set.seed(202)
boot_sample <- almonds_sample_100 |> 
  rep_sample_n(size = 100, replace = TRUE, reps = 1)


## -----------------------------------------------------------------------------
boot_sample


## -----------------------------------------------------------------------------
boot_sample |> 
  summarize(mean_weight = mean(weight))



## ----eval=FALSE---------------------------------------------------------------
## ggplot(boot_sample, aes(x = weight)) +
##   geom_histogram(binwidth = 0.1, color = "white") +
##   labs(title = "Resample of 100 weights")
## ggplot(almonds_sample_100, aes(x = weight)) +
##   geom_histogram(binwidth = 0.1, color = "white") +
##   labs(title = "Original sample of 100 weights")




## ----echo= -1-----------------------------------------------------------------
set.seed(20)
bootstrap_samples_35 <- almonds_sample_100 |> 
  rep_sample_n(size = 100, replace = TRUE, reps = 35)
bootstrap_samples_35


## -----------------------------------------------------------------------------
boot_means <- bootstrap_samples_35 |> 
  summarize(mean_weight = mean(weight))
boot_means


## ----resampling-35, fig.cap="Distribution of 35 sample means from 35 bootrap samples"----
ggplot(boot_means, aes(x = mean_weight)) +
  geom_histogram(binwidth = 0.01, color = "white") +
  labs(x = "sample mean weight in grams")


## -----------------------------------------------------------------------------
# Retrieve 1000 bootstrap samples
bootstrap_samples <- almonds_sample_100 |> 
  rep_sample_n(size = 100, replace = TRUE, reps = 1000)

# Compute sample means from the bootstrap samples
boot_means <- bootstrap_samples |> 
  summarize(mean_weight = mean(weight))


## ----echo=-1------------------------------------------------------------------
set.seed(20)
boot_means <- almonds_sample_100 |> 
  rep_sample_n(size = 100, replace = TRUE, reps = 1000) |> 
  summarize(mean_weight = mean(weight))
boot_means


## ----one-thousand-sample-means, message=FALSE, fig.cap="Histogram of 1000 bootstrap sample mean weights of almonds.", fig.height=ifelse(knitr::is_latex_output(), 3.85, 7)----
ggplot(boot_means, aes(x = mean_weight)) +
  geom_histogram(binwidth = 0.01, color = "white") +
  labs(x = "sample mean weight in grams")


## -----------------------------------------------------------------------------
boot_means |> 
  summarize(mean_of_means = mean(mean_weight),
            sd_of_means = sd(mean_weight))







## ----eval=FALSE---------------------------------------------------------------
## almonds_sample_100 |>
##   rep_sample_n(size = 100, replace = TRUE, reps = 1000)


## ----eval=FALSE---------------------------------------------------------------
## almonds_sample_100 |>
##   rep_sample_n(size = 100, replace = TRUE, reps = 1000) |>
##   summarize(mean_weight = mean(weight))


## ----eval=FALSE---------------------------------------------------------------
## almonds_sample_100 |>
##   summarize(stat = mean(weight))


## ----eval=FALSE---------------------------------------------------------------
## almonds_sample_100 |>
##   specify(response = weight) |>
##   calculate(stat = "mean")




## -----------------------------------------------------------------------------
almonds_sample_100 |> 
  specify(response = weight)


## ----eval=FALSE---------------------------------------------------------------
## almonds_sample_100 |>
##   specify(formula = weight ~ NULL)




## ----eval=FALSE---------------------------------------------------------------
## almonds_sample_100 |>
##   specify(response = weight) |>
##   generate(reps = 1000, type = "bootstrap")








## ----eval=FALSE---------------------------------------------------------------
## bootstrap_means <- almonds_sample_100 |>
##   specify(response = weight) |>
##   generate(reps = 1000) |>
##   calculate(stat = "mean")
## bootstrap_means








## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_means)








## -----------------------------------------------------------------------------
bootstrap_means


## -----------------------------------------------------------------------------
percentile_ci <- bootstrap_means |> 
  get_confidence_interval(level = 0.95, type = "percentile")
percentile_ci


## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_means) +
##   shade_confidence_interval(endpoints = percentile_ci)




## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_means) +
##   shade_ci(endpoints = percentile_ci, color = "hotpink", fill = "khaki")


## -----------------------------------------------------------------------------
SE_boot <- bootstrap_means |>
  summarize(SE = sd(stat)) |>
  pull(SE)
SE_boot


## -----------------------------------------------------------------------------
almonds_sample_100 |>
  summarize(lower_bound = mean(weight) - 1.96 * SE_boot,
            upper_bound = mean(weight) + 1.96 * SE_boot)


## -----------------------------------------------------------------------------
x_bar <- almonds_sample_100 |> 
  specify(response = weight) |> 
  calculate(stat = "mean")
x_bar


## -----------------------------------------------------------------------------
standard_error_ci <- bootstrap_means |> 
  get_confidence_interval(type = "se", point_estimate = x_bar, level = 0.95)
standard_error_ci


## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_means) +
##   shade_confidence_interval(endpoints = standard_error_ci)








## -----------------------------------------------------------------------------
mythbusters_yawn




## -----------------------------------------------------------------------------
mythbusters_yawn |> 
  group_by(group, yawn) |> 
  summarize(count = n(), .groups = "keep")




## ----eval=FALSE---------------------------------------------------------------
## mythbusters_yawn |>
##   specify(formula = yawn ~ group)


## -----------------------------------------------------------------------------
mythbusters_yawn |> 
  specify(formula = yawn ~ group, success = "yes")


## -----------------------------------------------------------------------------
first_six_rows <- head(mythbusters_yawn)
first_six_rows


## ----echo=FALSE---------------------------------------------------------------
set.seed(22)


## -----------------------------------------------------------------------------
first_six_rows |> 
  sample_n(size = 6, replace = TRUE)


## ----eval=FALSE---------------------------------------------------------------
## mythbusters_yawn |>
##   specify(formula = yawn ~ group, success = "yes") |>
##   generate(reps = 1000, type = "bootstrap")




## ----eval=FALSE---------------------------------------------------------------
## mythbusters_yawn |>
##   specify(formula = yawn ~ group, success = "yes") |>
##   generate(reps = 1000, type = "bootstrap") |>
##   calculate(stat = "diff in props")


## ----eval=FALSE---------------------------------------------------------------
## bootstrap_distribution_yawning <- mythbusters_yawn |>
##   specify(formula = yawn ~ group, success = "yes") |>
##   generate(reps = 1000, type = "bootstrap") |>
##   calculate(stat = "diff in props", order = c("seed", "control"))
## bootstrap_distribution_yawning






## -----------------------------------------------------------------------------
bootstrap_distribution_yawning |> 
  get_confidence_interval(type = "percentile", level = 0.95)



## -----------------------------------------------------------------------------
obs_diff_in_props <- mythbusters_yawn |> 
  specify(formula = yawn ~ group, success = "yes") |> 
  # generate(reps = 1000, type = "bootstrap") |> 
  calculate(stat = "diff in props", order = c("seed", "control"))
obs_diff_in_props


## -----------------------------------------------------------------------------
myth_ci_se <- bootstrap_distribution_yawning |> 
  get_confidence_interval(type = "se", point_estimate = obs_diff_in_props)
myth_ci_se










## ----message=FALSE------------------------------------------------------------
library(tidyverse)
library(moderndive)
library(infer)
library(nycflights23)
library(ggplot2movies)




## ----eval=FALSE---------------------------------------------------------------
## t.test(x = almonds_sample_100$weight, alternative = "two.sided", mu = 3.6)


## -----------------------------------------------------------------------------
almonds_sample_100


## -----------------------------------------------------------------------------
almonds_sample_100 |>
  summarize(sample_mean = mean(weight),
            sample_sd = sd(weight))


## ----eval=FALSE---------------------------------------------------------------
## almonds_sample_100 |>
##   summarize(x_bar = mean(weight),
##             s = sd(weight),
##             n = length(weight),
##             t = (x_bar - 3.6)/(s/sqrt(n)))






## ----eval = FALSE-------------------------------------------------------------
## 2 * pt(q = -2.26, df = 100 - 1)




## -----------------------------------------------------------------------------
null_dist <- almonds_sample_100 |>
  specify(response = weight) |>
  hypothesize(null = "point", mu = 3.6) |>
  generate(reps = 1000, type = "bootstrap") |>
  calculate(stat = "mean")


## ----echo=TRUE----------------------------------------------------------------
x_bar_almonds <- almonds_sample_100 |>
  summarize(sample_mean = mean(weight)) |>
  select(sample_mean)
null_dist |>
  get_p_value(obs_stat = x_bar_almonds, direction = "two-sided")


## ----echo=FALSE---------------------------------------------------------------
p_val_almonds <- null_dist |>
  get_p_value(obs_stat = x_bar_almonds, direction = "two-sided") 




## -----------------------------------------------------------------------------
almonds_sample_100 |>
  summarize(lower_bound = mean(weight) - 1.98*sd(weight)/sqrt(length(weight)),
            upper_bound = mean(weight) + 1.98*sd(weight)/sqrt(length(weight)))


## ----eval=FALSE---------------------------------------------------------------
## bootstrap_means <- almonds_sample_100 |>
##   specify(response = weight) |>
##   generate(reps = 1000, type = "bootstrap") |>
##   calculate(stat = "mean")




## -----------------------------------------------------------------------------
bootstrap_means |> 
  get_confidence_interval(level = 0.95, type = "percentile")




## ----echo=FALSE---------------------------------------------------------------
set.seed(2)


## ----eval=FALSE---------------------------------------------------------------
## spotify_metal_deephouse <- spotify_by_genre |>
##   filter(track_genre %in% c("metal", "deep-house")) |>
##   select(track_genre, artists, track_name, popularity, popular_or_not)
## spotify_metal_deephouse |>
##   group_by(track_genre, popular_or_not) |>
##   sample_n(size = 3)


## ----echo=FALSE---------------------------------------------------------------
spotify_metal_deephouse <- spotify_by_genre |> 
  filter(track_genre %in% c("metal", "deep-house")) |> 
  select(track_id, track_genre, artists, track_name, popularity, popular_or_not) 
sampled_spotify_metal_deephouse <- spotify_metal_deephouse |>
  group_by(track_genre, popular_or_not) |> 
  sample_n(size = 3) |> 
  arrange(track_id) |> 
  ungroup() |> 
  select(-track_id)
sampled_spotify_metal_deephouse |> 
  kbl(
    caption = "Sample of twelve songs from the Spotify data frame.",
    booktabs = TRUE,
    linesep = ""
  ) |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 6, 16),
    latex_options = c("HOLD_position")
  )


## ----eval=FALSE---------------------------------------------------------------
## ggplot(spotify_metal_deephouse, aes(x = track_genre, fill = popular_or_not)) +
##   geom_bar() +
##   labs(x = "Genre of track")




## -----------------------------------------------------------------------------
spotify_metal_deephouse |> 
  group_by(track_genre, popular_or_not) |>
  tally() # Same as summarize(n = n())






## ----eval=FALSE---------------------------------------------------------------
## spotify_52_original |>
##   select(-track_id) |>
##   head(10)


## ----echo=FALSE---------------------------------------------------------------
spotify_52_original |> 
  select(-track_id) |> 
  head(10) |> 
  kbl(caption = "Representative sample of metal and deep-house songs", 
      booktabs = TRUE,
      linesep = ""
  ) |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 6, 16),
    latex_options = c("HOLD_position")
  )


## ----eval=FALSE---------------------------------------------------------------
## spotify_52_shuffled |>
##   select(-track_id) |>
##   head(10)


## ----echo=FALSE---------------------------------------------------------------
spotify_52_shuffled |> 
  select(-track_id) |> 
  head(10) |> 
  kbl(caption = "(ref:spotify-shuffled-52)", 
      booktabs = TRUE,
      linesep = ""
  ) |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 6, 16),
    latex_options = c("HOLD_position")
  )






## ----eval=FALSE---------------------------------------------------------------
## ggplot(spotify_52_shuffled, aes(x = track_genre, fill = popular_or_not)) +
##   geom_bar() +
##   labs(x = "Genre of track")



## -----------------------------------------------------------------------------
spotify_52_shuffled |> 
  group_by(track_genre, popular_or_not) |> 
  tally()











## -----------------------------------------------------------------------------
spotify_metal_deephouse |> 
  specify(formula = popular_or_not ~ track_genre, success = "popular")


## -----------------------------------------------------------------------------
spotify_metal_deephouse |> 
  specify(formula = popular_or_not ~ track_genre, success = "popular") |> 
  hypothesize(null = "independence")




## ----eval=FALSE---------------------------------------------------------------
## spotify_generate <- spotify_metal_deephouse |>
##   specify(formula = popular_or_not ~ track_genre, success = "popular") |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute")
## nrow(spotify_generate)




## ----eval=FALSE---------------------------------------------------------------
## null_distribution <- spotify_metal_deephouse |>
##   specify(formula = popular_or_not ~ track_genre, success = "popular") |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute") |>
##   calculate(stat = "diff in props", order = c("metal", "deep-house"))
## null_distribution




## -----------------------------------------------------------------------------
obs_diff_prop <- spotify_metal_deephouse |> 
  specify(formula = popular_or_not ~ track_genre, success = "popular") |> 
  calculate(stat = "diff in props", order = c("metal", "deep-house"))
obs_diff_prop


## -----------------------------------------------------------------------------
spotify_metal_deephouse |> 
  observe(formula = popular_or_not ~ track_genre, 
          success = "popular", 
          stat = "diff in props", 
          order = c("metal", "deep-house"))


## ----null-distribution-infer, fig.show="hold", fig.cap="Null distribution.", fig.height=ifelse(knitr::is_latex_output(), 1.8, 7)----
visualize(null_distribution, bins = 25)


## ----null-distribution-infer-2, fig.cap="Shaded histogram to show $p$-value."----
visualize(null_distribution, bins = 25) + 
  shade_p_value(obs_stat = obs_diff_prop, direction = "right")


## -----------------------------------------------------------------------------
null_distribution |> 
  get_p_value(obs_stat = obs_diff_prop, direction = "right")



## ----eval=FALSE---------------------------------------------------------------
## null_distribution <- spotify_metal_deephouse |>
##   specify(formula = popular_or_not ~ track_genre, success = "popular") |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute") |>
##   calculate(stat = "diff in props", order = c("metal", "deep-house"))


## ----eval=FALSE---------------------------------------------------------------
## bootstrap_distribution <- spotify_metal_deephouse |>
##   specify(formula = popular_or_not ~ track_genre, success = "popular") |>
##   # Change 1 - Remove hypothesize():
##   # hypothesize(null = "independence") |>
##   # Change 2 - Switch type from "permute" to "bootstrap":
##   generate(reps = 1000, type = "bootstrap") |>
##   calculate(stat = "diff in props", order = c("metal", "deep-house"))




## -----------------------------------------------------------------------------
percentile_ci <- bootstrap_distribution |> 
  get_confidence_interval(level = 0.90, type = "percentile")
percentile_ci


## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_distribution) +
##   shade_confidence_interval(endpoints = percentile_ci)



## ----eval=FALSE---------------------------------------------------------------
## se_ci <- bootstrap_distribution |>
## get_confidence_interval(level = 0.95, type = "se",
## point_estimate = obs_diff_prop)
## se_ci


## ----eval=FALSE---------------------------------------------------------------
## visualize(bootstrap_distribution) +
## shade_confidence_interval(endpoints = se_ci)





## ----eval=FALSE---------------------------------------------------------------
## library(moderndive)
## library(infer)
## null_distribution_mean <- spotify_metal_deephouse |>
##   specify(formula = popular_or_not ~ track_genre, success = "popular") |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute") |>
##   calculate(stat = "diff in means", order = c("metal", "deep-house"))






















## -----------------------------------------------------------------------------
movies




## -----------------------------------------------------------------------------
movies_sample


## ----action-romance-boxplot, fig.cap="Boxplot of IMDb rating vs. genre.", fig.height=ifelse(knitr::is_latex_output(), 4, 7)----
ggplot(data = movies_sample, aes(x = genre, y = rating)) +
  geom_boxplot() +
  labs(y = "IMDb rating")


## -----------------------------------------------------------------------------
movies_sample |> 
  group_by(genre) |> 
  summarize(n = n(), mean_rating = mean(rating), std_dev = sd(rating))





## -----------------------------------------------------------------------------
movies_sample |> 
  specify(formula = rating ~ genre)


## -----------------------------------------------------------------------------
movies_sample |> 
  specify(formula = rating ~ genre) |> 
  hypothesize(null = "independence")


## ----eval=FALSE---------------------------------------------------------------
## movies_sample |>
##   specify(formula = rating ~ genre) |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute") |>
##   View()




## ----eval=FALSE---------------------------------------------------------------
## null_distribution_movies <- movies_sample |>
##   specify(formula = rating ~ genre) |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute") |>
##   calculate(stat = "diff in means", order = c("Action", "Romance"))
## null_distribution_movies




## -----------------------------------------------------------------------------
obs_diff_means <- movies_sample |> 
  specify(formula = rating ~ genre) |> 
  calculate(stat = "diff in means", order = c("Action", "Romance"))
obs_diff_means


## ----eval=FALSE---------------------------------------------------------------
## visualize(null_distribution_movies, bins = 10) +
##   shade_p_value(obs_stat = obs_diff_means, direction = "both")




## -----------------------------------------------------------------------------
null_distribution_movies |> 
  get_p_value(obs_stat = obs_diff_means, direction = "both")

## ----echo=FALSE---------------------------------------------------------------
p_value_movies <- null_distribution_movies |>
  get_p_value(obs_stat = obs_diff_means, direction = "both") |>
  mutate(p_value = round(p_value, 3))






## -----------------------------------------------------------------------------
movies_sample |> 
  group_by(genre) |> 
  summarize(n = n(), mean_rating = mean(rating), std_dev = sd(rating))



## -----------------------------------------------------------------------------
movies_sample |>
  t_test(formula = rating ~ genre, 
         order = c("Action", "Romance"), 
         alternative = "two-sided")




## -----------------------------------------------------------------------------
flights_sample <- flights |> 
  filter(carrier %in% c("HA", "AS"))


## ----ha-as-flights-boxplot, fig.cap="Air time for Hawaiian and Alaska Airlines flights departing NYC in 2023.", fig.height=ifelse(knitr::is_latex_output(), 2.8, 7)----
ggplot(data = flights_sample, mapping = aes(x = carrier, y = air_time)) +
  geom_boxplot() +
  labs(x = "Carrier", y = "Air Time")


## -----------------------------------------------------------------------------
flights_sample |> 
  group_by(carrier, dest) |> 
  summarize(n = n(), mean_time = mean(air_time, na.rm = TRUE), .groups = "keep")










## ----message=FALSE------------------------------------------------------------
library(tidyverse)
library(moderndive)
library(infer)
library(gridExtra)




## -----------------------------------------------------------------------------
UN_data_ch10 <- un_member_states_2024 |>
  select(country,
         life_exp = life_expectancy_2022, 
         fert_rate = fertility_rate_2022)|>
  na.omit()


## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch10


## ----echo=FALSE---------------------------------------------------------------
n_UN_data_ch10 <- nrow(UN_data_ch10)


## ----echo=FALSE---------------------------------------------------------------
un_member_states_2024 |>
  select(life_exp = life_expectancy_2022, 
         fert_rate = fertility_rate_2022)|>
  na.omit() |>
  tidy_summary() |> 
  kbl() |> 
  kable_styling(
    font_size = ifelse(is_latex_output(), 10, 16),
    latex_options = c("HOLD_position")
  )


## ----eval=FALSE---------------------------------------------------------------
## simple_model <- lm(fert_rate ~ life_exp, data = UN_data_ch10)
## coef(simple_model)




## ----regline-ch10, fig.cap="Relationship with regression line.", fig.height=ifelse(knitr::is_latex_output(), 3, 7), message=FALSE----
ggplot(UN_data_ch10, aes(x = life_exp, y = fert_rate)) +
  geom_point() +
  labs(x = "Life Expectancy (x)", 
       y = "Fertility Rate (y)",
       title = "Relationship between fertility rate and life expectancy") +  
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.5)


## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch10 |>
##   rowid_to_column() |>
##   filter(country == "France")|>
##   pull(rowid)


## ----echo=FALSE---------------------------------------------------------------
france_id <- UN_data_ch10 |>
  rowid_to_column() |>
  filter(country == "France")|>
  pull(rowid)
france_id


## ----eval=FALSE---------------------------------------------------------------
## UN_data_ch10 |>
##   filter(country == "France")


## ----echo=FALSE---------------------------------------------------------------
france_data <- UN_data_ch10 |>
  filter(country == "France")
france_data


## ----echo=FALSE---------------------------------------------------------------
actual_france <- france_data$fert_rate[1]
fitted_france <- lm_data$Values[1] - abs(lm_data$Values[2]) * france_data$life_exp[1]
resid_france <- actual_france - fitted_france


## ----eval=FALSE---------------------------------------------------------------
## simple_model |>
##   get_regression_points() |>
##   filter(ID == 57)




## ----fittedtable-ch10-all-----------------------------------------------------
simple_model |>
  get_regression_points()


## -----------------------------------------------------------------------------
old_faithful_2024


## ----eval=FALSE---------------------------------------------------------------
## old_faithful_2024 |>
##   select(duration, waiting) |>
##   tidy_summary()


## ----echo=FALSE---------------------------------------------------------------
old_faithful_2024 |>
  select(duration, waiting) |> 
  tidy_summary() |> 
  kbl() |> 
  kable_styling(
    font_size = ifelse(is_latex_output(), 10, 16),
    latex_options = c("HOLD_position")
  )


## ----echo=FALSE---------------------------------------------------------------
# This code is used for dynamic non-static in-line text output purposes
n_old_faithful <- dim(old_faithful_2024)[1]


## ----geyserplot1, echo=F, fig.cap="Scatterplot of relationship of eruption duration and waiting time", fig.height=ifelse(knitr::is_latex_output(), 4.5, 7)----
ggplot(old_faithful_2024, 
       aes(x = duration, y = waiting)) +
  geom_point(alpha = 0.3) +
  labs(x = "duration", y = "waiting")


## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## model_1 <- lm(waiting ~ duration, data = old_faithful_2024)
## 
## # Get the coefficients and standard deviation for the model
## coef(model_1)
## sigma(model_1)




## ----eval=FALSE---------------------------------------------------------------
## mod_diff_means <- lm(rating ~ genre, data = movies_sample)
## get_regression_table(mod_diff_means)


## ----echo=FALSE---------------------------------------------------------------
mod_diff_means <- lm(rating ~ genre, data = movies_sample)
get_regression_table(mod_diff_means) |> 
  kbl(caption = "Regression table for two-sample difference in means example") |> 
  kable_styling(
    font_size = ifelse(is_latex_output(), 8, 16),
    latex_options = c("HOLD_position")
  )


## ----echo=-1------------------------------------------------------------------
set.seed(6)
spotify_for_anova <- spotify_by_genre |> 
  select(artists, track_name, popularity, track_genre) |> 
  filter(track_genre %in% c("country", "hip-hop", "rock")) 


## ----eval=FALSE---------------------------------------------------------------
## spotify_for_anova |>
##   slice_sample(n = 10)


## ----echo=FALSE---------------------------------------------------------------
spotify_for_anova |> 
  slice_sample(n = 10) |> 
  kbl(caption = "(ref:spotify-for-anova-slice)") |> 
  kable_styling(
    font_size = ifelse(is_latex_output(), 8, 16),
    latex_options = c("HOLD_position")
  )


## ----fig.cap="Boxplot of popularity by genre.", fig.height=ifelse(knitr::is_latex_output(), 3.2, 7)----
ggplot(spotify_for_anova, aes(x = track_genre, y = popularity)) +
  geom_boxplot() +
  labs(x = "Genre", y = "Popularity")


## -----------------------------------------------------------------------------
mean_popularities_by_genre <- spotify_for_anova |> 
  group_by(track_genre) |>
  summarize(mean_popularity = mean(popularity))
mean_popularities_by_genre


## ----eval=FALSE---------------------------------------------------------------
## mod_anova <- lm(popularity ~ track_genre, data = spotify_for_anova)
## get_regression_table(mod_anova)


## ----echo=FALSE---------------------------------------------------------------
mod_anova <- lm(popularity ~ track_genre, data = spotify_for_anova)
get_regression_table(mod_anova) |> 
  kbl(caption = "Regression table for ANOVA example") |> 
  kable_styling(
    font_size = ifelse(is_latex_output(), 10, 16),
    latex_options = c("HOLD_position")
  )


## -----------------------------------------------------------------------------
aov(popularity ~ track_genre, data = spotify_for_anova) |> 
  anova()






## -----------------------------------------------------------------------------
old_faithful_2024 |>
  slice(c(49, 51))




## ----echo=FALSE---------------------------------------------------------------
# This code is used for dynamic non-static in-line text output purposes
q = round(qt(p = (1 - (1-0.95)/2), df = 114 - 2),3)
s <- round(sigma(model_1),3)
x <- old_faithful_2024$duration
n_old_faithful <- length(x)
#beta1
b1 <- round(coef(model_1)[[2]],3)
denom_se_b1 <- round(sqrt(sum((x - mean(x))^2)),3)
se_b1 <- round(s/denom_se_b1,3)
lb1 <- round(b1 - q*se_b1,3)
ub1 <- round(b1 + q*se_b1,3)
# beta0
b0 <- round(coef(model_1)[[1]],3)
se_b0 <- round(s*sqrt(1/n_old_faithful + mean(x)^2/sum((x - mean(x))^2)),3)
lb0 <- round(b1 - q*se_b0,3)
ub0 <- round(b1 + q*se_b0,3)
# t
t_stat <- round(b1/se_b1,3)
p_value <- round(2*(1 - pt(abs(t_stat), n_old_faithful-2)),3)


## ----pvalue1, echo=FALSE, fig.height=ifelse(knitr::is_latex_output(), 3, 7), fig.cap="Illustration of a two-sided p-value for a t-test"----
n <- n_old_faithful
shade <- function(t, a,b) {
  z = dt(t, df = n-2)
  z[abs(t) < b & -abs(t)>a] <- NA
  return(z)
}

ggplot(data.frame(x = c(-4, 4)), aes(x = x)) + 
  stat_function(fun = dt, args = list(df = n-2)) + 
  stat_function(fun = shade, args = list(a = -2, b = 2), 
                geom = "area", fill = "blue", alpha = .2)+
  scale_x_continuous(name = "t", breaks = seq(-4, 4, 2))+
  scale_y_continuous(labels = NULL)+
  theme(axis.title.y = element_blank(), axis.ticks.y = element_blank())






## ----eval=FALSE---------------------------------------------------------------
## get_regression_table(model_1)






## -----------------------------------------------------------------------------
# Fit regression model:
model_1 <- lm(waiting ~ duration, data = old_faithful_2024)
# Get regression points:
fitted_and_residuals <- get_regression_points(model_1)
fitted_and_residuals


## ----eval=FALSE---------------------------------------------------------------
## fitted_and_residuals |>
##   ggplot(aes(x = waiting_hat, y = residual)) +
##   geom_point() +
##   labs(x = "duration", y = "residual") +
##   geom_hline(yintercept = 0, col = "blue")








## ----eval=FALSE---------------------------------------------------------------
## ggplot(fitted_and_residuals, aes(residual)) +
##   geom_histogram(binwidth = 10, color = "white")


## ----eval = FALSE-------------------------------------------------------------
## fitted_and_residuals |>
##   ggplot(aes(sample = residual)) +
##   geom_qq() +
##   geom_qq_line()


## ----model1residualshist, echo=FALSE, warning=FALSE, fig.cap="Histogram of residuals."----
g1 <- ggplot(fitted_and_residuals, aes(x = residual)) +
  geom_histogram(aes(y=after_stat(density)), binwidth = 10, color = "white") + 
  stat_function(fun = dnorm,  args = list(mean = 0, sd = s), col="blue") + 
  xlim(-50,50) +
  labs(x = "residual")

g2 <- ggplot(fitted_and_residuals, aes(sample = residual)) +
  geom_qq() +
  geom_qq_line(col="blue", linewidth = 0.5)

grid.arrange(g1, g2, ncol=2)




## ----residual-plot, fig.cap="Plot of residuals against the regressor.", message=FALSE, fig.height=ifelse(knitr::is_latex_output(), 1.5, 7)----
ggplot(fitted_and_residuals, aes(x = duration, y = residual)) +
  geom_point(alpha = 0.6) +
  labs(x = "duration", y = "residual") +
  geom_hline(yintercept = 0)




## ----echo=FALSE, results="asis"-----------------------------------------------
if(!is_latex_output()) 
  cat("An example of such a transformation is given in [Appendix A online](https://moderndive.com/A-appendixA.html).")






## ----echo=FALSE---------------------------------------------------------------
n_reps <- 1000


## ----eval=FALSE---------------------------------------------------------------
## bootstrap_distn_slope <- old_faithful_2024 %>%
##   specify(formula = waiting ~ duration) %>%
##   generate(reps = 1000, type = "bootstrap") %>%
##   calculate(stat = "slope")
## bootstrap_distn_slope




## ----bootstrap-distribution-slope, fig.show="hold", fig.cap="Bootstrap distribution of slope.", fig.height=ifelse(knitr::is_latex_output(), 2.2, 7)----
visualize(bootstrap_distn_slope)


## -----------------------------------------------------------------------------
percentile_ci <- bootstrap_distn_slope %>% 
  get_confidence_interval(type = "percentile", level = 0.95)
percentile_ci


## -----------------------------------------------------------------------------
observed_slope <- old_faithful_2024 %>% 
  specify(waiting ~ duration) %>% 
  calculate(stat = "slope")
observed_slope


## -----------------------------------------------------------------------------
se_ci <- bootstrap_distn_slope %>% 
  get_ci(level = 0.95, type = "se", point_estimate = observed_slope)
se_ci


## ----eval=FALSE---------------------------------------------------------------
## null_distn_slope <- old_faithful_2024 |>
##   specify(waiting ~ duration) |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute") |>
##   calculate(stat = "slope")






## -----------------------------------------------------------------------------
# Observed slope
b1 <- old_faithful_2024 |> 
  specify(waiting ~ duration) |>
  calculate(stat = "slope")
b1




## -----------------------------------------------------------------------------
null_distn_slope |> 
  get_p_value(obs_stat = b1, direction = "both")






## -----------------------------------------------------------------------------
coffee_data <- coffee_quality |>
  select(aroma, 
         flavor, 
         moisture_percentage, 
         continent_of_origin, 
         total_cup_points) |>
  mutate(continent_of_origin = as.factor(continent_of_origin))


## -----------------------------------------------------------------------------
coffee_data


## ----eval=FALSE---------------------------------------------------------------
## coffee_data |>
##   tidy_summary()


## ----echo=FALSE---------------------------------------------------------------
coffee_data |>
  tidy_summary()  |> 
  kbl(
    digits = 3,
    caption = "Summary of coffee data",
    booktabs = TRUE,
    linesep = ""
  ) |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 7, 16),
    latex_options = c("HOLD_position")
  )


## ----echo=FALSE---------------------------------------------------------------
# This code is used for dynamic non-static in-line text output purposes
n_coffee <- length(coffee_data$total_cup_points)
table_coffee <- coffee_data |> tidy_summary()
tcp <- table_coffee[1,]
aroma <- table_coffee[2,]
flavor <- table_coffee[3,]




## ----echo=FALSE---------------------------------------------------------------
# This code is used for dynamic non-static in-line text output purposes
corr_table <- coffee_data |>
  select(-continent_of_origin) |>
  cor() |>
  round(digits = 2)


## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## mod_mult <- lm(
##   total_cup_points ~ aroma + flavor + moisture_percentage + continent_of_origin,
##   data = coffee_data
## )
## 
## # Get the coefficients of the model
## coef(mod_mult)
## 
## # Get the standard deviation of the model
## sigma(mod_mult)




## ----eval=FALSE---------------------------------------------------------------
## coffee_data |>
##   select(aroma, flavor, moisture_percentage)|>
##   tidy_summary() |>
##   select(column, min, max)








## ----eval=FALSE---------------------------------------------------------------
## get_regression_table(mod_mult)




## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## mod_mult_1 <- lm(
##   total_cup_points ~ aroma + flavor + moisture_percentage,
##   data = coffee_data)
## 
## # Get the coefficients of the model
## coef(mod_mult_1)
## sigma(mod_mult_1)




## ----eval=FALSE---------------------------------------------------------------
## # Fit regression model:
## mod_mult_2 <- lm(
##   total_cup_points ~ aroma + moisture_percentage, data = coffee_data)
## 
## # Get the coefficients of the model
## coef(mod_mult_2)
## sigma(mod_mult_2)




## ----echo=FALSE---------------------------------------------------------------
# This code is used for dynamic non-static in-line text output purposes
n_coffee <- dim(coffee_data)[1]
s_mult <- summary(mod_mult)$sigma
p_mult <- summary(mod_mult)$df[1]
df_mult <- summary(mod_mult)$df[2]

b1_mult <- summary(mod_mult)$coef[2,1]
se_b1_mult <- summary(mod_mult)$coef[2,2]

q_mult = qt(p = (1 - (1-0.95)/2), df = n_coffee - p_mult)
lb_mult <- b1_mult - q*se_b1_mult 
ub_mult <- b1_mult + q*se_b1_mult


## ----eval=FALSE---------------------------------------------------------------
## get_regression_table(mod_mult, conf.level = 0.98)




## ----eval=FALSE---------------------------------------------------------------
## get_regression_table(mod_mult_1)




## ----eval=FALSE---------------------------------------------------------------
## anova(mod_mult_2, mod_mult_1)




## ----eval=FALSE---------------------------------------------------------------
## anova(mod_mult_1, mod_mult)




## -----------------------------------------------------------------------------
# Fit regression model:
mod_mult_final <- lm(total_cup_points ~ aroma + flavor + continent_of_origin, 
                     coffee_data)
# Get fitted values and residuals:
fit_and_res_mult <- get_regression_points(mod_mult_final)


## ----fig.cap="Residuals vs. fitted values plot and QQ-plot for the multiple regression model", fig.height=ifelse(knitr::is_latex_output(), 4, 7)----
g1 <- fit_and_res_mult |>
  ggplot(aes(x = total_cup_points_hat, y = residual)) +
  geom_point() +
  labs(x = "fitted values (total cup points)", y = "residual") +
  geom_hline(yintercept = 0, col = "blue")
g2 <- ggplot(fit_and_res_mult, aes(sample = residual)) +
  geom_qq() +
  geom_qq_line(col="blue", linewidth = 0.5)
grid.arrange(g1, g2, ncol=2)






## -----------------------------------------------------------------------------
observed_fit <- coffee_data |>
  specify(
    total_cup_points ~ aroma + flavor + moisture_percentage + continent_of_origin
  ) |>
  fit()
observed_fit


## ----eval=FALSE---------------------------------------------------------------
## mod_mult_table


## ----echo=FALSE---------------------------------------------------------------
mod_mult_table |> 
  kbl(
    digits = 3,
    caption = "(ref:mod-mult-again)",
    booktabs = TRUE,
    linesep = ""
  ) |>
  kable_styling(
    font_size = ifelse(is_latex_output(), 8, 16),
    latex_options = c("HOLD_position")
  )


## ----eval=FALSE---------------------------------------------------------------
## coffee_data |>
##   specify(
##     total_cup_points ~ continent_of_origin + aroma + flavor + moisture_percentage
##   ) |>
##   generate(reps = 1000, type = "bootstrap")


## ----echo=FALSE---------------------------------------------------------------
if (!file.exists("rds/generated_distn_slopes.rds")) {
  set.seed(76)
  generated_distn_slopes <- coffee_data |>
    specify(
      total_cup_points ~ continent_of_origin + aroma + flavor + moisture_percentage
    ) |>
    generate(reps = 1000, type = "bootstrap")
  saveRDS(
    object = generated_distn_slopes,
    "rds/generated_distn_slopes.rds"
  )
} else {
  generated_distn_slopes <- readRDS("rds/generated_distn_slopes.rds")
}
generated_distn_slopes


## ----eval=FALSE---------------------------------------------------------------
## boot_distribution_mlr <- coffee_quality |>
##   specify(
##     total_cup_points ~ continent_of_origin + aroma + flavor + moisture_percentage
##   ) |>
##   generate(reps = 1000, type = "bootstrap") |>
##   fit()
## boot_distribution_mlr


## ----echo=FALSE---------------------------------------------------------------
if (!file.exists("rds/boot_distn_slopes.rds")) {
  set.seed(76)
  boot_distribution_mlr <- generated_distn_slopes |> 
    fit()
  saveRDS(
    object = boot_distribution_mlr,
    "rds/boot_distn_slopes.rds"
  )
} else {
  boot_distribution_mlr <- readRDS("rds/boot_distn_slopes.rds")
}
boot_distribution_mlr


## ----boot-distn-slopes, fig.cap="Bootstrap distributions of partial slopes.", fig.height=8----
visualize(boot_distribution_mlr)


## -----------------------------------------------------------------------------
confidence_intervals_mlr <- boot_distribution_mlr |> 
  get_confidence_interval(
    level = 0.95,
    type = "percentile",
    point_estimate = observed_fit)
confidence_intervals_mlr


## ----ci-slopes-multiple, fig.cap="95% confidence intervals for the partial slopes.", fig.height=8.5----
visualize(boot_distribution_mlr) +
  shade_confidence_interval(endpoints = confidence_intervals_mlr)


## -----------------------------------------------------------------------------
set.seed(2024)
null_distribution_mlr <- coffee_quality |>
  specify(total_cup_points ~ continent_of_origin + aroma + 
      flavor + moisture_percentage) |>
  hypothesize(null = "independence") |>
  generate(reps = 1000, type = "permute") |>
  fit()
null_distribution_mlr


## ----fig.height=6, fig.cap="Shaded p-values for the partial slopes in this multiple linear regression."----
visualize(null_distribution_mlr) +
  shade_p_value(obs_stat = observed_fit, direction = "two-sided")


## -----------------------------------------------------------------------------
null_distribution_mlr |>
  get_p_value(obs_stat = observed_fit, direction = "two-sided")


















## ----echo=FALSE, message=FALSE------------------------------------------------
library(tidyverse)
library(moderndive)
library(fivethirtyeight)




## ----eval=FALSE---------------------------------------------------------------
## View(house_prices)
## glimpse(house_prices)



## ----eval=FALSE---------------------------------------------------------------
## gain_summary <- flights |>
##   summarize(min = min(gain, na.rm = TRUE),
##             q1 = quantile(gain, 0.25, na.rm = TRUE),
##             median = quantile(gain, 0.5, na.rm = TRUE),
##             q3 = quantile(gain, 0.75, na.rm = TRUE),
##             max = max(gain, na.rm = TRUE),
##             mean = mean(gain, na.rm = TRUE),
##             sd = sd(gain, na.rm = TRUE),
##             missing = sum(is.na(gain)))


## ----eval=FALSE---------------------------------------------------------------
## house_prices |>
##   select(price, sqft_living, condition) |>
##   tidy_summary()


## ----echo=FALSE---------------------------------------------------------------
house_prices |> 
  select(price, sqft_living, condition) |> 
  tidy_summary() |> 
  kbl(caption = "(ref:some-house-price-vars)") |> 
  kable_styling(
    font_size = ifelse(is_latex_output(), 7.8, 16),
    latex_options = c("HOLD_position")
  )


## ----eval=FALSE, message=FALSE------------------------------------------------
## # Histogram of house price:
## ggplot(house_prices, aes(x = price)) +
##   geom_histogram(color = "white") +
##   labs(x = "price (USD)", title = "House price")
## 
## # Histogram of sqft_living:
## ggplot(house_prices, aes(x = sqft_living)) +
##   geom_histogram(color = "white") +
##   labs(x = "living space (square feet)", title = "House size")
## 
## # Barplot of condition:
## ggplot(house_prices, aes(x = condition)) +
##   geom_bar() +
##   labs(x = "condition", title = "House condition")




## ----echo=FALSE, results="asis"-----------------------------------------------
if(!is_latex_output()) 
  cat("If you are unfamiliar with such transformations, we highly recommend you read [Appendix A online](https://moderndive.com/A-appendixA.html) on logarithmic (log) transformations.")


## -----------------------------------------------------------------------------
house_prices <- house_prices |>
  mutate(
    log10_price = log10(price),
    log10_size = log10(sqft_living)
  )


## -----------------------------------------------------------------------------
house_prices |> 
  select(price, log10_price, sqft_living, log10_size)


## ----eval=FALSE---------------------------------------------------------------
## # Before log10 transformation:
## ggplot(house_prices, aes(x = price)) +
##   geom_histogram(color = "white") +
##   labs(x = "price (USD)", title = "House price: Before")
## 
## # After log10 transformation:
## ggplot(house_prices, aes(x = log10_price)) +
##   geom_histogram(color = "white") +
##   labs(x = "log10 price (USD)", title = "House price: After")




## ----eval=FALSE---------------------------------------------------------------
## # Before log10 transformation:
## ggplot(house_prices, aes(x = sqft_living)) +
##   geom_histogram(color = "white") +
##   labs(x = "living space (square feet)", title = "House size: Before")
## 
## # After log10 transformation:
## ggplot(house_prices, aes(x = log10_size)) +
##   geom_histogram(color = "white") +
##   labs(x = "log10 living space (square feet)", title = "House size: After")



## ----eval=FALSE---------------------------------------------------------------
## # Plot interaction model
## ggplot(house_prices,
##        aes(x = log10_size, y = log10_price, col = condition)) +
##   geom_point(alpha = 0.05) +
##   geom_smooth(method = "lm", se = FALSE) +
##   labs(y = "log10 price",
##        x = "log10 size",
##        title = "House prices in Seattle")
## # Plot parallel slopes model
## ggplot(house_prices,
##        aes(x = log10_size, y = log10_price, col = condition)) +
##   geom_point(alpha = 0.05) +
##   geom_parallel_slopes(se = FALSE) +
##   labs(y = "log10 price",
##        x = "log10 size",
##        title = "House prices in Seattle")



## ----eval=FALSE---------------------------------------------------------------
## ggplot(house_prices,
##        aes(x = log10_size, y = log10_price, col = condition)) +
##   geom_point(alpha = 0.4) +
##   geom_smooth(method = "lm", se = FALSE) +
##   labs(y = "log10 price",
##        x = "log10 size",
##        title = "House prices in Seattle") +
##   facet_wrap(~ condition)


## -----------------------------------------------------------------------------
house_prices |> 
  count(condition)




## ----eval=FALSE---------------------------------------------------------------
## price_interaction <- lm(log10_price ~ log10_size * condition, data = house_prices)
## get_regression_table(price_interaction)









## -----------------------------------------------------------------------------
2.45 + 1 * log10(1900)


## ----echo=FALSE, results="asis"-----------------------------------------------
if(!is_latex_output()) 
  cat("This described in [Appendix A online](https://moderndive.com/A-appendixA.html).")


## -----------------------------------------------------------------------------
10^(2.45 + 1 * log10(1900))


## ----eval=FALSE---------------------------------------------------------------
## price_interaction <- lm(log10_price ~ log10_size * condition,
##                         data = house_prices)
## get_regression_table(price_interaction)



## -----------------------------------------------------------------------------
observed_fit_coefficients <- house_prices |>
  specify(log10_price ~ log10_size * condition) |>
  fit()
observed_fit_coefficients


## ----eval=FALSE---------------------------------------------------------------
## null_distribution_housing <- house_prices |>
##   specify(log10_price ~ log10_size * condition) |>
##   hypothesize(null = "independence") |>
##   generate(reps = 1000, type = "permute") |>
##   fit()


## ----echo=FALSE---------------------------------------------------------------
if (!file.exists("rds/null_distribution_housing.rds")) {
  set.seed(2024)
  null_distribution_housing <- house_prices |>
    specify(log10_price ~ log10_size * condition) |>
    hypothesize(null = "independence") |>
    generate(reps = 1000, type = "permute") |>
    fit()
  saveRDS(
    object = null_distribution_housing,
    "rds/null_distribution_housing.rds"
  )
} else {
  null_distribution_housing <- readRDS("rds/null_distribution_housing.rds")
}


## ----eval=FALSE---------------------------------------------------------------
## visualize(null_distribution_housing) +
##   shade_p_value(obs_stat = observed_fit_coefficients, direction = "two-sided")


## ----echo=FALSE, message=FALSE------------------------------------------------
null_housing_shaded <- visualize(null_distribution_housing) +
  shade_p_value(obs_stat = observed_fit_coefficients, direction = "two-sided")
ggsave(filename = "images/null_housing_shaded.png", 
       plot = null_housing_shaded, 
       width = 6,
       height = 9,
       dpi = 320)


## ----echo=FALSE, out.height="100%"--------------------------------------------
knitr::include_graphics("images/null_housing_shaded.png")


## -----------------------------------------------------------------------------
null_distribution_housing |>
  get_p_value(obs_stat = observed_fit_coefficients, direction = "two-sided")






## -----------------------------------------------------------------------------
glimpse(US_births_1994_2003)


## -----------------------------------------------------------------------------
US_births_1999 <- US_births_1994_2003 |>
  filter(year == 1999)


## ----us-births, fig.cap="Number of births in the US in 1999.", fig.height=ifelse(knitr::is_latex_output(), 6.4, 7)----
ggplot(US_births_1999, aes(x = date, y = births)) +
  geom_line() +
  labs(x = "Date", 
       y = "Number of births", 
       title = "US Births in 1999")


## -----------------------------------------------------------------------------
US_births_1999 |> 
  arrange(desc(births))










## ----echo=FALSE---------------------------------------------------------------
package_versions <- sessioninfo::package_info(c(needed_CRAN_pkgs)) |> 
  as_tibble() |> 
  filter(attached == TRUE | package %in% c("bookdown")) |> 
  select(package, version = ondiskversion)
readr::write_rds(package_versions, "rds/package_versions.rds")


## ----echo=FALSE, results='asis'-----------------------------------------------
if(!is_latex_output()){
  cat("# (APPENDIX) Appendix {-}")
} else {
  cat("\\appendix")
}

