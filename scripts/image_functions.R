# Cross-chapter constants. In bookdown these were defined once in index.Rmd
# and shared via the merged knit session; in Quarto each chapter is its own
# R session, so they're defined here and sourced by every chapter.
version <- "2.1.0"           # current online build
date <- "April 27, 2026"     # date of the current online build
# `latest_release_*` refers specifically to the CRC Press print edition,
# which corresponds to v2.0.0 — used in 00-preface.qmd.
latest_release_version <- "2.0.0"
latest_release_date <- "March 20, 2025"
dev_version <- FALSE

needed_CRAN_pkgs <- c(
  "dygraphs", "fivethirtyeight", "gapminder", "ggplot2movies", "infer",
  "ISLR2", "janitor", "knitr", "moderndive", "nycflights23", "scales",
  "tidyverse", "broom", "gridExtra", "GGally",
  "devtools", "ggrepel", "here", "kableExtra", "mvtnorm", "patchwork",
  "remotes", "rmarkdown", "sessioninfo", "viridis", "webshot"
)

generate_r_file_link <- function(file) {
  if (is_html_output()) {
    cat(glue::glue("An R script file of all R code used in this chapter is available [here](scripts/{file})."))
  } else if (is_latex_output()) {
    cat(glue::glue("An R script file of all R code used in this chapter is available at <https://www.moderndive.com/v2/scripts/{file}>."))
  }
}

include_image <- function(path,
                          html_opts = "width=45%",
                          latex_opts = html_opts,
                          alt_text = "") {
  if (is_html_output()) {
    glue::glue("![{alt_text}]({path}){{ {html_opts} }}")
  } else if (is_latex_output()) {
    glue::glue("![{alt_text}]({path}){{ {latex_opts} }}")
  }
}

image_link <- function(path,
                       link,
                       html_opts = "height: 200px;",
                       latex_opts = "width=0.2\\textwidth",
                       alt_text = "",
                       centering = TRUE) {
  if (is_html_output()) {
    if (centering) {
      glue::glue(
        '<center><a target="_blank" class="page-link" href="{link}"><img src="{path}" style="{html_opts}"/></a></center>'
      )
    } else {
      glue::glue(
        '<a target="_blank" class="page-link" href="{link}"><img src="{path}" style="{html_opts}"/></a>'
      )
    }
  }
  else if (is_latex_output()) {
    if (centering) {
      glue::glue("\\begin{{center}}
        \\href{{{link}}}{{\\includegraphics[{latex_opts}]{{{path}}}}}
        \\end{{center}}")
    } else {
      glue::glue("\\href{{{link}}}{{\\includegraphics[{latex_opts}]{{{path}}}}}")
    }
  }
}
