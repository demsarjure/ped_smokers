# libraries --------------------------------------------------------------------
library(tidyverse)

source("utils/normal.R")

# data -------------------------------------------------------------------------
df_spectral <- read_csv("data/spectral.csv")

# split
df_smokers <- df_spectral %>%
  filter(smoker == 1)

df_non_smokers <- df_spectral %>%
  filter(smoker == 0)

# sef --------------------------------------------------------------------------
fit_sef_s <- fit_normal(df_smokers$sef, robust = TRUE)
fit_sef_ns <- fit_normal(df_non_smokers$sef, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_sef_s, label1 = "smoker", fit2 = fit_sef_ns, label2 = "non-smoker"
)

# delta power ------------------------------------------------------------------
fit_delta_s <- fit_normal(df_smokers$delta, robust = TRUE)
fit_delta_ns <- fit_normal(df_non_smokers$delta, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_delta_s, label1 = "smoker", fit2 = fit_delta_ns, label2 = "non-smoker"
)

# theta power ------------------------------------------------------------------
fit_theta_s <- fit_normal(df_smokers$theta, robust = TRUE)
fit_theta_ns <- fit_normal(df_non_smokers$theta, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_theta_s, label1 = "smoker", fit2 = fit_theta_ns, label2 = "non-smoker"
)

# alpha power ------------------------------------------------------------------
fit_alpha_s <- fit_normal(df_smokers$alpha, robust = TRUE)
fit_alpha_ns <- fit_normal(df_non_smokers$alpha, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_alpha_s, label1 = "smoker", fit2 = fit_alpha_ns, label2 = "non-smoker"
)

# beta power -------------------------------------------------------------------
fit_beta_s <- fit_normal(df_smokers$beta, robust = TRUE)
fit_beta_ns <- fit_normal(df_non_smokers$beta, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_beta_s, label1 = "smoker", fit2 = fit_beta_ns, label2 = "non-smoker"
)
