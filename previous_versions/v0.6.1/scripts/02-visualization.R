## ----message=FALSE-------------------------------------------------------
library(nycflights13)
library(ggplot2)
library(dplyr)


## ----message=FALSE, warning=FALSE, echo=FALSE----------------------------
# Packages needed internally, but not in book.
library(gapminder)
library(knitr)
library(kableExtra)
library(readr)
library(patchwork)
library(scales)
library(stringr)


## ---- echo=FALSE---------------------------------------------------------
gapminder_2007 <- gapminder %>% 
  filter(year == 2007) %>% 
  select(-year) %>% 
  rename(
    Country = country,
    Continent = continent,
    `Life Expectancy` = lifeExp,
    `Population` = pop,
    `GDP per Capita` = gdpPercap
  )


## ----gapminder-2007, echo=FALSE------------------------------------------
gapminder_2007 %>% 
  head() %>% 
  kable(
    digits=2,
    caption = "Gapminder 2007 Data: First 6 of 142 countries"#, 
#    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))


## ----gapminder, echo=FALSE, fig.cap="Life expectancy over GDP per capita in 2007."----
if(knitr::is_html_output()){
  ggplot(data = gapminder_2007, 
         mapping = aes(x = `GDP per Capita`, 
                       y = `Life Expectancy`, 
                       size = Population, 
                       color = Continent)) +
    geom_point() +
    labs(x = "GDP per capita", y = "Life expectancy")
} else {
    ggplot(data = gapminder_2007, 
         mapping = aes(x = `GDP per Capita`, 
                       y = `Life Expectancy`, 
                       size = Population, 
                       color = Continent)) +
    geom_point() +
    labs(x = "GDP per capita", y = "Life expectancy") +
    scale_color_grey()
}


## ----summary-table-gapminder, echo=FALSE---------------------------------
tibble(
  `data variable` = c("GDP per Capita", "Life Expectancy", "Population", "Continent"),
  aes = c("x", "y", "size", "color"),
  geom = c("point", "point", "point", "point")
) %>% 
  kable(
    caption = "Summary of Grammar of Graphics for this plot", 
    booktabs = TRUE
  ) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))


## ------------------------------------------------------------------------
alaska_flights <- flights %>% 
  filter(carrier == "AS")








## ---- eval=FALSE---------------------------------------------------------
## ggplot(data = alaska_flights, mapping = aes(x = dep_delay, y = arr_delay)) +
##   geom_point()


## ----noalpha, fig.cap="Arrival delays vs departure delays for Alaska Airlines flights from NYC in 2013.", warning=TRUE, echo=FALSE----
ggplot(data = alaska_flights, mapping = aes(x = dep_delay, y = arr_delay)) + 
  geom_point()


## ----nolayers, fig.cap="A plot with no layers."--------------------------
ggplot(data = alaska_flights, mapping = aes(x = dep_delay, y = arr_delay))






## ----alpha, fig.cap="Arrival vs departure delays scatterplot with alpha = 0.2."----
ggplot(data = alaska_flights, mapping = aes(x = dep_delay, y = arr_delay)) + 
  geom_point(alpha = 0.2)


## ----jitter-example-plot-1, fig.cap="Regular and jittered scatterplot.", echo=FALSE----
jitter_example <- tibble(
  x = rep(0, 4),
  y = rep(0, 4)
)
jittered_plot_1 <- ggplot(data = jitter_example, mapping = aes(x = x, y = y)) + 
  geom_point() +
  coord_cartesian(xlim = c(-0.025, 0.025), ylim = c(-0.025, 0.025)) + 
  labs(title = "Regular scatterplot")
jittered_plot_2 <- ggplot(data = jitter_example, mapping = aes(x = x, y = y)) + 
  geom_jitter(width = 0.01, height = 0.01) +
  coord_cartesian(xlim = c(-0.025, 0.025), ylim = c(-0.025, 0.025)) + 
  labs(title = "Jittered scatterplot")
