#!/usr/bin/env Rscript
# Teaching diagrams generator
#
# Produces 8 instructor-quality diagrams for the concepts that students
# most often misunderstand. Each diagram is saved as BOTH:
#   * .svg  — vector format, scales infinitely; use in slides & print
#   * .png  — raster @ 144 dpi; for inline preview & quick screenshots
#
# Output dir: instructor-solutions/_site/diagrams/
# Linked from instructor-solutions/diagrams.qmd
#
# Run:  Rscript scripts/build_diagrams.R

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(patchwork)
})

book <- "/Users/chesterismay/Desktop/repos/ModernDive_book"
if (dir.exists(book)) setwd(book)

out_dir <- "instructor-solutions/_site/diagrams"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# Consistent visual identity — ModernDive navy / blue / green palette,
# uniform fonts, clean grids, large legible titles.
theme_md <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", color = "#1F3A6B", size = base_size + 2),
      plot.subtitle = element_text(color = "#444", size = base_size),
      strip.text = element_text(face = "bold", color = "#1F3A6B"),
      strip.background = element_rect(fill = "#EEF6FF", color = NA),
      legend.position = "bottom",
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA)
    )
}

save_diagram <- function(p, name, width = 10, height = 6) {
  svg_path <- file.path(out_dir, paste0(name, ".svg"))
  png_path <- file.path(out_dir, paste0(name, ".png"))
  ggsave(svg_path, p, width = width, height = height, device = "svg", bg = "white")
  ggsave(png_path, p, width = width, height = height, device = "png", dpi = 144, bg = "white")
  cat(sprintf("  wrote %s.svg + %s.png\n", name, name))
}

# ============================================================
# 1. Sampling distribution vs bootstrap distribution
# ============================================================
diagram_sampling_vs_bootstrap <- function() {
  cat("[1] sampling vs bootstrap\n")
  set.seed(42)

  population <- rnorm(50000, mean = 100, sd = 15)
  many_means <- replicate(2000, mean(sample(population, 30)))

  set.seed(100)
  one_sample <- sample(population, 30)
  boot_means <- replicate(2000, mean(sample(one_sample, replace = TRUE)))

  d <- bind_rows(
    data.frame(value = many_means, type = "Sampling distribution"),
    data.frame(value = boot_means, type = "Bootstrap distribution")
  )
  d$type <- factor(d$type, levels = c("Sampling distribution", "Bootstrap distribution"))

  # Range for shared x-axis so the two are directly comparable
  xrng <- range(d$value)

  p1 <- ggplot(filter(d, type == "Sampling distribution"), aes(x = value)) +
    geom_histogram(fill = "#1A6FBE", color = "white", bins = 35) +
    geom_vline(xintercept = mean(many_means), linetype = "dashed", color = "#1F3A6B", linewidth = 1) +
    annotate("text", x = mean(many_means), y = Inf, label = sprintf("mean = %.1f", mean(many_means)),
             color = "#1F3A6B", hjust = -0.1, vjust = 2, fontface = "bold", size = 4) +
    xlim(xrng) +
    labs(
      title = "Sampling distribution",
      subtitle = "Many samples of n=30 from the population; each gives one x̄",
      x = "Sample mean (x̄)", y = "Count"
    ) +
    theme_md()

  p2 <- ggplot(filter(d, type == "Bootstrap distribution"), aes(x = value)) +
    geom_histogram(fill = "#76BC43", color = "white", bins = 35) +
    geom_vline(xintercept = mean(boot_means), linetype = "dashed", color = "#2E6E1A", linewidth = 1) +
    annotate("text", x = mean(boot_means), y = Inf, label = sprintf("mean = %.1f", mean(boot_means)),
             color = "#2E6E1A", hjust = -0.1, vjust = 2, fontface = "bold", size = 4) +
    xlim(xrng) +
    labs(
      title = "Bootstrap distribution",
      subtitle = "One sample of n=30, resampled w/ replacement → 2000 x̄*'s",
      x = "Bootstrap mean (x̄*)", y = "Count"
    ) +
    theme_md()

  combined <- (p1 | p2) +
    plot_annotation(
      title = "Sampling vs bootstrap distribution",
      subtitle = "Same approximate shape & spread — but built from very different inputs",
      caption = "Population: N(100, 15). 2000 sample means in each panel.",
      theme = theme(
        plot.title = element_text(face = "bold", color = "#1F3A6B", size = 16),
        plot.subtitle = element_text(color = "#444", size = 12),
        plot.caption = element_text(color = "#666", size = 9)
      )
    )

  save_diagram(combined, "01_sampling_vs_bootstrap", width = 13, height = 5.2)
}

