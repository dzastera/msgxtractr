process_times <- function(x) {
  list(
    creation_time = unlist(unname(x[grep(msg_fields$CreationTime, names(x), value=TRUE)])),
    last_mod_time = unlist(unname(x[grep(msg_fields$LastModificationTime, names(x), value=TRUE)])),
    last_mod_name = unlist(unname(x[grep(msg_fields$LastModifierName, names(x), value=TRUE)]))
  )

}
process_recipients <- function(x) {
  y <-  grep("/__recip_version1.0_", names(x), value=TRUE)
  z <- sapply(y, strsplit, split = "/", fixed=TRUE, USE.NAMES = FALSE)
  z <- sprintf("/%s", unique(sapply(z, `[`, 2)))
  lapply(z, function(r) {
    recip <- x[grep(sprintf("^%s", r), names(x), value=TRUE)]
    list(
      display_name = unlist(unname(x[grep(msg_fields$DisplayName, names(recip), value=TRUE)])),
      address_type = unlist(unname(x[grep(msg_fields$AddressType, names(recip), value=TRUE)])),
      email_address = unlist(unname(x[grep(msg_fields$EmailAddress, names(recip), value=TRUE)]))
    )
  })
}

process_attachments <- function(x) {
  y <- grep(paste0("^/__attach_version1.*", msg_fields$AttachFilename), names(x), value=TRUE)
  z <- regmatches(y, regexpr("^/__.*/", y))
  lapply(z, function(r) {
    attachmnt <- x[grep(paste0("^", r, "__substg1.0_[0-9A-F]{8}$"), names(x), value = TRUE)]
    list(
      filename = unlist(unname(x[grep(msg_fields$AttachFilename, names(attachmnt), value=TRUE)])),
      long_filename = unlist(unname(x[grep(msg_fields$AttachLongFilename, names(attachmnt), value=TRUE)])),
      mime = unlist(unname(x[grep(msg_fields$AttachMIME, names(attachmnt), value=TRUE)])),
      content = unlist(unname(x[grep(msg_fields$AttachContent, names(attachmnt), value=TRUE)])),
      extension = unlist(unname(x[grep(msg_fields$AttachExtension, names(attachmnt), value=TRUE)]))
    ) -> res
    res[sapply(res, is.null)] <- NA
    res
  })
}

process_subject <- function(x) {
  unlist(unname(x[grep(msg_fields$Subject, names(x), value=TRUE)]))
}

process_sender <- function(x) {

  res <- list()

  sender_email <- unlist(unname(x[grep(msg_fields$SenderEmailAddress, names(x), value=TRUE)]))
  sender_name <- unlist(unname(x[grep(msg_fields$SenderName, names(x), value=TRUE)]))

  if (!is.null(sender_email)) res$sender_email <- sender_email
  if (!is.null(sender_name)) res$sender_name <- sender_name

  res

}

process_envelope <- function(x) {

  res <- list()

  display_name <- unlist(unname(x[grep(msg_fields$DisplayName, names(x), value=TRUE)]))
  display_bcc <- unlist(unname(x[grep(msg_fields$DisplayBcc, names(x), value=TRUE)]))
  display_cc <- unlist(unname(x[grep(msg_fields$DisplayCc, names(x), value=TRUE)]))
  display_to <- unlist(unname(x[grep(msg_fields$DisplayTo, names(x), value=TRUE)]))

  if (!is.null(display_name)) res$display_name <- display_name
  if (!is.null(display_bcc)) res$display_bcc <- display_bcc
  if (!is.null(display_cc)) res$display_cc <- display_cc
  if (!is.null(display_to)) res$display_to <- display_to

  res

}

process_headers <- function(x) {
  x <- unlist(unname(x[grep(msg_fields$TransportMessageHeaders, names(x), value=TRUE)]))
  if (!is.null(x)) {
    txc <- textConnection(x)
    on.exit(close(txc))
    x <- read.dcf(txc, all=TRUE)
    class(x) <- c("tbl_df", "tbl", "data.frame")
  }
  x
}

process_body <- function(x) {
  list(
    text = unlist(unname(x[grep(msg_fields$MessageBody, names(x), value=TRUE)])),
    html = unlist(unname(x[grep(msg_fields$MessageBodyHtml, names(x), value=TRUE)]))
  ) -> res
  if (!is.null(res$html)) res$html <- readBin(res$html, "character")
  res
}
