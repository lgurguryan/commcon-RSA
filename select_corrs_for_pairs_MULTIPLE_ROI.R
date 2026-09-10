##This is selecting the correlation pairs that will be used in the analyses. 

# Libraries
library(dplyr)
library(readr)

# Subject IDs
#subject_numbers <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", 
  #                  "18", "19", "20", "21", "22", "23", "24", "25", "27", "28", "29", "30", "31", "32", "33", "34")  

subject_numbers <- c("20", "34")  

# List of ROIs
 rois <- c("left_Hippocampus_MNI-BOLD", "right_Hippocampus_MNI-BOLD", "left_Hippocampus-SUB_MNI-BOLD", "right_Hippocampus-SUB_MNI-BOLD",
"left_PHC_MNI-BOLD", "right_PHC_MNI-BOLD", "left_PRC_MNI-BOLD", "right_PRC_MNI-BOLD", "left_motor_mask_resampled", "right_motor_mask_resampled",
"left_A1_mask_resampled", "right_A1_mask_resampled", "left_V1_mask_resampled", "right_V1_mask_resampled",
"vmPFC_right_resampled", "vmPFC_left_resampled", "PMC_3mm_resampled_bin" )

# Define the pairs of interest files (3 conditions)
pair_files <- list(
  same_show_episode = "/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_scripts/same_show_episode.txt",
  same_show_diff_episode = "/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_scripts/same_show_diff_episode.txt",
  diff_show = "/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_scripts/diff_show.txt", 
  'same_show_episode_SAME-COMS' = "/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_scripts/same_show_episode_SAME-COMS.txt", 
  'same_show_episode_DIFF-COMS' = "/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_scripts/same_show_episode_DIFF-COMS.txt"
)

############
### PRE ###
############
for (roi in rois) {
  for (pair_name in names(pair_files)) {
    commercial_pairs <- read.delim(pair_files[[pair_name]], header = TRUE, sep = "\t")
    
    for (subject_number in subject_numbers) {
      subject_id <- paste0("sub-", subject_number)
      
      corr_file_path <- paste0("/Volumes/Chi/Model3_PRE/Model3_", subject_id, 
                               "/", subject_id, "_", roi, "_PRE_correlation_matrix_with_labels.csv")
      
      if (file.exists(corr_file_path)) {
        corr_matrix <- read.csv(corr_file_path, header = TRUE, row.names = 1)
        corr_matrix <- as.matrix(corr_matrix)
        
        colnames(corr_matrix) <- gsub("\\.", "-", colnames(corr_matrix))
        rownames(corr_matrix) <- gsub("\\.", "-", rownames(corr_matrix))
        
        corr_matrix[upper.tri(corr_matrix)] <- NA
        
        diff_pair_corrs <- data.frame(Commercial1 = character(0), Commercial2 = character(0), Correlation = numeric(0))
        
        for (i in 1:nrow(commercial_pairs)) {
          commercial1 <- commercial_pairs$Commercial[i]
          commercial2 <- commercial_pairs$CommercialCopy[i]
          
          corr_value <- if (commercial1 %in% colnames(corr_matrix) && commercial2 %in% rownames(corr_matrix)) {
            corr_matrix[commercial2, commercial1]
          } else {
            NA
          }
          
          diff_pair_corrs <- rbind(diff_pair_corrs, data.frame(
            Commercial1 = commercial1,
            Commercial2 = commercial2,
            Correlation = corr_value
          ))
        }
        
        output_file <- paste0("/Volumes/Chi/Model3_PRE/Model3_", subject_id, 
                              "/", subject_id, "_", roi, "_PRE_", pair_name, "_corrs.csv")
        write.csv(diff_pair_corrs, output_file, row.names = FALSE)
        
        message(paste("Saved PRE", pair_name, "for", subject_id, roi))
      }
    }
  }
}

############
### POST ###
############
for (roi in rois) {
  for (pair_name in names(pair_files)) {
    commercial_pairs <- read.delim(pair_files[[pair_name]], header = TRUE, sep = "\t")
    
    for (subject_number in subject_numbers) {
      subject_id <- paste0("sub-", subject_number)
      
      corr_file_path <- paste0("/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST/Model3_", subject_id, 
                               "/", subject_id, "_", roi, "_POST_correlation_matrix_with_labels.csv")
      
      if (file.exists(corr_file_path)) {
        corr_matrix <- read.csv(corr_file_path, header = TRUE, row.names = 1)
        corr_matrix <- as.matrix(corr_matrix)
        
        colnames(corr_matrix) <- gsub("\\.", "-", colnames(corr_matrix))
        rownames(corr_matrix) <- gsub("\\.", "-", rownames(corr_matrix))
        
        corr_matrix[upper.tri(corr_matrix)] <- NA
        
        diff_pair_corrs <- data.frame(Commercial1 = character(0), Commercial2 = character(0), Correlation = numeric(0))
        
        for (i in 1:nrow(commercial_pairs)) {
          commercial1 <- commercial_pairs$Commercial[i]
          commercial2 <- commercial_pairs$CommercialCopy[i]
          
          corr_value <- if (commercial1 %in% colnames(corr_matrix) && commercial2 %in% rownames(corr_matrix)) {
            corr_matrix[commercial2, commercial1]
          } else {
            NA
          }
          
          diff_pair_corrs <- rbind(diff_pair_corrs, data.frame(
            Commercial1 = commercial1,
            Commercial2 = commercial2,
            Correlation = corr_value
          ))
        }
        
        output_file <- paste0("/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST/Model3_", subject_id, 
                              "/", subject_id, "_", roi, "_POST_", pair_name, "_corrs.csv")
        write.csv(diff_pair_corrs, output_file, row.names = FALSE)
        
        message(paste("Saved POST", pair_name, "for", subject_id, roi))
      }
    }
  }
}

