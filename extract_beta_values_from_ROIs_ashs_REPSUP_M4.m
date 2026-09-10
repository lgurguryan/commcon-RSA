function [] = extract_beta_values_from_ROIs_ashs()

% Extract voxel x beta matrices from ASHS ROIs (REPSUP)

% DIRECTORIES
base_spm_results_dir = '/Volumes/Poodle/Model4_REPSUP';
base_roi_dir = '/Volumes/Poodle/ashs-ROIs';

beta_info_file = '/Volumes/Poodle/Model4_REPSUP/Seg-Beta-Maps_PRE.txt';

% LOAD BETA TABLE
opts = detectImportOptions(beta_info_file, 'FileType', 'text', 'Delimiter', '\t');
beta_table = readtable(beta_info_file, opts);

% SUBJECTS
subjects = [02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 18 19 20 21 22 23 24 25 27 28 29 30 31 32 33 34];
%subjects = [01 ];

% ROI FILES
roi_suffixes = {
    'left_Hippocampus_MNI-BOLD.nii.gz'
    'right_Hippocampus_MNI-BOLD.nii.gz'
    'left_PHC_MNI-BOLD.nii.gz'
    'left_PRC_MNI-BOLD.nii.gz'
    'right_PHC_MNI-BOLD.nii.gz'
    'right_PRC_MNI-BOLD.nii.gz'
};

% MAIN LOOP
for subj = subjects

    subjID = sprintf('%02d', subj);
    disp(['Processing subject: ' subjID]);

    subject_output_dir = fullfile(base_spm_results_dir, ['Model4_sub-' subjID]);

    % Get all beta rows for subject
    row_idx = find(beta_table.Subject == subj);

    for r = 1:length(roi_suffixes)

        roi_gz_filename = ['sub-' subjID '_' roi_suffixes{r}];
        roi_gz_file = fullfile(base_roi_dir, roi_gz_filename);

        if ~exist(roi_gz_file, 'file')
            disp(['  ROI not found: ' roi_gz_filename]);
            continue;
        end

        roi_file = erase(roi_gz_file, '.gz');

        if ~exist(roi_file, 'file')
            gunzip(roi_gz_file);
        end

        roi_name = erase(roi_suffixes{r}, '.nii.gz');
        disp(['  Processing ROI: ' roi_name]);

        roi_vol = spm_vol(roi_file);
        roi_img = spm_read_vols(roi_vol);
        roi_voxels = find(roi_img > 0);

        roi_combined_beta_values = [];

        % LOOP OVER ALL BETAS FOR SUBJECT
        for j = 1:length(row_idx)

            beta_filename = beta_table.BetaFile{row_idx(j)};
            label = beta_table.Label{row_idx(j)};

            resultDir = subject_output_dir;
            beta_file = fullfile(resultDir, beta_filename);

            if ~exist(beta_file, 'file')
                continue;
            end

            beta_vol = spm_vol(beta_file);
            beta_img = spm_read_vols(beta_vol);

            trial_beta_values = beta_img(roi_voxels);

            roi_combined_beta_values = ...
                [roi_combined_beta_values, trial_beta_values];

        end

        % REMOVE NaNs
        roi_combined_beta_values = ...
            roi_combined_beta_values(all(~isnan(roi_combined_beta_values), 2), :);

        % SAVE MATRIX
        beta_save_name = fullfile(subject_output_dir, ...
            ['Model4_sub-' subjID '_' roi_name '_beta_values_REPSUP.mat']);

        save(beta_save_name, 'roi_combined_beta_values');

    end
end

end
