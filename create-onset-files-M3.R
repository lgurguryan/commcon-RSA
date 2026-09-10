#########
## PRE ##
#########

# Load libraries
library(dplyr)

## Create 'master' onset file

# Define root dir (raw_behavioral folder)
root_dir <- "/Users/yorkie/Documents/CommCon/data/raw_behavioral"

# List all the subfolders in the raw_behavioral folder
subject_folders <- list.dirs(root_dir, full.names = TRUE, recursive = FALSE)

# Extract subject IDs from folder names 
subject_ids <- sub("commcon-(\\d+)", "\\1", basename(subject_folders))

# Loop through subjects
for (subject_id in subject_ids) {
  # Path for each subject
  subject_path <- file.path(root_dir, paste0("commcon-", subject_id, "/sub_", subject_id))
  
  # Find the CSV containing '_show_commercials_3_clips_pre_' in name
  csv_files <- list.files(subject_path, pattern = "_show_commercials_3_clips_pre_.*\\.csv$", full.names = TRUE)
  
  # Flag if more than 1 or 0 files found
  if (length(csv_files) == 0) {
    # No files found
    print(paste("No matching CSV files found for subject", subject_id))
  } else if (length(csv_files) > 1) {
    # More than 1 file found
    print(paste("Warning: More than one CSV file found for subject", subject_id))
  } else {
    # Read CSV file
    data <- read.csv(csv_files)
    
    # Extract value from 'getTrigger.rt' in row 2 (technically 3 in excel)
    trigger_rt_value <- data$getTrigger.rt[2]
    
    # Subtract this value from the 'movie_2.started' column
    #trigger_onset <- data$movie_2.started - trigger_rt_value
    
    # Extract value from 'getTrigger.started' in row 2
    trigger_started_value <- data$getTrigger.started[2]
    
    # Calculate trigger onset relative to global clock
    trigger_onset <- trigger_started_value + trigger_rt_value
    
    # Calculate movie onset relative to trigger 
    movieOnset_relative_trigger <- data$movie_2.started - trigger_onset
    
    # Combine the 'fname' column and 'onsets' into a new df
    result <- data.frame(fname = data$fname, onsets = movieOnset_relative_trigger)
    
    # Remove rows with NA in 'onsets' column (so non task rows)
    result <- result[!is.na(result$onsets), ]
    
    # Modify the 'fname' column to remove '_resized_1280-720_' & '.mp4'
    result$fname <- gsub("_resized_1280-720_", "_", result$fname)
    result$fname <- gsub(".mp4$", "", result$fname)  
    
    # Add the 'duration' column (each clip played for 5 seconds)
    result$duration <- 5
    
    # Add run number (1)
    result$run <- 1
    
    # Create a CSV file to store onsets
    onsets_file <- file.path(subject_path, paste0("subject_", subject_id, "_TimingFile_PRE.csv"))
    
    # Write onset to the CSV 
    write.csv(result, onsets_file, row.names = FALSE)
    print(paste("Results for subject", subject_id, "saved to", onsets_file))
  }
}


## Create onsets for MODEL 3 where for each commercial:
## [seg0] [seg1 seg2] [all others]
## [seg1] [seg0 seg2] [all others]
## [seg2] [seg0 seg1] [all others]


# Root dir for Model 3
model3_folder <- file.path(root_dir, "Model3")

# Create the Model3 folder if it doesn't exist
if (!dir.exists(model3_folder)) {
  dir.create(model3_folder)
}

for (subject_id in subject_ids) {
  subject_path <- file.path(root_dir, paste0("commcon-", subject_id, "/sub_", subject_id))
  
  timing_file_path <- file.path(subject_path, paste0("subject_", subject_id, "_TimingFile_PRE.csv"))
  
  if (file.exists(timing_file_path)) {
    data <- read.csv(timing_file_path)
    
    # Extract base commercial name by removing any _seg-0, _seg-1, or _seg-2 
    data$base_name <- gsub("_seg-[0-2]$", "", data$fname)
    
    # Get unique commercial names including their segments (full fname)
    unique_commercials <- unique(data$fname)
    
    # For each commercial (full fname, including segment), create a seperate file
    for (commercial in unique_commercials) {
      
      # Determine the base name for this commercial
      commercial_base <- gsub("_seg-[0-2]$", "", commercial)
      
      # Create a new column for the regressor_name:
      # - If the row's fname equals commercial, keep it as is (seg-0 will be separate file)
      # - If row has same base but segment is 1 or 2, rename to base commercial name (no seg)
      # - Everythign else, rename to AllOthers
      
      data$regressor_name <- ifelse(
        data$fname == commercial,                       
        commercial,
        ifelse(
          data$base_name == commercial_base,            
          commercial_base,
          "AllOthers"                                   
        ))
      
      # Select columns to save
      save_data <- data[, c("run", "regressor_name", "onsets", "duration")]
      
      # Create commercial folder 
      commercial_folder <- file.path(model3_folder, commercial)
      if (!dir.exists(commercial_folder)) {
        dir.create(commercial_folder)
      }
      
      # File name 
      file_name <- file.path(commercial_folder, paste0("sub_", subject_id, "_", commercial, "_TimingFile_M3_PRE.txt"))
      
      # Save 
      write.table(save_data, file_name, row.names = FALSE, col.names = TRUE, sep = "\t", quote = FALSE)
      
      print(paste("File saved:", file_name))
    }
    
  } else {
    print(paste("No TimingFile_PRE.csv found for subject", subject_id))
  }
}


