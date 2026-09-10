% Define the path to the txt file with the commercial names
commercialNamesFile = '/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_scripts/CommercialNames.txt';

% Grab commercial name
fid = fopen(commercialNamesFile, 'r');
commercialNames = textscan(fid, '%s');
fclose(fid);

% List of subject IDs
%subjects = [02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 18 19 20 21 22 23 24 25 27 28 29 30 31 32 33 34]; 
subjects = [01]; 

% Loop through each commercial name
for i = 1:length(commercialNames{1})
    commercialName = commercialNames{1}{i}; 

    % Loop through each subject 
    for subj = subjects
        % Format subject ID to have two nums
        subjID = sprintf('%02d', subj); 

        % Define the directory 
        fileDir = fullfile('/Volumes/BrusselsGriffon/CommCon/derivatives/fmriprep', ['sub-' subjID], 'func');
        
        % List all the preprocessed .nii files 
        niiFiles = dir(fullfile(fileDir, ['sub-' subjID '_task-commpre_run-*_space-MNI152NLin2009cAsym_desc-preproc_bold.nii']));
        
        % Create a cell array of full paths for .nii files
        filePaths = cellfun(@(x) fullfile(fileDir, x), {niiFiles.name}, 'UniformOutput', false);
        
        % Define the directory to store the results with the commercial name
        resultDir = fullfile('/Volumes/Chi/Model3_PRE', ['Model3_sub-' subjID], commercialName);
        
        % Define behavioral timing file 
        timingFile = fullfile('/Users/yorkie/Documents/CommCon/data/raw_behavioral/Model3', commercialName, ['sub_' subjID '_' commercialName '_TimingFile_M3_PRE.mat']);
        
        % Define the confounds file 
        confoundsFile = fullfile('/Volumes/BrusselsGriffon/CommCon/derivatives/fmriprep', ['sub-' subjID], 'func', ['sub-' subjID '_confounds_PRE.txt']);
        
        % Set up the first-level model 
        matlabbatch{1}.spm.stats.fmri_spec.dir = {resultDir}; 
        matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.5; 
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16; 
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8; 

        % Specify fMRI scan files
        matlabbatch{1}.spm.stats.fmri_spec.sess.scans = filePaths;
        
        % Specify the conditions 
        matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {timingFile};
        
        % Specify the confounds file
        matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {confoundsFile};
        
        % High-pass filtering 
        matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128; 

        % HRF basis function and no derivatives
        matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
        
        % Set the global normalization method
        matlabbatch{1}.spm.stats.fmri_spec.global = 'None';

        % Masking and contrast specification
        matlabbatch{1}.spm.stats.fmri_spec.mask = {''}; 
        matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)'; 
        
        % Run the first-level model for this subject
        spm_jobman('run', matlabbatch);
    end
end
