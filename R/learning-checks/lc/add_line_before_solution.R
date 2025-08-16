file_path <- "R/lc-answers/02_lc-answers.Rmd"
lines <- readLines(file_path, warn = FALSE)

lines_new <- unlist(lapply(seq_along(lines), function(i) {
  if (grepl("^\\*\\*Solution\\*\\*:", lines[i])) {
    # If the previous line isn't already blank, insert a blank line first
    if (i > 1 && nzchar(lines[i-1])) {
      return(c("", lines[i]))
    }
  }
  lines[i]
}))

writeLines(lines_new, "R/lc-answers/02_lc-answers_new.Rmd")
