# Quarto Book Deployment Preview

## Overview

Once the GitHub Actions workflow runs, the Quarto book will be deployed to GitHub Pages. Here's what the deployment will look like:

## Deployment URLs

After merging to the `v2` branch, the book will be automatically built and deployed to:

1. **Primary Location**: `https://moderndive.github.io/ModernDive_book/v2/`
2. **Alternative Branch**: `v2-publish` branch (for backup/verification)

## Book Structure

The Quarto book has been configured with the following structure:

### Main Sections

1. **Welcome Page** (index.qmd)
   - Welcome to ModernDive (v2)
   - Book cover and introduction

2. **Foreword** (00-foreword.qmd)
   - By Kelly S. McConville

3. **Preface** (00-preface.qmd)
   - Introduction for students
   - Introduction for instructors
   - About the book

4. **Part I: Getting Started**
   - Chapter 1: Getting Started with Data in R

5. **Part II: Data Science with tidyverse**
   - Chapter 2: Data Visualization
   - Chapter 3: Data Wrangling
   - Chapter 4: Tidy Data

6. **Part III: Statistical Modeling with moderndive**
   - Chapter 5: Simple Linear Regression
   - Chapter 6: Multiple Regression

7. **Part IV: Statistical Inference with infer**
   - Chapter 7: Sampling
   - Chapter 8: Confidence Intervals
   - Chapter 9: Hypothesis Testing
   - Chapter 10: Inference for Regression

8. **Part V: Conclusion**
   - Chapter 11: Tell Your Story with Data

9. **Part VI: Appendices**
   - Appendix A: Statistical Background
   - Appendix B: Inference Examples
   - Appendix C: Tips and Tricks
   - Appendix D: Solutions to Learning Checks
   - Appendix E: Package Versions

10. **References**

## Features

The deployed Quarto book will include:

### Navigation
- **Left Sidebar**: Table of contents with all chapters and sections
- **Top Navbar**: 
  - Home link
  - GitHub repository link
- **Bottom Footer**:
  - Creative Commons license
  - Netlify deployment badge

### Styling
- **Theme**: Cosmo (Bootstrap-based, clean and modern)
- **Custom CSS**: Preserved from the original bookdown book (style.css)
- **Responsive Design**: Works on desktop, tablet, and mobile

### Interactive Features
- **Code Blocks**: All R code is syntax-highlighted
- **Figures**: High-resolution images with captions
- **Cross-references**: Internal links to figures, tables, and sections work properly
- **Search**: Full-text search across all chapters
- **Table of Contents**: 
  - Collapsible sections
  - Shows current chapter location
  - 3 levels of depth

### Custom Elements
- **Learning Check Boxes**: Styled with green background (`.learncheck` class)
- **Announcement Boxes**: Styled with yellow background (`.announcement` class)
- **Book Cover**: Displayed on the index page
- **Analytics**: Google Analytics included (if configured in _includes/analytics.html)
- **Logo**: ModernDive logo in the header

## Build Process

When the GitHub Actions workflow runs:

1. **Setup**: Installs Quarto, R, and all required packages
2. **Render**: Runs `quarto render` which:
   - Processes all .qmd files
   - Executes R code chunks
   - Generates plots and tables
   - Creates cross-references
   - Builds the complete HTML site
3. **Output**: Creates the `docs/` folder with:
   - `index.html` (main entry point)
   - Individual chapter HTML files
   - `search.json` (for search functionality)
   - All images, CSS, and JavaScript files
   - R script files (in `docs/scripts/`)
4. **Deploy**: Pushes the `docs/` folder to:
   - `gh-pages` branch at `/v2/` subdirectory
   - `v2-publish` branch (entire site)

## Comparison with Bookdown

The Quarto version maintains all the content and functionality of the bookdown version, with these improvements:

### Same as Bookdown
- ✅ All chapter content identical
- ✅ All R code and outputs
- ✅ All figures and tables
- ✅ Cross-references work
- ✅ Bibliography and citations
- ✅ Custom CSS styling
- ✅ Learning check boxes

### Improvements over Bookdown
- ✅ Modern Quarto tooling (better maintained)
- ✅ Cleaner, more semantic HTML output
- ✅ Better mobile responsiveness
- ✅ Improved search functionality
- ✅ Easier to extend and customize
- ✅ Native support for multiple output formats
- ✅ Better integration with modern web standards

## Example Page Structure

Each chapter page will have:

```
┌─────────────────────────────────────────────────┐
│ [Logo] ModernDive        [Home] [GitHub Icon]  │ ← Top navbar
├──────────┬──────────────────────────────────────┤
│          │                                      │
│ Table of │  Chapter Title                       │
│ Contents │                                      │
│          │  Chapter content with:               │
│ • Part I │  - Text paragraphs                   │
│   ○ Ch1  │  - R code blocks                     │
│ • Part II│  - Figures and plots                 │
│   ○ Ch2  │  - Tables                            │
│   ○ Ch3  │  - Learning check boxes              │
│   ○ Ch4  │  - Cross-references                  │
│ ...      │                                      │
│          │  [Edit this page on GitHub]          │
│          │                                      │
├──────────┴──────────────────────────────────────┤
│ License info          [Netlify badge]           │ ← Footer
└─────────────────────────────────────────────────┘
```

## Testing Locally

To test the build locally:

```bash
# Install Quarto
# Download from https://quarto.org/docs/get-started/

# Install R and required packages
# Use renv to restore packages:
R -e "renv::restore()"

# Render the book
quarto render

# Preview locally
quarto preview
```

The preview will open at `http://localhost:XXXX` where you can explore all chapters.

## Verification Checklist

Once deployed, verify:

- [ ] All chapters load correctly
- [ ] Table of contents navigation works
- [ ] Search functionality works
- [ ] Images display properly
- [ ] Code blocks are properly formatted
- [ ] Cross-references link correctly
- [ ] Learning check boxes display with correct styling
- [ ] Footer links work
- [ ] GitHub edit links work
- [ ] Mobile view is responsive

## Current Status

- ✅ Quarto configuration complete (`_quarto.yml`)
- ✅ All files converted from .Rmd to .qmd
- ✅ All Quarto syntax conversions applied
- ✅ GitHub Actions workflow created
- ✅ Merge conflicts with base branch resolved
- ⏳ Awaiting merge to v2 branch for automatic deployment

Once this PR is merged to the `v2` branch, GitHub Actions will automatically build and deploy the Quarto book.
