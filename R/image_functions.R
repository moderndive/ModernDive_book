include_image <- function(path,
                          html_opts = "width=45%",
                          latex_opts = html_opts,
                          alt_text = "") {
  if (knitr::is_html_output()) {
    glue::glue("![{alt_text}]({path}){{ {html_opts} }}")
  } else if (knitr::is_latex_output()) {
    glue::glue("![{alt_text}]({path}){{ {latex_opts} }}")
  }
}

image_link <- function(path,
                       link,
                       html_opts = "height: 200px;",
                       latex_opts = "width=0.2\\textwidth",
                       alt_text = "",
                       centering = TRUE) {
  if (knitr::is_html_output()) {
    if (centering) {
      glue::glue(
        '<center><a target="_blank" class="page-link" href="{link}"><img src="{path}" style="{html_opts}"/></a></center>'
      )
    } else {
      glue::glue(
        '<a target="_blank" class="page-link" href="{link}"><img src="{path}" style="{html_opts}"/></a>'
      )
    }
  }
  else if (knitr::is_latex_output()) {
    if (centering) {
      glue::glue("\\begin{{center}}
        \\href{{{link}}}{{\\includegraphics[{latex_opts}]{{{path}}}}}
        \\end{{center}}")
    } else {
      glue::glue("\\href{{{link}}}{{\\includegraphics[{latex_opts}]{{{path}}}}}")
    }
  }
}
