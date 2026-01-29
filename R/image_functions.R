include_image <- function(path,
                          html_opts = "width=45%",
                          latex_opts = html_opts,
                          alt_text = "") {
  # In Quarto, we default to HTML output for this book
  glue::glue("![{alt_text}]({path}){{ {html_opts} }}")
}

image_link <- function(path,
                       link,
                       html_opts = "height: 200px;",
                       latex_opts = "width=0.2\\textwidth",
                       alt_text = "",
                       centering = TRUE) {
  # In Quarto, we default to HTML output for this book
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
