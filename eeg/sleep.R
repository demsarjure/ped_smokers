# libraries and utils ----------------------------------------------------------
library(tidyverse)

source("./utils/normal.R")

# load data --------------------------------------------------------------------
df_sleep <- read_csv("./data/sleep.csv")

# pairs ------------------------------------------------------------------------
df_smokers <- df_sleep %>%
  filter(smoker == 1)
df_non_smokers <- df_sleep %>%
  filter(smoker == 0)

# sw ---------------------------------------------------------------------------
fit_sw_s <- fit_normal(df_smokers$ta, robust = TRUE)
fit_sw_ns <- fit_normal(df_non_smokers$ta, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_sw_s, label1 = "smoker", fit2 = fit_sw_ns, label2 = "non-smoker"
)

# en
plot_comparison_two_normal(
  fit1 = fit_sw_s, label1 = "Smoker", fit2 = fit_sw_ns, label2 = "Non-smoker"
) + ggtitle("Sleep duration") + xlab("Duration (hours)")
ggsave(
  paste0("./figs/ta.png"),
  width = 1080,
  height = 540,
  dpi = 100,
  units = "px",
  bg = "white"
)

# si
plot_comparison_two_normal(
  fit1 = fit_sw_s, label1 = "Kadilke", fit2 = fit_sw_ns, label2 = "Nekadilke"
) + ggtitle("Delež mirnega spanja") + xlab("Delež")
ggsave(
  paste0("./figs/ta_si.png"),
  width = 1080,
  height = 540,
  dpi = 100,
  units = "px",
  bg = "white"
)
