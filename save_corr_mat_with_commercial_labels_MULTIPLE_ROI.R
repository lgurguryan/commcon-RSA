## This will label the original .mat correlation matrix of the betas with the commercial names (alphabetical)

# Load libraries
library(R.matlab)

# Subject IDs
#subject_numbers <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", 
#                    "18", "19", "20", "21", "22", "23", "24", "25", "27", "28", "29", "30", "31", "32", "33", "34")

subject_numbers <- c("20", "34")  


# List of ROIs
rois <- c("left_Hippocampus_MNI-BOLD", "right_Hippocampus_MNI-BOLD", "left_Hippocampus-SUB_MNI-BOLD", "right_Hippocampus-SUB_MNI-BOLD",
"left_PHC_MNI-BOLD", "right_PHC_MNI-BOLD", "left_PRC_MNI-BOLD", "right_PRC_MNI-BOLD", "left_motor_mask_resampled", "right_motor_mask_resampled",
"left_A1_mask_resampled", "right_A1_mask_resampled", "left_V1_mask_resampled", "right_V1_mask_resampled",
"vmPFC_right_resampled", "vmPFC_left_resampled", "PMC_3mm_resampled_bin" )

# Path to commercial names
commercial_names_file_path <- "/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_scripts/CommercialNames.txt"

############
### PRE ###
############
for (subject_number in subject_numbers) {
  subject_id <- paste0("sub-", subject_number)
  
  for (roi in rois) {
    
    # File path
    mat_file_path <- paste0("/Volumes/Chi/Model3_PRE/Model3_", subject_id, 
                            "/Model3_", subject_id, "_", roi, "_correlation_matrix_PRE.mat")
    
    # Check if file exists
    if (file.exists(mat_file_path)) {
      # Load .mat file 
      data <- readMat(mat_file_path)
      cor_matrix <- data$correlation.matrix
      
      # Load commercial names
      commercial_names <- readLines(commercial_names_file_path)
      
      # Assign names
      rownames(cor_matrix) <- commercial_names
      colnames(cor_matrix) <- commercial_names
      
      # Output path
      output_csv_path <- paste0("/Volumes/Chi/Model3_PRE/Model3_", subject_id,
                                "/", subject_id, "_", roi, "_PRE_correlation_matrix_with_labels.csv")
      
      # Save
      write.csv(cor_matrix, file = output_csv_path, row.names = TRUE)
    } else {
      warning(paste("Missing PRE file:", mat_file_path))
    }
  }
}

############
### POST ###
############
for (subject_number in subject_numbers) {
  subject_id <- paste0("sub-", subject_number)
  
  for (roi in rois) {
    
    # File path
    mat_file_path <- paste0("/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST/Model3_", subject_id, 
                            "/Model3_", subject_id, "_", roi, "_correlation_matrix_POST.mat")
    
    if (file.exists(mat_file_path)) {
      # Load .mat file 
      data <- readMat(mat_file_path)
      cor_matrix <- data$correlation.matrix
      
      # Load commercial names
      commercial_names <- readLines(commercial_names_file_path)
      
      # Assign names
      rownames(cor_matrix) <- commercial_names
      colnames(cor_matrix) <- commercial_names
      
      # Output path
      output_csv_path <- paste0("/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST/Model3_", subject_id,
                                "/", subject_id, "_", roi, "_POST_correlation_matrix_with_labels.csv")
      
      # Save
      write.csv(cor_matrix, file = output_csv_path, row.names = TRUE)
    } else {
      warning(paste("Missing POST file:", mat_file_path))
    }
  }
}

############
### DIFF ###
############
for (subject_number in subject_numbers) {
  subject_id <- paste0("sub-", subject_number)
  
  for (roi in rois) {
    
    # File path
    mat_file_path <- paste0("/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST-PRE/Model3_", 
                            subject_id, "_", roi, "_correlation_matrix_DIFF.mat")
    
    if (file.exists(mat_file_path)) {
      # Load .mat file 
      data <- readMat(mat_file_path)
      cor_matrix <- as.matrix(data$corr.matrix)
      
      # Load commercial names
      commercial_names <- readLines(commercial_names_file_path)
      
      # Assign names
      rownames(cor_matrix) <- commercial_names
      colnames(cor_matrix) <- commercial_names
      
      # Output path
      output_csv_path <- paste0("/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST-PRE/Model3_",
                                subject_id, "_", roi, "_DIFF_correlation_matrix_with_labels.csv")
      
      # Save
      write.csv(cor_matrix, file = output_csv_path, row.names = TRUE)
    } else {
      warning(paste("Missing DIFF file:", mat_file_path))
    }
  }
}


################
### DIFF RAW ###
################
for (subject_number in subject_numbers) {
  subject_id <- paste0("sub-", subject_number)
  
  for (roi in rois) {
    
    # File path
    mat_file_path <- paste0("/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST-PRE/Model3_", 
                            subject_id, "_", roi, "_correlation_matrix_DIFF_RAW.mat")
    
    if (file.exists(mat_file_path)) {
      # Load .mat file 
      data <- readMat(mat_file_path)
      cor_matrix <- as.matrix(data$corr.matrix.raw)
      
      # Load commercial names
      commercial_names <- readLines(commercial_names_file_path)
      
      # Assign names
      rownames(cor_matrix) <- commercial_names
      colnames(cor_matrix) <- commercial_names
      
      # Output path
      output_csv_path <- paste0("/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST-PRE/Model3_",
                                subject_id, "_", roi, "_DIFF_RAW_correlation_matrix_with_labels.csv")
      
      # Save
      write.csv(cor_matrix, file = output_csv_path, row.names = TRUE)
    } else {
      warning(paste("Missing DIFF file:", mat_file_path))
    }
  }
}
