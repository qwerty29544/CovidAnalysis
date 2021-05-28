library(dplyr)
countries = list(Belarus = "Belarus",
                 Ukraine = "Ukraine", Egypt = "Egypt",
                 Cyprus = "Cyprus", Turkey = "Turkey",
                 Greece = "Greece", Italy = "Italy",
                 Poland = "Poland", Japan = "Japan",
                 Azerbaijan = "Azerbaijan", Finland = "Finland",
                 Norway = "Norway", Georgia = "Georgia",
                 Latvia = "Latvia", Estonia = "Estonia",
                 Uzbekistan = "Uzbekistan")

min_max <- function(x){
  x <- sapply(X = x , FUN = function(c) replace(x = c, list = is.infinite(c), values = 0))
  return((x - min(x, na.rm = T)) / (max(x, na.rm = T) - min(x, na.rm = T)))
}

path <- "output_pngs/Russia/Pairs/"
if (!dir.exists(path)) {
  dir.create(path)
}

iter <- 0
for (country in countries) {
  iter <- iter + 1
  df1 <- select(df_confirmed[-(1:89), ], contains("Russia"))
  df2 <- select(df_confirmed[-(1:89), ], contains(country))
  #----------------------------------------------------------------------------
  png(filename = paste0(path, "xy_pair", iter,".png"), width = 800, height = 800)
  plot(y = min_max(log(diff(df1[[1]]))),
     x = min_max(log(diff(df2[[1]]))),
     type = 'p',
     ylab = "log(Russia)",
     xlab = paste0("log(", country, ")"))
  dev.off()
  #----------------------------------------------------------------------------
  png(filename = paste0(path, "xy_ts", iter,".png"), width = 800, height = 800)
  corr_1 = cor((diff(df1[[1]])), (diff(df2[[1]])))
  plot(min_max(log(diff(df1[[1]]))), type = "p", col = "blue",
       main = corr_1, pch = 19)
  lines(min_max(log(diff(df2[[1]]))), type = "p", col = "red", pch = 19)
  legend(x = 10, y = 0.9, legend = c("Russia", country),
         col = c("blue", "red"), lty = c(1, 1))
  dev.off()

  png(filename = paste0(path, "two_in_one", iter, ".png"), width = 1600, height = 800)
  par(mfrow = c(1, 2))
  corr_1 = cor((diff(df1[[1]])), (diff(df2[[1]])))
  plot(min_max(log(diff(df1[[1]]))), type = "p", col = "blue",
       main = corr_1, pch = 19)
  lines(min_max(log(diff(df2[[1]]))), type = "p", col = "red", pch = 19)
  legend(x = 10, y = 0.9, legend = c("Russia", country),
         col = c("blue", "red"), lty = c(1, 1))
  abline(h = c(min(min_max(log(diff(df2[[1]])))),
               max(min_max(log(diff(df2[[1]]))))),
         col = "red", lty = 2, lwd = I(0.5))
  abline(h = c(min(min_max(log(diff(df1[[1]])))),
               max(min_max(log(diff(df1[[1]]))))),
         col = "blue", lty = 2, lwd = I(0.5))

  plot(y = min_max(log(diff(df1[[1]]))),
       x = min_max(log(diff(df2[[1]]))),
       type = 'p',
       ylab = "log(Russia)",
       xlab = paste0("log(", country, ")"))
  abline(v = c(min(min_max(log(diff(df2[[1]])))),
               max(min_max(log(diff(df2[[1]]))))),
         col = "red", lty = 2, lwd = I(0.5))
  abline(h = c(min(min_max(log(diff(df1[[1]])))),
               max(min_max(log(diff(df1[[1]]))))),
         col = "blue", lty = 2, lwd = I(0.5))
  dev.off()
  par(mfrow = c(1, 1))

  png(filename = paste0(path, "four_in_one", iter, ".png"), width = 1600, height = 1600)
  par(mfrow = c(2, 2))
  corr_1 = cor((diff(df1[[1]])), (diff(df2[[1]])))
  plot(y = min_max(log(diff(df1[[1]]))),
       x = 1:length(diff(df1[[1]])) ,
       type = "p", col = "blue",
       main = corr_1, pch = 19)
  abline(h = c(min(min_max(log(diff(df1[[1]])))),
               max(min_max(log(diff(df1[[1]]))))),
         col = "blue", lty = 2, lwd = I(0.5))

  plot(y = min_max(log(diff(df1[[1]]))),
       x = min_max(log(diff(df2[[1]]))),
       type = 'p',
       ylab = "log(Russia)",
       xlab = paste0("log(", country, ")"))
  abline(v = c(min(min_max(log(diff(df2[[1]])))),
               max(min_max(log(diff(df2[[1]]))))),
         col = "red", lty = 2, lwd = I(0.5))
  abline(h = c(min(min_max(log(diff(df1[[1]])))),
               max(min_max(log(diff(df1[[1]]))))),
         col = "blue", lty = 2, lwd = I(0.5))
  plot(1, 1)

  plot(x = min_max(log(diff(df2[[1]]))),
       y = 1:length(diff(df2[[1]])),
       type = "p", col = "red", pch = 19)
  abline(v = c(min(min_max(log(diff(df2[[1]])))),
               max(min_max(log(diff(df2[[1]]))))),
         col = "red", lty = 2, lwd = I(0.5))

  dev.off()
  par(mfrow = c(1, 1))
}



