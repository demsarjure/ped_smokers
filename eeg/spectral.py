"""
Spectral analysis of EEG data.
"""

import os
import mne
import numpy as np
from joblib import Parallel, delayed
import pandas as pd

THRESHOLD = 0.9

# consts
CLEAN_ROOT = "/mnt/d/work/eeg_smokers_data/clean"
DATA_ROOT = "/home/jure/work/ped_smokers/data"

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
    fif_file = f"{CLEAN_ROOT}/{subject}_clean.fif"

    eeg_data = mne.io.read_raw_fif(fif_file, preload=True)

    psd = eeg_data.compute_psd(method="welch", fmin=0.5, fmax=100, n_fft=2048)
    psd_data, freqs = psd.get_data(return_freqs=True)

    # sef
    sef = []
    for ch_psd in psd_data:
        cumulative_power = np.cumsum(ch_psd)
        total_power = cumulative_power[-1]
        sef_freq = freqs[np.searchsorted(cumulative_power, THRESHOLD * total_power)]
        sef.append(sef_freq)

    sef_mean = np.mean(sef)

    # band max power
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
