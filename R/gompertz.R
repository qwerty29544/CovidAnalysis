quantmod::getSymbols(src = "yahoo", from = "2020-09-21", to = "2021-04-19", Symbols = "ATVI")
df <- get("ATVI")

df <- log(df[, "ATVI.Close"])
df_gomp <- data.frame(df[-(1:20), ])
plot(log((df_gomp$ATVI.Close - min(df_gomp$ATVI.Close))/cumsum(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close))))
abline(a = -2.4, b  =-0.017)
plot(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close))
lines(x = 1:nrow(df_gomp), y = df_gomp$ATVI.Close - min(df_gomp$ATVI.Close))
lines(x = 1:nrow(df_gomp), y = exp(-2.4 + -0.017 * 1:nrow(df_gomp)) * cumsum(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close)))

plot(x = 1:nrow(df_gomp), y = exp(-2.4 + -0.017 * 1:nrow(df_gomp)) * cumsum(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close)))
plot(x = 1:nrow(df_gomp), y = cumsum(exp(-2.4 + -0.017 * 1:nrow(df_gomp)) * cumsum(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close))))
plot(x = 1:nrow(df_gomp), y = df_gomp$ATVI.Close - min(df_gomp$ATVI.Close) - exp(-2.4 + -0.017 * 1:nrow(df_gomp)) * cumsum(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close)))


plot(IMSSLAER::MariaRemark.Alter_Johns(IMSSLAER::MariaRemark.out_of_trend(ts = df_gomp$ATVI.Close - min(df_gomp$ATVI.Close) - exp(-2.4 + -0.017 * 1:nrow(df_gomp)) * cumsum(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close)), delta = 3, mode = "GP_lin")), type = "o")
abline(v = 32)

model1 <- forecast::auto.arima(y = df_gomp$ATVI.Close - min(df_gomp$ATVI.Close) - exp(-2.4 + -0.017 * 1:nrow(df_gomp)) * cumsum(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close)))
future <- forecast::forecast(model1, h = 30)
forecast::autoplot(future)

stl_model <- stl(x = ts(data = df_gomp$ATVI.Close - min(df_gomp$ATVI.Close) - exp(-2.4 + -0.017 * 1:nrow(df_gomp)) * cumsum(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close)), frequency = 32), s.window = "periodic")
plot(stl_model)
stl_matrix <- as.matrix(stl_model$time.series)

plot(y = (df_gomp$ATVI.Close - min(df_gomp$ATVI.Close)) / cumsum(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close)), x = log(cumsum(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close))), type = "o", xlim = c(1, 4), ylim = c(0, 0.1))
abline(a = 0.075, b = -0.021)
abline(h = 0)
abline(v = 3.56)

y_inf = exp(3.56)
y_inf
plot(x = 1:nrow(df_gomp), y = cumsum(exp(-2.4 + -0.017 * 1:nrow(df_gomp)) * cumsum(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close))), ylim = c(0, y_inf), xlim = c(0, 200))

tau <- 1:30
ln_y_t_tau <- numeric(length(tau))
for (i in tau){
  ln_y_t_tau[tau] <- exp(-0.017 * tau) * log(cumsum(exp(-2.4 + -0.017 * 1:nrow(df_gomp)) * cumsum(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close)))[length(df_gomp$ATVI.Close)]) + (1 - exp(-0.017 * tau)) * log(y_inf)
}
plot(x = 1:nrow(df_gomp), y = cumsum(exp(-2.4 + -0.017 * 1:nrow(df_gomp)) * cumsum(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close))), ylim = c(0, y_inf), xlim = c(0, 200))
lines(x = tau + length(df_gomp$ATVI.Close), y = exp(ln_y_t_tau), col = "red")

gompertz_curve <- c(cumsum(exp(-2.4 + -0.017 * 1:nrow(df_gomp)) * cumsum(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close))), exp(ln_y_t_tau))
plot(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close), xlim = c(0, 160))
lines(x = 1:nrow(df_gomp), y = df_gomp$ATVI.Close - min(df_gomp$ATVI.Close), col = "blue")
lines(x = 1:nrow(df_gomp), y = exp(-2.4 + -0.017 * 1:nrow(df_gomp)) * cumsum(df_gomp$ATVI.Close - min(df_gomp$ATVI.Close)), col = "orange")
lines(x = tau[-length(tau)] + length(df_gomp$ATVI.Close), y = diff(gompertz_curve[tau + length(df_gomp$ATVI.Close)]) + 0.034 + stl_matrix[tau[-length(tau)], 1], col = "green")





# polynomial_prog ---------------------------------------------------------

plot(x = 1:nrow(df_gomp), y = df_gomp$ATVI.Close)
df_gomp <- data.frame(x = 1:nrow(df_gomp), x_quad = (1:nrow(df_gomp))^2,
                      x_triple = (1:nrow(df_gomp))^3, x_quadro = (1:nrow(df_gomp))^4, x_quinto = (1:nrow(df_gomp))^5, y = df_gomp$ATVI.Close)
model_poly <- lm(y ~ x + x_quad, data = df_gomp)
future_data <- data.frame(x = nrow(df_gomp) + tau, x_quad = (nrow(df_gomp) + tau)^2,
                          x_triple = (nrow(df_gomp) + tau)^3, x_quadro = (nrow(df_gomp) + tau)^4, x_quinto = (nrow(df_gomp) + tau)^5)
future <- predict(model_poly, future_data, se = T)

plot(x = 1:nrow(df_gomp), y = df_gomp$y, xlim = c(0, nrow(df_gomp) + tau[length(tau)]), type = "o", col = "blue")
lines(x = tau + nrow(df_gomp), y = future$fit, col = "green")
lines(x = tau + nrow(df_gomp), y = future$fit + future$se.fit, col = "darkgreen")
lines(x = tau + nrow(df_gomp), y = future$fit - future$se.fit, col = "darkgreen")
lines(model_poly$fitted.values, col = "orange")
