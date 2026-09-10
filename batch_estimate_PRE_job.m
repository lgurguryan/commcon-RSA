% Define the path to the txt file with the commercial names
commercialNamesFile = '/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_scripts/CommercialNames.txt';

% Grab commercial name
fid = fopen(commercialNamesFile, 'r');
commercialNames = textscan(fid, '%s');
fclose(fid);

% List of subject IDs
%subjects = [01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 18 19 20 21 22 23 24 25 27 28 29 30 31 32 33 34]; 
 subjects = [01]

% Loop through each commercial name
for i = 1:length(commercialNames{1})
    commercialName = commercialNames{1}{i}; 

    % Loop through each subject
    for subj = subjects
        subjID = sprintf('%02d', subj); 

        % Define the results directory
        resultDir = fullfile('/Volumes/Chi/Model3_PRE', ['Model3_sub-' subjID], commercialName);
        
        % Load the design matrix 
        matlabbatch_file = fullfile(resultDir, ['SPM.mat']);
        load(matlabbatch_file, 'SPM'); 

        % Set up for job
        matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(resultDir, 'SPM.mat')};
        matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0; 
        matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1; 

        % Estimate
        spm_jobman('run', matlabbatch);
    end
end