# ============================================================
# 2. 95% CI coverage in repeated sampling
# ============================================================
diagram_ci_coverage <- function() {
  cat("[2] 95% CI coverage\n")
  set.seed(42)
  mu <- 50; sigma <- 10
  n_samples <- 100
  n <- 30

  sims <- t(replicate(n_samples, {
    s <- rnorm(n, mu, sigma)
    m <- mean(s); se <- sd(s) / sqrt(n)
    c(lower = m - 1.96*se, upper = m + 1.96*se, mean = m)
  }))
  df <- as.data.frame(sims)
  df$id <- seq_len(n_samples)
  df$covers <- df$lower <= mu & df$upper >= mu
  df$status <- ifelse(df$covers, "contains μ", "misses μ")

  n_miss <- sum(!df$covers)
  n_cov  <- sum(df$covers)

  p <- ggplot(df, aes(y = id)) +
    geom_segment(aes(x = lower, xend = upper, yend = id, color = status), linewidth = 0.55, alpha = 0.85) +
    geom_point(aes(x = mean, color = status), size = 0.9) +
    geom_vline(xintercept = mu, color = "#1F3A6B", linewidth = 0.9) +
    annotate("text", x = mu, y = n_samples + 4, label = "true population μ = 50",
             color = "#1F3A6B", fontface = "bold", size = 4.2, hjust = -0.05) +
    scale_color_manual(values = c("contains μ" = "#76BC43", "misses μ" = "#CC3333")) +
    scale_y_continuous(breaks = c(1, 25, 50, 75, 100)) +
    labs(
      title = "What '95% confidence' actually means",
      subtitle = sprintf("100 repeated samples (n=30), each with a 95%% CI for the mean — %d contain μ, %d miss",
                         n_cov, n_miss),
      x = "Confidence interval (x̄ ± 1.96·SE)",
      y = "Sample (1 to 100)",
      color = NULL,
      caption = "The 95% refers to the procedure — not to any single CI being '95% likely' to contain μ."
    ) +
    theme_md() +
    theme(plot.caption = element_text(color = "#666", size = 9))

  save_diagram(p, "02_ci_coverage", width = 11, height = 8)
}

# ============================================================
# 3. CLT in action (skewed population → normal sampling dist as n grows)
# ============================================================
diagram_clt <- function() {
  cat("[3] CLT in action\n")
  set.seed(42)

  pop <- data.frame(x = rexp(50000, rate = 0.05))  # Heavily right-skewed
  pop_mean <- mean(pop$x)

  ns <- c(5, 30, 100, 500)
  draws <- function(n, k = 3000) {
    data.frame(
      n = factor(paste("n =", n), levels = paste("n =", ns)),
      sample_mean = replicate(k, mean(sample(pop$x, n, replace = TRUE)))
    )
  }
  dist_df <- bind_rows(lapply(ns, draws))

  pop_plot <- ggplot(filter(pop, x < 100), aes(x = x)) +
    geom_histogram(fill = "#888", color = "white", bins = 60) +
    geom_vline(xintercept = pop_mean, linetype = "dashed", color = "#1F3A6B", linewidth = 0.8) +
    annotate("text", x = pop_mean, y = Inf, label = sprintf("population mean μ ≈ %.0f", pop_mean),
             color = "#1F3A6B", hjust = -0.1, vjust = 2, fontface = "bold", size = 4) +
    labs(title = "Population (highly right-skewed exponential)",
         x = "Value", y = "Count") +
    theme_md()

  sd_plot <- ggplot(dist_df, aes(x = sample_mean, fill = n)) +
    geom_histogram(color = "white", bins = 45) +
    facet_wrap(~ n, ncol = 4, scales = "free") +
    scale_fill_manual(values = c("n = 5" = "#FFB347", "n = 30" = "#4D93D3",
                                  "n = 100" = "#76BC43", "n = 500" = "#1F3A6B"),
                      guide = "none") +
    labs(title = "Sampling distribution of x̄ across 3000 samples",
         subtitle = "Even with a skewed population, x̄'s distribution becomes more normal as n grows",
         x = "Sample mean (x̄)", y = "Count") +
    theme_md()

  combined <- pop_plot / sd_plot +
    plot_layout(heights = c(1, 2)) +
    plot_annotation(
      title = "The Central Limit Theorem in action",
      caption = "Same skewed population, four different sample sizes. The bell shape emerges from the sampling process, not the data.",
      theme = theme(
        plot.title = element_text(face = "bold", color = "#1F3A6B", size = 16),
        plot.caption = element_text(color = "#666", size = 9)
      )
    )

  save_diagram(combined, "03_clt", width = 12, height = 8)
}

