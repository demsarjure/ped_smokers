"""
Connectome metrics calculation script.
"""

import os
import yaml
from glob import glob

import bct
import mne
import pandas as pd
import numpy as np

# config
CONNECTOME_DIR = os.path.join(".", "data", "connectomes")
DATA_ROOT = "/home/jure/work/ped_smokers/data"
CLEAN_ROOT = "/mnt/d/work/eeg_smokers_data/clean"

# get channel names
fif_file = f"{CLEAN_ROOT}/N01_clean.fif"
eeg_data = mne.io.read_raw_fif(fif_file, preload=True)
electrodes = {ch: i + 1 for i, ch in enumerate(eeg_data.info["ch_names"])}


def load_connectome(file_path: str) -> np.ndarray:
    """
    Load a connectome from a CSV file.

    Args:
        file_path (str): Path to the CSV file.
    """
    try:
        connectome = pd.read_csv(file_path, header=None)
        connectome = connectome.values
        return connectome
    except Exception as e:
        print(f"Error loading {file_path}: {e}")
        return np.ndarray([])


def calculate_ge(connectome: np.ndarray) -> float:
    """
    Calculate the global efficiency of a connectome.

    Args:
        connectome (np.ndarray): The connectome matrix.
    """
    try:
        ge = bct.efficiency_wei(connectome)
        return ge
    except Exception as e:
        print(f"Error in calculating the global efficiency: {e}")
        return np.nan


def calculate_cc(connectome: np.ndarray) -> float:
    """
    Calculate the clustering coefficient of a connectome.

    Args:
        connectome (np.ndarray): The connectome matrix.
    """
    try:
        cc = bct.clustering_coef_wu(connectome).mean()
        return cc
    except Exception as e:
        print(f"Error in calculating the clustering coefficient: {e}")
        return np.nan


def calculate_average_strength(
    connectome: np.ndarray, electrode_array_1: list[str], electrode_array_2: list[str]
) -> float:
    """
    Calculate the average strength between two sets of electrodes.

    Args:
        connectome (np.ndarray): The connectome matrix.
        electrode_array_1 (list[str]): The first array of electrodes.
        electrode_array_2 (list[str]): The second array of electrodes.
    """
    strenghts = []
    for e_1 in electrode_array_1:
        for e_2 in electrode_array_2:
            strenghts.append(connectome[electrodes[e_1] - 1, electrodes[e_2] - 1])

    return float(np.mean(strenghts))


def process_connectomes(band: str) -> pd.DataFrame:
    """
    Process all connectomes and calculate metrics.

    Args:
        group (str): The group to process ("test" or "control").
    """
    # get all connectomes
    connectome_files = glob(os.path.join(CONNECTOME_DIR, band, "*.csv"))

    results = []

    for file in connectome_files:
        # get subject id from filename
        subject = os.path.basename(file).replace(".csv", "")
        print(f"    - processing {subject}")

        # group
        smoker = 0
        if subject.startswith("S"):
            smoker = 1

        # connectome
        connectome = load_connectome(file)

        # metrics
        ge = calculate_ge(connectome)
        cc = calculate_cc(connectome)

        # average strength
        # right
        r_1 = ["Fp2", "AF4", "AF8", "F2", "F4", "F6", "F8"]
        r_2 = ["FC6", "C6", "FT8", "T8", "TP8"]
        cas_r = calculate_average_strength(connectome, r_1, r_2)
        # left
        l_1 = ["Fp1", "AF3", "AF7", "F1", "F3", "F5", "F7"]
        l_2 = ["FC5", "C5", "FT7", "T7", "TP7"]
        cas_l = calculate_average_strength(connectome, l_1, l_2)

        # Append results
        results.append(
            {
                "id": subject,
                "smoker": smoker,
                "band": band,
                "ge": ge,
                "cc": cc,
                "cas_r": cas_r,
                "cas_l": cas_l,
            }
        )

    # to df
    return pd.DataFrame(results)


all_results = []
for band in ["delta", "theta", "alpha"]:
    print(f"---> Processing {band} connectomes")

    # calculate metrics
    results_df = process_connectomes(band)

    # append
    all_results.append(results_df)

all_results = pd.concat(all_results)
all_results.to_csv(os.path.join(DATA_ROOT, f"connectome_metrics.csv"), index=False)

print()
print("---> All results saved to connectome_metrics.csv")
