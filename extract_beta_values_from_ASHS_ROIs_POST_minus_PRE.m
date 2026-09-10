function [] = zscore_and_difference_scores()
% This function loads POST and PRE beta values for each subject and ROI, 
% z-scores the values, and computes the difference score (POST - PRE).
% The resulting data is saved as MAT files.

% Define directories
base_spm_results_dir_diff = '/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST-PRE/';  
base_spm_results_dir_post = '/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST/';  
base_spm_results_dir_pre = '/Volumes/Chi/Model3_PRE/';    
base_roi_dir = '/Volumes/Poodle/ashs-ROIs';

% Define path to txt file with the commercial names
commercialNamesFile = '/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_scripts/CommercialNames.txt';

% Grab commercial names from the text file
fid = fopen(commercialNamesFile, 'r');
commercialNames = textscan(fid, '%s');
fclose(fid);

% List of subject IDs
 subjects = [20 34]; 
%subjects = [01];
 %subjects = [01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 18 19 20 21 22 23 24 25 27 28 29 30 31 32 33 34];  

% Loop through each subject
for subj = subjects
    subjID = sprintf('%02d', subj);  
    disp(['Processing subject: ' subjID]);
    
    % Define ROI names 
roi_names = {
    'left_Hippocampus_MNI-BOLD' 
    'left_Hippocampus_MNI-BOLD'
    'right_Hippocampus_MNI-BOLD'
    'right_Hippocampus_MNI-BOLD'
    'left_Hippocampus-SUB_MNI-BOLD' 
    'left_Hippocampus-SUB_MNI-BOLD'
    'right_Hippocampus-SUB_MNI-BOLD'
    'right_Hippocampus-SUB_MNI-BOLD'
    'left_PHC_MNI-BOLD'
    'left_PRC_MNI-BOLD'
    'right_PHC_MNI-BOLD'
    'right_PRC_MNI-BOLD'
    };


% Loop through each ROI
for iroi = 1:length(roi_names)

    roi_name = roi_names{iroi};        
        disp(['  Processing ROI: ' roi_name]);

        % Load POST beta values 
        post_beta_file = fullfile(base_spm_results_dir_post, ['Model3_sub-' subjID], ...
            ['Model3_sub-' subjID '_' roi_name '_beta_values_POST.mat']);
        
        disp(['Checking POST file: ', post_beta_file]);  

        if exist(post_beta_file, 'file')
            post_data = load(post_beta_file);
            disp('POST file variables:');
            disp(post_data);  
            
            % Check 
            if isfield(post_data, 'roi_combined_beta_values_POST')
                roi_combined_beta_values_POST = post_data.roi_combined_beta_values_POST;
            else
                disp('POST variable not found!');
                continue;
            end
        else
            disp(['  POST beta file not found for ' roi_name]);
            continue;
         end

        % Load PRE beta values 
        pre_beta_file = fullfile(base_spm_results_dir_pre, ['Model3_sub-' subjID], ...
            ['Model3_sub-' subjID '_' roi_name '_beta_values_PRE.mat']);
        
        disp(['Checking PRE file: ', pre_beta_file]);  

        if exist(pre_beta_file, 'file')
            pre_data = load(pre_beta_file);
            disp('PRE file variables:');
            disp(pre_data);  
            
            % Check 
            if isfield(pre_data, 'roi_combined_beta_values_PRE')
                roi_combined_beta_values_PRE = pre_data.roi_combined_beta_values_PRE;
            else
                disp('PRE variable not found!');
                continue;
            end
        else
            disp(['  PRE beta file not found for ' roi_name]);
            continue;
         end

        % Check if POST and PRE matrices have the same number of trials (columns)
        if size(roi_combined_beta_values_POST, 2) ~= size(roi_combined_beta_values_PRE, 2)
            disp(['  Number of trials do not match between POST and PRE for ' roi_name ' in subject ' subjID]);
            continue;
        end
        
        % Only keep if both PRE and POST have values in that voxel (remove
        % if one is nan)
        % Find the minimum number of voxels (rows)
        n_voxels = min(size(roi_combined_beta_values_POST,1), size(roi_combined_beta_values_PRE,1));
        
        % Trim both matrices to the same number of voxels
        roi_combined_beta_values_POST = roi_combined_beta_values_POST(1:n_voxels,:);
        roi_combined_beta_values_PRE  = roi_combined_beta_values_PRE(1:n_voxels,:);
        
        % Now remove any rows with NaNs in either
        valid_voxels = all(~isnan(roi_combined_beta_values_POST),2) & ...
                       all(~isnan(roi_combined_beta_values_PRE),2);
        
        roi_combined_beta_values_POST = roi_combined_beta_values_POST(valid_voxels,:);
        roi_combined_beta_values_PRE  = roi_combined_beta_values_PRE(valid_voxels,:);


%%%%%%%%%
       % USE RAW VALUES FOR CORR MATRIX 
if size(roi_combined_beta_values_POST, 2) > 1
    raw_diff = roi_combined_beta_values_POST - roi_combined_beta_values_PRE;

    % Remove rows with NaNs
    raw_diff = raw_diff(all(~isnan(raw_diff),2), :);

    % Compute correlation matrix
    corr_matrix_raw = corr(raw_diff, 'rows', 'pairwise');

    % Save correlation matrix
    save_name_corr_raw = fullfile(base_spm_results_dir_diff, ...
        ['Model3_sub-' subjID '_' roi_name '_correlation_matrix_DIFF_RAW.mat']);
    save(save_name_corr_raw, 'corr_matrix_raw');
    disp(['  Saved RAW correlation matrix to: ' save_name_corr_raw]);
end
%%%%%%%%%

        % Z-score the beta values
        zscore_post = zscore(roi_combined_beta_values_POST, 0, 2);  % Z-score across trials (columns)
        zscore_pre = zscore(roi_combined_beta_values_PRE, 0, 2);    % Z-score across trials (columns)

        % Compute the difference score (POST - PRE)
        diff_score = zscore_post - zscore_pre;

        % Save the difference score
        diff_filename = fullfile(base_spm_results_dir_diff, ...
        ['Model3_sub-' subjID '_' roi_name '_diff_score.mat']);
        save(diff_filename, 'diff_score');
        disp(['  Saved difference score to: ' diff_filename]);

        % Compute and save correlation matrix
        if size(diff_score, 2) > 1
            corr_matrix_diff = corr(diff_score, 'rows', 'pairwise');
            save_name_corr = fullfile(base_spm_results_dir_diff, ...
                ['Model3_sub-' subjID '_' roi_name '_correlation_matrix_DIFF.mat']);
            save(save_name_corr, 'corr_matrix_diff');
            disp(['  Saved correlation matrix to: ' save_name_corr]);
    end
end

end