jittered_plot_1 + jittered_plot_2


## ----jitter, fig.cap="Arrival vs departure delays jittered scatterplot."----
ggplot(data = alaska_flights, mapping = aes(x = dep_delay, y = arr_delay)) + 
  geom_jitter(width = 30, height = 30)






## ------------------------------------------------------------------------
early_january_weather <- weather %>% 
  filter(origin == "EWR" & month == 1 & day <= 15)






## ----hourlytemp, fig.cap="Hourly temperature in Newark for January 1-15, 2013."----
ggplot(data = early_january_weather, mapping = aes(x = time_hour, y = temp)) +
  geom_line()






## ----temp-on-line, echo=FALSE, fig.height=0.8, fig.cap="Plot of hourly temperature recordings from NYC in 2013."----
ggplot(data = weather, mapping = aes(x = temp, y = factor("A"))) +
  geom_point() +
  theme(axis.ticks.y = element_blank(), 
        axis.title.y = element_blank(),
        axis.text.y = element_blank())
hist_title <- "Histogram of Hourly Temperature Recordings from NYC in 2013"


## ----histogramexample, warning=FALSE, echo=FALSE, fig.cap="Example histogram."----
ggplot(data = weather, mapping = aes(x = temp)) +
  geom_histogram(binwidth = 10, boundary = 70, color = "white")


## ----weather-histogram, warning=TRUE, fig.cap="Histogram of hourly temperatures at three NYC airports."----
ggplot(data = weather, mapping = aes(x = temp)) +
  geom_histogram()


## ----weather-histogram-2, warning=FALSE, message=FALSE, fig.cap="Histogram of hourly temperatures at three NYC airports with white borders."----
ggplot(data = weather, mapping = aes(x = temp)) +
  geom_histogram(color = "white")


## ---- eval = FALSE-------------------------------------------------------
## ggplot(data = weather, mapping = aes(x = temp)) +
##   geom_histogram(color = "white", fill = "steelblue")


## ---- eval = FALSE-------------------------------------------------------
## ggplot(data = weather, mapping = aes(x = temp)) +
##   geom_histogram(bins = 40, color = "white")


## ---- eval = FALSE-------------------------------------------------------
## ggplot(data = weather, mapping = aes(x = temp)) +
##   geom_histogram(binwidth = 10, color = "white")


## ----hist-bins, warning=FALSE, message=FALSE, fig.cap= "Setting histogram bins in two ways.", echo=FALSE----
hist_1 <- ggplot(data = weather, mapping = aes(x = temp)) +
  geom_histogram(bins = 40, color = "white") +
  labs(title = "With 40 bins")
hist_2 <- ggplot(data = weather, mapping = aes(x = temp)) +
  geom_histogram(binwidth = 10, color = "white") +
  labs(title = "With binwidth = 10 deg F")
hist_1 + hist_2






## ----facethistogram, fig.cap="Faceted histogram of hourly temperatures by month."----
ggplot(data = weather, mapping = aes(x = temp)) +
  geom_histogram(binwidth = 5, color = "white") +
  facet_wrap(~ month)


## ----facethistogram2, fig.cap="Faceted histogram with 4 instead of 3 rows."----
ggplot(data = weather, mapping = aes(x = temp)) +
  geom_histogram(binwidth = 5, color = "white") +
  facet_wrap(~ month, nrow = 4)






## ---- echo=FALSE---------------------------------------------------------
n_nov <- weather %>% 
  filter(month == 11) %>% 
  nrow()
min_nov <- weather %>% 
  filter(month == 11) %>% 
  pull(temp) %>% 
  min(na.rm = TRUE) %>% 
  round(0)
max_nov <- weather %>% 
  filter(month == 11) %>% 
  pull(temp) %>%
  max(na.rm = TRUE) %>% 
  round(0)
quartiles <- weather %>% 
  filter(month == 11) %>% 
  pull(temp) %>% 
  quantile(prob=c(0.25, 0.5, 0.75)) %>% 
  round(0)
