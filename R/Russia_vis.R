# Create dir --------------------------------------------------------------

if (!dir.exists("./output_pngs/Russia/")){
  dir.create("./output_pngs/Russia/")
}

if (!dir.exists("./output_pngs/Russia/Exploration")) {
  dir.create("./output_pngs/Russia/Exploration")
}


# get data ----------------------------------------------------------------
df_confirmed <- read.csv("./output_csv/data_conf_output.csv")
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

png(filename = "./output_pngs/Russia/Exploration/Cumulative.png", width = 1000, height = 900, res = 90)
plot(plot_cumul)
dev.off()

rm("plot_cumul")

# differential dynamics ---------------------------------------------------
plot_diff <- ggplot2::ggplot(data = df_Russia,
                             mapping = aes(x = date,
                                           y = diff_conf)) +
  ggplot2::geom_line(lwd = 0.5) +
  ggplot2::geom_point() +
  ggplot2::theme_bw(base_size = 12) +
  ggplot2::scale_x_date(breaks = function(x) seq.Date(from = min(x), to = max(x), by = "2 months"),
                        minor_breaks = function(x) seq.Date(from = min(x), to = max(x), by = "1 month")) +
  ggplot2::scale_y_continuous(breaks = function(y) seq(0, max(y), max(y) %/% 10)) +
  ggplot2::labs(x = paste0("Даты процесса c ", min(df_Russia$date)),
                y = "Динамика заболевших, чел.",
                title = "Динамика переболевших Covid19 по России")


plot(plot_diff)

png(filename = "./output_pngs/Russia/Exploration/Differential.png", width = 1000, height = 900, res = 90)
plot(plot_diff)
dev.off()



plot_diff_part <- plot_diff + ggplot2::coord_cartesian(c(as.Date("2020-12-29"), max(df_Russia$date))) +
  ggplot2::scale_x_date(breaks = function(x) seq.Date(from = min(x), to = max(x), by = "10 days"),
                        minor_breaks = function(x) seq.Date(from = min(x), to = max(x), by = "5 day"))

png(filename = "./output_pngs/Russia/Exploration/Differential_part.png", width = 1000, height = 900, res = 90)
plot(plot_diff_part)
dev.off()



rm("plot_diff")
rm(list = ls())









df_russia2_diff_subset <- df_Russia[-(1:240),]
plot(log(df_russia2_diff_subset$diff_conf / cumsum(df_russia2_diff_subset$diff_conf)), pch = 19, cex = I(0.5))
abline(a = -2.45, b = -0.019)

plot(x = 241:nrow(df_Russia),
     y = df_russia2_diff_subset$diff_conf,
     xlim = c(0, nrow(df_Russia)),
     ylim = c(0, max(df_Russia$diff_conf)))
lines(x = 1:nrow(df_Russia),
      y = )
