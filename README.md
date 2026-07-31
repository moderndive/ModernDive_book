# ModernDive <img src="images/logos/hex_blue_text.png" align="right" width=125 />

[![DOI](https://zenodo.org/badge/66818484.svg)](https://zenodo.org/badge/latestdoi/66818484) [![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable) [![GitHub Actions Deployment](https://github.com/moderndive/ModernDive_book/actions/workflows/quarto-publish.yml/badge.svg)](https://github.com/moderndive/ModernDive_book/actions/workflows/quarto-publish.yml)

Welcome to the GitHub repository page for **Statistical Inference via Data Science: A ModernDive into R and the Tidyverse**.

* **Second Edition (current):** [moderndive.com/v2/](https://moderndive.com/v2/) — also available in print from [CRC Press](https://www.routledge.com/Statistical-Inference-via-Data-Science-A-ModernDive-into-R-and-the-Tidyverse/Ismay-Kim-Valdivia/p/book/9781032708379).
* **First Edition (archived):** [moderndive.com](https://moderndive.com/).

<img src="images/logos/v2_cover.jpg" width="50%"/>


## Branches and Source

The book has been migrated from `bookdown` to **[Quarto](https://quarto.org/)**. As of v2.1.0, the live build pipeline uses Quarto.

| Branch | Source format | Status | Deploys to |
|---|---|---|---|
| `v2-quarto-html` | Quarto (`.qmd`) | **Active development** for the next release of the Second Edition. | `v2-publish` branch (preview). |
| `v2` | bookdown (`.Rmd`) | Canonical build of the Second Edition currently served at moderndive.com/v2/. Will be superseded by `v2-quarto-html` after merge. | `gh-pages/v2/` (live: [moderndive.com/v2/](https://moderndive.com/v2/)). |
| `master` | bookdown (`.Rmd`) | First Edition source. | `gh-pages` (live: [moderndive.com](https://moderndive.com/)). |

The source for [previously released versions](https://moderndive.com/index.html#about-book) is on the [Releases](https://github.com/moderndive/ModernDive_book/releases) page. A summary of all changes between versions is in [NEWS.md](https://github.com/moderndive/ModernDive_book/blob/v2/NEWS.md).


## Building the Book Locally

To render the Second Edition locally from the `v2-quarto-html` branch:

1. Install [Quarto](https://quarto.org/docs/get-started/) (≥ 1.4).
2. Install R (the build was developed against R 4.5.2).
3. From the repo root, run `renv::restore()` to set up the locked R package environment.
4. Run `quarto preview` for live reload, or `quarto render` for a one-shot HTML build into `docs/`.

The `master` branch (First Edition) still uses `bookdown`; building it requires `install.packages("bookdown")` and `bookdown::render_book("index.Rmd")`.


## More Information

* The [`moderndive`](https://moderndive.github.io/moderndive/) R package — datasets, helpers, and `get_regression_*()` functions used throughout the book.
* The [instructor resources page](http://moderndive.com/labs) with sample problem sets and term projects.
* Sign up for the [mailing list](http://eepurl.com/cBkItf) for periodic ModernDive updates (roughly every 3 months).
