# R Code Chunk Naming Conventions

This document describes the naming conventions used for R code chunks in the ModernDive book.

## Overview

All 917 R code chunks in the book are now named following consistent, context-aware conventions. Previously, 337 chunks (36.8%) were unnamed. This document describes the naming strategy applied.

## Naming Patterns

### 1. Setup Chunks
Chunks that set up chapter-specific options or configurations:
- Pattern: `setup_<chapter-name>` or `setup`
- Example: `setup_getting_started`, `setup_viz`, `setup_wrangling`

### 2. Package Loading
Chunks that load R packages:
- Pattern: `load-<package-name>`
- Examples: `load-ggplot2`, `load-dplyr`, `load-tidyverse`, `load-mvtnorm`

### 3. Graphics and Images
Chunks that display images using `include_graphics()`:
- Pattern: Uses descriptive filename (cleaned up, hyphens for spaces)
- Examples: `ModernDive_heart`, `R-vs-RStudio-1`, `RStudio-interface`

### 4. Plots
Chunks that create visualizations:
- Pattern: `plot` (with numeric suffix if multiple)
- Examples: `plot`, `plot-1`, `plot-2`

### 5. Data Operations
Chunks performing data transformations:
- `filter` - filtering data
- `select` - selecting columns
- `mutate` - creating/modifying variables
- `summarize` - summarizing data
- `group-by` - grouping operations
- `join` - joining datasets
- `pivot` - pivoting data
- Numeric suffixes added when multiple chunks use same operation

### 6. Statistical Operations
Chunks performing statistical analysis:
- `model` - fitting models with `lm()`
- `regression` - regression-related operations using `get_regression_*` functions
- `resample` - resampling operations

### 7. Inference Operations (infer package)
Chunks using the infer package workflow:
- `specify` - specifying variables and success
- `hypothesize` - setting null hypothesis
- `generate` - generating bootstrap/permutation samples
- `calculate` - calculating statistics
- `visualize` - visualizing distributions
- `shade` - adding shading to visualizations
- `infer` - general infer operations (p-values, confidence intervals)

### 8. Data Viewing
Chunks that display or preview data:
- `glimpse-<dataname>` - using `glimpse()` function
- `view-data` - using `View()` function
- `preview-data` - using `head()` or `tail()`
- `table` - creating tables with `kable()`

### 9. Generic Code
Chunks that don't fit other categories:
- Pattern: `code` (with numeric suffix if multiple)
- Used sparingly for miscellaneous operations

### 10. Comment-Based Naming
For chunks with descriptive comments:
- Pattern: Derived from first comment line (cleaned, hyphenated)
- Example: A chunk starting with `# Used to define Learning Check numbers` might be named `used-to-define-learn`

## Naming Rules

1. **All chunks must have names**: No anonymous chunks (`{r}` or `{r, options}`)
2. **Names start with letter or number**: Valid R identifiers
3. **Use hyphens for word separation**: `load-ggplot2`, not `load_ggplot2` (for consistency with existing style)
4. **Underscores allowed**: Legacy names with underscores (e.g., `setup_getting_started`) were preserved
5. **Keep names concise**: Aim for clarity but brevity
6. **Add numeric suffixes for duplicates**: `plot-1`, `plot-2`, etc.
7. **Be descriptive**: Names should hint at chunk purpose

## Benefits of Named Chunks

1. **Better error messages**: Errors reference chunk names, making debugging easier
2. **Improved navigation**: Easier to find and reference specific chunks
3. **Cache management**: Named chunks enable better caching strategies
4. **Documentation**: Self-documenting code with meaningful chunk names
5. **Cross-referencing**: Easier to reference chunks in text and other chunks

## Implementation

The chunk naming was implemented systematically across all 18 .Rmd files:
- Main chapters (01-11)
- Appendices (91-95)
- Front matter (00-foreword, 00-preface)
- index.Rmd

A Python script was used to automatically analyze chunk content and suggest appropriate names based on the patterns above, while ensuring uniqueness within each file.
