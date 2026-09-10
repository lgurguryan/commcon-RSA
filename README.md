# commcon-RSA

# MODEL INFO: 

## Model 3:
- For each commercial segment, 3 separate GLMs is modeled (i.e., (1) segment of interest for commercial, (2) remaining 2 segments of the commercial, (3) all other commercial segments)
- 72 GLMs per participant 

## Model 4:
- 1 GLM is modeled per participant with 3 regressors of interest: (1) segment 1 for all commercials, (2) segment 2 for all commercials, (3) segment 3 for all commercials
- Used only for the repetition suppression analysis in footnote 
  
# SETUP SCRIPTS

## STEP 01: these scripts will generate the files you need to set up the 1st level scripts 
- _create-onset-files-M3.R_: extract/create onset files for model 3 (Pre and Post separate; 1 regressor per commercial segment of interest, the remaining segments of the commercial of interest, and all other commercials)
- _create-onset-files-M4.R_: extract/create onset files for model 4 (PRE only, with 3 regressors (seg-0, seg-1, and seg-2) for all commercials together; used for footnote analysis)
- _create_confound_files.R_: creates confounds file for nuisance regressors 
- _create_mat_files_for_job_M3_.m: Take timing txt file and convert to .mat file needed for 1st levels
- _create_mat_files_for_job_M4.m_: Take timing txt file and convert to .mat file needed for 1st levels 

## STEP 02: these scripts will run/estimate the 1st level models 
- _Run_1stLevels_PRE_M3.m_: run script to create 1st levels for model 3 for PRE run
- _Run_1stLevels_POST_M3.m_: run script to create 1st levels for model 3 for POST run
- _REPSUP_1stLevels_M4.m_: run script to create 1st levels for model 4 for PRE run
- _batch_estimate_REPSUP_M4_job.m_: run script to estimate 1st levels for model 4 for PRE run
- _batch_estimate_PRE_job.m_: run script to estimate 1st levels for model 3 for PRE run
- _batch_estimate_POST_job.m_: run script to estimate 1st levels for model 3 for POST run

## STEP 03: these scripts will extract the betas and compute the correlation matrices needed for RSA analyses 
- _extract_beta_descrip.m_: Extracts beta-map descriptions for each subject and commercial from the Model 3 PRE and POST for each subject
- _Com-Beta_mappings.R_: identifies the beta maps for each commercial seg for every participant and creates separate PRE and POST files
extract_beta_descrip_M4.m: extracts descriptions of all beta images for each subject from the PRE Model 4
- _Seg-Beta_mappings.R_: combines beta-map info from all subjects into a file, identifying the beta maps corresponding to the 3 task regressors (seg-0, seg-1, and seg-2); model 4
- _extract_beta_values_from_MULTIPLE_ROIs_PRE.m_: model 3; extract PRE betas + correlation matrix from vmPFC, PMC, A1
- _extract_beta_values_from_MULTIPLE_ROIs_POST.m_: model 3; extract POST betas + correlation matrix from vmPFC, PMC, A1
- _extract_beta_values_from_MULTIPLE_ROIs_POST_minus_PRE.m_: model 3; compute difference score betas + correlation matrix from vmPFC, PMC, A1
- _extract_beta_values_from_ASHS_ROIs_PRE.m_: model 3; extract PRE betas + correlation matrix from hippocampus, PHC, PRC
- _extract_beta_values_from_ASHS_ROIs_POST.m_: model 3; extract POST betas + correlation matrix from hippocampus, PHC, PRC
- _extract_beta_values_from_ASHS_ROIs_POST_minus_PRE.m_: model 3; compute difference score betas + correlation matrix from hippocampus, PHC, PRC
- _extract_beta_values_from_ROIs_REPSUP_M4.m_: extract PRE betas for model 4 (for footnote repsup analysis) from vmPFC, PMC, and A1
- _extract_beta_values_from_ROIs_ashs_REPSUP_M4.m_: extract PRE betas for model 4 (for footnote repsup analysis) from hippocampus, PHC, PRC

## STEP 04: These scripts clean/prep the corr matrices for the RSA analyses
- _pick_pairs_M3.R_: creates txt files for the pairs of commercials that we care about for RSA analysis
- _order_rows_for_corr_plots_MULTIPLE_ROI.R_: reorders corr matrices according to the participant's actual viewing sequence; model 3, all ROIs
- _save_corr_mat_with_commercial_labels_MULTIPLE_ROI.R_: adds commercial names to matrices; model 3, all ROIs
- _select_corrs_for_pairs_MULTIPLE_ROI.R_: picks out the commercial pairs we care about for RSA

# ANALYSIS SCRIPTS:
- _common-demo.R_: demographics info
- _behavioural_MemTest_data.R_: computes averages for post-scan source memory test
- _lme_ashs.R_: RSA analysis in the ASHS ROIs (hippocampus, PHC, PRC).
- _lme.R_: RSA analysis in the vmPFC, PMC, A1
- _brain-behaviour-model3-lme.R_: analysis examining relationship between source memory accuracy and pattern similarity 
- _REPSUP_conceptual-rep.R_: conceptual repetition suppression analysis (seg1-seg3) using model3 (segment level GLMS) PRE 
- _REPSUP_M4.R_: conceptual repetition suppression analysis using model 4 (i.e., 1 GLM per participant) PRE 
