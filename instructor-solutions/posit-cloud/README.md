# ModernDive Posit Cloud template

A pre-configured RStudio project for instructors to upload to Posit Cloud and share with their class as a one-click workspace template.

## What's in this folder

| File | Purpose |
|---|---|
| `setup.R` | Installs every CRAN + GitHub package the course uses. Run once in a fresh project. |
| `welcome.qmd` | Student-facing first notebook; sanity checks the install. |
| `moderndive-template.Rproj` | RStudio project file (sets project-level options). |
| `.Rprofile` | Sets sensible defaults; shows a startup message. |
| `README.md` | This file. |

## How to deploy the template (instructor, one-time setup)

1. **Sign up** for [Posit Cloud](https://posit.cloud/) — free tier works for the template; consider Cloud for Teaching (free for educators) if you have a large class.
2. **Create a workspace** for your course (e.g., "STAT 101 Spring 2026").
3. **Create a new project** in that workspace — pick "New RStudio Project".
4. **Upload the contents of this folder** (drag and drop into the Files pane).
5. **Run `source("setup.R")`** — wait ~5 minutes for installs to finish.
6. **Run `source("welcome.qmd")`** to confirm everything works (or just open it and click Render).
7. **Click the project's gear icon → "Make Template"** — Posit Cloud freezes the project as a clean template.
8. **Share the workspace URL** with students. They click → Posit Cloud copies the template to their account → they have their own clean copy.

## How students use it (no instructor work)

1. Click the workspace URL the instructor shared.
2. Click "Save as Permanent Copy" (saves to their own Posit Cloud account).
3. Open `welcome.qmd`, run the first chunk.

That's it — no install pain, no version drift, no "it works on my laptop but not theirs."

## Maintaining the template

- **When the book updates**: re-run `source("setup.R")` to pull the latest GitHub-only packages.
- **When you add a new package to the course**: edit `setup.R`'s `cran_packages` or `github_packages` list, re-source, then "Update Template" on the project.
- **Each semester**: copy the template into a new workspace named after the term ("STAT 101 Fall 2026") so prior-semester students don't see your active course.

## Tradeoffs vs. local install

| | Posit Cloud template | Local install |
|---|---|---|
| Student setup time | ~30 seconds (click + go) | ~30-90 minutes (varies) |
| Works on a phone / Chromebook | Yes | No |
| Uses student's internet during class | Yes, requires connection | No |
| Subject to Posit Cloud usage caps | Free tier: 25 hours/student/month | Unlimited |
| Easy to send a notebook to a friend | Share project link | Send the `.qmd` + hope they have R |

Most courses use the template for the **first 4 weeks** (when install pain blocks most adoption) and let students transition to local installs later if they prefer. Both can co-exist; the same `.qmd` files work in both environments.

## See also

- [Posit Cloud documentation](https://docs.posit.cloud/)
- [Posit Cloud for Teaching](https://posit.cloud/learn/guide#account-types) (free-for-educators tier)
- ModernDive [instructor hub](https://moderndive-instructor-resources.netlify.app/posit-cloud.html) for the latest version of this README
