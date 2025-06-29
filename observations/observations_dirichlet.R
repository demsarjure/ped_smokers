# libraries --------------------------------------------------------------------
library(bayesplot)
library(cmdstanr)
library(ggplot2)
library(posterior)
library(tidyverse)
library(HDInterval)

# load the data and the model --------------------------------------------------
source("data/load_observations.R")


# fit --------------------------------------------------------------------------
model <- cmdstan_model("models/dirichlet.stan")

# 0 removal trick
y <- as.matrix(df_observations %>% select(awake, drowsy, rem, peaceful_sleep)) + 0.0001
y <- y / rowSums(y)

stan_data <- list(
  n = nrow(df_observations),
  k = 4,
  y = y,
  group = df_observations$smoker
)

fit <- model$sample(
  data = stan_data,
  parallel_chains = 4
)

mcmc_trace(fit$draws())
fit$summary()

# compare means ----------------------------------------------------------------
df_alpha_smoker <- as_draws_df(fit$draws("alpha_smoker"))
df_alpha_non_smoker <- as_draws_df(fit$draws("alpha_non_smoker"))

# drop .chain .iteration. draw
df_alpha_smoker <- df_alpha_smoker %>% select(-contains(c(".chain", ".iteration", ".draw")))
df_alpha_non_smoker <- df_alpha_non_smoker %>% select(-contains(c(".chain", ".iteration", ".draw")))

states <- c("awake", "drowsy", "rem", "peaceful_sleep")
colnames(df_alpha_smoker) <- states
colnames(df_alpha_non_smoker) <- states

# softmax over rows
df_percentage_smoker <- df_alpha_smoker %>%
  rowwise() %>%
  mutate(
    total = sum(c_across(everything())),
    across(everything(), ~ .x / total)
  ) %>%
  select(-total)

df_percentage_non_smoker <- df_alpha_non_smoker %>%
  rowwise() %>%
  mutate(
    total = sum(c_across(everything())),
    across(everything(), ~ .x / total)
  ) %>%
  select(-total)

bootstrap_hdi <- function(y1, y2, n = 1000) {
  n1 <- length(y1)
  n2 <- length(y2)

  p <- replicate(n, {
    sample1 <- sample(y1, n1, replace = TRUE)
    sample2 <- sample(y2, n2, replace = TRUE)
    mean(sample1 > sample2)
  })

  hdi(p)
}

# awake
mean(df_percentage_smoker$awake)
hdi(df_percentage_smoker$awake)
mean(df_percentage_non_smoker$awake)
hdi(df_percentage_non_smoker$awake)
mean(df_percentage_smoker$awake > df_percentage_non_smoker$awake)
bootstrap_hdi(df_percentage_smoker$awake, df_percentage_non_smoker$awake)

# drowsy
mean(df_percentage_smoker$drowsy)
hdi(df_percentage_smoker$drowsy)
mean(df_percentage_non_smoker$drowsy)
hdi(df_percentage_non_smoker$drowsy)
mean(df_percentage_smoker$drowsy > df_percentage_non_smoker$drowsy)
bootstrap_hdi(df_percentage_smoker$drowsy, df_percentage_non_smoker$drowsy)

# rem
mean(df_percentage_smoker$rem)
hdi(df_percentage_smoker$rem)
mean(df_percentage_non_smoker$rem)
hdi(df_percentage_non_smoker$rem)
mean(df_percentage_non_smoker$rem > df_percentage_smoker$rem)
bootstrap_hdi(df_percentage_non_smoker$rem, df_percentage_smoker$rem)

# peaceful sleep
mean(df_percentage_smoker$peaceful_sleep)
hdi(df_percentage_smoker$peaceful_sleep)
mean(df_percentage_non_smoker$peaceful_sleep)
hdi(df_percentage_non_smoker$peaceful_sleep)
mean(df_percentage_non_smoker$peaceful_sleep > df_percentage_smoker$peaceful_sleep)
bootstrap_hdi(df_percentage_non_smoker$peaceful_sleep, df_percentage_smoker$peaceful_sleep)

# plot -------------------------------------------------------------------------
df_smoker_summary <- df_percentage_smoker %>%
  pivot_longer(cols = everything(), names_to = "state", values_to = "value") %>%
  group_by(state) %>%
  summarize(
    mean = mean(value),
    sd = sd(value),
    .groups = "drop"
  ) %>%
  mutate(smoker = "smoker")

df_non_smoker_summary <- df_percentage_non_smoker %>%
  pivot_longer(cols = everything(), names_to = "state", values_to = "value") %>%
  group_by(state) %>%
  summarize(
    mean = mean(value),
    sd = sd(value),
    .groups = "drop"
  ) %>%
  mutate(smoker = "non_smoker")

df_summary <- bind_rows(df_smoker_summary, df_non_smoker_summary) %>%
  select(smoker, state, mean, sd)

df_summary

# awake -> budnost
# drowsy -> dremavost
# rem -> REM faza
# peaceful_sleep -> mirno spanje
df_summary_si <- df_summary %>%
  mutate(
    state = case_when(
      state == "awake" ~ "Budnost",
      state == "drowsy" ~ "Dremavost",
      state == "rem" ~ "REM faza",
      state == "peaceful_sleep" ~ "Mirno spanje"
    ),
    smoker = case_when(
      smoker == "smoker" ~ "Kadilka",
      smoker == "non_smoker" ~ "Nekadilka"
    )
  )

ggplot(df_summary_si, aes(x = smoker, y = mean)) +
  geom_col(width = 0.75, fill = "skyblue") +
  geom_errorbar(aes(ymin = mean - sd, ymax = mean + sd),
    width = 0.2, size = 0.5, color = "grey25"
  ) +
  facet_grid(~state, scales = "free_x", space = "free_x") +
  labs(
    y = "Delež v fazi spanja",
    x = "",
    title = ""
  ) +
  theme_minimal() +
  ylim(0, 1) +
  theme(
    legend.position = "none",
    panel.spacing.x = unit(3, "lines")
  )

ggsave(
  paste0("./figs/observation_states.png"),
  width = 2160,
  height = 1080,
  dpi = 200,
  units = "px",
  bg = "white"
)
