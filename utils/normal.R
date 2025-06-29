# libraries
library(bayesplot)
library(cmdstanr)
library(ggplot2)
library(ggdist)
library(posterior)
library(tidyverse)
library(HDInterval)

# bootstrap HDI ----------------------------------------------------------------
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

# fit the normal model ---------------------------------------------------------
fit_normal <- function(y, robust = FALSE) {
  # load the model
  if (!robust) {
    model <- cmdstan_model("./models/normal.stan")
  } else {
    model <- cmdstan_model("./models/cauchy.stan")
  }

  # remove NAs
  filtered_y <- y[!is.na(y)]

  # prep data
  stan_data <- list(
    n = length(filtered_y),
    y = filtered_y
  )

  # fit
  fit <- model$sample(
    data = stan_data,
    parallel_chains = 4,
    refresh = 0
  )

  print(mcmc_trace(fit$draws()))
  print(fit$summary())

  return(fit)
}

# compare two normal fits ------------------------------------------------------
compare_two_normal <- function(fit1, label1, fit2, label2) {
  # extract
  df_samples_1 <- as_draws_df(fit1$draws())
  df_samples_2 <- as_draws_df(fit2$draws())

  # compare
  bigger <- mean(df_samples_1$mu > df_samples_2$mu)
  smaller <- mean(df_samples_1$mu < df_samples_2$mu)
  bigger_prob <- round(bigger[[1]] * 100, 2)
  smaller_prob <- round(smaller[[1]] * 100, 2)

  # hdi
  bigger_hdi <- bootstrap_hdi(df_samples_1$mu, df_samples_2$mu)
  smaller_hdi <- bootstrap_hdi(df_samples_2$mu, df_samples_1$mu)

  # print results
  cat(paste0(
    "# P(", label1, " > ", label2, ") = ",
    bigger_prob, "% [", round(bigger_hdi[1] * 100, 2),
    "% - ", round(bigger_hdi[2] * 100, 2), "%]\n"
  ))
  cat(paste0(
    "# P(", label1, " < ", label2, ") = ",
    smaller_prob, "% [", round(smaller_hdi[1] * 100, 2),
    "% - ", round(smaller_hdi[2] * 100, 2), "%]\n"
  ))

  list(
    bigger_prob = bigger_prob,
    bigger_hdi = bigger_hdi,
    smaller_prob = smaller_prob,
    smaller_hdi = smaller_hdi
  )
}

# plot comparison between two normal fits --------------------------------------
plot_comparison_two_normal <- function(fit1, label1, fit2, label2) {
  # extract
  df_samples_1 <- as_draws_df(fit1$draws())
  df_samples_2 <- as_draws_df(fit2$draws())

  # prepare the df
  df_comparison <- data.frame(mu = df_samples_1$mu, label = label1)
  df_comparison <- df_comparison %>%
    add_row(data.frame(mu = df_samples_2$mu, label = label2))

  # plot
  p <- ggplot(data = df_comparison, aes(x = mu, y = label)) +
    stat_halfeye(fill = "skyblue", alpha = 0.75) +
    xlab("Mean") +
    ylab("")

  p
}

# compare a normal fit with a constant -----------------------------------------
compare_normal <- function(fit, constant = 0, label1 = "", label2 = "") {
  # extract
  df_samples <- as_draws_df(fit$draws())

  # compare
  bigger <- mean(df_samples$mu > constant)
  smaller <- mean(df_samples$mu < constant)
  bigger_prob <- round(bigger[[1]] * 100, 2)
  smaller_prob <- round(smaller[[1]] * 100, 2)

  # hdi
  bigger_hdi <- bootstrap_hdi(df_samples$mu, constant)
  smaller_hdi <- bootstrap_hdi(constant, df_samples$mu)

  # set label
  if (label2 == "") {
    label2 <- constant
  }

  # print results
  cat(paste0(
    "# P(", label1, " > ", label2, ") = ",
    bigger_prob, "% [", round(bigger_hdi[1] * 100, 2),
    "% - ", round(bigger_hdi[2] * 100, 2), "%]\n"
  ))
  cat(paste0(
    "# P(", label1, " < ", label2, ") = ",
    smaller_prob, "% [", round(smaller_hdi[1] * 100, 2),
    "% - ", round(smaller_hdi[2] * 100, 2), "%]\n"
  ))

  list(
    bigger_prob = bigger_prob,
    bigger_hdi = bigger_hdi,
    smaller_prob = smaller_prob,
    smaller_hdi = smaller_hdi
  )
}

# plot comparison between a normal fit and a constant --------------------------
plot_comparison_normal <- function(fit, prob = NULL, constant = 0, ci = NULL) {
  # extract
  df_samples <- as_draws_df(fit$draws())

  # prepare the df
  df_comparison <- data.frame(mu = df_samples$mu)

  # plot
  p <- ggplot(data = df_comparison, aes(x = mu))

  if (is.null(ci)) {
    p <- p +
      stat_halfeye(fill = "skyblue", alpha = 0.75)
  } else if (ci > 0.5) {
    q <- quantile(df_comparison$mu, ci)
    p <- p +
      stat_slab(aes(fill = stat(x < q)), alpha = 0.75, show.legend = FALSE)
  } else {
    q <- quantile(df_comparison$mu, ci)
    p <- p +
      stat_slab(aes(fill = stat(x > q)), alpha = 0.75, show.legend = FALSE)
  }

  p <- p +
    xlab("Mean") +
    ylab("") +
    scale_fill_manual(values = c("grey90", "skyblue")) +
    geom_vline(
      xintercept = constant, linetype = "dashed",
      color = "grey50", linewidth = 1
    ) +
    theme_minimal()

  if (!is.null(prob)) {
    mean <- mean(df_samples$mu)
    p <- p +
      annotate(
        "text",
        x = mean,
        y = 0.125,
        label = paste0(prob, "%"),
        size = 4,
        color = "grey20",
        hjust = 0.5
      )
  }

  return(p)
}

# plot comparison between two normal fits and a constant -----------------------
plot_comparison_two_normal_constant <- function(fit1, label1 = "Group 1",
                                                fit2, label2 = "Group 2",
                                                constant = 0, ci = c(0.66, 0.95)) {
  # extract
  df_samples <- data.frame(
    value = as_draws_df(fit1$draws())$mu,
    group = label1
  )
  df_samples <- df_samples %>% add_row(
    value = as_draws_df(fit2$draws())$mu,
    group = label2
  )

  # plot
  p <- ggplot(data = df_samples, aes(x = value, y = group)) +
    stat_pointinterval(.width = ci) +
    xlab("Mean") +
    ylab("") +
    geom_vline(
      xintercept = 0, linetype = "dashed",
      color = "grey50", linewidth = 1
    ) +
    theme_minimal()

  return(p)
}
