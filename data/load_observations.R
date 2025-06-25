# libraries --------------------------------------------------------------------
library(tidyverse)

# load observations.csv and demographics.csv, join on id -----------------------
df_observations <- read_csv("data/observations.csv")
df_demographics <- read_csv("data/demographics.csv")
df_observations <- df_observations %>%
  left_join(df_demographics, by = "id")

# split to smokers and non-smokers ---------------------------------------------
df_smokers <- df_observations %>%
  filter(smoker == 1)

df_non_smokers <- df_observations %>%
  filter(smoker == 0)
