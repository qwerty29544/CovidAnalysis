install_new_package <- function(libs = c("tidyverse", "openxlsx", "dplyr", "tidyr", "stringr", "ggplot2", "forecast", "openxlsx", "quantreg")) {
    for (libI in libs) {
        if (libI %in% installed.packages() == FALSE) {
            install.packages(libI)
        }
    }
}