five_number_summary <- tibble(
  temp = c(min_nov, quartiles, max_nov)
)


## ----nov1, echo=FALSE, fig.cap="November temperatures represented as points."----
base_plot <- weather %>% 
  filter(month %in% c(11)) %>% 
  ggplot(mapping = aes(x = factor(month), y = temp)) +
  labs(x = "")
base_plot +
  geom_jitter(width = 0.075, height = 0.5, alpha = 0.1)


## ----nov2, echo=FALSE, fig.cap="Building up a boxplot of November temperatures."----
boxplot_1 <- base_plot +
  geom_hline(data = five_number_summary, aes(yintercept=temp), linetype = "dashed") +
  geom_jitter(width = 0.075, height = 0.5, alpha = 0.1)
boxplot_2 <- base_plot +
  geom_boxplot() +
  geom_hline(data = five_number_summary, aes(yintercept=temp), linetype = "dashed") +
  geom_jitter(width = 0.075, height = 0.5, alpha = 0.1)
boxplot_3 <- base_plot +
  geom_boxplot()
boxplot_1 + boxplot_2 + boxplot_3


## ----badbox, fig.cap="Invalid boxplot specification.", fig.height=3.5----
ggplot(data = weather, mapping = aes(x = month, y = temp)) +
  geom_boxplot()


## ----monthtempbox, fig.cap="Side-by-side boxplot of temperature split by month.", fig.height=3.7----
ggplot(data = weather, mapping = aes(x = factor(month), y = temp)) +
  geom_boxplot()






## ------------------------------------------------------------------------
fruits <- tibble(
  fruit = c("apple", "apple", "orange", "apple", "orange")
)
fruits_counted <- tibble(
  fruit = c("apple", "orange"),
  number = c(3, 2)
)


## ----fruits, echo=FALSE--------------------------------------------------
fruits


## ----fruitscounted, echo=FALSE-------------------------------------------
fruits_counted


## ----geombar, fig.cap="Barplot when counts are not pre-counted.", fig.height=2.5----
ggplot(data = fruits, mapping = aes(x = fruit)) +
  geom_bar()


## ---- geomcol, fig.cap="Barplot when counts are pre-counted.", fig.height=2.5----
ggplot(data = fruits_counted, mapping = aes(x = fruit, y = number)) +
  geom_col()


## ----flightsbar, fig.cap='(ref:geombar)', fig.height=2.5-----------------
ggplot(data = flights, mapping = aes(x = carrier)) +
  geom_bar()


## ----flights-counted, message=FALSE, echo=FALSE--------------------------
flights_table <- flights %>% 
  group_by(carrier) %>% 
  summarize(number = n())
kable(flights_table,
      digits = 3,
      caption = "Number of flights pre-counted for each carrier.", 
      booktabs = TRUE,
      longtable = TRUE
) %>% 
  kable_styling(font_size = ifelse(knitr:::is_latex_output(), 10, 16),
                latex_options = c("hold_position"))


## ---- eval=FALSE---------------------------------------------------------
## ggplot(data = flights_table, mapping = aes(x = carrier, y = number)) +
##   geom_col()






## ----carrierpie, echo=FALSE, fig.cap="The dreaded pie chart.", out.width="75%"----
if(knitr::is_html_output()){
  ggplot(flights, mapping = aes(x = factor(1), fill = carrier)) +
    geom_bar(width = 1) +
    coord_polar(theta = "y") +
    theme(axis.title.x = element_blank(), 
      axis.title.y = element_blank(),
      axis.ticks = element_blank(),
      axis.text.y = element_blank(),
      axis.text.x = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()) +
    guides(fill = guide_legend(keywidth = 0.8, keyheight = 0.8))
} else {
  ggplot(flights, mapping = aes(x = factor(1), fill = carrier)) +
    geom_bar(width = 1) +
    coord_polar(theta = "y") +
    theme_light() +
    theme(axis.title.x = element_blank(), 
      axis.title.y = element_blank(),
      axis.ticks = element_blank(),
      axis.text.y = element_blank(),
      axis.text.x = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()) +
    guides(fill = guide_legend(keywidth = 0.8, keyheight = 0.8)) +
    scale_fill_grey()
}