############
### DIFF ###
############
for (roi in rois) {
  for (pair_name in names(pair_files)) {
    commercial_pairs <- read.delim(pair_files[[pair_name]], header = TRUE, sep = "\t")
    
    for (subject_number in subject_numbers) {
      subject_id <- paste0("sub-", subject_number)
      
      corr_file_path <- paste0("/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST-PRE/Model3_", 
                               subject_id, "_", roi, "_DIFF_correlation_matrix_with_labels.csv")
      
      if (file.exists(corr_file_path)) {
        corr_matrix <- read.csv(corr_file_path, header = TRUE, row.names = 1)
        corr_matrix <- as.matrix(corr_matrix)
        
        colnames(corr_matrix) <- gsub("\\.", "-", colnames(corr_matrix))
        rownames(corr_matrix) <- gsub("\\.", "-", rownames(corr_matrix))
        
        corr_matrix[upper.tri(corr_matrix)] <- NA
        
        diff_pair_corrs <- data.frame(Commercial1 = character(0), Commercial2 = character(0), Correlation = numeric(0))
        
        for (i in 1:nrow(commercial_pairs)) {
          commercial1 <- commercial_pairs$Commercial[i]
          commercial2 <- commercial_pairs$CommercialCopy[i]
          
          corr_value <- if (commercial1 %in% colnames(corr_matrix) && commercial2 %in% rownames(corr_matrix)) {
            corr_matrix[commercial2, commercial1]
          } else {
            NA
          }
          
          diff_pair_corrs <- rbind(diff_pair_corrs, data.frame(
            Commercial1 = commercial1,
            Commercial2 = commercial2,
            Correlation = corr_value
          ))
        }
        
        output_file <- paste0("/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST-PRE/Model3_", 
                              subject_id, "_", roi, "_DIFF_", pair_name, "_corrs.csv")
        write.csv(diff_pair_corrs, output_file, row.names = FALSE)
        
        message(paste("Saved DIFF", pair_name, "for", subject_id, roi))
      }
    }
  }
}


################
### DIFF RAW ###
###############
for (roi in rois) {
  for (pair_name in names(pair_files)) {
    commercial_pairs <- read.delim(pair_files[[pair_name]], header = TRUE, sep = "\t")
    
    for (subject_number in subject_numbers) {
      subject_id <- paste0("sub-", subject_number)
      
      corr_file_path <- paste0("/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST-PRE/Model3_", 
                               subject_id, "_", roi, "_DIFF_RAW_correlation_matrix_with_labels.csv")
      
      if (file.exists(corr_file_path)) {
        corr_matrix <- read.csv(corr_file_path, header = TRUE, row.names = 1)
        corr_matrix <- as.matrix(corr_matrix)
        
        colnames(corr_matrix) <- gsub("\\.", "-", colnames(corr_matrix))
        rownames(corr_matrix) <- gsub("\\.", "-", rownames(corr_matrix))
        
        corr_matrix[upper.tri(corr_matrix)] <- NA
        
        diff_pair_corrs <- data.frame(Commercial1 = character(0), Commercial2 = character(0), Correlation = numeric(0))
        
        for (i in 1:nrow(commercial_pairs)) {
          commercial1 <- commercial_pairs$Commercial[i]
          commercial2 <- commercial_pairs$CommercialCopy[i]
          
          corr_value <- if (commercial1 %in% colnames(corr_matrix) && commercial2 %in% rownames(corr_matrix)) {
            corr_matrix[commercial2, commercial1]
          } else {
            NA
          }
          
          diff_pair_corrs <- rbind(diff_pair_corrs, data.frame(
            Commercial1 = commercial1,
            Commercial2 = commercial2,
            Correlation = corr_value
          ))
        }
        
        output_file <- paste0("/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST-PRE/Model3_", 
                              subject_id, "_", roi, "_DIFF_", pair_name, "_corrs_RAW.csv")
        write.csv(diff_pair_corrs, output_file, row.names = FALSE)
        
        message(paste("Saved DIFF", pair_name, "for", subject_id, roi))
      }
    }
  }
}

