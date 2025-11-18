# Migration from bookdown to Quarto

This document describes the migration of the ModernDive book from bookdown to Quarto.

## Summary

The book has been successfully converted from using R bookdown to Quarto, an open-source scientific and technical publishing system. All content remains the same, but the rendering engine has been changed.

## Key Changes

### Configuration Files

- **New:** `_quarto.yml` - Main configuration file for Quarto
- **Replaced:** `_bookdown.yml` and `_output.yml` are no longer used (but kept for reference)

### File Format

- All `.Rmd` files have been renamed to `.qmd` (Quarto markdown)
- Total files converted: 43 (20 main files + 12 learning check answer files + 11 other files)

### Syntax Changes

1. **Unnumbered headers:** `{-}` → `{.unnumbered}`
2. **Output detection:** `is_html_output()` → `knitr::is_html_output()`
3. **Parts:** Defined in `_quarto.yml` instead of inline `(PART)` headers
4. **Custom blocks:** `{block, type='learncheck'}` → `::: {.learncheck}`
5. **Content visibility:** `{block, include=is_html_output()}` → `::: {.content-visible when-format="html"}`

### Build Process

- **Old:** `bookdown::render_book("index.Rmd", "bookdown::bs4_book")`
- **New:** `quarto render`

### GitHub Actions

- **Old workflow:** `.github/workflows/deploy_bookdown.yml`
- **New workflow:** `.github/workflows/quarto-publish.yml`

### Dependencies

- Removed `bookdown` package from DESCRIPTION
- R packages still required (via renv)
- Quarto itself must be installed separately

## Building the Book

### Local Build

1. Install Quarto from <https://quarto.org/docs/get-started/>
2. Install R and required packages (use renv)
3. Run: `quarto render`
4. Output will be in the `docs/` directory

### Using the Build Script

```bash
./_build.sh
```

## Structure

The book is organized into parts in `_quarto.yml`:

1. Getting Started (Chapter 1)
2. Data Science with tidyverse (Chapters 2-4)
3. Statistical Modeling with moderndive (Chapters 5-6)
4. Statistical Inference with infer (Chapters 7-10)
5. Conclusion (Chapter 11)
6. Appendices (Appendices A-E)

## Cross-References

Quarto supports bookdown-style cross-references (`\@ref(label)`), so most existing cross-references should work without changes. For new content, Quarto's native syntax can be used:

- Sections: `@sec-label`
- Figures: `@fig-label`
- Tables: `@tbl-label`

## CSS and Styling

The existing `style.css` file is still used and contains styles for custom classes like `.learncheck` and `.announcement`.

## Notes for Contributors

- Edit `.qmd` files (not `.Rmd`)
- Use Quarto div syntax for custom blocks
- Test builds locally before committing
- The book structure is defined in `_quarto.yml`

## Resources

- Quarto documentation: <https://quarto.org/docs/books/>
- Quarto cross-references: <https://quarto.org/docs/authoring/cross-references.html>
- Migrating from bookdown: <https://quarto.org/docs/books/book-migrations.html>
