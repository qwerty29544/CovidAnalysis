
# create dirs -------------------------------------------------------------
plot_dir = "output_pngs/Russia/Analysis"
if (!dir.exists(plot_dir)) {
  dir.create(plot_dir)
}


# dynamics ----------------------------------------------------------------
df_confirmed <- read.csv("./output_csv/data_conf_output.csv")
df_confirmed$date <- as.Date(df_confirmed$date)


# Russia subsetting -------------------------------------------------------
df_Russia <- df_confirmed %>% dplyr::select(date, contains("Russia")) %>%
  dplyr::mutate(diff_conf = c(0, diff(Russia.)), log_diff = log(diff_conf + 1))

rm("df_confirmed")


# plots -------------------------------------------------------------------

