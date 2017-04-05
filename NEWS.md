# ModernDive 0.1.3.9000
* Add license to Preamble
* Added ggplot2 Review and dplyr DataCamp links
* Fix typos
* Fixed $T$ distribution plot with histogram in Chapter 7
  * Based on [issue](https://github.com/ismayc/moderndiver-book/issues/3) that identified the use of the wrong data set for resampling

# ModernDive 0.1.3

* Attempting to fix Shiny app in Figure 6.2 appearing as white box in published site noted [here](https://github.com/ismayc/moderndiver-book/issues/2)
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
* Attempting to fix Shiny app in Figure 6.2 appearing as white box in published site noted [here](https://github.com/ismayc/moderndiver-book/issues/2)

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

* Basic chapter structure in place
* First pass at II Inference section (Chapters 6-9) complete
* First revisions of I Data Exploration (Chapters 3-5) nearly complete