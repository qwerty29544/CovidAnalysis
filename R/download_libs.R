# Libraries download script v1.01 -----------------------------------------

libraries = c("tidyverse", "openxlsx",
              "dplyr", "tidyr", "stringr",
              "ggplot2", "forecast",
              "openxlsx", "quantreg")

#' Downloading and installing packages in R session
#'
#' @param libs - vector of character libraries that you want to download
#'
#' @return NULL
#' @export
#'
#' @examples
#' install_new_package("ggplot2")
#' install_new_package(c("dplyr", "forecast"))
install_new_package <- function(libs = libraries) {
    for (libI in libs) {
        if (libI %in% installed.packages() == FALSE) {
            install.packages(libI)
        }
    }
}

# -------------------------------------------------------------------------

