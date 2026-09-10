function [] = extract_beta_values_from_ROIs_ashs()

% Extract voxel x trial beta matrices from ASHS ROIs

% Directories
base_spm_results_dir = '/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST';
base_roi_dir = '/Volumes/Poodle/ashs-ROIs';
commercialNamesFile = '/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_scripts/CommercialNames.txt';
beta_info_file = '/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST/Com-Beta-Maps_POST.txt';

% Load commercial names
fid = fopen(commercialNamesFile, 'r');
commercialNames = textscan(fid, '%s');
fclose(fid);
commercialNames = commercialNames{1};

% Load beta mapping table
opts = detectImportOptions(beta_info_file, 'FileType', 'text', 'Delimiter', '\t');
beta_table = readtable(beta_info_file, opts);

% Subjects
 %subjects = [01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 18 19 20 21 22 23 24 25 27 28 29 30 31 32 33 34];
subjects = [20 34];

% ROI suffixes (8 total)
roi_suffixes = {
    'left_Hippocampus_MNI-BOLD.nii.gz' 
    'left_Hippocampus_MNI-BOLD.nii.gz'
    'right_Hippocampus_MNI-BOLD.nii.gz'
    'right_Hippocampus_MNI-BOLD.nii.gz'
    'left_Hippocampus-SUB_MNI-BOLD.nii.gz' 
    'left_Hippocampus-SUB_MNI-BOLD.nii.gz'
    'right_Hippocampus-SUB_MNI-BOLD.nii.gz'
    'right_Hippocampus-SUB_MNI-BOLD.nii.gz'
    'left_PHC_MNI-BOLD.nii.gz'
    'left_PRC_MNI-BOLD.nii.gz'
    'right_PHC_MNI-BOLD.nii.gz'
    'right_PRC_MNI-BOLD.nii.gz'
    };


% Loop subjects
for subj = subjects

    subjID = sprintf('%02d', subj);
    disp(['Processing subject: ' subjID]);

    subject_output_dir = fullfile(base_spm_results_dir, ['Model3_sub-' subjID]);

    % Loop ROIs
    for r = 1:length(roi_suffixes)

        roi_gz_filename = ['sub-' subjID '_' roi_suffixes{r}];
        roi_gz_file = fullfile(base_roi_dir, roi_gz_filename);

        if ~exist(roi_gz_file, 'file')
            disp(['  ROI not found: ' roi_gz_filename]);
            continue;
        end

        % Remove .gz to get .nii filename
        roi_file = erase(roi_gz_file, '.gz');

        % Unzip only if .nii does not already exist
        if ~exist(roi_file, 'file')
            disp(['  Unzipping ROI: ' roi_gz_filename]);
            gunzip(roi_gz_file);
        end

        roi_name = erase(roi_suffixes{r}, '.nii.gz');
        disp(['  Processing ROI: ' roi_name]);

        % Load ROI
        roi_vol = spm_vol(roi_file);
        roi_img = spm_read_vols(roi_vol);
        roi_voxels = find(roi_img > 0);

        roi_combined_beta_values_POST = [];

        % Loop commercials
        for i = 1:length(commercialNames)

            commercialName = commercialNames{i};
            resultDir = fullfile(subject_output_dir, commercialName);

            row_idx = find(beta_table.Subject == subj & ...
                           strcmp(beta_table.Label, commercialName));

            if isempty(row_idx)
                continue;
            end

            beta_filename = beta_table.BetaFile{row_idx};
            beta_file = fullfile(resultDir, beta_filename);

            if ~exist(beta_file, 'file')
                continue;
            end

            % Load beta image
            beta_vol = spm_vol(beta_file);
            beta_img = spm_read_vols(beta_vol);

            % Extract ROI voxels
            trial_beta_values = beta_img(roi_voxels);

            % Concatenate (voxel x trial)
            roi_combined_beta_values_POST = ...
                [roi_combined_beta_values_POST, trial_beta_values];

        end

        % Remove NaNs
        roi_combined_beta_values_POST = ...
            roi_combined_beta_values_POST( ...
            all(~isnan(roi_combined_beta_values_POST), 2), :);

        % Save beta matrix
        beta_save_name = fullfile(subject_output_dir, ...
            ['Model3_sub-' subjID '_' roi_name '_beta_values_POST.mat']);

        save(beta_save_name, 'roi_combined_beta_values_POST');

        % Save correlation matrix
        if size(roi_combined_beta_values_POST, 2) > 1

            correlation_matrix = corr(roi_combined_beta_values_POST, ...
                'rows', 'pairwise');

            corr_save_name = fullfile(subject_output_dir, ...
                ['Model3_sub-' subjID '_' roi_name '_correlation_matrix_POST.mat']);

            save(corr_save_name, 'correlation_matrix');
        end

    end
end

end