# ============================================================
# 4. Regression: observed = fitted + residual
# ============================================================
diagram_residuals <- function() {
  cat("[4] regression residuals\n")
  set.seed(7)
  d <- data.frame(x = c(1, 2, 3, 4, 5, 6, 7, 8))
  d$y <- 1.5 + 1.7 * d$x + c(-0.6, 1.4, -0.8, 0.9, -1.4, 1.1, -0.4, 1.3)
  fit <- lm(y ~ x, d)
  d$fitted <- predict(fit)
  d$resid  <- d$y - d$fitted

  # Pick one point to annotate explicitly
  hi <- which.max(abs(d$resid))

  p <- ggplot(d, aes(x = x, y = y)) +
    geom_segment(aes(xend = x, yend = fitted), color = "#CC3333",
                 linetype = "dashed", linewidth = 0.7) +
    geom_abline(slope = coef(fit)["x"], intercept = coef(fit)["(Intercept)"],
                color = "#1F3A6B", linewidth = 1.1) +
    geom_point(aes(y = fitted), size = 3, color = "#1A6FBE", shape = 1, stroke = 1.1) +
    geom_point(size = 3.2, color = "#1F3A6B") +
    annotate("segment", x = d$x[hi] + 0.55, xend = d$x[hi] + 0.15,
             y = (d$y[hi] + d$fitted[hi]) / 2, yend = (d$y[hi] + d$fitted[hi]) / 2,
             arrow = arrow(length = unit(0.18, "cm")), color = "#CC3333") +
    annotate("text", x = d$x[hi] + 0.6, y = (d$y[hi] + d$fitted[hi]) / 2,
             label = sprintf("residual = y − ŷ = %.2f", d$resid[hi]),
             color = "#CC3333", hjust = 0, fontface = "bold", size = 4.2) +
    annotate("text", x = 1, y = max(d$y) - 0.3,
             label = expression(hat(y) == b[0] + b[1]~x),
             color = "#1F3A6B", hjust = 0, size = 5) +
    annotate("text", x = 1, y = max(d$y) - 1.6,
             label = "● observed (y)\n○ fitted (ŷ)\n– – residual (e)",
             color = "#444", hjust = 0, size = 3.8, lineheight = 1.3) +
    labs(
      title = "Observed = fitted + residual",
      subtitle = expression("Each point's vertical distance from the regression line is its residual" ~ e == y - hat(y)),
      x = "x", y = "y"
    ) +
    theme_md()

  save_diagram(p, "04_regression_residuals", width = 10, height = 6.5)
}

