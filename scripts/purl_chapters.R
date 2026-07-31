# Generate per-chapter R scripts from the chapter .qmd files.
#
# Port of the bookdown-era purl.R (still visible on the pre-cutover v2
# history): every rendered chapter ends with "An R script file of all R code
# used in this chapter is available ..." linking to scripts/NN-chapter.R, and
# the PDF prints the absolute https://www.moderndive.com/v2/scripts/ URL (see
# generate_r_file_link() in scripts/image_functions.R). Bookdown generated
# those files at build time; Quarto does not, so this script runs in CI after
# `quarto render` (see quarto-publish.yml) and writes them into docs/scripts/.
# Without it the /v2 deploy's clean:true would delete the bookdown-era copies
# and every chapter's script link would 404.
#
# knitr::purl() respects the chunks' purl=TRUE/FALSE options, so readers get
# exactly the code the chapters show, minus the purl=FALSE scaffolding.

chapter_qmds <- list.files(pattern = "^(0[1-9]|1[01])-.*\\.qmd$")
stopifnot(length(chapter_qmds) == 11)

out_dir <- file.path("docs", "scripts")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

for (qmd in chapter_qmds) {
  out <- file.path(out_dir, sub("\\.qmd$", ".R", qmd))
  knitr::purl(qmd, output = out, quiet = TRUE)
  message("purled ", qmd, " -> ", out)
}
