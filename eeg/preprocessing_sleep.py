"""
The auto cleanup script for EEG data for sleep analysis.
"""

import os
import yaml
from joblib import Parallel, delayed

import mne
import scipy.io

# consts
ROOT = "/mnt/d/work/eeg_smokers_data"
RAW_ROOT = f"{ROOT}/raw"
SLEEP_ROOT = f"{ROOT}/sleep"
DATA_ROOT = "/home/jure/work/ped_smokers/data"

# get subjects
subjects = [
    subject.replace(".eeg", "")
    for subject in os.listdir(RAW_ROOT)
    if subject.endswith(".eeg") and os.path.isfile(os.path.join(RAW_ROOT, subject))
]

# electrodes mapping
with open(f"{DATA_ROOT}/electrodes.yaml", "r") as f:
    mapping_data = yaml.safe_load(f)
if mapping_data is None:
    raise ValueError(
        f"Failed to load electrodes from {DATA_ROOT}/electrodes.yaml: file is empty or invalid."
    )
mapping = {str(k): v for k, v in mapping_data.items()}


def process_subject(subject):
    # load the data
    vhdr_file = f"{RAW_ROOT}/{subject}.vhdr"
    raw = mne.io.read_raw_brainvision(vhdr_file, preload=True)

    # add montage
    montage = mne.channels.read_custom_montage(
        "/mnt/d/work/eeg_smokers_data/electrodes/RNP-AP-64.bvef"
    )
    available_mapping = {
        ch: mapping[ch] for ch in raw.info["ch_names"] if ch in mapping
    }
    raw.rename_channels(available_mapping)
    raw.set_montage(montage)

    # remove starting 120 s and ending 120 s
    total_duration = raw.times[-1]
    raw.crop(tmin=120, tmax=total_duration - 120)

    # band-pass
    raw.filter(l_freq=0.1, h_freq=30)

    # downsample
    raw.resample(64)

    # re-reference to average reference
    raw.set_eeg_reference("average", projection=False)

    # bipolar montage
    raw = mne.set_bipolar_reference(
        raw, anode="F3", cathode="C3", ch_name="F3-C3", copy=False
    )
    raw = raw.pick(["F3-C3"])

    # save
    sleep_file = f"{SLEEP_ROOT}/{subject}_sleep.mat"
    data, times = raw.get_data(return_times=True)
    scipy.io.savemat(sleep_file, {"data": data, "times": times})


# process all subjects in parallel
if __name__ == "__main__":
    Parallel(n_jobs=8)(delayed(process_subject)(subject) for subject in subjects)
    print("All subjects processed.")
