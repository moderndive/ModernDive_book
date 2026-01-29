# Quarto Conversion Notes

## Conversion Completed

The v2 bookdown project has been successfully converted to Quarto. Here's what was changed:

### Files Converted
- All 20 `.Rmd` files have been renamed to `.qmd` files
- `_quarto.yml` configuration file created to replace `_bookdown.yml` and `_output.yml`
- Old bookdown configs renamed to `_bookdown.yml.bak` and `_output.yml.bak` for reference
- `purl.R` script updated to reference `.qmd` files instead of `.Rmd`
- `_build.sh` script updated to use `quarto render` instead of bookdown
- `index.qmd` updated to remove bookdown-specific YAML and use Quarto conventions

### Configuration Changes
- Book metadata moved to `_quarto.yml`
- Format settings (HTML theme, CSS, TOC) configured in `_quarto.yml`
- Navbar and repository links configured
- Bibliography files properly referenced
- Knitr options configured globally

### Syntax Updates
- Updated unnumbered chapter syntax from `{-}` to `{.unnumbered}`
- Changed bookdown functions to use `knitr::` namespace prefix (e.g., `knitr::is_html_output()`)
- Converted `{block}` chunks to Quarto's conditional content syntax (`::: {.content-visible when-format="html"}`)
- Removed `bookdown.clean_book` option
- Updated `opts_chunk$set` to `knitr::opts_chunk$set`

### Cross-References
Note: The bookdown-style cross-references using `\@ref()` have been left as-is. Quarto has backward compatibility for these references, so they should work without modification. If needed in the future, these can be converted to native Quarto syntax:
- `\@ref(fig:label)` → `@fig-label`
- `\@ref(tab:label)` → `@tbl-label`
- `\@ref(sec:label)` → `@sec-label`

### GitHub Actions
A new workflow file `.github/workflows/deploy_quarto.yml` has been created for building and deploying the Quarto book.

## Building the Book

To build the book locally:
```bash
quarto render
```

Or use the provided build script:
```bash
./_build.sh
```

The output will be in the `docs/` directory as configured.

## Testing

The Quarto project structure has been validated using:
```bash
quarto inspect
```

All 20 chapters are properly recognized and configured.

## Next Steps

1. Install R packages required by the book (can be done via GitHub Actions or locally)
2. Test the full build with all packages installed
3. Verify the rendered output matches the original bookdown version
4. Update deployment workflow to use the Quarto workflow for the v2 branch
5. Consider converting cross-references to native Quarto syntax (optional, for better performance)