# ============================================================
# 5. LINE diagnostic plots — what each violation looks like
# ============================================================
diagram_line <- function() {
  cat("[5] LINE diagnostic plots\n")
  set.seed(42)
  n <- 120

  # L violation — linearity (curved residuals)
  x_L <- runif(n, 0, 10)
  y_L <- 2 + 0.5 * x_L^2 + rnorm(n, sd = 3)
  fit_L <- lm(y_L ~ x_L)
  d_L <- data.frame(fitted = fitted(fit_L), resid = resid(fit_L))

  # I violation — independence (residuals over time autocorrelated)
  t <- 1:n
  noise <- arima.sim(list(ar = 0.85), n = n) * 1.5
  y_I <- 5 + 0.03 * t + as.numeric(noise)
  fit_I <- lm(y_I ~ t)
  d_I <- data.frame(t = t, resid = resid(fit_I))

  # N violation — normality (heavy-tailed residuals via t-dist)
  resids_N <- rt(n, df = 3) * 2
  d_N <- data.frame(theoretical = qnorm(ppoints(n)), sample = sort(resids_N))

  # E violation — equal variance (fan-shaped residuals)
  x_E <- runif(n, 0, 10)
  y_E <- 2 + 0.5 * x_E + rnorm(n, sd = 0.4 * x_E)
  fit_E <- lm(y_E ~ x_E)
  d_E <- data.frame(fitted = fitted(fit_E), resid = resid(fit_E))

  p_L <- ggplot(d_L, aes(x = fitted, y = resid)) +
    geom_hline(yintercept = 0, color = "gray60", linetype = "dashed") +
    geom_point(color = "#CC3333", size = 1.8, alpha = 0.7) +
    geom_smooth(se = FALSE, color = "#1F3A6B", linewidth = 0.9) +
    labs(title = "L — Linearity violated",
         subtitle = "Curved (U-shaped) pattern in residuals vs fitted",
         x = "Fitted values", y = "Residuals") +
    theme_md(base_size = 11)

  p_I <- ggplot(d_I, aes(x = t, y = resid)) +
    geom_hline(yintercept = 0, color = "gray60", linetype = "dashed") +
    geom_line(color = "#CC3333", linewidth = 0.6) +
    geom_point(color = "#CC3333", size = 1.6, alpha = 0.7) +
    labs(title = "I — Independence violated",
         subtitle = "Residuals stay positive/negative in runs (autocorrelation)",
         x = "Observation order (time)", y = "Residuals") +
    theme_md(base_size = 11)

  p_N <- ggplot(d_N, aes(x = theoretical, y = sample)) +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray60") +
    geom_point(color = "#CC3333", size = 1.8, alpha = 0.7) +
    labs(title = "N — Normality violated",
         subtitle = "QQ-plot points pull away at both tails (heavy-tailed residuals)",
         x = "Theoretical normal quantiles", y = "Sample quantiles") +
    theme_md(base_size = 11)

  p_E <- ggplot(d_E, aes(x = fitted, y = resid)) +
    geom_hline(yintercept = 0, color = "gray60", linetype = "dashed") +
    geom_point(color = "#CC3333", size = 1.8, alpha = 0.7) +
    labs(title = "E — Equal-variance violated",
         subtitle = "Residual spread fans out as fitted value increases (heteroscedasticity)",
         x = "Fitted values", y = "Residuals") +
    theme_md(base_size = 11)

  combined <- (p_L | p_I) / (p_N | p_E) +
    plot_annotation(
      title = "LINE conditions for regression inference — what each violation looks like",
      subtitle = "Four diagnostic plots, one per condition. Each shows a CLEAR violation; on a healthy model, all four would look like random scatter around 0.",
      theme = theme(
        plot.title = element_text(face = "bold", color = "#1F3A6B", size = 14),
        plot.subtitle = element_text(color = "#444", size = 11)
      )
    )

  save_diagram(combined, "05_line_diagnostics", width = 12, height = 9)
}

