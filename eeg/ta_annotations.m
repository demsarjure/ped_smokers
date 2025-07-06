% Add detector code to path
addpath('D:/work/interburst_detector');

% Path to input folder and output file
input_folder = 'D:/work/eeg_smokers_data/sleep';
output_csv = '../data/annotations.csv';

% Get list of all .mat files in the folder
subjects = ["N09", "S04"];

% Sampling frequency
Fs = 64;

% Initialize result vectors
all_ids = [];
all_eeg = [];
all_annotations = [];

% Loop through each subject
for subject = subjects
    % Get the files
    file_name = subject + '_sleep.mat';
    file_path = fullfile(input_folder, file_name);

    % Load the EEG data
    sleep_data = load(file_path);

    % Convert to µV
    eeg_signal = sleep_data.data * 1e6;

    % Run interburst detector
    [burst_anno, ~, ~] = eeg_interburst_detector(eeg_signal, Fs);

    % Clean
    valid_idx = ~isnan(burst_anno);
    burst_clean = burst_anno(valid_idx);
    eeg_clean = eeg_signal(valid_idx);

    % Repeat subject ID to match vector length
    n = length(burst_clean);
    id_vector = repmat(subject, n, 1);

    % Append to combined arrays
    all_ids = [all_ids; id_vector];
    all_eeg = [all_eeg; eeg_clean(:)];
    all_annotations = [all_annotations; burst_clean(:)];
end

% Create table and write CSV
output_table = table(all_ids, all_eeg, all_annotations, ...
    'VariableNames', {'id', 'eeg', 'annotation'});
writetable(output_table, output_csv);

fprintf('Saved results to %s\n', output_csv);
