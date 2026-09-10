##The custom order is just based on runs
# The sequence order is the order in which they watched the commercials during the experiment. 
# Will then use this to sort the PRE/POST/DIFF matrices to match the order they watched them in. 

# Libraries 
library(R.matlab)  
library(ggplot2)   
library(reshape2)

# ORGANIZE 

# Define subjects
#subject_ids <- c("s01", "s02", "s03", "s04", "s05", "s06", "s07", "s08", "s09", "s10", "s11", "s12", "s13", "s14", "s15", "s16", 
 #                "s18", "s19", "s21", "s22", "s23", "s24", "s25", "s27", "s28", "s29", "s30", "s31", "s32", "s33", "s20", "s34", "s26") 
 subject_ids <- c("s20", "s34")

# Define directories 
sequence_dir <- "/Users/yorkie/Documents/CommCon/sequence-files_all-subjects"
script_dir <- "/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_scripts"  

# Loop through each subject
for (subject_id in subject_ids) {
  
  # Create a list to store sequence of comms
  all_text_data <- character(0)  
  
  # Loop through the 3 runs 
  for (run_num in 1:3) {
    
    # Construct path for CSV file
    csv_file <- file.path(sequence_dir, paste0(subject_id, "_video-clip-sequence_run-", run_num, ".csv"))
    
    # Check if exists
    if (file.exists(csv_file)) {
      
      # Read CSV and extract the 'show_clip_basename' column
      csv_data <- read.csv(csv_file)
      
      # Make sure 'show_clip_basename' is a character vector 
      show_clip_basename <- as.character(csv_data$show_clip_basename[1])
      
      # Figure out the corresponding txt file based on show_clip_basename
      txt_file <- file.path(script_dir, paste0(show_clip_basename, ".txt"))
      
      # Check if corresponding txt file exists
      if (file.exists(txt_file)) {
        # Read 
        txt_data <- readLines(txt_file)
        
        # Combine all sequences
        all_text_data <- c(all_text_data, txt_data)
      } else {
        warning(paste("Text file not found for show_clip_basename:", show_clip_basename, "in run", run_num))
      }
    } else {
      warning(paste("CSV file not found for subject", subject_id, "and run", run_num))
    }
  }
  
  # Define output path/file
  output_txt_file <- file.path(sequence_dir, paste0(subject_id, "_sequence_order.txt"))
  
  # Ensure all_text_data is a character vector & save (still gives errors but works...)
  all_text_data <- as.character(all_text_data)
  
  writeLines(all_text_data, output_txt_file)
  
  cat("Processed and saved data for subject:", subject_id, "\n")
}

# REORDER

# Define subject IDs
#subject_ids <- c("s01", "s02", "s03", "s04", "s05", "s06", "s07", "s08", "s09", "s10", "s11", "s12", "s13", "s14", "s15", "s16", 
#                "s18", "s19", "s20","s21", "s22", "s23", "s24", "s25", "s27", "s28", "s29", "s30", "s31", "s32", "s33", "s34") 
subject_ids <- c("s20", "s34")
 
# Define the list of ROIs
rois <- c("left_Hippocampus_MNI-BOLD", "right_Hippocampus_MNI-BOLD", "left_Hippocampus-SUB_MNI-BOLD", "right_Hippocampus-SUB_MNI-BOLD",
          "left_PHC_MNI-BOLD", "right_PHC_MNI-BOLD", "left_PRC_MNI-BOLD", "right_PRC_MNI-BOLD", "left_motor_mask_resampled", "right_motor_mask_resampled",
          "left_A1_mask_resampled", "right_A1_mask_resampled", "left_V1_mask_resampled", "right_V1_mask_resampled",
          "vmPFC_right_resampled", "vmPFC_left_resampled", "PMC_3mm_resampled_bin" )

# Define directories
script_dir <- "/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_scripts"
commercial_names_file_path <- "/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_scripts/CommercialNames.txt"
sequence_dir <- "/Users/yorkie/Documents/CommCon/sequence-files_all-subjects"

############
### PRE ###
############

# Subject IDs
#subject_numbers <- c("s01", "s02", "s03", "s04", "s05", "s06", "s07", "s08", "s09", "s10", "s11", "s12", "s13", "s14", "s15", "s16", 
#                     "s18", "s19", "s20","s21", "s22", "s23", "s24", "s25", "s27", "s28", "s29", "s30", "s31", "s32", "s33", "s34") 
subject_numbers <- c("20", "34")