# ============================================================
# 6. Permutation test mechanism
# ============================================================
diagram_permutation <- function() {
  cat("[6] permutation test mechanism\n")
  set.seed(42)

  # Original two-group data (observed: group A and B with real difference)
  nA <- 25; nB <- 25
  groupA <- rnorm(nA, mean = 5.5, sd = 1.0)
  groupB <- rnorm(nB, mean = 4.0, sd = 1.0)
  values <- c(groupA, groupB)
  labels <- c(rep("A", nA), rep("B", nB))
  observed_diff <- mean(groupA) - mean(groupB)

  # Generate null distribution by shuffling labels many times
  n_perms <- 5000
  null_diffs <- replicate(n_perms, {
    shuffled <- sample(labels)
    mean(values[shuffled == "A"]) - mean(values[shuffled == "B"])
  })
  p_value <- mean(abs(null_diffs) >= abs(observed_diff))

  # === Top row: original data + 4 example shuffles
  shuffles_for_display <- lapply(1:4, function(i) {
    set.seed(100 + i)
    shuffled <- sample(labels)
    data.frame(
      iter = paste0("Shuffle ", i),
      value = values, group = shuffled,
      diff = mean(values[shuffled == "A"]) - mean(values[shuffled == "B"])
    )
  })
  shuffle_df <- bind_rows(shuffles_for_display)
  shuffle_df$iter <- factor(shuffle_df$iter, levels = paste0("Shuffle ", 1:4))

  observed_df <- data.frame(
    iter = "Observed",
    value = values, group = labels,
    diff = observed_diff
  )

  all_top <- bind_rows(observed_df, shuffle_df)
  all_top$iter <- factor(all_top$iter, levels = c("Observed", paste0("Shuffle ", 1:4)))
  diff_labels <- all_top %>% group_by(iter) %>% summarize(diff = first(diff)) %>%
    mutate(label = sprintf("diff = %.2f", diff))

  top_panel <- ggplot(all_top, aes(x = group, y = value, color = group)) +
    geom_jitter(width = 0.18, size = 1.6, alpha = 0.75) +
    geom_text(data = diff_labels, aes(x = 1.5, y = max(values) + 0.7, label = label),
              color = "#1F3A6B", fontface = "bold", size = 3.5, inherit.aes = FALSE) +
    facet_wrap(~ iter, ncol = 5) +
    scale_color_manual(values = c("A" = "#1A6FBE", "B" = "#CC9933"), guide = "none") +
    labs(x = NULL, y = "Value") +
    theme_md(base_size = 10) +
    theme(strip.text = element_text(size = 10))

  # === Bottom: null distribution + observed marker
  bottom_panel <- ggplot(data.frame(d = null_diffs), aes(x = d)) +
    geom_histogram(fill = "#888", color = "white", bins = 60) +
    geom_vline(xintercept = c(-observed_diff, observed_diff),
               color = "#CC3333", linewidth = 1, linetype = "dashed") +
    annotate("text", x = observed_diff, y = Inf, label = sprintf("observed = %.2f", observed_diff),
             color = "#CC3333", fontface = "bold", hjust = -0.05, vjust = 2, size = 4) +
    annotate("text", x = -observed_diff, y = Inf, label = sprintf("−observed = %.2f", -observed_diff),
             color = "#CC3333", fontface = "bold", hjust = 1.05, vjust = 2, size = 4) +
    labs(
      title = sprintf("Null distribution of %d shuffled differences", n_perms),
      subtitle = sprintf("p-value = proportion of shuffles |diff| ≥ |observed| = %.4f", p_value),
      x = "Difference in shuffled group means (A − B)", y = "Count"
    ) +
    theme_md()

  combined <- top_panel / bottom_panel +
    plot_layout(heights = c(1, 1.6)) +
    plot_annotation(
      title = "Permutation test mechanism",
      subtitle = "Top: original data + 4 example shuffles, each with its (under-the-null) difference.   Bottom: histogram of 5000 shuffles, observed marked in red.",
      theme = theme(
        plot.title = element_text(face = "bold", color = "#1F3A6B", size = 16),
        plot.subtitle = element_text(color = "#444", size = 11)
      )
    )

  save_diagram(combined, "06_permutation_test", width = 13, height = 9)
}

