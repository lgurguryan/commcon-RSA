function [] = extract_beta_values_from_ROIs_REPSUP()

% Extract voxel x beta matrices from ROIs (REPSUP)

% DIRECTORIES
base_spm_results_dir = '/Volumes/Poodle/Model4_REPSUP';
base_roi_dir = '/Volumes/Chi/ROI/Model3_ROIs';

beta_info_file = '/Volumes/Poodle/Model4_REPSUP/Seg-Beta-Maps_PRE.txt';

% LOAD BETA TABLE
opts = detectImportOptions(beta_info_file, 'FileType', 'text', 'Delimiter', '\t');
beta_table = readtable(beta_info_file, opts);

% SUBJECTS
subjects = [02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 18 19 20 21 22 23 24 25 27 28 29 30 31 32 33 34];
%subjects = [01];

% ROI FILES
roi_files = dir(fullfile(base_roi_dir, '*.nii'));

% MAIN LOOP
for subj = subjects

    subjID = sprintf('%02d', subj);
    disp(['Processing subject: ' subjID]);

    subject_dir = fullfile(base_spm_results_dir, ['Model4_sub-' subjID]);

    % all betas for subject
    subj_rows = find(beta_table.Subject == subj);

    % loop ROIs
    for iroi = 1:length(roi_files)

        roi_file = fullfile(base_roi_dir, roi_files(iroi).name);
        [~, roi_name, ~] = fileparts(roi_file);

        disp(['  ROI: ' roi_name]);

        roi_vol = spm_vol(roi_file);
        roi_img = spm_read_vols(roi_vol);
        roi_voxels = find(roi_img > 0);

        roi_combined_beta_values = [];

        % loop over all betas for subject
        for j = 1:length(subj_rows)

            beta_filename = beta_table.BetaFile{subj_rows(j)};
            label = beta_table.Label{subj_rows(j)};

            beta_file = fullfile(subject_dir, beta_filename);

            if ~exist(beta_file, 'file')
                continue;
            end

            beta_vol = spm_vol(beta_file);
            beta_img = spm_read_vols(beta_vol);

            trial_beta_values = beta_img(roi_voxels);

            roi_combined_beta_values = ...
                [roi_combined_beta_values, trial_beta_values];

        end

        % remove NaNs
        roi_combined_beta_values = ...
            roi_combined_beta_values(all(~isnan(roi_combined_beta_values), 2), :);

        % save beta matrix
        save_filename = fullfile(subject_dir, ...
            ['Model4_sub-' subjID '_' roi_name '_beta_values_REPSUP.mat']);

        save(save_filename, 'roi_combined_beta_values');

    end
end

end
