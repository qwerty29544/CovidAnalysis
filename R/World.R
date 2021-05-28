df_confirmed <- read.csv("./output_csv/data_conf_output.csv")
df_confirmed$date <- as.Date(df_confirmed$date)
df_confirmed$World <- rowSums(df_confirmed[, 3:ncol(df_confirmed)])
plot(diff(df_confirmed$World), type = "o", cex = I(0.5))
grid()

plot(1/diff(df_confirmed$World[(nrow(df_confirmed) - 100):nrow(df_confirmed)]) * 10e6, type = "o", cex = I(0.5),
     ylim = c(0,50),
     xlim = c(0, 150)
     )
abline(a = 50, b = -0.38)
abline(v = -50 / (-0.38))
abline(h = 0)
grid()

df_confirmed$date[1] + (nrow(df_confirmed) - 100 - 50 / (-0.38))

plot(x = seq(1, length(interval4), 1), df_Russia$diff_conf[interval4], type = "o", pch = 19)
abline(v = seq(1, length(interval2) + 5, 5), lty = 2)
