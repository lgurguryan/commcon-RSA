
function [] = extract_and_process_beta_differences()
% Extract, z-score, and compute beta differences (POST – PRE) for multiple ROIs.
% Uses beta-mapping tables to locate correct beta files.

% Define directories
base_spm_results_dir_pre  = '/Volumes/Chi/Model3_PRE';
base_spm_results_dir_post = '/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST';
base_spm_results_dir_diff = '/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST-PRE';
%base_roi_dir              = '/Volumes/Chi//HCPex_v1.1/ROIs';
base_roi_dir = ['/Volumes/Poodle/Baldassano_ROIs/resampled']

% Commercial list
commercialNamesFile = '/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_scripts/CommercialNames.txt';
fid = fopen(commercialNamesFile, 'r');
commercialNames = textscan(fid, '%s');
fclose(fid);

% Beta-mapping tables
beta_info_file_pre  = '/Volumes/Chi/Model3_PRE/Com-Beta-Maps_PRE.txt';
beta_info_file_post = '/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST/Com-Beta-Maps_POST.txt';

opts = detectImportOptions(beta_info_file_pre,  'FileType','text','Delimiter','\t');
beta_table_pre  = readtable(beta_info_file_pre,  opts);

opts = detectImportOptions(beta_info_file_post, 'FileType','text','Delimiter','\t');
beta_table_post = readtable(beta_info_file_post, opts);

% Subjects and ROIs
subjects  = [01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 18 19 20 21 22 23 24 25 27 28 29 30 31 32 33 34];
%subjects = [01];

%roi_files = dir(fullfile(base_roi_dir, '*_mask_resampled.nii'));
roi_files = dir(fullfile(base_roi_dir, '*_resampled_bin.nii'));

% Main loop
for subj = subjects
    subjID = sprintf('%02d', subj);
    disp(['Processing subject: ' subjID]);

    for iroi = 1:length(roi_files)
        roi_file = fullfile(base_roi_dir, roi_files(iroi).name);
        [~, roi_name, ~] = fileparts(roi_file);
        disp(['  ROI: ' roi_name]);

        roi_beta_pre  = [];
        roi_beta_post = [];

        for i = 1:length(commercialNames{1})
            commercialName = commercialNames{1}{i};

            % Look up PRE beta file 
            row_pre = find(beta_table_pre.Subject == subj & strcmp(beta_table_pre.Label, commercialName));
            % Look up POST beta file
            row_post = find(beta_table_post.Subject == subj & strcmp(beta_table_post.Label, commercialName));

            if isempty(row_pre) || isempty(row_post)
                disp(['  No mapping found for ' commercialName ' (subject ' subjID ')']);
                continue;
            end

            beta_file_pre  = fullfile(base_spm_results_dir_pre,  ['Model3_sub-' subjID], commercialName, beta_table_pre.BetaFile{row_pre});
            beta_file_post = fullfile(base_spm_results_dir_post, ['Model3_sub-' subjID], commercialName, beta_table_post.BetaFile{row_post});

            if ~exist(beta_file_pre,'file') || ~exist(beta_file_post,'file')
                disp(['  Missing beta file(s) for ' commercialName]);
                continue;
            end

            % Load beta images and ROI
            beta_pre  = spm_read_vols(spm_vol(beta_file_pre));
            beta_post = spm_read_vols(spm_vol(beta_file_post));
            roi_mask  = spm_read_vols(spm_vol(roi_file));
            roi_voxels = find(roi_mask > 0);

            %Extract voxel beta values
            roi_beta_pre  = [roi_beta_pre,  beta_pre(roi_voxels)];
            roi_beta_post = [roi_beta_post, beta_post(roi_voxels)];
        end

%%%%%%%%%
       % USE RAW VALUES FOR CORR MATRIX 
if ~isempty(roi_beta_pre) && size(roi_beta_pre,2) > 1
    % Combine pre and post raw beta differences
    raw_diff = roi_beta_post - roi_beta_pre;
    
    % Remove rows with NaNs
    raw_diff = raw_diff(all(~isnan(raw_diff),2),:);
    
    % Compute correlation matrix
    corr_matrix_raw = corr(raw_diff,'rows','pairwise');
    
    % Save correlation matrix
    corr_file_raw = fullfile(base_spm_results_dir_diff, ...
        ['Model3_sub-' subjID '_' roi_name '_correlation_matrix_DIFF_RAW.mat']);
    save(corr_file_raw,'corr_matrix_raw');
    disp(['  Saved RAW correlation matrix to: ' corr_file_raw]);
end
%%%%%%%%%

        % Z-score and compute differences
        roi_beta_pre_z  = zscore(roi_beta_pre,  0, 2);
        roi_beta_post_z = zscore(roi_beta_post, 0, 2);
        roi_beta_diff   = roi_beta_post_z - roi_beta_pre_z;

        % Remove NaN voxels
        before = size(roi_beta_diff,1);
        roi_beta_diff = roi_beta_diff(all(~isnan(roi_beta_diff),2),:);
        removed = before - size(roi_beta_diff,1);
        if removed>0
            disp(['  Removed ' num2str(removed) ' NaN voxels']);
        end

        % Save output 
        diff_file = fullfile(base_spm_results_dir_diff, ...
            ['Model3_sub-' subjID '_' roi_name '_beta_DIFF.mat']);
        save(diff_file,'roi_beta_diff');
        disp(['  Saved difference matrix to: ' diff_file]);

        if size(roi_beta_diff,2) > 1
            corr_matrix = corr(roi_beta_diff,'rows','pairwise');
            corr_file = fullfile(base_spm_results_dir_diff, ...
                ['Model3_sub-' subjID '_' roi_name '_correlation_matrix_DIFF.mat']);
            save(corr_file,'corr_matrix');
            disp(['  Saved correlation matrix to: ' corr_file]);
        end
    end
end
end



