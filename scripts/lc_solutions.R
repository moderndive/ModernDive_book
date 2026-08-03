# Inline Learning Check solutions.
#
# Solutions are authored in lc-answers/NN_lc-answers.qmd, one block per Learning
# Check, each introduced by a "**(LCc.n)**" marker. Historically the whole file
# was pulled into the Learning Check Solutions appendix as a child document.
# This script parses the same files into per-LC fragments so a chapter can show
# each solution as a collapsible callout directly beneath its question.
#
# The answers files stay the single source of truth: nothing here duplicates
# solution prose, and adding a Learning Check needs no change to this script.

lc_cache <- new.env(parent = emptyenv())

lc_answers_path <- function(chap) sprintf("lc-answers/%02d_lc-answers.qmd", chap)

# Split one chapter's answers file into its preamble and its per-LC blocks.
lc_parse <- function(chap) {
  key <- as.character(chap)
  cached <- lc_cache[[key]]
  if (!is.null(cached)) return(cached)

  path <- lc_answers_path(chap)
  if (!file.exists(path)) stop("no Learning Check answers file at ", path)
  lines <- readLines(path, warn = FALSE)

  starts <- grep("^\\*\\*\\(LC[0-9]+\\.[0-9]+\\)\\*\\*", lines)
  if (!length(starts)) stop("no LC markers found in ", path)

  nums <- as.integer(sub("^\\*\\*\\(LC[0-9]+\\.([0-9]+)\\).*$", "\\1", lines[starts]))
  if (!identical(nums, seq_along(nums)))
    stop(sprintf("LC numbers in %s are not 1..n in order: %s",
                 path, paste(nums, collapse = ", ")))

  ends <- c(starts[-1] - 1L, length(lines))
  blocks <- lapply(seq_along(starts), function(i) lines[starts[i]:ends[i]])
  names(blocks) <- as.character(nums)

  # Anything ahead of the first marker is the answers file's own setup. It is
  # not only library() calls: ch04 reads dem_score from CSV, and ch05/ch06 build
  # the UN_data_* and credit_ch6 frames their solutions go on to use.
  preamble <- if (starts[1] > 1L) lines[seq_len(starts[1] - 1L)] else character()

  parsed <- list(preamble = preamble, blocks = blocks)
  lc_cache[[key]] <- parsed
  parsed
}

# Drop the restated question stem, keeping everything else. Inline, the question
# sits directly above the callout, so repeating the stem is noise.
#
# Only the stem goes: the leading paragraph, up to the first blank line. What
# follows it is answer material even when it precedes the **Solution** marker --
# LC3.7's chunk recreating by_monthly_origin *is* the answer, and LC3.5's table
# is what its answer discusses. Cutting to the marker would silently drop both.
lc_body <- function(block, chap, n) {
  if (!any(grepl("\\*\\*Solution(\\*\\*:|:\\*\\*)", block)))
    stop(sprintf("LC%d.%d has no **Solution** marker", chap, n))

  blank <- which(!nzchar(trimws(block)))
  body <- if (length(blank)) block[(blank[1] + 1L):length(block)] else block[-1]

  while (length(body) && !nzchar(trimws(body[1])))
    body <- body[-1]
  while (length(body) && !nzchar(trimws(body[length(body)])))
    body <- body[-length(body)]

  # The callout is already titled "Solution", so drop a leading marker rather
  # than saying it twice. Only when it leads: in LC3.5 and LC3.7 the marker sits
  # further down, after setup, where it usefully separates setup from answer.
  if (length(body))
    body[1] <- sub("^\\s*\\*\\*Solution(\\*\\*:|:\\*\\*)\\s*", "", body[1])
  while (length(body) && !nzchar(trimws(body[1])))
    body <- body[-1]

  body
}

# Run the answers file's setup inside the chapter's own knit session, and throw
# the rendered output away: the reader has already seen the chapter's setup, but
# the objects it defines have to exist before any solution runs.
#
# envir = knit_global() is load-bearing. knit_child() defaults to parent.frame(),
# which here is this function's frame, so the objects would be created and then
# discarded with it.
lc_setup <- function(chap) {
  preamble <- lc_parse(chap)$preamble
  if (!length(preamble)) return(invisible(character()))
  invisible(knitr::knit_child(
    text = paste(preamble, collapse = "\n"),
    envir = knitr::knit_global(),
    quiet = TRUE
  ))
}

# Render one solution as a collapsed callout. Call from a results='asis' chunk.
lc_solution <- function(chap, n) {
  parsed <- lc_parse(chap)
  block <- parsed$blocks[[as.character(n)]]
  if (is.null(block))
    stop(sprintf("no solution authored for LC%d.%d", chap, n))

  fragment <- c(
    '::: {.callout-tip collapse="true"}',
    '## Solution',
    '',
    lc_body(block, chap, n),
    '',
    ':::',
    ''
  )
  knitr::knit_child(
    text = paste(fragment, collapse = "\n"),
    envir = knitr::knit_global(),
    quiet = TRUE
  )
}

# Standalone check that every chapter's questions and answers line up. Run with
#   Rscript scripts/lc_solutions.R --self-test
lc_self_test <- function() {
  chapter_file <- function(chap) {
    hits <- list.files(".", pattern = sprintf("^%02d-.*\\.qmd$", chap))
    if (length(hits) != 1L) stop("cannot resolve chapter file for ", chap)
    hits
  }
  ok <- TRUE
  for (chap in 1:11) {
    parsed <- lc_parse(chap)
    n_ans <- length(parsed$blocks)
    n_qs <- sum(grepl("lc <- lc + 1", readLines(chapter_file(chap), warn = FALSE), fixed = TRUE))
    match <- n_ans == n_qs
    ok <- ok && match
    cat(sprintf("  ch%02d: %2d questions, %2d solutions %s\n",
                chap, n_qs, n_ans, if (match) "ok" else "MISMATCH"))
    for (n in seq_len(n_ans)) lc_body(parsed$blocks[[as.character(n)]], chap, n)
  }
  cat(if (ok) "✓ self-test: every Learning Check has exactly one solution\n"
      else "✗ self-test: question/solution counts disagree\n")
  invisible(ok)
}

if (!interactive() && "--self-test" %in% commandArgs(trailingOnly = TRUE)) {
  quit(status = if (isTRUE(lc_self_test())) 0L else 1L)
}
