clear all

%%%----Things you will want to change for your study----%%%
% subjects = [02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 18 19 20 21 22 23 24 25 27 28 29 30 31 32 33 34];
subjects = [01] 

% Loop through each subject
for subj = subjects

    % Format subject ID to have 2 nums
    subjID = sprintf('%02d', subj);

    % Directory
    fileDir = fullfile('/Volumes/BrusselsGriffon/CommCon/derivatives/fmriprep', ...
        ['sub-' subjID], 'func');

    % List scans
    niiFiles_pre = dir(fullfile(fileDir, ['sub-' subjID '_task-commpre_run-*_space-MNI152NLin2009cAsym_desc-preproc_bold.nii']));
    
    fprintf('PRE found: %d\n', length(niiFiles_pre));

    filePaths = cellstr(spm_select('ExtFPList', fileDir, ...
        ['^sub-' subjID '_task-commpre.*bold\.nii$'], Inf));
    
    filePaths = filePaths(:);  % enforce column for SPM

    % Output directory
    resultDir = fullfile('/Volumes/Poodle/Model4_REPSUP', ...
        ['Model4_sub-' subjID]);

    % Define behavioral timing file
    timingFile = fullfile( ...
        '/Users/yorkie/Documents/CommCon/data/raw_behavioral/Model4', ...
        ['sub_' subjID '_TimingFile_M4_PRE.mat'] ...
    );

    % Define confounds file
    confoundsFile = fullfile( ...
        '/Volumes/BrusselsGriffon/CommCon/derivatives/fmriprep', ...
        ['sub-' subjID], ...
        'func', ...
        ['sub-' subjID '_confounds_PRE.txt'] ...
    );

    % Set up the first-level model 
    matlabbatch{1}.spm.stats.fmri_spec.dir = {resultDir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.5;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

    % Scans
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = filePaths;

    % Specify the conditions 
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {timingFile};

    % Specify the confounds 
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {confoundsFile};

    % High-pass filter
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;

    % HRF basis function and no derivatives
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];

    % Set the global normalization method
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';

    % Masking and contrast specification
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

    % Run model
    spm_jobman('run', matlabbatch);

end
