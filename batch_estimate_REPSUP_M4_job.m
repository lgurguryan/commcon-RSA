% List of subject IDs
subjects = [02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 18 19 20 21 22 23 24 25 27 28 29 30 31 32 33 34]; 
%subjects = [01]

% Loop through each subject
for subj = subjects
    subjID = sprintf('%02d', subj); 

    % Define the results directory
    resultDir = fullfile('/Volumes/Poodle/Model4_REPSUP', ['Model4_sub-' subjID]);
    
    % Load the design matrix 
    matlabbatch_file = fullfile(resultDir, ['SPM.mat']);
    load(matlabbatch_file, 'SPM'); 

    % Set up for job
    matlabbatch = [];
    matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(resultDir, 'SPM.mat')};
    matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0; 
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1; 

    % Estimate
    spm_jobman('run', matlabbatch);
end