# ============================================================
# 7. Tidy data structure
# ============================================================
diagram_tidy_data <- function() {
  cat("[7] tidy data structure\n")

  # Helper: turn a small data frame into a ggplot "table"
  table_plot <- function(df, title, subtitle = NULL, highlight = NULL,
                          title_color = "#1F3A6B") {
    long <- df |>
      mutate(row = row_number()) |>
      pivot_longer(-row, names_to = "col", values_to = "val") |>
      mutate(col = factor(col, levels = names(df)))
    long$highlight <- if (!is.null(highlight)) {
      paste(long$row, long$col) %in% highlight
    } else FALSE

    # Add the header row as row 0
    header <- data.frame(
      row = 0, col = factor(names(df), levels = names(df)),
      val = names(df), highlight = FALSE
    )
    plotdf <- bind_rows(header, long)

    ggplot(plotdf, aes(x = col, y = -row)) +
      geom_tile(aes(fill = ifelse(row == 0, "header",
                                   ifelse(highlight, "bad", "cell"))),
                color = "white", linewidth = 1.5) +
      geom_text(aes(label = val, fontface = ifelse(row == 0, "bold", "plain")),
                color = "white", size = 3.7) +
      scale_fill_manual(values = c("header" = "#1F3A6B",
                                    "cell" = "#4D93D3",
                                    "bad" = "#CC3333"),
                        guide = "none") +
      labs(title = title, subtitle = subtitle) +
      scale_x_discrete(position = "top") +
      coord_fixed() +
      theme_void(base_size = 10) +
      theme(
        plot.title = element_text(face = "bold", color = title_color, size = 12, hjust = 0),
        plot.subtitle = element_text(color = "#555", size = 9, hjust = 0)
      )
  }

  # The same observations expressed 4 ways:
  # treatment outcomes for 3 patients (P1-P3) before & after a treatment
  untidy_A <- data.frame(
    patient = c("P1", "P2", "P3"),
    before  = c("5",  "7",  "6"),
    after   = c("8", "10",  "7")
  )
  # Bad: "before" and "after" are values of a variable (time), not separate columns

  untidy_B <- data.frame(
    patient = c("P1", "P2", "P3"),
    measurements = c("5, 8", "7, 10", "6, 7")
  )
  # Bad: two values in one cell

  untidy_C <- data.frame(
    info_pair  = c("P1 before", "P1 after", "P2 before", "P2 after", "P3 before", "P3 after"),
    score      = c("5", "8", "7", "10", "6", "7")
  )
  # Bad: variable info crammed into row labels

  tidy_form <- data.frame(
    patient = c("P1", "P1", "P2", "P2", "P3", "P3"),
    time    = c("before", "after", "before", "after", "before", "after"),
    score   = c("5", "8", "7", "10", "6", "7")
  )

  p_a <- table_plot(untidy_A, "❌ Untidy form 1 — wide",
                    subtitle = "'before' & 'after' are LEVELS of one variable, not separate variables",
                    highlight = c("1 before", "1 after", "2 before", "2 after", "3 before", "3 after"))
  p_b <- table_plot(untidy_B, "❌ Untidy form 2 — multiple values per cell",
                    subtitle = "Each cell holds two numbers; analysis tools expect ONE value per cell",
                    highlight = c("1 measurements", "2 measurements", "3 measurements"))
  p_c <- table_plot(untidy_C, "❌ Untidy form 3 — variables in row labels",
                    subtitle = "'patient' and 'time' are smushed into the label column",
                    highlight = c("1 info_pair", "2 info_pair", "3 info_pair", "4 info_pair", "5 info_pair", "6 info_pair"))
  p_d <- table_plot(tidy_form, "✓ Tidy form",
                    subtitle = "Each row is one observation; each column is one variable; each cell is one value",
                    title_color = "#2E6E1A")

  combined <- (p_a | p_b) / (p_c | p_d) +
    plot_annotation(
      title = "Three ways to be untidy — and the one way to be tidy",
      subtitle = "Same data (3 patients × 2 time-points = 6 observations), four representations",
      theme = theme(
        plot.title = element_text(face = "bold", color = "#1F3A6B", size = 16),
        plot.subtitle = element_text(color = "#444", size = 11)
      )
    )

  save_diagram(combined, "07_tidy_data", width = 12, height = 9)
}

