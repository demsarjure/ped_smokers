# libraries --------------------------------------------------------------------
library(readxl)
library(tidyverse)

# load xlsx, filter and convert to csv -----------------------------------------
# data.xlsx is not included as it includes potentially sensitive information
xls_demographics <- read_excel("data/data.xlsx", sheet = 1)

df_demographics <- tibble(
  id = sprintf("P%02d", seq_len(nrow(xls_demographics))),
  smoker = if_else(xls_demographics$KADILSTVO == "NE", 0L, 1L),
  sex = if_else(xls_demographics$SPOL == "M", 1L, 0L)
)

# save
write.table(df_demographics, "data/demographics.csv", sep = ",", row.names = FALSE)
