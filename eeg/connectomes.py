"""
Connectomes calculation script.
"""

import os
from concurrent.futures import ProcessPoolExecutor

import numpy as np
import mne
from mne_connectivity import spectral_connectivity_epochs
from functools import partial

# paths
CLEAN_ROOT = "/mnt/d/work/eeg_smokers_data/clean"
DATA_ROOT = "/home/jure/work/ped_smokers/data"
CONNECTOME_DIR = os.path.join(DATA_ROOT, "connectomes")
GROUPS = ["non-smokers", "smokers"]

# frequencies - extended alpha band
BANDS = {
    "delta": (0.5, 4),
    "theta": (4, 8),
    "alpha": (8, 13),
}

# create output directories
for b in BANDS.keys():
    os.makedirs(os.path.join(CONNECTOME_DIR, b), exist_ok=True)

# get subjects
subjects = [
    subject.replace("_clean.fif", "")
    for subject in os.listdir(CLEAN_ROOT)
    if subject.endswith(".fif") and os.path.isfile(os.path.join(CLEAN_ROOT, subject))
]


def process_subject(subject, band):
    # get frequencies
    low_freq, high_freq = BANDS[band]

    # get the cleaned eeg file
    eeg_file = os.path.join(CLEAN_ROOT, f"{subject}_clean.fif")

    # load
    raw = mne.io.read_raw_fif(eeg_file, preload=True)

    # apply Surface Laplacian
    raw_laplacian = mne.preprocessing.compute_current_source_density(raw)

    # epoch
    epochs = mne.make_fixed_length_epochs(raw_laplacian, duration=1)

    # dPLI
    result = spectral_connectivity_epochs(
        epochs,
        method="wpli2_debiased",
        mode="multitaper",
        fmin=low_freq,
        fmax=high_freq,
        faverage=True,
        n_jobs=1,
    )

    # convert to a 2D connectome matrix
    n_channels = len(result.names)
    con_vals = result.get_data().reshape(n_channels, n_channels)
    conn_matrix = con_vals + con_vals.T

    # store as csv
    output_path = os.path.join(CONNECTOME_DIR, band, f"{subject}.csv")
    np.savetxt(output_path, conn_matrix, delimiter=",")

    print(f"---> Connectome saved as {output_path}")


with ProcessPoolExecutor(max_workers=4) as executor:
    for band_name in BANDS.keys():
        partial_subject_processor = partial(process_subject, band=band_name)
        list(executor.map(partial_subject_processor, subjects))

print()
print(f"---> All connectomes have been generated!")