# ============================================================
# 8. dplyr verbs flowchart
# ============================================================
diagram_dplyr_verbs <- function() {
  cat("[8] dplyr verbs\n")

  # Tiny illustrative data frame: 5 rows × 3 cols
  starter <- data.frame(
    name  = c("Ana", "Bob", "Cy",  "Dee", "El"),
    age   = c(30L,  25L,  41L,   18L,  29L),
    role  = c("teacher", "student", "teacher", "student", "teacher"),
    stringsAsFactors = FALSE
  )

  # Tiny table renderer
  mini_table <- function(df, title, subtitle = NULL, highlight_rows = NULL,
                          highlight_cols = NULL, title_color = "#1F3A6B") {
    if (nrow(df) == 0) {
      placeholder <- data.frame(name = "(empty)")
      return(mini_table(placeholder, title, subtitle, title_color = title_color))
    }
    df_str <- as.data.frame(lapply(df, as.character))
    long <- df_str |>
      mutate(row = row_number()) |>
      pivot_longer(-row, names_to = "col", values_to = "val") |>
      mutate(col = factor(col, levels = names(df_str)))
    long$highlight <- (long$row %in% (highlight_rows %||% c())) |
                       (as.character(long$col) %in% (highlight_cols %||% c()))

    header <- data.frame(
      row = 0, col = factor(names(df_str), levels = names(df_str)),
      val = names(df_str), highlight = FALSE
    )
    plotdf <- bind_rows(header, long)

    ggplot(plotdf, aes(x = col, y = -row)) +
      geom_tile(aes(fill = ifelse(row == 0, "header",
                                   ifelse(highlight, "high", "cell"))),
                color = "white", linewidth = 1.4) +
      geom_text(aes(label = val,
                    fontface = ifelse(row == 0, "bold", "plain")),
                color = "white", size = 3.2) +
      scale_fill_manual(values = c("header" = "#1F3A6B",
                                    "cell" = "#4D93D3",
                                    "high" = "#76BC43"),
                        guide = "none") +
      labs(title = title, subtitle = subtitle) +
      scale_x_discrete(position = "top") +
      coord_fixed() +
      theme_void(base_size = 9) +
      theme(
        plot.title = element_text(face = "bold", color = title_color, size = 11, hjust = 0),
        plot.subtitle = element_text(color = "#555", size = 8.5, hjust = 0,
                                      margin = margin(b = 4))
      )
  }
  `%||%` <- function(a, b) if (is.null(a)) b else a

  # filter() — keep rows matching condition
  filter_after <- starter |> dplyr::filter(role == "teacher")
  p_filter <- mini_table(filter_after,
                          "filter()",
                          "keep only rows where role == 'teacher'",
                          highlight_rows = 1:nrow(filter_after))

  # select() — keep columns
  select_after <- starter |> dplyr::select(name, age)
  p_select <- mini_table(select_after,
                          "select()",
                          "keep only columns 'name' & 'age'",
                          highlight_cols = c("name", "age"))

  # mutate() — add a column
  mutate_after <- starter |> dplyr::mutate(age_doubled = age * 2)
  p_mutate <- mini_table(mutate_after,
                          "mutate()",
                          "add a NEW column derived from existing ones",
                          highlight_cols = "age_doubled")

  # arrange() — sort rows
  arrange_after <- starter |> dplyr::arrange(age)
  p_arrange <- mini_table(arrange_after,
                           "arrange()",
                           "sort rows by 'age' (ascending)")

  # summarize() — collapse to 1 row
  summarize_after <- starter |> dplyr::summarize(mean_age = round(mean(age), 1),
                                                  n = n())
  p_summarize <- mini_table(summarize_after,
                             "summarize()",
                             "collapse to one row of aggregates",
                             highlight_rows = 1)

  # group_by + summarize — collapse per group
  group_after <- starter |> dplyr::group_by(role) |>
    dplyr::summarize(mean_age = round(mean(age), 1), n = n(), .groups = "drop")
  p_group <- mini_table(group_after,
                         "group_by() + summarize()",
                         "collapse to one row PER GROUP of 'role'",
                         highlight_cols = "role")

  starter_panel <- mini_table(starter,
                               "starting data frame",
                               "5 rows × 3 columns",
                               title_color = "#444")

  # Layout: starter in the middle row by itself, then 6 verbs in 3x2 grid
  verbs_grid <- (p_filter | p_select | p_mutate) / (p_arrange | p_summarize | p_group)

  combined <- starter_panel / verbs_grid +
    plot_layout(heights = c(1, 2.4)) +
    plot_annotation(
      title = "The 6 core dplyr verbs — before / after on the same starter frame",
      subtitle = "Each verb takes a data frame and returns a NEW one. Green highlights show what changed.",
      theme = theme(
        plot.title = element_text(face = "bold", color = "#1F3A6B", size = 16),
        plot.subtitle = element_text(color = "#444", size = 11)
      )
    )

  save_diagram(combined, "08_dplyr_verbs", width = 13, height = 10)
}

# ============================================================
# Run all
# ============================================================
cat("\n=== Building 8 teaching diagrams ===\n\n")
t_start <- Sys.time()

diagram_sampling_vs_bootstrap()
diagram_ci_coverage()
diagram_clt()
diagram_residuals()
diagram_line()
diagram_permutation()
diagram_tidy_data()
diagram_dplyr_verbs()

cat(sprintf("\nAll 8 diagrams built in %.1fs. Output: %s\n",
            as.numeric(difftime(Sys.time(), t_start, units = "secs")),
            out_dir))