for (subject_number in subject_numbers) {
  
  subject_id <- paste0("sub-", subject_number)
  
  # Load the commercial names (this is order of betas which I had sorted alphabetically)
  commercial_names <- readLines(commercial_names_file_path)  
  
  for (roi in rois) {
    
    mat_file_path <- paste0("/Volumes/Chi/Model3_PRE/Model3_", subject_id, "/Model3_", subject_id, "_", roi, "_correlation_matrix_PRE.mat")
    sequence_file_path <- paste0(sequence_dir, "/s", subject_number, "_sequence_order.txt")
    
    if (file.exists(mat_file_path)) {
      
      data <- readMat(mat_file_path)
      cor_matrix <- data$correlation.matrix
      
      rownames(cor_matrix) <- commercial_names
      colnames(cor_matrix) <- commercial_names
      
      custom_order <- readLines(sequence_file_path)  
      cor_matrix_sorted <- cor_matrix[custom_order, custom_order, drop = FALSE]
      cor_melt_sorted <- melt(cor_matrix_sorted)
      
      CorrMat_sorted <- ggplot(cor_melt_sorted, aes(Var1, Var2, fill = value)) +
        geom_tile() +
        scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0) +
        theme_bw() +
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
        labs(title = paste(roi, "sorted: Trial x trial correlation matrix for", subject_id), 
             x = "Commercial", y = "Commercial") +
        scale_x_discrete(labels = custom_order) +  
        scale_y_discrete(labels = custom_order)
      
      output_file_path <- paste0("/Volumes/Chi/Model3_PRE/CorrMatrices/", subject_id, "_", roi, "_CorMat_PRE_sorted.png")
      ggsave(filename = output_file_path, plot = CorrMat_sorted, width = 7, height = 7, dpi = 300)
      
    } else {
      warning(paste("File not found:", mat_file_path))
    }
  }
}

############
### POST ###
############
#subject_numbers <- c("s01", "s02", "s03", "s04", "s05", "s06", "s07", "s08", "s09", "s10", "s11", "s12", "s13", "s14", "s15", "s16", 
 #                    "s18", "s19", "s20","s21", "s22", "s23", "s24", "s25", "s27", "s28", "s29", "s30", "s31", "s32", "s33", "s34") 
subject_numbers <- c("20", "34")

for (subject_number in subject_numbers) {
  
  subject_id <- paste0("sub-", subject_number)
  
  commercial_names <- readLines(commercial_names_file_path)  
  
  for (roi in rois) {
    
    mat_file_path <- paste0("/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST/Model3_", subject_id, "/Model3_", subject_id, "_", roi, "_correlation_matrix_POST.mat")
    sequence_file_path <- paste0(sequence_dir, "/s", subject_number, "_sequence_order.txt")
    
    if (file.exists(mat_file_path)) {
      
      data <- readMat(mat_file_path)
      cor_matrix <- data$correlation.matrix
      
      rownames(cor_matrix) <- commercial_names
      colnames(cor_matrix) <- commercial_names
      
      custom_order <- readLines(sequence_file_path)  
      cor_matrix_sorted <- cor_matrix[custom_order, custom_order, drop = FALSE]
      cor_melt_sorted <- melt(cor_matrix_sorted)
      
      CorrMat_sorted <- ggplot(cor_melt_sorted, aes(Var1, Var2, fill = value)) +
        geom_tile() +
        scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0) +
        theme_bw() +
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
        labs(title = paste(roi, "sorted: Trial x trial correlation matrix for", subject_id), 
             x = "Commercial", y = "Commercial") +
        scale_x_discrete(labels = custom_order) +  
        scale_y_discrete(labels = custom_order)
      
      output_file_path <- paste0("/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST/CorrMatrices/", subject_id, "_", roi, "_CorMat_POST_sorted.png")
      ggsave(filename = output_file_path, plot = CorrMat_sorted, width = 7, height = 7, dpi = 300)
      
    } else {
      warning(paste("File not found:", mat_file_path))
    }
  }
}

############
### DIFF ###
############

# Subject IDs
#subject_numbers <- c("s01", "s02", "s03", "s04", "s05", "s06", "s07", "s08", "s09", "s10", "s11", "s12", "s13", "s14", "s15", "s16", 
 #                    "s18", "s19", "s20","s21", "s22", "s23", "s24", "s25", "s27", "s28", "s29", "s30", "s31", "s32", "s33", "s34") 
 subject_numbers <- c("20", "34")

for (subject_number in subject_numbers) {
  
  subject_id <- paste0("sub-", subject_number)
  
  commercial_names <- readLines(commercial_names_file_path)  
  
  for (roi in rois) {
    
    mat_file_path <- paste0("/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST-PRE/Model3_", subject_id, "_", roi, "_correlation_matrix_DIFF.mat")
    sequence_file_path <- paste0(sequence_dir, "/s", subject_number, "_sequence_order.txt")
    
    if (file.exists(mat_file_path)) {
      
      data <- readMat(mat_file_path)
      cor_matrix <- as.matrix(data$corr.matrix) # or data$corr.matrix.diff
      
      rownames(cor_matrix) <- commercial_names
      colnames(cor_matrix) <- commercial_names
      
      custom_order <- readLines(sequence_file_path)  
      cor_matrix_sorted <- cor_matrix[custom_order, custom_order, drop = FALSE]
      cor_melt_sorted <- melt(cor_matrix_sorted)
      
      CorrMat_sorted <- ggplot(cor_melt_sorted, aes(Var1, Var2, fill = value)) +
        geom_tile() +
        scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0) +
        theme_bw() +
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
        labs(title = paste(roi, "sorted: Trial x trial correlation matrix for", subject_id), 
             x = "Commercial", y = "Commercial") +
        scale_x_discrete(labels = custom_order) +  
        scale_y_discrete(labels = custom_order)
      
      output_file_path <- paste0("/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST-PRE/CorrMatrices/", subject_id, "_", roi, "_CorMat_DIFF_sorted.png")
      ggsave(filename = output_file_path, plot = CorrMat_sorted, width = 7, height = 7, dpi = 300)
      
    } else {
      warning(paste("File not found:", mat_file_path))
    }
  }
}

