% Add detector code to path
addpath('D:/work/interburst_detector');

% Path to input folder and output file
input_folder = 'D:/work/eeg_smokers_data/sleep';
output_csv = '../data/sleep.csv';

% Get list of all .mat files in the folder
mat_files = dir(fullfile(input_folder, '*.mat'));

% Sampling frequency
Fs = 64;

% Initialize results cell array
results = {'id', 'smoker', 'ta'};

% Loop through each file
for i = 1:length(mat_files)
    file_name = mat_files(i).name;
    file_path = fullfile(input_folder, file_name);

    % Extract subject ID (e.g., N01 or S02)
    tokens = regexp(file_name, '(N|S)\d{2}', 'match');
    if isempty(tokens)
        fprintf('Skipping invalid file name: %s\n', file_name);
        continue;
    end

    subj_id = tokens{1};
    is_smoker = double(startsWith(subj_id, 'S'));

    % Load the EEG data
    sleep_data = load(file_path);

    % Convert to µV
    eeg_signal = sleep_data.data * 1e6;

    % Run interburst detector
    [burst_anno, ~, ~] = eeg_interburst_detector(eeg_signal, Fs);

    % Calculate TA percentage
    burst_clean = burst_anno(~isnan(burst_anno));
    [labels, ~, label_idx] = unique(burst_clean);
    counts = histcounts(label_idx, 0.5:(max(label_idx) + 0.5));
    ta_percentage = counts(2) / (counts(1) + counts(2));

    % Append result row
    results(end+1, :) = {subj_id, is_smoker, ta_percentage};
end

% Write results to CSV
output_table = cell2table(results(2:end, :), 'VariableNames', results(1, :));
writetable(output_table, output_csv);

fprintf('Saved results to %s\n', output_csv);
