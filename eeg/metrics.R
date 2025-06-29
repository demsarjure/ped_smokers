# libraries and utils ----------------------------------------------------------
library(tidyverse)

source("./utils/normal.R")

# load data --------------------------------------------------------------------
df_metrics <- read_csv(paste0("./data/connectome_metrics.csv"))

# pairs ------------------------------------------------------------------------
df_smokers_delta <- df_metrics %>%
  filter(smoker == 1 & band == "delta")
df_non_smokers_delta <- df_metrics %>%
  filter(smoker == 0 & band == "delta")

df_smokers_theta <- df_metrics %>%
  filter(smoker == 1 & band == "theta")
df_non_smokers_theta <- df_metrics %>%
  filter(smoker == 0 & band == "theta")

df_smokers_alpha <- df_metrics %>%
  filter(smoker == 1 & band == "alpha")
df_non_smokers_alpha <- df_metrics %>%
  filter(smoker == 0 & band == "alpha")

# ge delta ---------------------------------------------------------------------
fit_ge_delta_s <- fit_normal(df_smokers_delta$ge, robust = TRUE)
fit_ge_delta_ns <- fit_normal(df_non_smokers_delta$ge, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_ge_delta_s, label1 = "smoker", fit2 = fit_ge_delta_ns, label2 = "non-smoker"
)

# cc delta ---------------------------------------------------------------------
fit_cc_delta_s <- fit_normal(df_smokers_delta$cc, robust = TRUE)
fit_cc_delta_ns <- fit_normal(df_non_smokers_delta$cc, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_cc_delta_s, label1 = "smoker", fit2 = fit_cc_delta_ns, label2 = "non-smoker"
)

# cas_r delta ------------------------------------------------------------------
fit_cas_r_delta_s <- fit_normal(df_smokers_delta$cas_r, robust = TRUE)
fit_cas_r_delta_ns <- fit_normal(df_non_smokers_delta$cas_r, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_cas_r_delta_s, label1 = "smoker", fit2 = fit_cas_r_delta_ns, label2 = "non-smoker"
)
plot_comparison_two_normal(
  fit1 = fit_cas_r_delta_s, label1 = "Kadilke", fit2 = fit_cas_r_delta_ns, label2 = "Nekadilke"
) + ggtitle("Funkcijska povezljivost, desna hemisfera, delta pas [0,5 - 4 Hz]") + xlab("Povprečna vrednost")

ggsave(
  paste0("./figs/cas_r_delta.png"),
  width = 1080,
  height = 540,
  dpi = 100,
  units = "px",
  bg = "white"
)


# cas_l delta ------------------------------------------------------------------
fit_cas_l_delta_s <- fit_normal(df_smokers_delta$cas_l, robust = TRUE)
fit_cas_l_delta_ns <- fit_normal(df_non_smokers_delta$cas_l, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_cas_l_delta_s, label1 = "smoker", fit2 = fit_cas_l_delta_ns, label2 = "non-smoker"
)

# ge theta ---------------------------------------------------------------------
fit_ge_theta_s <- fit_normal(df_smokers_theta$ge, robust = TRUE)
fit_ge_theta_ns <- fit_normal(df_non_smokers_theta$ge, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_ge_theta_s, label1 = "smoker", fit2 = fit_ge_theta_ns, label2 = "non-smoker"
)

# cc theta ---------------------------------------------------------------------
fit_cc_theta_s <- fit_normal(df_smokers_theta$cc, robust = TRUE)
fit_cc_theta_ns <- fit_normal(df_non_smokers_theta$cc, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_cc_theta_s, label1 = "smoker", fit2 = fit_cc_theta_ns, label2 = "non-smoker"
)

# cas_r theta ------------------------------------------------------------------
fit_cas_r_theta_s <- fit_normal(df_smokers_theta$cas_r, robust = TRUE)
fit_cas_r_theta_ns <- fit_normal(df_non_smokers_theta$cas_r, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_cas_r_theta_s, label1 = "smoker", fit2 = fit_cas_r_theta_ns, label2 = "non-smoker"
)

# cas_l theta ------------------------------------------------------------------
fit_cas_l_theta_s <- fit_normal(df_smokers_theta$cas_l, robust = TRUE)
fit_cas_l_theta_ns <- fit_normal(df_non_smokers_theta$cas_l, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_cas_l_theta_s, label1 = "smoker", fit2 = fit_cas_l_theta_ns, label2 = "non-smoker"
)

# ge alpha ---------------------------------------------------------------------
fit_ge_alpha_s <- fit_normal(df_smokers_alpha$ge, robust = TRUE)
fit_ge_alpha_ns <- fit_normal(df_non_smokers_alpha$ge, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_ge_alpha_s, label1 = "smoker", fit2 = fit_ge_alpha_ns, label2 = "non-smoker"
)
plot_comparison_two_normal(
  fit1 = fit_ge_alpha_s, label1 = "Kadilke", fit2 = fit_ge_alpha_ns, label2 = "Nekadilke"
) + ggtitle("Globalna učinkovitost, alpha pas [8 - 13 Hz]") + xlab("Povprečna vrednost")

ggsave(
  paste0("./figs/ge_alpha.png"),
  width = 1080,
  height = 540,
  dpi = 100,
  units = "px",
  bg = "white"
)

# cc alpha ---------------------------------------------------------------------
fit_cc_alpha_s <- fit_normal(df_smokers_alpha$cc, robust = TRUE)
fit_cc_alpha_ns <- fit_normal(df_non_smokers_alpha$cc, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_cc_alpha_s, label1 = "smoker", fit2 = fit_cc_alpha_ns, label2 = "non-smoker"
)

# cas_r alpha ------------------------------------------------------------------
fit_cas_r_alpha_s <- fit_normal(df_smokers_alpha$cas_r, robust = TRUE)
fit_cas_r_alpha_ns <- fit_normal(df_non_smokers_alpha$cas_r, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_cas_r_alpha_s, label1 = "smoker", fit2 = fit_cas_r_alpha_ns, label2 = "non-smoker"
)
plot_comparison_two_normal(
  fit1 = fit_cas_r_alpha_s, label1 = "Kadilke", fit2 = fit_cas_r_alpha_ns, label2 = "Nekadilke"
) + ggtitle("Funkcijska povezljivost, desna hemisfera, alfa pas [8 - 13 Hz]") + xlab("Povprečna vrednost")

ggsave(
  paste0("./figs/cas_r_alpha.png"),
  width = 1080,
  height = 540,
  dpi = 100,
  units = "px",
  bg = "white"
)

# cas_l alpha ------------------------------------------------------------------
fit_cas_l_alpha_s <- fit_normal(df_smokers_alpha$cas_l, robust = TRUE)
fit_cas_l_alpha_ns <- fit_normal(df_non_smokers_alpha$cas_l, robust = TRUE)
results <- compare_two_normal(
  fit1 = fit_cas_l_alpha_s, label1 = "smoker", fit2 = fit_cas_l_alpha_ns, label2 = "non-smoker"
)
