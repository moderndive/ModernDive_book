#!/usr/bin/env Rscript
# Figure alt-text audit for ModernDive.
#
# Detects three figure patterns and audits alt-text presence/quality:
#   (1) `fig.alt = "..."` inside an R or webr chunk header (chunk produces a fig)
#   (2) `![alt](path)` markdown image syntax
#   (3) `include_graphics()` / `knitr::include_graphics()` calls inside a chunk
#       — alt text must live on the *enclosing chunk's* `fig.alt=` option
#
# Flags:
#   MISSING — figure shown with no alt text reachable
#   EMPTY   — alt text present but empty (`![](...)` or `fig.alt = ""`)
#   SHORT   — alt text < 25 characters (typically not descriptive enough)
#   CAPTION — alt text identical to fig.cap (alt should describe the *visual*,
#             not duplicate the caption — they have different jobs)

suppressPackageStartupMessages({
  library(stringr)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
setwd(book)

qmd_files <- list.files(".", pattern = "\\.qmd$", full.names = FALSE)
qmd_files <- qmd_files[!grepl("^(96|99|index)", qmd_files)]  # skip glossary/refs/index home
qmd_files <- sort(qmd_files)

# Parse a chunk header line like ```{r label, fig.alt="...", fig.cap="..."}
# and extract fig.alt + fig.cap. Naive but works for the book's conventions.
parse_chunk_header <- function(line) {
  if (!grepl("^```\\{", line)) return(NULL)
  # Extract fig.alt
  m_alt <- str_match(line, "fig\\.alt\\s*=\\s*\"((?:[^\"\\\\]|\\\\.)*)\"")
  m_alt2 <- str_match(line, "fig\\.alt\\s*=\\s*'((?:[^'\\\\]|\\\\.)*)'")
  m_cap <- str_match(line, "fig\\.cap\\s*=\\s*\"((?:[^\"\\\\]|\\\\.)*)\"")
  m_label <- str_match(line, "^```\\{(?:r|webr-r)\\s+([A-Za-z0-9_-]+)")
  alt <- if (!is.na(m_alt[1, 2])) m_alt[1, 2] else if (!is.na(m_alt2[1, 2])) m_alt2[1, 2] else NA
  cap <- if (!is.na(m_cap[1, 2])) m_cap[1, 2] else NA
  label <- if (!is.na(m_label[1, 2])) m_label[1, 2] else NA
  list(alt = alt, cap = cap, label = label, raw = line)
}

# Classify chunk header: does this chunk *render* a figure?
# Rules:
#   - Reject `{webr-r}` chunks (interactive widgets, not static figures rendered to alt-text)
#   - Reject `eval=FALSE` chunks (they're code-display chunks)
#   - Reject `purl=FALSE` chunks that have neither `fig.cap=` nor body content that
#     visibly produces a figure (these are usually internal setup)
chunk_renders_figure <- function(header_line, body) {
  if (grepl("^```\\{webr-r", header_line)) return(FALSE)
  if (grepl("eval\\s*=\\s*FALSE", header_line)) return(FALSE)
  if (grepl("include\\s*=\\s*FALSE", header_line)) return(FALSE)
  # fig.show='hide' / fig.show="hide" — the figure is generated but not shown
  if (grepl("fig\\.show\\s*=\\s*['\"]hide['\"]", header_line)) return(FALSE)
  txt <- paste(body, collapse = "\n")
  grepl(
    "\\binclude_graphics\\(|\\bggsave\\(|knitr::include_graphics|\\bgrid\\.arrange\\(|gridExtra::grid\\.arrange\\(|\\bcowplot::(plot_grid|draw_)|\\bpatchwork::|\\bplot_layout\\(|\\bgganimate|geom_|\\bplot\\(|\\bbarplot\\(|\\bhist\\(|\\bvisualize\\(",
    txt
  )
}

flags <- list()
chunk_count <- 0
md_img_count <- 0

for (f in qmd_files) {
  lines <- readLines(f, warn = FALSE)
  in_chunk <- FALSE
  in_html_comment <- FALSE
  chunk_header_idx <- NA_integer_
  chunk_header_parse <- NULL
  chunk_body <- character()
  for (i in seq_along(lines)) {
    l <- lines[i]
    # Track multi-line HTML comments — markdown images inside them never render
    if (!in_chunk) {
      if (!in_html_comment && grepl("<!--", l) && !grepl("-->", l)) {
        in_html_comment <- TRUE
        next
      }
      if (in_html_comment) {
        if (grepl("-->", l)) in_html_comment <- FALSE
        next
      }
    }
    if (!in_chunk && grepl("^```\\{", l)) {
      in_chunk <- TRUE
      chunk_header_idx <- i
      chunk_header_parse <- parse_chunk_header(l)
      chunk_body <- character()
    } else if (in_chunk && grepl("^```\\s*$", l)) {
      # End of chunk — audit it
      if (chunk_renders_figure(chunk_header_parse$raw, chunk_body)) {
        chunk_count <- chunk_count + 1
        alt <- chunk_header_parse$alt
        cap <- chunk_header_parse$cap
        label <- chunk_header_parse$label
        # Determine flag
        if (is.na(alt)) {
          flags[[length(flags) + 1]] <- list(
            file = f, line = chunk_header_idx, kind = "chunk",
            flag = "MISSING", label = label, alt = NA_character_, cap = cap,
            header = chunk_header_parse$raw
          )
        } else if (alt == "") {
          flags[[length(flags) + 1]] <- list(
            file = f, line = chunk_header_idx, kind = "chunk",
            flag = "EMPTY", label = label, alt = "", cap = cap,
            header = chunk_header_parse$raw
          )
        } else {
          if (nchar(alt) < 25) {
            flags[[length(flags) + 1]] <- list(
              file = f, line = chunk_header_idx, kind = "chunk",
              flag = "SHORT", label = label, alt = alt, cap = cap,
              header = chunk_header_parse$raw
            )
          }
          if (!is.na(cap) && !is.na(alt) && tolower(trimws(alt)) == tolower(trimws(cap))) {
            flags[[length(flags) + 1]] <- list(
              file = f, line = chunk_header_idx, kind = "chunk",
              flag = "CAPTION", label = label, alt = alt, cap = cap,
              header = chunk_header_parse$raw
            )
          }
        }
      }
      in_chunk <- FALSE
      chunk_body <- character()
    } else if (in_chunk) {
      chunk_body <- c(chunk_body, l)
    } else {
      # Outside any chunk: look for markdown images ![alt](path)
      img_matches <- str_match_all(l, "!\\[([^\\]]*)\\]\\(([^)\\s]+)(?:\\s+[^)]*)?\\)")[[1]]
      if (nrow(img_matches) > 0) {
        for (k in seq_len(nrow(img_matches))) {
          md_img_count <- md_img_count + 1
          alt <- img_matches[k, 2]
          src <- img_matches[k, 3]
          if (nchar(alt) == 0) {
            flags[[length(flags) + 1]] <- list(
              file = f, line = i, kind = "markdown-img",
              flag = "EMPTY", label = src, alt = "", cap = NA,
              header = trimws(l)
            )
          } else if (nchar(alt) < 25) {
            flags[[length(flags) + 1]] <- list(
              file = f, line = i, kind = "markdown-img",
              flag = "SHORT", label = src, alt = alt, cap = NA,
              header = trimws(l)
            )
          }
        }
      }
    }
  }
}

# Summary
cat(sprintf("Scanned %d chapter qmd files.\n", length(qmd_files)))
cat(sprintf("  Figure-producing code chunks: %d\n", chunk_count))
cat(sprintf("  Markdown images (`![...](...)`): %d\n", md_img_count))
cat(sprintf("  Total flags: %d\n\n", length(flags)))

# Bucket
buckets <- list(MISSING = list(), EMPTY = list(), SHORT = list(), CAPTION = list())
for (f in flags) buckets[[f$flag]] <- c(buckets[[f$flag]], list(f))

for (b in c("MISSING", "EMPTY", "SHORT", "CAPTION")) {
  cat(sprintf("=== %s (%d) ===\n", b, length(buckets[[b]])))
  if (length(buckets[[b]])) {
    by_file <- split(buckets[[b]], sapply(buckets[[b]], function(x) x$file))
    for (file in names(by_file)) {
      cat(sprintf("\n  [%s]  (%d flags)\n", file, length(by_file[[file]])))
      for (fl in by_file[[file]]) {
        snippet <- substr(fl$header, 1, 140)
        label_or_src <- if (is.na(fl$label)) "(no label)" else fl$label
        if (b == "CAPTION") {
          cat(sprintf("    L%-5d %s — alt==cap=%s\n",
                      fl$line, label_or_src, substr(fl$alt, 1, 100)))
        } else if (b == "SHORT") {
          cat(sprintf("    L%-5d %s [%d chars] -> %s\n",
                      fl$line, label_or_src, nchar(fl$alt), fl$alt))
        } else if (b == "EMPTY") {
          cat(sprintf("    L%-5d %s\n",
                      fl$line, label_or_src))
        } else { # MISSING
          cat(sprintf("    L%-5d %s\n      %s\n",
                      fl$line, label_or_src, snippet))
        }
      }
    }
  }
  cat("\n")
}

cat("========== DONE ==========\n")
