# libraries --------------------------------------------------------------------
library(tidyverse)

# load data --------------------------------------------------------------------
source("data/load_observations.R")

# smokers / non-smokers --------------------------------------------------------
print(paste0("Smokers: ", nrow(df_smokers)))
print(paste0("Non-smokers: ", nrow(df_non_smokers)))

# boys/girls -------------------------------------------------------------------
n_girls <- sum(df_observations$sex)
print(paste0("Girls: ", n_girls))
print(paste0("Boys: ", nrow(df_observations) - n_girls))

n_girls_smokers <- sum(df_smokers$sex)
print(paste0("Girls smokers: ", n_girls_smokers))
print(paste0("Boys smokers: ", nrow(df_smokers) - n_girls_smokers))

n_girls_non_smokers <- sum(df_non_smokers$sex)
print(paste0("Girls non-smokers: ", n_girls_non_smokers))
print(paste0("Boys non-smokers: ", nrow(df_non_smokers) - n_girls_non_smokers))