path <- "output_pngs/Russia/Pairs2/"
if (!dir.exists(path)) {
  dir.create(path)
}


iter <- 0
for (country in countries) {
  iter <- iter + 1
  df1 <- select(df_confirmed, contains("Russia"))
  df2 <- select(df_confirmed, contains(country))
  #----------------------------------------------------------------------------
  png(filename = paste0(path, "1xy_pair", iter,".png"), width = 800, height = 800)
  plot(y = min_max(log(diff(df1[[1]]))),
       x = min_max(log(diff(df2[[1]]))),
       type = 'p',
       ylab = "log(Russia)",
       xlab = paste0("log(", country, ")"))
  dev.off()
  #----------------------------------------------------------------------------
  png(filename = paste0(path, "1xy_ts", iter,".png"), width = 800, height = 800)
  corr_1 = cor((diff(df1[[1]])), (diff(df2[[1]])))
  plot(min_max(log(diff(df1[[1]]))), type = "p", col = "blue",
       main = corr_1, pch = 19)
  lines(min_max(log(diff(df2[[1]]))), type = "p", col = "red", pch = 19)
  legend(x = 10, y = 0.9, legend = c("Russia", country),
         col = c("blue", "red"), lty = c(1, 1))
  dev.off()

  png(filename = paste0(path, "1two_in_one", iter, ".png"), width = 1600, height = 800)
  par(mfrow = c(1, 2))
  corr_1 = cor((diff(df1[[1]])), (diff(df2[[1]])))
  plot((log(diff(df1[[1]]))), type = "p", col = "blue",
       main = corr_1, pch = 19)
  par(new = T)
  plot((log(diff(df2[[1]]))), type = "p",
       col = "red", pch = 19,
       axes = F, xlab = "", ylab = "")
  axis(4, ylim = c(0,7000), col="red", col.axis="red",las=1)
  legend(x = 10, y = 0.9, legend = c("Russia", country),
         col = c("blue", "red"), lty = c(1, 1))
  abline(h = c(min((log(diff(df2[[1]])))),
               max((log(diff(df2[[1]]))))),
         col = "red", lty = 2, lwd = I(0.5))
  abline(h = c(min((log(diff(df1[[1]])))),
               max((log(diff(df1[[1]]))))),
         col = "blue", lty = 2, lwd = I(0.5))

  plot(y = (log(diff(df1[[1]]))),
       x = (log(diff(df2[[1]]))),
       type = 'p',
       ylab = "log(Russia)",
       xlab = paste0("log(", country, ")"))
  abline(v = c(min((log(diff(df2[[1]])))),
               max((log(diff(df2[[1]]))))),
         col = "red", lty = 2, lwd = I(0.5))
  abline(h = c(min((log(diff(df1[[1]])))),
               max((log(diff(df1[[1]]))))),
         col = "blue", lty = 2, lwd = I(0.5))
  dev.off()
  par(mfrow = c(1, 1))

}

df1 <- select(df_confirmed, contains("Egypt"))
df2 <- select(df_confirmed, contains("Belarus"))
png(filename = paste0("1two_in_one", iter, ".png"), width = 1600, height = 800)
par(mfrow = c(1, 2))
corr_1 = cor((diff(df1[[1]])), (diff(df2[[1]])))
plot(y = (log(diff(df1[[1]]))), x = 1:length((log(diff(df1[[1]])))), type = "p", col = "blue",
     main = corr_1, pch = 19)
lines(y = (log(diff(df2[[1]]))), x = 1:length((log(diff(df2[[1]])))) + 30, type = "p",
     col = "red")
axis(4, ylim = c(0,7000), col="red", col.axis="red",las=1)
legend(x = 10, y = 0.9, legend = c("Russia", country),
       col = c("blue", "red"), lty = c(1, 1))
abline(h = c(min((log(diff(df2[[1]])))),
             max((log(diff(df2[[1]]))))),
       col = "red", lty = 2, lwd = I(0.5))
abline(h = c(min((log(diff(df1[[1]])))),
             max((log(diff(df1[[1]]))))),
       col = "blue", lty = 2, lwd = I(0.5))

plot(y = (log(diff(df1[[1]]))),
     x = (log(diff(df2[[1]]))),
     type = 'p',
     ylab = "log(Russia)",
     xlab = paste0("log(", country, ")"))
abline(v = c(min((log(diff(df2[[1]])))),
             max((log(diff(df2[[1]]))))),
       col = "red", lty = 2, lwd = I(0.5))
abline(h = c(min((log(diff(df1[[1]])))),
             max((log(diff(df1[[1]]))))),
       col = "blue", lty = 2, lwd = I(0.5))
dev.off()
par(mfrow = c(1, 1))
