
# create dirs -------------------------------------------------------------
plot_dir = "output_pngs/Russia/Analysis"
if (!dir.exists(plot_dir)) {
  dir.create(plot_dir)
}


# dynamics ----------------------------------------------------------------
df_confirmed <- read.csv("./output_csv/data_conf_output.csv")
df_confirmed$date <- as.Date(df_confirmed$date)

df_confirmed <- df_confirmed[-(1:43), ]
# Russia subsetting -------------------------------------------------------
df_Russia <- df_confirmed %>% dplyr::select(date, contains("Russia")) %>%
  dplyr::mutate(diff_conf = c(0, diff(Russia.)), log_diff = log(diff_conf + 1), rownum = 1:nrow(df_confirmed))

rm("df_confirmed")


# plots -------------------------------------------------------------------
predict_forward = 110
period = 114
date_max = which.max(df_Russia$diff_conf)

png(file = paste0(plot_dir, "/diff_plot.png"), width = 1000, height = 900, res = 90)

plot(x = df_Russia$rownum, y = df_Russia$diff_conf,
     col = "black", type = "o", pch = 19, cex = I(0.8), lwd = I(0.5),
     main = "График динамики заражений Covid19 в России",
     xlab = paste0("Дни с даты ", df_Russia$date[1]),
     ylab = "Прирост заболевших, чел",
     xlim = c(0, max(df_Russia$rownum) + predict_forward))
abline(v = date_max + period * (-2:2), col = "orange")
text(x = date_max + period * (-2:2) - 20, y = 2500,
     labels = c(df_Russia$date[date_max + period * (-2:1)],
                df_Russia$date[date_max + period] + period))
grid()

dev.off()

# seasonal ----------------------------------------------------------------
max_lag <- 100
acf_Rus_conf <- acf(x = diff(df_Russia$diff_conf), lag.max = max_lag, demean = TRUE)


png(file = paste0(plot_dir, "/acf_plot.png"), width = 1000, height = 900, res = 90)
plot(x = acf_Rus_conf$lag, y = acf_Rus_conf$acf,
     type = "o", pch = 19, col = "red3", cex = I(0.8),
     main = "График автокореляций для прироста заболевших",
     xlab = "Лаги по времени, дни",
     ylab = "Автокорреляции ряда")
abline(v = 7 * (1:20), col = "blue2", lty = 3, lwd = I(0.5))
abline(h = c(-1:1) * 1.96 * (1 / sqrt(nrow(df_Russia))),
       lty = 2, lwd = I(0.5))
grid()
dev.off()


# Alter-Johns -------------------------------------------------------------
MariaRemark.Alter_Johns <- function(ts, p = 1) {
  lents <- length(ts)
  a <- numeric(length = lents - 1)
  for (i in 1:(lents-1)) {
    a[i] <- 1/(lents - i) * sum(abs(ts[1:(lents - i)] - ts[(1 + i):lents])^(p))^(1/p)
  }
  return(a)
}

at_diff_Russ_p2 <- MariaRemark.Alter_Johns(diff(df_Russia$diff_conf), p = 2)

png(file = paste0(plot_dir, "/AJ_plot.png"), width = 1000, height = 900, res = 90)
plot(at_diff_Russ_p2,
     type = "o", col = "red2", pch = 19, cex = I(0.8),
     xlim = c(0, max_lag), ylim = c(min(at_diff_Russ_p2[1:max_lag]),
                                    max(at_diff_Russ_p2[1:max_lag])),
     main = "График функции Альтера-Джонса для p = 2",
     xlab = "Лаги по времени, дни",
     ylab = "Значения функции Альтера-Джонса")
abline(v = 7 * (1:20), col = "blue2", lty = 3, lwd = I(0.5))
grid()
dev.off()


# TrendAnalysis -----------------------------------------------------------


