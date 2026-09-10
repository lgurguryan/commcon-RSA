function [] = extract_beta_values_from_ROIs()

% Define directories
base_spm_results_dir = '/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST';
base_roi_dir = '/Volumes/Chi/HCPex_v1.1/ROIs';
%base_roi_dir = ['/Volumes/Poodle/Baldassano_ROIs/resampled']


% Define path to txt file with the commercial names
commercialNamesFile = '/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_scripts/CommercialNames.txt';

% Grab commercial names from the text file
fid = fopen(commercialNamesFile, 'r');
commercialNames = textscan(fid, '%s');
fclose(fid);

% List of subject IDs
subjects = [01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 18 19 20 21 22 23 24 25 27 28 29 30 31 32 33 34];  
%subjects = [01];  

% List ROI masks 
roi_files = dir(fullfile(base_roi_dir, '*_mask_resampled.nii'));
%roi_files = dir(fullfile(base_roi_dir, '*_resampled_bin.nii'));

% Beta mapping info 
beta_info_file = '/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST/Com-Beta-Maps_POST.txt';
opts = detectImportOptions(beta_info_file, 'FileType', 'text', 'Delimiter', '\t');
beta_table = readtable(beta_info_file, opts);


% Loop through each subject
for subj = subjects
    subjID = sprintf('%02d', subj);  
    
    % Display subject
    disp(['Processing subject: ' subjID]);

    % Loop through each ROI
    for iroi = 1:length(roi_files)
        roi_file = fullfile(base_roi_dir, roi_files(iroi).name);
        [~, roi_name, ~] = fileparts(roi_file);

        disp(['  Processing ROI: ' roi_name]);

        % Matrix to store beta values across commercials (voxel x trial)
        roi_combined_beta_values = [];

        % Loop through each commercial
for i = 1:length(commercialNames{1})
    commercialName = commercialNames{1}{i}; 
    
    % Construct subject-specific directory
    resultDir = fullfile(base_spm_results_dir, ['Model3_sub-' subjID], commercialName);
    
    % Find matching beta file
row_idx = find(beta_table.Subject == subj & strcmp(beta_table.Label, commercialName));
    
    if ~isempty(row_idx)
        beta_filename = beta_table.BetaFile{row_idx}; 
        beta_file = fullfile(resultDir, beta_filename);
    else
        disp(['  No matching beta file found for ' commercialName ' for subject ' subjID]);
        continue; 
    end
    
    % Check if file exists
    if exist(beta_file, 'file')
        % Load beta image
        beta_vol = spm_vol(beta_file);
        beta_img = spm_read_vols(beta_vol);

        % Load ROI mask
        roi_vol = spm_vol(roi_file);
        roi_img = spm_read_vols(roi_vol);

        % Get voxel indices inside ROI
        roi_voxels = find(roi_img > 0); 

        % Extract beta values
        trial_beta_values = beta_img(roi_voxels); 

        % Add to combined matrix
        roi_combined_beta_values = [roi_combined_beta_values, trial_beta_values];

    else
        disp(['  Beta file not found: ' beta_file]);
    end
end

        % Remove NaNs
        num_voxels_before = size(roi_combined_beta_values, 1);
        roi_combined_beta_values = roi_combined_beta_values(all(~isnan(roi_combined_beta_values), 2), :);
        num_voxels_after = size(roi_combined_beta_values, 1);

        if num_voxels_before > num_voxels_after
            disp(['  Removed ' num2str(num_voxels_before - num_voxels_after) ' voxels with NaNs']);
        else
            disp('  No NaNs found in ROI data');
        end

        % Save beta matrix
        save_filename = fullfile(base_spm_results_dir, ['Model3_sub-' subjID], ...
            ['Model3_sub-' subjID '_' roi_name '_beta_values_POST.mat']);
        save(save_filename, 'roi_combined_beta_values');
        disp(['  Saved beta values to: ' save_filename]);

        % Compute and save correlation matrix
        if size(roi_combined_beta_values, 2) > 1
            correlation_matrix = corr(roi_combined_beta_values, 'rows', 'pairwise');
            correlation_filename = fullfile(base_spm_results_dir, ['Model3_sub-' subjID], ...
                ['Model3_sub-' subjID '_' roi_name '_correlation_matrix_POST.mat']);
            save(correlation_filename, 'correlation_matrix');
            disp(['  Saved correlation matrix to: ' correlation_filename]);
        end
    end
end

end
