library(googledrive)

drive_upload(media = "docs/ismaykim.pdf",
             path = "moderndive_pdf/",
             name = paste0("moderndive_", Sys.Date(), ".pdf"),
             type = NULL,
             verbose = TRUE)