## ---- fig.height=2.5, eval=FALSE-----------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier)) +
##   geom_bar()


## ----eval=FALSE----------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier, fill = origin)) +
##   geom_bar()


## ----flights-stacked-bar, echo=FALSE, fig.cap="Stacked barplot comparing the number of flights by carrier and origin.", fig.height=3.5----
if(knitr::is_html_output()) {
  ggplot(data = flights, mapping = aes(x = carrier, fill = origin)) +
    geom_bar()
} else {
  ggplot(data = flights, mapping = aes(x = carrier, fill = origin)) +
    geom_bar() +
    scale_fill_grey()
}


## ---- eval=FALSE---------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier), fill = origin) +
##   geom_bar()


## ----eval=FALSE----------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier, color = origin)) +
##   geom_bar()


## ----flights-stacked-bar-color, echo=FALSE, fig.cap="Stacked barplot with color aesthetic used instead of fill.", fig.height=3.5----
if(knitr::is_html_output()){
  ggplot(data = flights, mapping = aes(x = carrier, color = origin)) +
    geom_bar()
} else {
  ggplot(data = flights, mapping = aes(x = carrier, color = origin)) +
    geom_bar() +
    scale_color_grey()
}


## ----eval=FALSE----------------------------------------------------------
## ggplot(data = flights, mapping = aes(x = carrier, fill = origin)) +
##   geom_bar(position = "dodge")


## ----flights-dodged-bar-color, echo=FALSE, fig.cap="Side-by-side barplot comparing number of flights by carrier and origin.", fig.height=3.5----
if(knitr::is_html_output()){
  ggplot(data = flights, mapping = aes(x = carrier, fill = origin)) +
    geom_bar(position = "dodge")
} else {
  ggplot(data = flights, mapping = aes(x = carrier, fill = origin)) +
    geom_bar(position = "dodge") +
    scale_fill_grey()
}


## ----facet-bar-vert, fig.cap="Faceted barplot comparing the number of flights by carrier and origin.", fig.height=7.5----
ggplot(data = flights, mapping = aes(x = carrier)) +
  geom_bar() +
  facet_wrap(~ origin, ncol = 1)








## ---- eval=FALSE---------------------------------------------------------
## # Segment 1:
## ggplot(data = flights, mapping = aes(x = carrier)) +
##   geom_bar()
## 
## # Segment 2:
## ggplot(flights, aes(x = carrier)) +
##   geom_bar()




## ----ggplot-cheatsheet, echo=FALSE, fig.cap="Data Visualization with ggplot2 cheatsheet."----
if(knitr::is_html_output())
  include_graphics("images/cheatsheets/ggplot_cheatsheet-1.png")


## ----viz-map, echo=FALSE, fig.cap="Mind map for Data Visualization.", out.width="200%"----
library(knitr)
if(knitr:::is_html_output()){
  include_url("https://coggle.it/diagram/V_G2gzukTDoQ-aZt-", 
              height = "1000px")
} else {
  include_graphics("images/coggleviz.png")
}


## ---- eval=FALSE---------------------------------------------------------
## alaska_flights <- flights %>%
##   filter(carrier == "AS")
## 
## ggplot(data = alaska_flights, mapping = aes(x = dep_delay, y = arr_delay)) +
##   geom_point()


## ---- eval=FALSE---------------------------------------------------------
## early_january_weather <- weather %>%
##   filter(origin == "EWR" & month == 1 & day <= 15)
## 
## ggplot(data = early_january_weather, mapping = aes(x = time_hour, y = temp)) +
##   geom_line()

