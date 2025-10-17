# libraries and utils ----------------------------------------------------------
library(tidyverse)
library(ggplot2)

# load data --------------------------------------------------------------------
df <- read_csv("./data/annotations.csv")

# clamp EEG data between -2500 adn 2500
df <- df %>%
  mutate(eeg = pmin(pmax(eeg, -2500), 2500))

# prepare data for plotting ----------------------------------------------------
# Calculate time column (assuming 64Hz sampling rate)
df_plot <- df %>%
  group_by(id) %>%
  mutate(
    time_seconds = (row_number() - 1) / 64,
    time_minutes = time_seconds / 60
  ) %>%
  filter(time_minutes >= 5 & time_minutes <= 15) %>%
  mutate(time_minutes = time_minutes - min(time_minutes)) %>%
  mutate(time_seconds = time_seconds - min(time_seconds)) %>%
  ungroup()

df_plot$group <- ifelse(startsWith(df_plot$id, "S"), "Smoker", "Non-smoker")

# Create annotation areas for background coloring
annotation_areas <- df_plot %>%
  group_by(group) %>%
  mutate(
    # Create groups for continuous annotation periods
    annotation_group = cumsum(annotation != lag(annotation, default = 0))
  ) %>%
  filter(annotation == 1) %>%
  group_by(group, annotation_group) %>%
  summarise(
    xmin = min(time_minutes),
    xmax = max(time_minutes),
    .groups = "drop"
  )

# create plot ------------------------------------------------------------------
# en
ggplot(df_plot, aes(x = time_minutes, y = eeg)) +
  # Add background rectangles for annotation areas
  geom_rect(
    data = annotation_areas,
    aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf),
    fill = "lightblue", alpha = 0.3, inherit.aes = FALSE
  ) +
  # Add EEG signal line
  geom_line(color = "black", size = 0.5) +
  # Facet by ID
  facet_wrap(~group, scales = "free_y", ncol = 1) +
  # Labels and theme
  labs(
    x = "Time (min)",
    y = "EEG (μV)",
    title = "EEG with annotated TA"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  paste0("./figs/annotations.pdf"),
  width = 1080,
  height = 540,
  dpi = 100,
  units = "px",
  bg = "white"
)

ggsave(
  paste0("./figs/annotations.png"),
  width = 1080,
  height = 540,
  dpi = 100,
  units = "px",
  bg = "white"
)

# si
# translate group in df_plot and annotation_areas to Kadilka Nekadilka
df_plot$group <- ifelse(df_plot$group == "Smoker", "Kadilka", "Nekadilka")
annotation_areas$group <- ifelse(annotation_areas$group == "Smoker", "Kadilka", "Nekadilka")

ggplot(df_plot, aes(x = time_minutes, y = eeg)) +
  # Add background rectangles for annotation areas
  geom_rect(
    data = annotation_areas,
    aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf),
    fill = "lightblue", alpha = 0.3, inherit.aes = FALSE
  ) +
  # Add EEG signal line
  geom_line(color = "black", size = 0.5) +
  # Facet by ID
  facet_wrap(~group, scales = "free_y", ncol = 1) +
  # Labels and theme
  labs(
    x = "Čas (minute)",
    y = "EEG (μV)",
    title = "EEG z anotiranim TA"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave(
  paste0("./figs/annotations_si.png"),
  width = 1080,
  height = 540,
  dpi = 100,
  units = "px",
  bg = "white"
)
