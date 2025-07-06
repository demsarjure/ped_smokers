"""
The auto cleanup script for EEG data.
"""

import os
import yaml
from joblib import Parallel, delayed

import mne
from mne.preprocessing import ICA
from autoreject import AutoReject, get_rejection_threshold

# consts
ROOT = "/mnt/d/work/eeg_smokers_data"
RAW_ROOT = f"{ROOT}/raw"
CLEAN_ROOT = f"{ROOT}/clean"
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
    raw.filter(l_freq=0.1, h_freq=40)
    raw_for_ica = raw.copy().filter(l_freq=1.0, h_freq=None)

    # downsample
    raw.resample(250)

    # re-reference to average reference
    raw.set_eeg_reference("average", projection=False)

    # ica
    ica = ICA(n_components=None, max_iter="auto")
    ica.fit(raw_for_ica)

    # try to auto-detect EOG artifacts
    eog_inds, scores = ica.find_bads_eog(raw, ch_name=["Fp1", "Fp2", "AF7", "AF8"])

    # remove bad components
    ica.exclude = eog_inds
    clean = raw.copy()
    ica.apply(clean)

    # define epochs
    epochs = mne.make_fixed_length_epochs(clean, duration=1.0, preload=True)

    # autoreject get_rejection_threshold
    epochs = mne.make_fixed_length_epochs(clean, duration=1)
    thresholds = get_rejection_threshold(epochs)
    thresholds = {k: v * 2.0 for k, v in thresholds.items()}
    epochs.drop_bad(reject=thresholds)
    bads = epochs.info["bads"]

    if bads:
        clean.info["bads"] = bads
        clean.interpolate_bads(reset_bads=True)

    # save
    clean_file = f"{CLEAN_ROOT}/{subject}_clean.fif"
    clean.save(clean_file, overwrite=True)


# process all subjects in parallel
if __name__ == "__main__":
    Parallel(n_jobs=4, verbose=10)(
        delayed(process_subject)(subject) for subject in subjects
    )
    print("All subjects processed.")
