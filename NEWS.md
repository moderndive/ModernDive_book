# ModernDive 0.4.0.9000

* Added Learning Check solutions section to Appendix
* Added PDF build
* Added subsection 2.2.3 "Errors, warnings, and messages" by @andrewheiss

# ModernDive 0.4.0

## Highlights

1. The [`infer` package](http://infer.netlify.com/) is ready for prime-time! Thus we made a first pass at incorporating it into the book in Chapters 9 and 10 on confidence intervals and hypothesis testing!
1. Chapter 12 on "Thinking with Data" now includes a case study using the [Seattle house prices](https://www.kaggle.com/harlfoxem/housesalesprediction) dataset on Kaggle.com. Chapters 3 and 4 from new ["Modeling with Data in the Tidyverse"](https://www.datacamp.com/courses/modeling-with-data-in-the-tidyverse) DataCamp course by Albert Y. Kim are based on this analysis!
1. Speaking of DataCamp, we point readers to [various DataCamp courses](https://moderndive.netlify.com/index.html#datacamp) that directly align with various chapters in the book!
1. We significantly cleaned up Chapter 8 on sampling! In particular: adding a [2013 Obama approval rating poll](https://www.npr.org/sections/itsallpolitics/2013/12/04/248793753/poll-support-for-obama-among-young-americans-eroding) example to tie in with our sampling bowl tactile and virtual simulations and making it very clear that ultimately we are performing statistical **inference via sampling**.


## All content changes

* Introduction: Added section on correspondence of chapters to various DataCamp courses. Furthermore, links to relevant DataCamp course are included at the outset of each chapter.
* Chapter 3 - Data visualization:
    + Added simplified `geom_jitter()` example
    + More explanations for how whiskers and outliers are constructed in `geom_boxplots`
    + Added summary of table of all 5 named graphs
* Chapter 4 - Tidy data:
    + Added section on importing Excel data via RStudio
    + Added example of tidy vs non-tidy: `fivethirtyeight::drinks`
* Chapter 5 - Data wrangling:
    + Added computing [available seat miles](https://en.wikipedia.org/wiki/Available_seat_miles) data wrangling case study
    + Abandoned "5 Main Verbs" 5MV notion
    + Added `_join()` and `group_by()` multiple variables
* Chapter 6 - Basic regression:
    + Clarified explanations of indicator/dummy variables when using categorical variable in regression. 
    + Expanded "Correlation is not necessarily causation" subsection with example of "does sleeping with shoes on cause headaches?" including [causal diagram](https://github.com/moderndive/moderndive_book/blob/master/images/flowcharts/flowchart.009-cropped.png)
    + Introduced concept of a "wrapper function" when introducing `moderndive::get_regression_table()` function
    + Replaced all `base::summary()` with `skimr::skim()` for quick numerical summaries
* Chapter 7 - Multiple regression:
    + Changed all "everything else being equal" interpretation statements with "taking into account/controlling for all other variables in our model"
* Chapter 8 - Sampling:
    + Significantly cleaned up sampling terminology and definitions and made more clear that we are **sampling for inference**
    + Cleaned up section and subsection structure to be much cleaner:
        1. Tactile sampling simulation
        1. Virtual sampling simulation
        1. In real-life sampling: Introduced example of 2013 Obama approval rating poll and then tie everything with [sampling bowl](https://github.com/moderndive/moderndive_book/blob/master/images/sampling_bowl.jpeg).
* **Major overhaul**: Chapter 9 - Confidence intervals
    + [`infer` package](http://infer.netlify.com/) now being ready for prime-time, we made first pass at incorporation into book.
* **Major overhaul**: Chapter 10 - Hypothesis testing
    + [`infer` package](http://infer.netlify.com/) now being ready for prime-time, we made first pass at incorporation into book.
    + Added discussion on Allan Downey's ["There is only one test"](http://allendowney.blogspot.com/2016/06/there-is-still-only-one-test.html) ideas
* Chapter 11 - Inference for Regression
    + Added a simple linear regression example using the `infer` package    
* **Major overhaul**: Chapter 12 - Thinking with data
    + Added case study of [Seattle house prices](https://www.kaggle.com/harlfoxem/housesalesprediction) dataset from Kaggle, which is now available in `house_prices` dataframe in `moderndive` package. 
        1. Chapters 3 and 4 from new ["Modeling with Data in the Tidyverse"](https://www.datacamp.com/courses/modeling-with-data-in-the-tidyverse) DataCamp course are based on this analysis
        1. Includes a discussion on the importance of `log10`-transformations
        1. Introduces modeling/regression for prediction: predicting house prices
    + Laid outline for "effective data storytelling" using `fivethirtyeight` data and added one small example using US births data
    + At the beginning of chapter, we now come full circle and revisit the discussion on the ModernDive [flowchart](https://github.com/moderndive/moderndive_book/blob/master/images/flowcharts/flowchart/flowchart.002.png) in the introduction.


## Other changes

* Updated `moderndive` package on CRAN to 0.2.0. See [`NEWS.md`](https://github.com/moderndive/moderndive/releases)

 


# ModernDive 0.3.0

## Content changes

* Reorganized chapter sequencing according to flowchart at top of [Section 1.1](https://moderndive.com/index.html#intro-for-students)
* Chapter 2 - Getting Started: Added more explanation on R packages, including analogy for `install.packages()` and `library()` (akin to downloading apps onto phone)
* Added "Data Modeling" portion to book
    + Chapter 6 - Basic regression: one numerical explanatory variable, correlation, one categorical explanatory variable)
    + Chapter 7 - Multiple regression: two numerical explanatory variables, one numerical and one categorical, interaction effects, Simpson's Paradox
    + Uses new [`moderndive`](https://moderndive.github.io/moderndive/) package, which includes `get_regression_table()` and `get_regression_points()` wrapper functions to simplify outputting of clean regression tables and observed/fitted values + residuals
* Added "statistical inference" portion to book
    + Added Chapter 8 - Sampling (still under construction) using [sampling bowl](https://github.com/moderndive/moderndive/blob/master/data-raw/sampling_bowl.jpeg)
    + Chapters 9 and 10 on confidence intervals and hypothesis testing have not yet been updated, as we were awaiting the now launched package: [`infer`: A tidyverse-friendly R package fo statistical inference](https://github.com/andrewpbray/infer)
    + Added Chapter 11 - Inference for regression (still under construction), where we'll revisit the regression models fit in Chapters 6 & 7


## Other changes

- Development version of book now available at <https://moderndive.netlify.com/>; deployed via travis-ci + netlify. 
- Added wide ModernDive logo to top of each chapter and `logos` folder
- Added favicon (icon in browser tab)
- Moved home GitHub repository from <https://github.com/ismayc/moderndiver-book/> to <https://github.com/moderndive/moderndive_book>



# ModernDive 0.2.0

## Content changes

* Incorporated feedback from consultations with Prof. Yana Weinstein, cognitive psychological scientist and co-founder of [The Learning Scientists](http://www.learningscientists.org/yana-weinstein/).
* Restructured/revamped chapters
    + **Chapter 1: Introduction**
        + Friendlier introduction targeted to students is first thing users see. Followed then by introduction  for instructors, ways to connect/contribute, and technical details.
        + Added links to example student projects from two courses that have previously used ModernDive:
            + Middlebury College [MATH 116 Introduction to Statistical and Data Sciences](https://rudeboybert.github.io/MATH116/PS/final_project/final_project_outline.html#past_examples) using student collected data.
            + Pacific University [SOC 301 Social Statistics](https://ismayc.github.io/soc301_s2017/group-projects/index.html) using data from the [fivethirtyeight R package](https://cran.r-project.org/web/packages/fivethirtyeight/vignettes/fivethirtyeight.html)
    + **Chapter 2: Getting Started** New chapter added meant for new R users/coders, including
        + Discussions on R vs RStudio and how to install both (with support videos)
        + A "How do I code in R?" section with links to [DataCamp.com](https://www.datacamp.com/) courses that covers the console, data types, vectors, factors, data frames, boolean operators, functions etc
        + Thorough discussion on R packages
        + An end-to-end starter example analysis of the data frames in the `nycflights13` package using the console, `View()`, `glimpse()` etc.
    + **Chapter 3: Data Visualization via `ggplot2`** now first non-intro chapter.
        + Replaced Menard's "Napolean's March on Moscow" with Hans Rosling's (RIP) "Gapminder" plots as introductory example to Grammar of Graphics.
        + Added `geom_col()` for making barcharts when data is pre-tabulated, instead of using `geom_bar(stat="identity")` 
    + **Chapter 4: Tidy Data via `tidyr`** bumped back. Added sections on converting from wide to long/tidy format and importing CSV's
    + **Chapter 5: Data ~~Manipulation~~ Wrangling via `dplyr`**
    + **Chapter 6: Data Modeling using Regression via `broom`** bumped up from end of book to here given its pedagogical importance, added notes on viewing regression in a prediction framework.
    + **Chapter 7-9: Sampling, Hypothesis Testing, Confidence Intervals** Mostly unchanged for now; see pending changes section below.

## Technical changes

* Book is now hosted on [ModernDive.com](https://moderndive.com/)
* Development version now on original ModernDive site [https://ismayc.github.io/moderndiver-book/](https://ismayc.github.io/moderndiver-book/)
* Added links to digital copies and source code of all past versions of ModernDive in Chapter 1.
* Cut build/compilation time of book from ~20 minutes to ~1 minute
* Disabled gitbook PDF output

## Pending changes for next version

* **Chapter 6: Data Modeling using Regression via `broom`**
    + Better treatment of experimental design and its effect on bias/causation than currently exists in chapter.
    + Examples of regression with categorical predictors with 3 or more levels.
    + Multivariate regression, in particular the following predictor scenarios: 2 numerical, 2 categorical, and 1 numerical + 1 categorical
    + Interaction effects
* **Chapter 7-9: Sampling, Hypothesis Testing, Confidence Intervals** have largely not been updated, pending developments of [`infer`: A tidyverse-friendly R package fo statistical inference](https://github.com/andrewpbray/infer)



# ModernDive 0.1.3

* Attempting to fix Shiny app in Figure 6.2 appearing as white box in published site noted [here](https://github.com/moderndive/moderndive_book/issues/2)
    * Reverted to using screenshot with link instead
* Updated link to `dplyr` [cheatsheet](https://github.com/rstudio/cheatsheets/raw/master/source/pdfs/data-transformation-cheatsheet.pdf) and `ggplot2` [cheatsheet](https://www.rstudio.com/wp-content/uploads/2016/11/ggplot2-cheatsheet-2.1.pdf)
* Began adding DataCamp chapters as Review Questions to the end of Chapters 3 and 4 (More to come)
* Updated link to MailChimp
* Fixed wording in a few Ch 3 Learning Checks



# ModernDive 0.1.2

* Converted last updated in index.Rmd to inline instead of R chunk
* Fixed edit link to point to moderndive-book GitHub repo instead of moderndive-source repo
* Fixed broken links to script files at the end of Chapters 4-9
* Added `purl=FALSE` to chunks that do not contain useful code to the reader
* Attempting to fix Shiny app in Figure 6.2 appearing as white box in published site noted [here](https://github.com/moderndive/moderndive_book/issues/2)



# ModernDive 0.1.1

* Fixed the problems of chapter cross-references not working by removing the backticks in chapter names
    + Issue created on `bookdown` [here](https://github.com/rstudio/bookdown/issues/294)
* Looked for typos throughout all chapters
* Added coggle diagrams to Chapter 4 and Appendix B
* Followed the same format of having a Conclusion section at the end of each chapter
* Fixed $T$ distribution plot with histogram in Chapter 7
    + May be weird issue with `cache = TRUE` that incorrectly plotted values on 1/10^th^ the correct scale
    + Will need to keep an eye on it going forward
* Fixed typo on Reach for the Stars chapter name



# ModernDive 0.1.0

* Fiat Lux!
* Basic chapter structure in place
* First pass at II Inference section (Chapters 6-9) complete
* First revisions of I Data Exploration (Chapters 3-5) nearly complete