##########
## POST ##
##########

# Load libraries
library(dplyr)

## Create 'master' onset file

# Define root dir (raw_behavioral folder)
root_dir <- "/Users/yorkie/Documents/CommCon/data/raw_behavioral"

# List all the subfolders in the raw_behavioral folder
subject_folders <- list.dirs(root_dir, full.names = TRUE, recursive = FALSE)

# Extract subject IDs from folder names 
subject_ids <- sub("commcon-(\\d+)", "\\1", basename(subject_folders))

# Loop through subjects
for (subject_id in subject_ids) {
  # Path for each subject
  subject_path <- file.path(root_dir, paste0("commcon-", subject_id, "/sub_", subject_id))
  
  # Find the CSV containing '_show_commercials_3_clips_post_' in name
  csv_files <- list.files(subject_path, pattern = "_show_commercials_3_clips_post_.*\\.csv$", full.names = TRUE)
  
  # Flag if more than 1 or 0 files found
  if (length(csv_files) == 0) {
    # No files found
    print(paste("No matching CSV files found for subject", subject_id))
  } else if (length(csv_files) > 1) {
    # More than 1 file found
    print(paste("Warning: More than one CSV file found for subject", subject_id))
  } else {
    # Read CSV file
    data <- read.csv(csv_files)
    
    # Extract value from 'getTrigger.rt' in row 2 (technically 3 in excel)
    trigger_rt_value <- data$getTrigger.rt[2]
    
    # Subtract this value from the 'movie_2.started' column
    #trigger_onset <- data$movie_2.started - trigger_rt_value
    
    # Extract value from 'getTrigger.started' in row 2
    trigger_started_value <- data$getTrigger.started[2]
    
    # Calculate trigger onset relative to global clock
    trigger_onset <- trigger_started_value + trigger_rt_value
    
    # Calculate movie onset relative to trigger 
    movieOnset_relative_trigger <- data$movie_2.started - trigger_onset
    
    # Combine the 'fname' column and 'onsets' into a new df
    result <- data.frame(fname = data$fname, onsets = movieOnset_relative_trigger)
    
    # Remove rows with NA in 'onsets' column (so non task rows)
    result <- result[!is.na(result$onsets), ]
    
    # Modify the 'fname' column to remove '_resized_1280-720_' & '.mp4'
    result$fname <- gsub("_resized_1280-720_", "_", result$fname)
    result$fname <- gsub(".mp4$", "", result$fname)  
    
    # Add the 'duration' column (each clip played for 5 seconds)
    result$duration <- 5
    
    # Add run number (1)
    result$run <- 1
    
    # Order colymns
    result <- result[, c("run", "fname", "onsets", "duration")]
    
    # Create a CSV file to store onsets
    onsets_file <- file.path(subject_path, paste0("subject_", subject_id, "_TimingFile_POST.csv"))
    
    # Write onset to the CSV 
    write.csv(result, onsets_file, row.names = FALSE)
    print(paste("Results for subject", subject_id, "saved to", onsets_file))
  }
}


## Create onsets for MODEL 3 where for each commercial:
## [seg0] [seg1 seg2] [all others]
## [seg1] [seg0 seg2] [all others]
## [seg2] [seg0 seg1] [all others]


# Root dir for Model 3
model3_folder <- file.path(root_dir, "Model3")

# Create the Model3 folder if it doesn't exist
if (!dir.exists(model3_folder)) {
  dir.create(model3_folder)
}

for (subject_id in subject_ids) {
  subject_path <- file.path(root_dir, paste0("commcon-", subject_id, "/sub_", subject_id))
  
  timing_file_path <- file.path(subject_path, paste0("subject_", subject_id, "_TimingFile_POST.csv"))
  
  if (file.exists(timing_file_path)) {
    data <- read.csv(timing_file_path)
    
    # Extract base commercial name by removing any _seg-0, _seg-1, or _seg-2 
    data$base_name <- gsub("_seg-[0-2]$", "", data$fname)
    
    # Get unique commercial names including their segments (full fname)
    unique_commercials <- unique(data$fname)
    
    # For each commercial (full fname, including segment), create a seperate file
    for (commercial in unique_commercials) {
      
      # Determine the base name for this commercial
      commercial_base <- gsub("_seg-[0-2]$", "", commercial)
      
      # Create a new column for the regressor_name:
      # - If the row's fname equals commercial, keep it as is (seg-0 will be separate file)
      # - If row has same base but segment is 1 or 2, rename to base commercial name (no seg)
      # - Everythign else, rename to AllOthers
      
      data$regressor_name <- ifelse(
        data$fname == commercial,                       
        commercial,
        ifelse(
          data$base_name == commercial_base,            
          commercial_base,
          "AllOthers"                                    ))
      
      # Select columns to save
      save_data <- data[, c("run", "regressor_name", "onsets", "duration")]
      
      # Create commercial folder 
      commercial_folder <- file.path(model3_folder, commercial)
      if (!dir.exists(commercial_folder)) {
        dir.create(commercial_folder)
      }
      
      # File name 
      file_name <- file.path(commercial_folder, paste0("sub_", subject_id, "_", commercial, "_TimingFile_M3_POST.txt"))
      
      # Save 
      write.table(save_data, file_name, row.names = FALSE, col.names = TRUE, sep = "\t", quote = FALSE)
      
      print(paste("File saved:", file_name))
    }
    
  } else {
    print(paste("No TimingFile_POST.csv found for subject", subject_id))
  }
}