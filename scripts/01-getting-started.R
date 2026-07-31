## ----setup-init, include=FALSE------------------------------------------------
library(knitr)
source("scripts/image_functions.R")
















## ----getting-started-load-ggplot2, eval=FALSE---------------------------------
# library(ggplot2)


## ----getting-started-load-packages, message=FALSE-----------------------------
library(nycflights23)
library(dplyr)
library(knitr)




## ----load_flights-------------------------------------------------------------
flights


## ----getting-started-glimpse-flights------------------------------------------
glimpse(flights)


## ----getting-started-kable-airlines, eval=FALSE-------------------------------
# airlines
# kable(airlines)


## ----getting-started-demo-code, eval=FALSE------------------------------------
# airlines$name


## ----getting-started-glimpse-airports-----------------------------------------
glimpse(airports)


## ----getting-started-demo-code-v2, eval=FALSE---------------------------------
# ?flights


## ----getting-started-install-olympic, eval=FALSE------------------------------
# install.packages("remotes")
# remotes::install_github("moderndive/olympicAthletes")


## ----getting-started-load-olympic, eval=FALSE---------------------------------
# library(olympicAthletes)


## -----------------------------------------------------------------------------
#| label: ch1-exercises
#| results: asis
#| echo: false
#| message: false
source(if (file.exists("scripts/exercise_helpers.R")) "scripts/exercise_helpers.R" else "../scripts/exercise_helpers.R")
cat(render_chapter_exercises(1))

