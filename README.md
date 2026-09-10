# commcon-RSA
repo for manuscript describing RSA analyses

Setup Scripts
Step 01: Generate Files for First-Level Scripts

These scripts generate the files needed to set up the first-level scripts.

create-onset-files-M3.R — Extracts/creates onset files for Model 3 (PRE and POST separate; 1 regressor per commercial segment of interest, the remaining segments of the commercial of interest, and all other commercials).
create-onset-files-M4.R — Extracts/creates onset files for Model 4 (PRE only, with 3 regressors: seg-0, seg-1, and seg-2 for all commercials together; used for footnote analysis).
create_confound_files.R — Creates confounds files for nuisance regressors.
create_mat_files_for_job_M3.m — Takes timing .txt files and converts them to .mat files needed for first-level analyses.
create_mat_files_for_job_M4.m — Takes timing .txt files and converts them to .mat files needed for first-level analyses.
Step 02: Run/Estimate First-Level Models

These scripts run and estimate the first-level models.

Run_1stLevels_PRE_M3.m — Creates first-level models for Model 3, PRE run.
Run_1stLevels_POST_M3.m — Creates first-level models for Model 3, POST run.
REPSUP_1stLevels_M4.m — Creates first-level models for Model 4, PRE run.
batch_estimate_REPSUP_M4_job.m — Estimates first-level models for Model 4, PRE run.
batch_estimate_PRE_job.m — Estimates first-level models for Model 3, PRE run.
batch_estimate_POST_job.m — Estimates first-level models for Model 3, POST run.
Step 03: Extract Betas and Compute Correlation Matrices

These scripts extract beta values and compute the correlation matrices needed for RSA analyses.

extract_beta_descrip.m — Extracts beta-map descriptions for each subject and commercial from Model 3 PRE and POST.
Com-Beta_mappings.R — Identifies the beta maps for each commercial segment for every participant and creates separate PRE and POST files.
extract_beta_descrip_M4.m — Extracts descriptions of all beta images for each subject from the PRE Model 4.
Seg-Beta_mappings.R — Combines beta-map information from all subjects into a single file, identifying the beta maps corresponding to the 3 task regressors (seg-0, seg-1, and seg-2) for Model 4.
extract_beta_values_from_MULTIPLE_ROIs_PRE.m — Model 3; extracts PRE betas and correlation matrices from vmPFC, PMC, and A1.
extract_beta_values_from_MULTIPLE_ROIs_POST.m — Model 3; extracts POST betas and correlation matrices from vmPFC, PMC, and A1.
extract_beta_values_from_MULTIPLE_ROIs_POST_minus_PRE.m — Model 3; computes difference-score betas and correlation matrices from vmPFC, PMC, and A1.
extract_beta_values_from_ASHS_ROIs_PRE.m — Model 3; extracts PRE betas and correlation matrices from hippocampus, PHC, and PRC.
extract_beta_values_from_ASHS_ROIs_POST.m — Model 3; extracts POST betas and correlation matrices from hippocampus, PHC, and PRC.
extract_beta_values_from_ASHS_ROIs_POST_minus_PRE.m — Model 3; computes difference-score betas and correlation matrices from hippocampus, PHC, and PRC.
extract_beta_values_from_ROIs_REPSUP_M4.m — Extracts PRE betas for Model 4 (footnote repetition-suppression analysis) from vmPFC, PMC, and A1.
extract_beta_values_from_ROIs_ashs_REPSUP_M4.m — Extracts PRE betas for Model 4 (footnote repetition-suppression analysis) from hippocampus, PHC, and PRC.
Step 04: Clean and Prepare Correlation Matrices

These scripts clean and prepare the correlation matrices for RSA analyses.

pick_pairs_M3.R — Creates .txt files containing the pairs of commercials used for RSA analyses.
order_rows_for_corr_plots_MULTIPLE_ROI.R — Reorders correlation matrices according to each participant's actual viewing sequence; Model 3, all ROIs.
save_corr_mat_with_commercial_labels_MULTIPLE_ROI.R — Adds commercial names to correlation matrices; Model 3, all ROIs.
select_corrs_for_pairs_MULTIPLE_ROI.R — Selects the commercial pairs used for RSA analyses.
Analysis Scripts
common-demo.R — Processes demographic information.
behavioural_MemTest_data.R — Computes averages for the post-scan source memory test.
lme_ashs.R — RSA analysis in the ASHS ROIs (hippocampus, PHC, PRC).
lme.R — RSA analysis in the vmPFC, PMC, and A1.
brain-behaviour-model3-lme.R — Examines the relationship between source memory accuracy and pattern similarity.
REPSUP_conceptual-rep.R — Conceptual repetition-suppression analysis (seg1–seg3) using Model 3 (segment-level GLMs), PRE.
REPSUP_M4.R — Conceptual repetition-suppression analysis using Model 4 (1 GLM per participant), PRE.
