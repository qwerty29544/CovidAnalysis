
# create dirs -------------------------------------------------------------
plot_dir = "output_pngs/Russia/Analysis"
if (!dir.exists(plot_dir)) {
  dir.create(plot_dir)
}


# dynamics ----------------------------------------------------------------
df_confirmed <- read.csv("./output_csv/data_conf_output.csv")
df_confirmed$date <- as.Date(df_confirmed$date)

df_confirmed <- df_confirmed
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
abline(v = date_max + period * (-3:2), col = "orange")
text(x = date_max + period * (-3:2) - 20, y = 2500,
     labels = c(df_Russia$date[date_max + period * (-2)] - period,
                df_Russia$date[date_max + period * (-2:1)],
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
interval1 <- 1:(date_max - 2 * period - 1)
interval2 <- (date_max - 2 * period):(date_max - period - 1)
interval3 <- (date_max - period):(date_max - 1)
interval4 <- (date_max):(date_max + period - 1)

# Главный график функции Гомперца для первого участка
png(file = paste0(plot_dir, "/gmp1.png"), width = 1000, height = 900, res = 90)
plot(x = df_Russia$date[c(interval1, interval2, interval3)],
     y = df_Russia$diff_conf[c(interval1, interval2, interval3)], type = "o", pch = 19,
     xlab = paste("Даты со дня", df_Russia$date[1]),
     ylab = "Прирост заражений, чел",
     main = "График пророста заболевших Covid19 в России",
     xlim = c(df_Russia$date[1], df_Russia$date[length(c(interval3, interval4))]),
     ylim = c(0, max(df_Russia$diff_conf[c(interval1, interval2)])))
abline(v = df_Russia$date[which.max(df_Russia$diff_conf[c(interval1, interval2)])], col = "red")
text(x = df_Russia$date[which.max(df_Russia$diff_conf[c(interval1, interval2)])] + 10,
     y = max(df_Russia$diff_conf[c(interval1, interval2)]) / 3,
     labels = df_Russia$date[which.max(df_Russia$diff_conf[c(interval1, interval2)])])
abline(h = max(df_Russia$diff_conf[c(interval1, interval2)])/1.44, col = "blue")
abline(v = df_Russia$date[which.max(df_Russia$diff_conf[c(interval1, interval2)])] + 36)
text(x = df_Russia$date[which.max(df_Russia$diff_conf[c(interval1, interval2)])] + 36 + 10,
     y = max(df_Russia$diff_conf[c(interval1, interval2)]) / 3,
     labels = df_Russia$date[which.max(df_Russia$diff_conf[c(interval1, interval2)])] + 36)
lines(x =  df_Russia$date[c(interval3, interval4)] - (max(df_Russia$date[c(interval1, interval2)]) - min(df_Russia$date[c(interval1, interval2)])),
      y = df_Russia$diff_conf[c(interval3, interval4)] / max(df_Russia$diff_conf) * max(df_Russia$diff_conf[c(interval1, interval2)]),
      lty = 2, col = "grey4")
grid()
dev.off()


# Модель Гомперца на первом интервале -------------------------------------

diff_russia12_y <- df_Russia$diff_conf[c(interval1, interval2)]
diff_russia12_x <- c(interval1, interval2)
gmp12_y <- log(diff_russia12_y/cumsum(diff_russia12_y))



png(file = paste0(plot_dir, "/gmp12_a.png"), width = 1000, height = 900, res = 90)
plot(x = diff_russia12_x,
     y = gmp12_y,
     type = "o",
     pch = 19,
     cex = I(0.8),
     main = "Анаморфоза Гомперца ln(y_dot / y) ~ t",
     ylab = "Значения анаморфозы Гомперца",
     xlab = paste("Дни с", df_Russia$date[1]))
gmp12_alpha = -0.033  # Угол наклона модели Гомперца на анаморфозе Гомперца
gmp12_beta = 0.67      # Пересечение с 0 в анаморфозе Гомперца
abline(a = gmp12_beta, b = gmp12_alpha)
abline(h = log(-gmp12_alpha))
arrows(x0 = (log(-gmp12_alpha) - gmp12_beta) / gmp12_alpha,
       x1 = (log(-gmp12_alpha) - gmp12_beta) / gmp12_alpha,
       y0 = log(-gmp12_alpha),
       y1 = 0)
text(x = (log(-gmp12_alpha) - gmp12_beta) / gmp12_alpha, y = 0,
     labels = df_Russia$date[round((log(-gmp12_alpha) - gmp12_beta) / gmp12_alpha)])
grid()
dev.off()

# Отображение модели на первый интервал
png(file = paste0(plot_dir, "/gmp12.png"), width = 1000, height = 900, res = 90)
plot(x = diff_russia12_x, y = diff_russia12_y,
     col = "black", type = "o", pch = 19,
     main = "Модель Гомперца на основе первого интервала",
     xlab = paste("Дни с", df_Russia$date[1]),
     ylab = "Приросты числа заболевших, чел")
lines(x = diff_russia12_x,
      y = exp(gmp12_alpha * diff_russia12_x + gmp12_beta) *
        cumsum(diff_russia12_y), col = "red")
abline(v = (log(-gmp12_alpha) - gmp12_beta) / gmp12_alpha, col = "red")
grid()
dev.off()

# Отображение модели на первый интервал полностью
png(file = paste0(plot_dir, "/gmp12_wgmp_full.png"), width = 1000, height = 900, res = 90)
plot(x = df_Russia$rownum, y = df_Russia$diff_conf,
     col = "black", type = "o", pch = 19, cex = I(0.8), lwd = I(0.5),
     main = "График динамики заражений Covid19 в России",
     xlab = paste0("Дни с даты ", df_Russia$date[1]),
     ylab = "Прирост заболевших, чел",
     xlim = c(0, max(df_Russia$rownum) + predict_forward))
abline(v = date_max + period * (-3:2), col = "orange")
text(x = date_max + period * (-3:2) - 20, y = 2500,
     labels = c(df_Russia$date[date_max + period * (-2)] - period,
                df_Russia$date[date_max + period * (-2:1)],
                df_Russia$date[date_max + period] + period))
lines(x = df_Russia$rownum,
      y = exp(gmp12_alpha * df_Russia$rownum + gmp12_beta) *
        cumsum(df_Russia$diff_conf), col = "red")
abline(v = (log(-gmp12_alpha) - gmp12_beta) / gmp12_alpha, col = "red")
grid()
dev.off()

# Отнимем от всей зависимости первого Гомперца и начнём строить второго
df_Russia$wo_gmp1 <- df_Russia$diff_conf - exp(gmp12_alpha * df_Russia$rownum + gmp12_beta) *
  cumsum(df_Russia$diff_conf)

png(file = paste0(plot_dir, "/gmp12_without_gmp1_full.png"), width = 1000, height = 900, res = 90)
plot(x = df_Russia$rownum, y = df_Russia$wo_gmp1,
     col = "black", type = "o", pch = 19, cex = I(0.8), lwd = I(0.5),
     main = "График динамики заражений Covid19 в России",
     xlab = paste0("Дни с даты ", df_Russia$date[1]),
     ylab = "Прирост заболевших, чел",
     xlim = c(0, max(df_Russia$rownum) + predict_forward))
abline(v = date_max + period * (-3:2), col = "orange")
text(x = date_max + period * (-3:2) - 20, y = 2500,
     labels = c(df_Russia$date[date_max + period * (-2)] - period,
                df_Russia$date[date_max + period * (-2:1)],
                df_Russia$date[date_max + period] + period))
grid()
dev.off()


# Гомперц 2 ---------------------------------------------------------------
png(file = paste0(plot_dir, "/gmp34_a.png"), width = 1000, height = 900, res = 90)
plot(x = df_Russia$rownum, y = log(df_Russia$wo_gmp1 / cumsum(df_Russia$wo_gmp1)))
gmp12_2_alpha <- -0.021
gmp12_2_beta <- 2.8
abline(a = gmp12_2_beta, b = gmp12_2_alpha)
abline(h = log(-gmp12_2_alpha))
arrows(x0 = (log(-gmp12_2_alpha) - gmp12_2_beta) / gmp12_2_alpha,
       x1 = (log(-gmp12_2_alpha) - gmp12_2_beta) / gmp12_2_alpha,
       y0 = log(-gmp12_2_alpha),
       y1 = 0)
text(x = (log(-gmp12_2_alpha) - gmp12_2_beta) / gmp12_2_alpha, y = 0,
     labels = df_Russia$date[round((log(-gmp12_2_alpha) - gmp12_2_beta) / gmp12_2_alpha)])
grid()
dev.off()


stl_model1 <- stl(ts(log(df_Russia$diff_conf[interval4]), frequency = 7), s.window = "periodic")
stl_matrix1 <- as.matrix(stl_model1$time.series)

# df_Russia$wo_gmp1[1:(which.max(df_Russia$diff_conf[c(interval1, interval2)]) + 36)] <- 0
# Гомперц 2
png(file = paste0(plot_dir, "/gmp34.png"), width = 1000, height = 900, res = 90)
plot(x = df_Russia$rownum, y = df_Russia$wo_gmp1,
     col = "black", type = "o", pch = 19, cex = I(0.8), lwd = I(0.5),
     main = "График динамики заражений Covid19 в России",
     xlab = paste0("Дни с даты ", df_Russia$date[1]),
     ylab = "Прирост заболевших, чел",
     xlim = c(0, max(df_Russia$rownum) + predict_forward))
abline(v = date_max + period * (-3:2), col = "orange")
text(x = date_max + period * (-3:2) - 20, y = 2500,
     labels = c(df_Russia$date[date_max + period * (-2)] - period,
                df_Russia$date[date_max + period * (-2:1)],
                df_Russia$date[date_max + period] + period))
lines(x = df_Russia$rownum,
      y = exp(gmp12_2_alpha * df_Russia$rownum + gmp12_2_beta) *
        cumsum(df_Russia$wo_gmp1), col = "purple")
lines(x = df_Russia$rownum + 50,
      y = exp(gmp12_2_alpha * df_Russia$rownum + gmp12_2_beta) *
        cumsum(df_Russia$wo_gmp1), col = "blue")
abline(h = min(df_Russia$diff_conf[interval4]) * c(1, exp(1)), lty = 2, col = "red")
text(x = df_Russia$rownum[max(interval4)],
     y = min(df_Russia$diff_conf[interval4]) * c(1, exp(1)) - 700,
     labels = round(min(df_Russia$diff_conf[interval4]) * c(1, exp(1))) - 700)
abline(h = max(df_Russia$diff_conf), col = "red", lty = 2)
text(x = which.max(df_Russia$diff_conf) + 26, y = max(df_Russia$diff_conf) - 700,
     labels = max(df_Russia$diff_conf))
abline(v = c(df_Russia$rownum[max(interval3)],
             df_Russia$rownum[max(interval3)] + 36),
       col = "red", lty = 2)
lines(x = 1:length(c(interval4,interval4)) + max(interval3),
      y = exp(log(lm1$coefficients[1] +
                    lm1$coefficients[2] * (1:length(c(interval4,interval4))) +
                    lm1$coefficients[3] * (1:length(c(interval4,interval4)))^2) +
                c(stl_matrix1[,1], stl_matrix1[,1])),
      col = "orange")
grid()
dev.off()

# Парабола прогноз
png(file = paste0(plot_dir, "/prog_test.png"), width = 1000, height = 900, res = 90)
plot(x = 1:length(interval4),
     y = df_Russia$diff_conf[interval4],
     xlim = c(0, length(c(interval4,interval4))),
     type = "o", pch = 19, col = "red")
x_lm <- 1:length(interval4)
x_lm_2 <- x_lm^2
lm1 <- lm(df_Russia$diff_conf[interval4] ~ x_lm + x_lm_2)
lm1
lines(x = 1:length(c(interval4,interval4)), y = exp(log(lm1$coefficients[1] + lm1$coefficients[2] * (1:length(c(interval4,interval4))) + lm1$coefficients[3] * (1:length(c(interval4,interval4)))^2) + c(stl_matrix1[,1], stl_matrix1[,1])))
grid()
dev.off()


# Разность гомперца -------------------------------------------------------
diff_gomp <- (df_Russia$wo_gmp1 - exp(gmp12_2_alpha * df_Russia$rownum + gmp12_2_beta) *
  cumsum(df_Russia$wo_gmp1))[interval4]

plot(log(diff_gomp), type = "o", col = "red", pch = 19)
abline(a = 3.4, b = 0.0435)


# Экспонента прогноза -----------------------------------------------------
exp_interval4 <- exp(3.4 + 0.0435 * 1:length(interval4))
plot(exp_interval4)


plot(x = df_Russia$rownum, y = df_Russia$wo_gmp1,
     col = "black", type = "o", pch = 19, cex = I(0.8), lwd = I(0.5),
     main = "График динамики заражений Covid19 в России",
     xlab = paste0("Дни с даты ", df_Russia$date[1]),
     ylab = "Прирост заболевших, чел",
     xlim = c(0, max(df_Russia$rownum) + predict_forward))
abline(v = date_max + period * (-3:2), col = "orange")
text(x = date_max + period * (-3:2) - 20, y = 2500,
     labels = c(df_Russia$date[date_max + period * (-2)] - period,
                df_Russia$date[date_max + period * (-2:1)],
                df_Russia$date[date_max + period] + period))
lines(x = df_Russia$rownum,
      y = exp(gmp12_2_alpha * df_Russia$rownum + gmp12_2_beta) *
        cumsum(df_Russia$wo_gmp1), col = "purple")
lines(x = df_Russia$rownum + 50,
      y = exp(gmp12_2_alpha * df_Russia$rownum + gmp12_2_beta) *
        cumsum(df_Russia$wo_gmp1), col = "blue")
abline(h = min(df_Russia$diff_conf[interval4]) * c(1, exp(1)), lty = 2, col = "red")
text(x = df_Russia$rownum[max(interval4)],
     y = min(df_Russia$diff_conf[interval4]) * c(1, exp(1)) - 700,
     labels = round(min(df_Russia$diff_conf[interval4]) * c(1, exp(1))) - 700)
abline(h = max(df_Russia$diff_conf), col = "red", lty = 2)
text(x = which.max(df_Russia$diff_conf) + 26, y = max(df_Russia$diff_conf) - 700,
     labels = max(df_Russia$diff_conf))
abline(v = c(df_Russia$rownum[max(interval3)],
             df_Russia$rownum[max(interval3)] + 36),
       col = "red", lty = 2)
lines(x = interval4, y = (exp(gmp12_2_alpha * df_Russia$rownum + gmp12_2_beta) *
                            cumsum(df_Russia$wo_gmp1))[interval4] + exp_interval4,
      col = "green4")
grid()


# Интервальное преобразование для второго горба по Гомперцу ---------------
gmp_diff2_it <- df_Russia$wo_gmp1[(date_max - period - 10):nrow(df_Russia)]
gmp_diff2 <- gmp_diff2_it - min(gmp_diff2_it)

# График второго горба ----------------------------------------------------
plot(gmp_diff2, type = "o", pch = 19)

# Анаморфоза Гомперца -----------------------------------------------------
plot(log(gmp_diff2 / cumsum(gmp_diff2)))
gmp_diff2_alpha <- -0.0222
gmp_diff2_beta <- -1.44
abline(a = gmp_diff2_beta, b = gmp_diff2_alpha)

# Аппроксимация второго горба функцией Гомперца ---------------------------
gmp_diff2_approx <- exp(gmp_diff2_alpha * 1:length(gmp_diff2) + gmp_diff2_beta) * cumsum(gmp_diff2)
plot(gmp_diff2, type = "o", pch = 19)
lines(x = 1:length(gmp_diff2_it), y = gmp_diff2_approx)


# Анаморфоза для поиска y_inf ---------------------------------------------
plot(y = gmp_diff2 / cumsum(gmp_diff2), x = log(cumsum(gmp_diff2)),
     ylim = c(0, 0.2), xlim = c(8, 17), cex = I(0.6), pch = 19)
a <- -0.02
b <-  0.29876
abline(col = "red",
       a = b, b = a)
abline(h = 0, col = "red")
abline(v = -b / a, col = "red")
y_inf <- exp(-b / a)


# Отрисовка кумулятивной суммы --------------------------------------------
plot(cumsum(gmp_diff2), xlim = c(0, 400), ylim = c(0, y_inf))

future <- 200
predict_gmp <- function(ts_last, k, pred_forecast, y_inf) {
  forecast_future <- numeric(length = pred_forecast)
  for (i in 1:pred_forecast) {
    forecast_future[i] <- exp(-k * i) * log(ts_last) + (1 - exp(-k * i)) * log(y_inf)
  }
  return(forecast_future)
}

future_gmp = exp(predict_gmp(ts_last = cumsum(gmp_diff2)[length(gmp_diff2)],
                             k = -gmp_diff2_alpha, pred_forecast = future, y_inf = y_inf))
plot(cumsum(gmp_diff2), xlim = c(0, 400), ylim = c(0, y_inf))
lines(x = (length(gmp_diff2) + 1):(length(gmp_diff2) + future), y = future_gmp, col = "red")
abline(h = y_inf)

gmp_itog2 <- c(rep(0, max((date_max - period - 11))),
               exp(gmp_diff2_alpha *
                     1:length(gmp_diff2) +
                     gmp_diff2_beta) *
                 cumsum(gmp_diff2) +
                 min(gmp_diff2_it))

png(file = paste0(plot_dir, "/gmp_full.png"), width = 1000, height = 900, res = 90)
plot(x = df_Russia$rownum, y = df_Russia$diff_conf,
     col = "black", type = "o", pch = 19, cex = I(0.8), lwd = I(0.5),
     main = "График динамики заражений Covid19 в России",
     xlab = paste0("Дни с даты ", df_Russia$date[1]),
     ylab = "Прирост заболевших, чел",
     xlim = c(0, max(df_Russia$rownum) + predict_forward))
abline(v = date_max + period * (-3:2), col = "orange")
text(x = date_max + period * (-3:2) - 20, y = 2500,
     labels = c(df_Russia$date[date_max + period * (-2)] - period,
                df_Russia$date[date_max + period * (-2:1)],
                df_Russia$date[date_max + period] + period))
abline(h = min(df_Russia$diff_conf[interval4]) * c(1, exp(1)), lty = 2, col = "red")
text(x = df_Russia$rownum[max(interval4)],
     y = min(df_Russia$diff_conf[interval4]) * c(1, exp(1)) - 700,
     labels = round(min(df_Russia$diff_conf[interval4]) * c(1, exp(1))) - 700)
abline(h = max(df_Russia$diff_conf), col = "red", lty = 2)
text(x = which.max(df_Russia$diff_conf) + 26, y = max(df_Russia$diff_conf) - 700,
     labels = max(df_Russia$diff_conf))
abline(v = c(df_Russia$rownum[max(interval3)],
             df_Russia$rownum[max(interval3)] + 36),
       col = "red", lty = 2)
grid()
lines(gmp_itog2 + exp(gmp12_alpha * df_Russia$rownum + gmp12_beta) *
        cumsum(df_Russia$diff_conf), col = "blue")
lines(x = max(interval4):(max(interval4) + future - 2),
      y = diff(future_gmp) + min(gmp_diff2_it), col = "red")
dev.off()


# Статический разрез ------------------------------------------------------
if (!dir.exists("output_pngs/Russia/diff_hist")) {
  dir.create("output_pngs/Russia/diff_hist")
}
n_digits <- function(number) {
  return(nchar(as.character(number)))
}
hist_breaks <- 100
for (i in 1:hist_breaks) {
  number_string <- paste0(rep(0, n_digits(hist_breaks) - n_digits(i)), i)
  png(filename = paste0("output_pngs/Russia/diff_hist/hist", number_string,".png"),
      width = 900, height = 900, res = 90)
  hist(x = df_Russia$diff_conf, breaks = i)
  dev.off()
}
