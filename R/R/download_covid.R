# Подключение пакетов -----------------------------------------------------
library(dplyr)    # Обработка фреймов
library(tidyr)    # Пакет для приведения данных в порядок
library(stringr)  # Пакет для обработки строк
library(openxlsx) # Пакет для экспорта данных в xlsx

# Загрузка данных ---------------------------------------------------------
df <- read.csv(file = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv")
df_deaths <- read.csv(file = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")
df_recovered <- read.csv(file = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv")

# Исследование данных -----------------------------------------------------

# Имена столбцов показывают, что данные о Covid19 обновляются путём добавления
# столбцов каждый день
#
# Строк 273, что соответствует локациям, в которых проводятся подсчёты
# статистики числа заболевших
#
# О странах известно, в каких точных (до второго знака)
# координатах они находятся
#
# Типы полей - целочисленные


# Слияние колонок страна/регион -------------------------------------------

# Создадим новую колонку из двух старых
df <- tidyr::unite(data = df,
                   col = "Country/Province",
                   sep = "/",
                   Country.Region,
                   Province.State)
df_deaths <- tidyr::unite(data = df_deaths,
                          col = "Country/Province",
                          sep = "/",
                          Country.Region,
                          Province.State)
df_recovered <- tidyr::unite(data = df_recovered,
                             col = "Country/Province",
                             sep = "/",
                             Country.Region,
                             Province.State)

# Создание дополнительного фрейма данных с метаданными о странах ----------

#“Страна/Регион”
#Широта
#Долгота
#Сумма заболевших
#Среднее число заболевших
#Стандартное отклонение числа заболевших

# Сохраним названия в отдельный вектор
country_names <- df$`Country/Province`
country_names_deaths <- df_deaths$`Country/Province`
country_names_recovered <- df_recovered$`Country/Province`

# Сохраним даты в отдельный вектор
test_dates <- colnames(df)[4:ncol(df)]

# Сохраним в отдельный df информацию о странах и описательные статистики
df_meta <- data.frame(df[, 1:3],
                      pos_mean = apply(as.matrix(df[, 4:ncol(df)]), 1, mean),
                      pos_std = apply(as.matrix(df[, 4:ncol(df)]), 1, mean),
                      pos_sum = apply(as.matrix(df[, 4:ncol(df)]), 1, sum))
df_deaths_meta <- data.frame(df_deaths[, 1:3],
                             pos_mean = apply(as.matrix(df[, 4:ncol(df)]), 1, mean),
                             pos_std = apply(as.matrix(df[, 4:ncol(df)]), 1, mean),
                             pos_sum = apply(as.matrix(df[, 4:ncol(df)]), 1, sum))
df_recovered_meta <- data.frame(df[, 1:3],
                                pos_mean = apply(as.matrix(df[, 4:ncol(df)]), 1, mean),
                                pos_std = apply(as.matrix(df[, 4:ncol(df)]), 1, mean),
                                pos_sum = apply(as.matrix(df[, 4:ncol(df)]), 1, sum))


# Создание нового фрейма --------------------------------------------------

# 1. Обработка дат для приведения их к стандартному формату

# Избавимся от лишних символов
test_dates <- gsub("X", "", test_dates)

# Вытащим из вектора дат месяцы, дни и годы
months <- as.numeric(stringr::str_extract(string = test_dates,
                                          pattern = "^\\d+"))

days <- as.numeric(gsub(pattern = "\\.",
                        replacement = "",
                        x = stringr::str_extract(string = test_dates,
                                                 pattern = "\\.\\d+\\.")))

years <- 2000 + as.numeric(gsub(pattern = "\\.",
                                replacement = "",
                                x = stringr::str_extract(string = test_dates,
                                                         pattern = "\\.\\d+$")))

# Преобразуем их к единому формату дат
date_time <- ISOdate(year = years, month = months, day = days)
date <- as.Date(date_time)

# Удаление переменных
rm("months", "days", "years", "test_dates", "date_time")

# 2. Транспонирование данных и приведение к новой таблице на основе исходной
# Измерения в исходном фрейме начинаются с 4 столбца, следовательно
# сделаем выборку всех строк по столбцам с 4 по последний и транспонируем,
# поскольку в пределах данного куска таблицы все данные однотипны
new_table <- data.frame(date = date,
                        t(as.matrix(df[,4:ncol(df)])),
                        row.names = 1:(ncol(df) - 3))
new_table_deaths <- data.frame(date = date,
                               t(as.matrix(df_deaths[,4:ncol(df_deaths)])),
                               row.names = 1:(ncol(df_deaths) - 3))
new_table_recovered <- data.frame(date = date,
                                  t(as.matrix(df_recovered[,4:ncol(df_recovered)])),
                                  row.names = 1:(ncol(df_recovered) - 3))

colnames(new_table) <- c("date", country_names)
colnames(new_table_deaths) <- c("date", country_names_deaths)
colnames(new_table_recovered) <- c("date", country_names_recovered)

# Экспорт -----------------------------------------------------------------
# Экспортируем подготовленные данные в csv-файл
if (!dir.exists("output_csv")) {
  dir.create("output_csv")
}
write.csv(x = new_table,
          file = "output_csv/data_conf_output.csv")
write.csv(x = df_meta,
          file = "output_csv/metadata_conf.csv")
write.csv(x = new_table_deaths,
          file = "output_csv/data_deaths_output.csv")
write.csv(x = df_deaths_meta,
          file = "output_csv/metadata_deaths.csv")
write.csv(x = new_table_recovered,
          file = "output_csv/data_recovered_output.csv")
write.csv(x = df_recovered_meta,
          file = "output_csv/metadata_recovered.csv")


# Экспортируем данные в xlsx
if (!dir.exists("output_xlsx")) {
  dir.create("output_xlsx")
}
openxlsx::write.xlsx(x = new_table,
                     file = "output_xlsx/data_conf_output.xlsx")
openxlsx::write.xlsx(x = df_meta,
                     file = "output_xlsx/metadata_conf.xlsx")
openxlsx::write.xlsx(x = new_table_deaths,
                     file = "output_xlsx/data_deaths_output.xlsx")
openxlsx::write.xlsx(x = df_deaths_meta,
                     file = "output_xlsx/metadata_deaths.xlsx")
openxlsx::write.xlsx(x = new_table_recovered,
                     file = "output_xlsx/data_recovered_output.xlsx")
openxlsx::write.xlsx(x = df_recovered_meta,
                     file = "output_xlsx/metadata_recovered.xlsx")


# Удаление данных сессии --------------------------------------------------
rm(list = ls())
