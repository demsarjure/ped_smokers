"""
Spectral analysis of EEG data.

This module provides functions to compute power spectral density (PSD) using Welch's method,
spectral edge frequency (SEF), and relative power in standard EEG frequency bands.
Typical EEG sampling rates (e.g., 250-1000 Hz) and analysis parameters are considered.
"""

import os
import mne
import numpy as np
from joblib import Parallel, delayed
import pandas as pd

# Threshold for spectral edge frequency (SEF) calculation (0.9 = 90% of total power).
THRESHOLD = 0.9

# consts
CLEAN_ROOT = "/mnt/d/work/eeg_smokers_data/clean"
DATA_ROOT = "/home/jure/work/ped_smokers/data"

# Standard EEG frequency band definitions (in Hz).
BANDS = {
    "delta": (0.5, 4),
    "theta": (4, 8),
    "alpha": (8, 13),
    "beta": (13, 30),
}

# get subjects
subjects = [
    subject.replace("_clean.fif", "")
    for subject in os.listdir(CLEAN_ROOT)
    if subject.endswith(".fif") and os.path.isfile(os.path.join(CLEAN_ROOT, subject))
]


def spectral_analysis(subject):
    """
    Compute spectral metrics for a single subject's EEG data.

    Parameters
    ----------
    subject : str
        Subject identifier used to locate the preprocessed FIF file.

    Returns
    -------
    sef_mean : float
        Mean spectral edge frequency across channels (frequency below which 90% of total power resides).
    relative_power : dict
        Relative power per EEG band, normalized by total power (0.5-100 Hz). Keys are band names.

    Notes
    -----
    - The PSD is estimated using Welch's method with a default Hann window and 2048-point FFT.
      Larger `n_fft` yields finer frequency resolution, critical for distinguishing alpha (8-13 Hz)
      and beta (13-30 Hz) bands, at the cost of reduced time resolution.
    - The Hann window reduces spectral leakage but widens the main lobe, which may affect
      detection of narrowband oscillations.
    - Detrending is applied by default in MNE's `compute_psd` to remove slow drifts.
    - Relative power is computed as the proportion of total power within each band,
      which helps control for inter‑subject differences in overall signal amplitude.
    """
    fif_file = f"{CLEAN_ROOT}/{subject}_clean.fif"

    eeg_data = mne.io.read_raw_fif(fif_file, preload=True)

    # Compute PSD using Welch's method with Hann window and 2048-point FFT.
    # Frequency resolution = sampling_rate / n_fft (e.g., 0.24 Hz at 500 Hz).
    psd = eeg_data.compute_psd(method="welch", fmin=0.5, fmax=100, n_fft=2048)
    psd_data, freqs = psd.get_data(return_freqs=True)

    # Compute spectral edge frequency (SEF) per channel:
    # frequency below which 90% of total power resides.
    sef = []
    for ch_psd in psd_data:
        cumulative_power = np.cumsum(ch_psd)
        total_power = cumulative_power[-1]
        sef_freq = freqs[np.searchsorted(cumulative_power, THRESHOLD * total_power)]
        sef.append(sef_freq)

    sef_mean = np.mean(sef)

    # Compute relative power per band:
    # proportion of total power within each frequency range.
    total_power = np.trapz(psd_data, freqs, axis=1)
    relative_power = {}

    for band, (fmin, fmax) in BANDS.items():
        idx = np.logical_and(freqs >= fmin, freqs <= fmax)
        band_power = np.trapz(psd_data[:, idx], freqs[idx], axis=1)
        band_proportion = band_power / total_power
        relative_power[band] = band_proportion.mean()

    return (sef_mean, relative_power)


# smoker/non-smoker
def get_group(subject):
    return 0 if subject.startswith("N") else 1


def process_subject(subject):
    sef_mean, relative_power = spectral_analysis(subject)
    result = {
        "id": subject,
        "smoker": get_group(subject),
        "sef": sef_mean,
    }
    # store power for each band
    for band_name, value in relative_power.items():
        result[f"{band_name}"] = value
    return result


# process all subjects in parallel
if __name__ == "__main__":
    results = Parallel(n_jobs=16, verbose=10)(
        delayed(process_subject)(subject) for subject in subjects
    )

    df = pd.DataFrame(results)
    df.to_csv(os.path.join(DATA_ROOT, "spectral.csv"), index=False)
