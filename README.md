# ped_smokers

Repository for the study about the influence of smoking during pregnancy on babies.

## Repository contents

This repository is organized as follows:

- data/
  - Analysis-ready tabular datasets (mostly CSV) plus a few scripts used to generate them.
  - Key files:
    - annotations.csv: exported annotation summary used in analyses/figures.
    - demographics.csv: participant demographics used for grouping/covariates.
    - observations.csv: exported, merged observation-level dataset.
    - sleep.csv: sleep-related derived measures.
    - spectral.csv: EEG spectral features (e.g., band power, SEF) exported from the EEG pipeline.
    - connectome_metrics.csv: graph/connectome-derived metrics exported from connectome processing.
    - electrodes.yaml: channel renaming/mapping configuration used during preprocessing.
    - data.xlsx: original/source spreadsheet used to produce some of the CSV exports.
  - Scripts:
    - demographics_to_csv.R, observations_to_csv.R: convert spreadsheet/source formats into CSV.
    - load_observations.R: loader/helper for observation data.
  - Subfolders:
    - connectomes/
      - Per-subject connectivity matrices exported as CSV.
      - Organized by frequency band (alpha/, delta/, theta/), with files like N01.csv / S02.csv.
    - observations/
      - Per-participant observation logs exported as TSV (observation_P01.tsv ...).

- eeg/
  - EEG processing and feature-extraction code (Python/R/Matlab) used to produce the derived datasets in data/.
  - Typical flow:
    - preprocessing_general.py / preprocessing_sleep.py: preprocessing/cleanup of raw EEG into cleaned FIF.
    - spectral.py: spectral feature extraction exported to data/spectral.csv.
    - connectomes.py: connectome generation exported into data/connectomes/.
    - metrics.py: connectome metrics exported to data/connectome_metrics.csv.
  - Notebooks:
    - exploratory.ipynb, plot_spectral.ipynb: exploratory analysis and plotting.
  - Annotation / TA detection:
    - annotations.R and ta_detection.m (+ related Matlab autosave files).

- figs/
  - Exported figures (PDF/PNG) used in the manuscript and/or supplementary information.

- models/
  - Statistical models.
  - Stan sources:
    - normal.stan, cauchy.stan: simple univariate models for continuous outcomes.
    - dirichlet.stan: Dirichlet model for simplex/compositional outcomes with smoker/non-smoker groups.

- observations/
  - R scripts focused on observation-derived analyses and summaries.
  - Examples:
    - summary.R: basic cohort counts/summary statistics.
    - observations_dirichlet.R: Dirichlet-model analysis for compositional observation outputs.

- utils/
  - Small shared utilities used by the R analysis scripts (e.g., distribution helpers in normal.R).

- Top-level files
  - README.md: high-level description of the repository.
  - LICENSE: repository license.
