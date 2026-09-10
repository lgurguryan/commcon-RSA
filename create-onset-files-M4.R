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
  subject_path <- file.path(
    root_dir,
    paste0("commcon-", subject_id, "/sub_", subject_id))
  
  # Find the CSV containing '_show_commercials_3_clips_pre_' in name
  csv_files <- list.files(
    subject_path,
    pattern = "_show_commercials_3_clips_pre_.*\\.csv$",
    full.names = TRUE)
  
  # Flag if more than 1 or 0 files found
  if (length(csv_files) == 0) {
    
    # No files found
    print(
      paste(
        "No matching CSV files found for subject",
        subject_id))
    
  } else if (length(csv_files) > 1) {
    
    # More than 1 file found
    print(
      paste(
        "Warning: More than one CSV file found for subject",
        subject_id
      )
    )
    
  } else {
    
    # Read CSV file
    data <- read.csv(csv_files)
    
    # Extract value from 'getTrigger.rt' in row 2
    # (technically row 3 in Excel)
    trigger_rt_value <- data$getTrigger.rt[2]
    
    # Extract value from 'getTrigger.started' in row 2
    trigger_started_value <- data$getTrigger.started[2]
    
    # Calculate trigger onset relative to global clock
    trigger_onset <- trigger_started_value + trigger_rt_value
    
    # Calculate movie onset relative to trigger
    movieOnset_relative_trigger <- data$movie_2.started - trigger_onset
    
    # Combine the 'fname' column and 'onsets' into a new df
    result <- data.frame(
      fname = data$fname,
      onsets = movieOnset_relative_trigger)
    
    # Remove rows with NA in 'onsets' column
    # (so non-task rows are removed)
    result <- result[!is.na(result$onsets), ]
    
    # Modify the 'fname' column to remove
    # '_resized_1280-720_' & '.mp4'
    result$fname <- gsub(
      "_resized_1280-720_",
      "_",
      result$fname)
    
    result$fname <- gsub(
      ".mp4$",
      "",
      result$fname)
    
    # Add the 'duration' column
    result$duration <- 5
    
    # Add run number
    result$run <- 1
    
    # Create a CSV file to store onsets
    onsets_file <- file.path(
      subject_path,
      paste0(
        "subject_",
        subject_id,
        "_TimingFile_PRE.csv"))
    
    # Write onset to the CSV
    write.csv(
      result,
      onsets_file,
      row.names = FALSE)
    
    print(
      paste(
        "Results for subject",
        subject_id,
        "saved to",
        onsets_file))}}

################
## MODEL 4 ##
################

## Create one timing file per participant.
## Each timing file contains three regressors: seg-0, seg-1, seg-2

# Root dir for Model 4
model4_folder <- file.path(
  root_dir,
  "Model4")

if (!dir.exists(model4_folder)) {
  dir.create(model4_folder)}


# Loop through subjects
for (subject_id in subject_ids) {
  
  # Path for each subject
  subject_path <- file.path(
    root_dir,
    paste0("commcon-", subject_id, "/sub_", subject_id))
  
  # Path to participant's PRE timing file
  timing_file_path <- file.path(
    subject_path,
    paste0(
      "subject_",
      subject_id,
      "_TimingFile_PRE.csv"))
  
  # Check that timing file exists
  if (file.exists(timing_file_path)) {
    
    # Read timing file
    data <- read.csv(timing_file_path)
    
    # Extract segment number from fname
    
    data$regressor_name <- ifelse(
      grepl("_seg-[0-2]$", data$fname),
      sub(
        ".*_(seg-[0-2])$",
        "\\1",
        data$fname), NA)
    
    # Remove any rows that are not seg-0, seg-1, or seg-2
    data <- data[!is.na(data$regressor_name), ]
    
    # Keep only the columns needed for SPM
    save_data <- data[, c(
      "run",
      "regressor_name",
      "onsets",
      "duration")]
    
    # Create participant-specific Model 4 timing file
    file_name <- file.path(
      model4_folder,
      paste0(
        "sub_",
        subject_id,
        "_TimingFile_M4_PRE.txt"))
    
    # Save as tab-delimited text file
    write.table(
      save_data,
      file_name,
      row.names = FALSE,
      col.names = TRUE,
      sep = "\t",
      quote = FALSE)
    
    print(
      paste(
        "Model 4 file saved:",
        file_name))
    
  } else {
    
    print(
      paste(
        "No TimingFile_PRE.csv found for subject",
        subject_id))}}
