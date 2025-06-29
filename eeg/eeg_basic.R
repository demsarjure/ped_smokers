# libraries --------------------------------------------------------------------
library(tidyverse)
library(cowplot)

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
plot_comparison_two_normal(
  fit1 = fit_sef_s, label1 = "Kadilke", fit2 = fit_sef_ns, label2 = "Nekadilke"
) + ggtitle("SEF 90") + xlab("Povprečna vrednost SEF 90 [Hz]")

ggsave(
  paste0("./figs/eeg_sef.png"),
  width = 1080,
  height = 540,
  dpi = 100,
  units = "px",
  bg = "white"
)

# delta power ------------------------------------------------------------------
fit_delta_s <- fit_normal(df_smokers$delta, robust = TRUE)
fit_delta_ns <- fit_normal(df_non_smokers$delta, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_delta_s, label1 = "smoker", fit2 = fit_delta_ns, label2 = "non-smoker"
)
p_delta <- plot_comparison_two_normal(
  fit1 = fit_delta_s, label1 = "Kadilke", fit2 = fit_delta_ns, label2 = "Nekadilke"
) + ggtitle("Delta pas [0,5 - 4 Hz]") + xlab("Relativna moč delta pasu")

# theta power ------------------------------------------------------------------
fit_theta_s <- fit_normal(df_smokers$theta, robust = TRUE)
fit_theta_ns <- fit_normal(df_non_smokers$theta, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_theta_s, label1 = "smoker", fit2 = fit_theta_ns, label2 = "non-smoker"
)
p_theta <- plot_comparison_two_normal(
  fit1 = fit_theta_s, label1 = "Kadilke", fit2 = fit_theta_ns, label2 = "Nekadilke"
) + ggtitle("Theta pas [4 - 8 Hz]") + xlab("Relativna moč theta pasu")

# alpha power ------------------------------------------------------------------
fit_alpha_s <- fit_normal(df_smokers$alpha, robust = TRUE)
fit_alpha_ns <- fit_normal(df_non_smokers$alpha, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_alpha_s, label1 = "smoker", fit2 = fit_alpha_ns, label2 = "non-smoker"
)
p_alpha <- plot_comparison_two_normal(
  fit1 = fit_alpha_s, label1 = "Kadilke", fit2 = fit_alpha_ns, label2 = "Nekadilke"
) + ggtitle("Alfa pas [8 - 13 Hz]") + xlab("Relativna moč alfa pasu")

# beta power -------------------------------------------------------------------
fit_beta_s <- fit_normal(df_smokers$beta, robust = TRUE)
fit_beta_ns <- fit_normal(df_non_smokers$beta, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_beta_s, label1 = "smoker", fit2 = fit_beta_ns, label2 = "non-smoker"
)
p_beta <- plot_comparison_two_normal(
  fit1 = fit_beta_s, label1 = "Kadilke", fit2 = fit_beta_ns, label2 = "Nekadilke"
) + ggtitle("Beta pas [13 - 30 Hz]") + xlab("Relativna moč beta pasu")

# plot all together ------------------------------------------------------------
plot_grid(
  p_delta, p_theta, p_alpha, p_beta,
  ncol = 2, nrow = 2, scale = 0.9
)

ggsave(
  paste0("./figs/eeg_bands.png"),
  width = 1080,
  height = 540,
  dpi = 100,
  units = "px",
  bg = "white"
)
