# Create dir --------------------------------------------------------------

if (!dir.exists("R/output_pngs/Russia/")){
  dir.create("R/output_pngs/Russia/")
}
if (!dir.exists("R/output_pngs/Russia/Exploration")) {
  dir.create("R/output_pngs/Russia/Exploration")
}


# get data ----------------------------------------------------------------
df_confirmed <- read.csv("output_csv/data_conf_output.csv")
df_confirmed$date <- as.Date(df_confirmed$date)


# Russia subsetting -------------------------------------------------------
df_Russia <- df_confirmed %>% dplyr::select(date, contains("Russia")) %>%
  dplyr::mutate(diff_conf = c(0, diff(Russia.)), log_diff = log(diff_conf + 1))

rm("df_confirmed")

# exploratory -------------------------------------------------------------
library(ggplot2)

# cumulative dynamics -----------------------------------------------------
plot_cumul <- ggplot2::ggplot(data = df_Russia,
                mapping = aes(x = date, y = Russia., color = diff_conf)) +
  ggplot2::geom_line(lwd = I(0.5)) +
  ggplot2::geom_point() +
  ggplot2::theme_bw(base_size = 14) +
  ggplot2::scale_x_date(breaks = function(x) seq.Date(from = min(x), to = max(x), by = "2 months"),
                        minor_breaks = function(x) seq.Date(from = min(x), to = max(x), by = "1 month")) +
  ggplot2::scale_y_continuous(breaks = function(y) seq(0, max(y), max(y) %/% 10)) +
  ggplot2::labs(x = paste0("Даты процесса c ", min(df_Russia$date)),
                y = "Кумулятивная сумма заболевших, чел.",
                title = "Общая сумма переболевших Covid19 по России")

png(filename = "R/output_pngs/Russia/Exploration/Cumulative.png", width = 1000, height = 900, res = 90)
plot(plot_cumul)
dev.off()

rm("plot_cumul")

# differential dynamics ---------------------------------------------------
plot_diff <- ggplot2::ggplot(data = df_Russia,
                             mapping = aes(x = date,
                                           y = diff_conf)) +
  ggplot2::geom_line(lwd = 0.5) +
  ggplot2::geom_point() +
  ggplot2::theme_bw(base_size = 14) +
  ggplot2::scale_x_date(breaks = function(x) seq.Date(from = min(x), to = max(x), by = "2 months"),
                        minor_breaks = function(x) seq.Date(from = min(x), to = max(x), by = "1 month")) +
  ggplot2::scale_y_continuous(breaks = function(y) seq(0, max(y), max(y) %/% 10)) +
  ggplot2::labs(x = paste0("Даты процесса c ", min(df_Russia$date)),
                y = "Динамика заболевших, чел.",
                title = "Динамика переболевших Covid19 по России")


plot(plot_diff)

png(filename = "R/output_pngs/Russia/Exploration/Differential.png", width = 1000, height = 900, res = 90)
plot(plot_diff)
dev.off()

rm("plot_diff")
