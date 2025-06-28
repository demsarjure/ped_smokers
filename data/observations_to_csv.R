# libraries --------------------------------------------------------------------
library(tidyverse)

# load individual observations, summarize and store as csv ---------------------
n <- 27

df_observations <- tibble(
  id = character(),
  awake = numeric(),
  drowsy = numeric(),
  rem = numeric(),
  peaceful_sleep = numeric(),
  duration = numeric()
)

for (i in seq_len(n)) {
  # load
  id <- sprintf("P%02d", i)
  obs <- scan(paste0("data/observations/observation_", id, ".tsv"), what = numeric(), sep = "\t", quiet = TRUE)

  # summarize
  # 1 - awake
  # 2 - drowsy
  # 3 - rem
  # 4 - peaceful sleep
  duration <- length(obs)
  awake <- sum(obs == 1) / duration
  drowsy <- sum(obs == 2) / duration
  rem <- sum(obs == 3) / duration
  peaceful_sleep <- sum(obs == 4) / duration

  df_observations <- add_row(
    df_observations,
    id = id,
    awake = awake,
    drowsy = drowsy,
    rem = rem,
    peaceful_sleep = peaceful_sleep,
    duration = duration
  )
}

# save
write.table(df_observations, "data/observations.csv", sep = ",", row.names = FALSE)
