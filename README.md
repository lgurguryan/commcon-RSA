# commcon-RSA
repo for manuscript describing RSA analyses

# Model info: 

## Model 3:
- For each commercial segment, 3 separate GLMs is modeled (i.e., (1) segment of interest for commercial, (2) remaining 2 segments of the commercial, (3) all other commercial segments)
- 72 GLMs per participant 

## Model 4:
- 1 GLM is modeled per participant with 3 regressors of interest: (1) segment 1 for all commercials, (2) segment 2 for all commercials, (3) segment 3 for all commercials
- Used only for the repetition suppression analysis in footnote 
  
# SETUP SCRIPTS

## STEP 01: these scripts will generate the files you need to set up the 1st level scripts 
- create-onset-files-M3.R: extract/create onset files for model 3 (Pre and Post separate; 1 regressor per commercial segment of interest, the remaining segments of the commercial of interest, and all other commercials)
- create-onset-files-M4.R: extract/create onset files for model 4 (PRE only, with 3 regressors (seg-0, seg-1, and seg-2) for all commercials together; used for footnote analysis)
- create_confound_files.R: creates confounds file for nuisance regressors 
- create_mat_files_for_job_M3.m: Take timing txt file and convert to .mat file needed for 1st levels
- create_mat_files_for_job_M4.m: Take timing txt file and convert to .mat file needed for 1st levels 

## STEP 02: these scripts will run/estimate the 1st level models 
- Run_1stLevels_PRE_M3.m: run script to create 1st levels for model 3 for PRE run
- Run_1stLevels_POST_M3.m: run script to create 1st levels for model 3 for POST run
- REPSUP_1stLevels_M4.m: run script to create 1st levels for model 4 for PRE run
- batch_estimate_REPSUP_M4_job.m: run script to estimate 1st levels for model 4 for PRE run
- batch_estimate_PRE_job.m: run script to estimate 1st levels for model 3 for PRE run
- batch_estimate_POST_job.m: run script to estimate 1st levels for model 3 for POST run

## STEP 03: these scripts will extract the betas and compute the correlatin matrices needed for RSA analyses 
- extract_beta_descrip.m: Extracts beta-map descriptions for each subject and commercial from the Model 3 PRE and POST for each subject
- Com-Beta_mappings.R: identifies the beta maps for each commercial seg for every participant and creates separate PRE and POST files
extract_beta_descrip_M4.m: extracts descriptions of all beta images for each subject from the PRE Model 4
- Seg-Beta_mappings.R: combines beta-map info from all subjects into a file, identifying the beta maps corresponding to the 3 task regressors (seg-0, seg-1, and seg-2); model 4
- extract_beta_values_from_MULTIPLE_ROIs_PRE.m: model 3; extract PRE betas + correlation matrix from vmPFC, PMC, A1
- extract_beta_values_from_MULTIPLE_ROIs_POST.m: model 3; extract POST betas + correlation matrix from vmPFC, PMC, A1
- extract_beta_values_from_MULTIPLE_ROIs_POST_minus_PRE.m: model 3; compute difference score betas + correlation matrix from vmPFC, PMC, A1
- extract_beta_values_from_ASHS_ROIs_PRE.m: model 3; extract PRE betas + correlation matrix from hippocampus, PHC, PRC
- extract_beta_values_from_ASHS_ROIs_POST.m: model 3; extract POST betas + correlation matrix from hippocampus, PHC, PRC
- extract_beta_values_from_ASHS_ROIs_POST_minus_PRE.m: model 3; compute difference score betas + correlation matrix from hippocampus, PHC, PRC
- extract_beta_values_from_ROIs_REPSUP_M4.m: extract PRE betas for model 4 (for footnote repsup analysis) from vmPFC, PMC, and A1
- extract_beta_values_from_ROIs_ashs_REPSUP_M4.m: extract PRE betas for model 4 (for footnote repsup analysis) from hippocampus, PHC, PRC

## STEP 04: These scripts clean/prep the corr matrices for the RSA analyses
- pick_pairs_M3.R: creates txt files for the pairs of commercials that we care about for RSA analysis
- order_rows_for_corr_plots_MULTIPLE_ROI.R: reorders corr matrices according to the participant's actual viewing sequence; model 3, all ROIs
- save_corr_mat_with_commercial_labels_MULTIPLE_ROI.R: adds commercial names to matrices; model 3, all ROIs
- select_corrs_for_pairs_MULTIPLE_ROI.R: picks out the commercial pairs we care about for RSA

# ANALYSIS SCRIPTS:
- common-demo.R: demographics info
- behavioural_MemTest_data.R: computes averages for post-scan source memory test
- lme_ashs.R: RSA analysis in the ASHS ROIs (hippocampus, PHC, PRC).
- lme.R: RSA analysis in the vmPFC, PMC, A1
- brain-behaviour-model3-lme.R: analysis examining relationship between source memory accuracy and pattern similarity 
- REPSUP_conceptual-rep.R: conceptual repetition suppression analysis (seg1-seg3) using model3 (segment level GLMS) PRE 
- REPSUP_M4.R: conceptual repetition suppression analysis using model 4 (i.e., 1 GLM per participant) PRE 
