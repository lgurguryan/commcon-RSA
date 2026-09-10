# Load libraries
library(dplyr)
library(tidyr)
library(ggplot2)

# Root dir
root_dir <- "/Users/yorkie/Documents/CommCon/data/raw_behavioral"

# Subject folders
subject_folders <- list.dirs(root_dir, full.names = TRUE, recursive = FALSE)

# Columns to keep 
columns_to_extract <- c("commercial_name", "prior_clip", "memResp.keys")

# Crate empty df
combined_data <- data.frame()

# Loop over all subject folders
for (subject_folder in subject_folders) {
  
  # Get subject ID from the folder name (get number part)
  subject_id <- sub("commcon-(\\d+)", "\\1", basename(subject_folder))  
  
  # Construct path
  behavioral_data_files <- list.files(path = file.path(subject_folder, paste0("sub_", subject_id)),
                                      pattern = paste0(subject_id, "_commercials_mem_test.*\\.csv$"),
                                      full.names = TRUE)
  
  # If no files found print a message and skip 
  if (length(behavioral_data_files) == 0) {
    message(paste("Behavioural data file not found for subject:", subject_id))
    next  
  }
  
  # Behavioural file
  behavioral_data_file <- behavioral_data_files
  
  # Read data
  subject_data <- tryCatch({
    read.csv(behavioral_data_file)
  }, error = function(e) {
    message(paste("Error reading file for subject:", subject_id, ":", e$message))
    return(NULL)  
  })
  
  # Skip 
  if (is.null(subject_data)) {
    next
  }
  
  # Extract only columns to keep 
  subject_data <- subject_data[, columns_to_extract, drop = FALSE]
  
  # Remove rows with NA in 'memResp.keys'
  subject_data <- subject_data %>% filter(!is.na(memResp.keys))
  
  # Keep only the part before the underscore in 'commercial_name' and 'prior_clip'
  subject_data$commercial_name <- sub("_.*", "", subject_data$commercial_name)
  subject_data$prior_clip <- sub("_.*", "", subject_data$prior_clip)
  
  # Create  'correctRESP' column based on 'prior_clip'
  subject_data <- subject_data %>%
    mutate(correctRESP = case_when(
      prior_clip == "corner-gas" ~ 1,
      prior_clip == "filmore" ~ 2,
      prior_clip == "panam" ~ 3,
      prior_clip == "popular" ~ 4,
      prior_clip == "the-riches" ~ 5,
      prior_clip == "the-tribe" ~ 6,
      TRUE ~ NA_real_  
    ))
  
  # Create  'accuracy' column
  subject_data <- subject_data %>%
    mutate(accuracy = ifelse(memResp.keys == correctRESP, 1, 0))
  
  # Add  subject ID as a new column
  subject_data$subject_id <- subject_id
  
  # Combine data
  combined_data <- bind_rows(combined_data, subject_data)
}

# View combined data
head(combined_data)

# Calculate 
accuracy_summary <- combined_data %>%
  group_by(commercial_name) %>%
  summarise(
    average_accuracy = mean(accuracy, na.rm = TRUE),
    sem = sd(accuracy, na.rm = TRUE) / sqrt(n())
  )

# Plot 
ggplot(accuracy_summary, aes(x = commercial_name, y = average_accuracy, fill = commercial_name)) +
  geom_bar(stat = "identity") +
  labs(title = "Average accuracy per commercial", 
       x = "Commercial name", 
       y = "Accuracy") +
  geom_errorbar(aes(ymin = average_accuracy - sem, ymax = average_accuracy + sem), 
                width = 0.2, color = "black") +  
  # chance is 1/6  ~ 0.167
  geom_hline(yintercept = 0.17, linetype = "dotted", color = "red") +  
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none")

# Counts
accuracy_counts <- combined_data %>%
  group_by(subject_id, commercial_name, accuracy) %>%
  count(name = "count") %>%
  pivot_wider(names_from = accuracy, values_from = count, names_prefix = "accuracy_") %>%
  replace_na(list(accuracy_0 = 0, accuracy_1 = 0)) %>%
  arrange(subject_id, commercial_name)

# Summarize total counts of accuracy per commercial
plot_data <- combined_data %>%
  group_by(commercial_name, accuracy) %>%
  summarise(count = n(), .groups = "drop") %>%
  mutate(accuracy = factor(accuracy, levels = c(0, 1), labels = c("Incorrect", "Correct")))

# Plot stacked per commercial 
ggplot(plot_data, aes(x = commercial_name, y = count, fill = accuracy)) +
  geom_bar(stat = "identity", alpha = 0.75) +
  labs(title = "Accuracy counts per commercial (stacked acrosss all subjects)",
       x = "Commercial",
       y = "Total Count",
       fill = "Accuracy") +
  scale_fill_manual(values = c("Incorrect" = "red", "Correct" = "green")) +
  geom_hline(yintercept = 16.5, color = "black", size = 1.5) +
  annotate("text", x = 1, y = 17, label = "50% subjects (n=33)", vjust = -0.5, hjust = 0, size = 3.5, fontface = "bold") +
  geom_text(aes(label = count),
            position = position_stack(vjust = 0.5),
            color = "black",fontface = "bold", size = 3.5) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#########
# SAME SHOW SAME EPISODE
#########
txt_path <- "/Volumes/Chi/Model1_scripts/same_show_episode.txt"
same_show_same_epi <- read.table(txt_path, header = TRUE, stringsAsFactors = FALSE)

# sUBJECTS
subject_ids <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10",
                 "11", "12", "13", "14", "15", "16", "18", "19", "20", "21", "22", "23", "24", "25", 
                 "27", "28", "29", "30", "31", "32", "33", "34")
#26 missing 

# Create list
subject_dfs <- list()

# Loop and create df for each subject
for (subject_id in subject_ids) {
  subject_data <- same_show_same_epi %>%
    mutate(SubjectID = subject_id)
  
  # Grab accuracy from combine_data for each commercial
  C1_accuracy <- combined_data %>%
    filter(subject_id == subject_id) %>%
    select(subject_id, commercial_name, accuracy) %>%
    rename(C1_commercial = commercial_name, C1_sourceACC = accuracy)
  
  C2_accuracy <- combined_data %>%
    filter(subject_id == subject_id) %>%
    select(subject_id, commercial_name, accuracy) %>%
    rename(C2_commercial = commercial_name, C2_sourceACC = accuracy)
  
  # Merge
  subject_data <- subject_data %>%
    left_join(C1_accuracy, by = c("SubjectID" = "subject_id", "Commercial" = "C1_commercial")) %>%
    left_join(C2_accuracy, by = c("SubjectID" = "subject_id", "CommercialCopy" = "C2_commercial"))
  
  # Sve
  subject_dfs[[subject_id]] <- subject_data
}

# Check
head(subject_dfs[["01"]])
#View(subject_dfs[["01"]])
#View(subject_dfs[["26"]])

# Create a master dataframe by combining all the subject-specific dataframes
same_show_same_episode_master_df <- bind_rows(subject_dfs, .id = "subject_id")
head(same_show_same_episode_master_df)

# Source memory?
same_show_same_episode_master_df <- same_show_same_episode_master_df %>%
  mutate(SourceMemCond = case_when(
    C1_sourceACC == 0 & C2_sourceACC == 0 ~ "no",         
    C1_sourceACC == 0 | C2_sourceACC == 0 ~ "mixed",      
    C1_sourceACC == 1 & C2_sourceACC == 1 ~ "yes"
  ))

head(same_show_same_episode_master_df)

# coUNTS
source_mem_cond_counts1 <- same_show_same_episode_master_df %>%
  group_by(pair_id, SourceMemCond) %>%
  summarise(count = n(), .groups = "drop")

# Plot
ggplot(source_mem_cond_counts1, aes(x = pair_id, y = count, fill = SourceMemCond)) +
  geom_bar(stat = "identity", position = "stack", alpha = 0.75) +
  labs(title = "Same show, same episode",
       x = "Pair ID",
       y = "Count",
       fill = "Source memory condition") +
  scale_fill_manual(values = c("no" = "red", "mixed" = "yellow", "yes" = "green")) +
  geom_hline(yintercept = 16.5, color = "black", size = 1.5) +
  annotate("text", x = 1, y = 17, label = "50% subjects (n=33)", vjust = -0.5, hjust = 0, size = 3.5, fontface = "bold") +
  geom_text(aes(label = count),
            position = position_stack(vjust = 0.5),
            color = "black",fontface = "bold", size = 3.5) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 

#########
# SAME SHOW DIFFERENT EPISODE
#########
txt_path <- "/Volumes/Chi/Model1_scripts/same_show_diff_episode.txt"
same_show_diff_epi <- read.table(txt_path, header = TRUE, stringsAsFactors = FALSE)

# sUBJECTS
subject_ids <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10",
                 "11", "12", "13", "14", "15", "16", "18", "19", "20", "21", "22", "23", "24", "25", 
                 "27", "28", "29", "30", "31", "32", "33", "34")

# Create list
subject_dfs <- list()

# Loop and create df for each subject
for (subject_id in subject_ids) {
  subject_data <- same_show_diff_epi %>%
    mutate(SubjectID = subject_id)
  
  # Grab accuracy from combine_data for each commercial
  C1_accuracy <- combined_data %>%
    filter(subject_id == subject_id) %>%
    select(subject_id, commercial_name, accuracy) %>%
    rename(C1_commercial = commercial_name, C1_sourceACC = accuracy)
  
  C2_accuracy <- combined_data %>%
    filter(subject_id == subject_id) %>%
    select(subject_id, commercial_name, accuracy) %>%
    rename(C2_commercial = commercial_name, C2_sourceACC = accuracy)
  
  # Merge
  subject_data <- subject_data %>%
    left_join(C1_accuracy, by = c("SubjectID" = "subject_id", "Commercial" = "C1_commercial")) %>%
    left_join(C2_accuracy, by = c("SubjectID" = "subject_id", "CommercialCopy" = "C2_commercial"))
  
  # Sve
  subject_dfs[[subject_id]] <- subject_data
}

# Check
head(subject_dfs[["01"]])
#View(subject_dfs[["01"]])
#View(subject_dfs[["26"]])

# Create a master dataframe by combining all the subject-specific dataframes
same_show_diff_episode_master_df <- bind_rows(subject_dfs, .id = "subject_id")
head(same_show_diff_episode_master_df)

# Source memory?
same_show_diff_episode_master_df <- same_show_diff_episode_master_df %>%
  mutate(SourceMemCond = case_when(
    C1_sourceACC == 0 & C2_sourceACC == 0 ~ "no",         
    C1_sourceACC == 0 | C2_sourceACC == 0 ~ "mixed",      
    C1_sourceACC == 1 & C2_sourceACC == 1 ~ "yes"
  ))

head(same_show_diff_episode_master_df)

# coUNTS
source_mem_cond_counts2 <- same_show_diff_episode_master_df %>%
  group_by(pair_id, SourceMemCond) %>%
  summarise(count = n(), .groups = "drop")

# Plot
ggplot(source_mem_cond_counts2, aes(x = pair_id, y = count, fill = SourceMemCond)) +
  geom_bar(stat = "identity", position = "stack", alpha = 0.75) +
  labs(title = "Same show, different episode",
       x = "Pair ID",
       y = "Count",
       fill = "Source memory condition") +
  scale_fill_manual(values = c("no" = "red", "mixed" = "yellow", "yes" = "green")) +
  geom_hline(yintercept = 16.5, color = "black", size = 1.5) +
  annotate("text", x = 1, y = 17, label = "50% subjects (n=33)", vjust = -0.5, hjust = 0, size = 3.5, fontface = "bold") +
  geom_text(aes(label = count),
            position = position_stack(vjust = 0.5),
            color = "black",fontface = "bold", size = 3.5) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 

#########
# DIFFERENT SHOWS
#########
txt_path <- "/Volumes/Chi/Model1_scripts/diff_show.txt"
diff_show <- read.table(txt_path, header = TRUE, stringsAsFactors = FALSE)

# sUBJECTS
subject_ids <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10",
                 "11", "12", "13", "14", "15", "16", "18", "19", "20", "21", "22", "23", "24", "25", 
                 "27", "28", "29", "30", "31", "32", "33", "34")

# Create list
subject_dfs <- list()

# Loop and create df for each subject
for (subject_id in subject_ids) {
  subject_data <- diff_show %>%
    mutate(SubjectID = subject_id)
  
  # Grab accuracy from combine_data for each commercial
  C1_accuracy <- combined_data %>%
    filter(subject_id == subject_id) %>%
    select(subject_id, commercial_name, accuracy) %>%
    rename(C1_commercial = commercial_name, C1_sourceACC = accuracy)
  
  C2_accuracy <- combined_data %>%
    filter(subject_id == subject_id) %>%
    select(subject_id, commercial_name, accuracy) %>%
    rename(C2_commercial = commercial_name, C2_sourceACC = accuracy)
  
  # Merge
  subject_data <- subject_data %>%
    left_join(C1_accuracy, by = c("SubjectID" = "subject_id", "Commercial" = "C1_commercial")) %>%
    left_join(C2_accuracy, by = c("SubjectID" = "subject_id", "CommercialCopy" = "C2_commercial"))
  
  # Sve
  subject_dfs[[subject_id]] <- subject_data
}

# Check
head(subject_dfs[["01"]])
View(subject_dfs[["01"]])
#View(subject_dfs[["26"]])

# Create a master dataframe by combining all the subject-specific dataframes
diff_show_master_df <- bind_rows(subject_dfs, .id = "subject_id")
head(diff_show_master_df)

# Source memory?
diff_show_master_df <- diff_show_master_df %>%
  mutate(SourceMemCond = case_when(
    C1_sourceACC == 0 & C2_sourceACC == 0 ~ "no",         
    C1_sourceACC == 0 | C2_sourceACC == 0 ~ "mixed",      
    C1_sourceACC == 1 & C2_sourceACC == 1 ~ "yes"
  ))

head(diff_show_master_df)

# coUNTS
source_mem_cond_counts3 <- diff_show_master_df %>%
  group_by(pair_id, SourceMemCond) %>%
  summarise(count = n(), .groups = "drop")

# Plot

# ggplot(source_mem_cond_counts3, aes(x = pair_id, y = count, fill = SourceMemCond)) +
#   geom_bar(stat = "identity", position = "stack", alpha = 0.75) +
#   labs(title = "Source Memory Condition Counts by Pair ID",
#        x = "Pair ID",
#        y = "Count",
#        fill = "Source Memory Condition") +
#   scale_fill_manual(values = c("no" = "red", "mixed" = "yellow", "yes" = "green")) +
#   theme_minimal() +
#   theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
#   facet_wrap(~ pair_id, ncol = 6)

ggplot(source_mem_cond_counts3, aes(x = pair_id, y = count, fill = SourceMemCond)) +
  geom_bar(stat = "identity", position = "stack", alpha = 0.75) +
  labs(title = "Different show",
       x = "Pair ID",
       y = "Count",
       fill = "Source memory condition") +
  scale_fill_manual(values = c("no" = "red", "mixed" = "yellow", "yes" = "green")) +
  geom_hline(yintercept = 16.5, color = "black", size = 1.5) +
  annotate("text", x = 1, y = 17, label = "50% subjects (n=33)", vjust = -0.5, hjust = 0, size = 3.5, fontface = "bold") +
 # geom_text(aes(label = count),
         #  position = position_stack(vjust = 0.5),
          #  color = "black",fontface = "bold", size = 3.5) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 


# Save out dfs 
output_df_dir <- "/Users/yorkie/Documents/CommCon/data"

write.csv(diff_show_master_df,
          file.path(output_df_dir, "diff_show_master_df_accuracies.csv"),
          row.names = FALSE)

write.csv(same_show_diff_episode_master_df,
          file.path(output_df_dir, "same_show_diff_episode_master_df_accuracies.csv"),
          row.names = FALSE)

write.csv(same_show_same_episode_master_df,
          file.path(output_df_dir, "same_show_same_episode_master_df_accuracies.csv"),
          row.names = FALSE)

########################################
### Averages to report in manuscript ###
########################################

# Overall recognition accuracy 
overall_accuracy_subject <- combined_data %>%
  group_by(subject_id) %>%
  summarise(
    accuracy = mean(accuracy, na.rm = TRUE),
    n_commercials = n(),
    .groups = "drop")

overall_accuracy_summary <- overall_accuracy_subject %>%
  summarise(
    mean_accuracy = mean(accuracy, na.rm = TRUE),
    sd_accuracy = sd(accuracy, na.rm = TRUE),
    n = n())

overall_accuracy_summary

# Averages based on condtion 
# SAME SHOW, DIFFERENT EPISODE
subject_dfs <- list()

for (subj in subject_ids) {
  
  subject_data <- same_show_diff_epi %>%
    mutate(SubjectID = subj)
  
  C1_accuracy <- combined_data %>%
    filter(subject_id == subj) %>%
    select(subject_id, commercial_name, accuracy) %>%
    rename(
      C1_commercial = commercial_name,
      C1_sourceACC = accuracy)
  
  C2_accuracy <- combined_data %>%
    filter(subject_id == subj) %>%
    select(subject_id, commercial_name, accuracy) %>%
    rename(
      C2_commercial = commercial_name,
      C2_sourceACC = accuracy)
  
  subject_data <- subject_data %>%
    left_join(
      C1_accuracy,
      by = c(
        "SubjectID" = "subject_id",
        "Commercial" = "C1_commercial")) %>%
    left_join(
      C2_accuracy,
      by = c(
        "SubjectID" = "subject_id",
        "CommercialCopy" = "C2_commercial"))
  
  subject_dfs[[subj]] <- subject_data
}

same_show_diff_episode_pairs <- bind_rows(subject_dfs)

same_show_diff_episode_pairs <- same_show_diff_episode_pairs %>%
  mutate(
    source_memory = case_when(
      C1_sourceACC == 1 & C2_sourceACC == 1 ~ 1,
      TRUE ~ 0))

same_show_same_episode_pairs %>%
  group_by(subject_id = SubjectID) %>%
  summarise(
    accuracy = mean(source_memory, na.rm = TRUE),
    .groups = "drop") %>%
  summarise(
    M = mean(accuracy, na.rm = TRUE),
    SD = sd(accuracy, na.rm = TRUE))


# SAME SHOW, DIFFERENT EPISOD
subject_dfs <- list()

for (subj in subject_ids) {
  
  subject_data <- same_show_diff_epi %>%
    mutate(SubjectID = subj)
  
  C1_accuracy <- combined_data %>%
    filter(subject_id == subj) %>%
    select(subject_id, commercial_name, accuracy) %>%
    rename(
      C1_commercial = commercial_name,
      C1_sourceACC = accuracy)
  
  C2_accuracy <- combined_data %>%
    filter(subject_id == subj) %>%
    select(subject_id, commercial_name, accuracy) %>%
    rename(
      C2_commercial = commercial_name,
      C2_sourceACC = accuracy)
  
  subject_data <- subject_data %>%
    left_join(
      C1_accuracy,
      by = c(
        "SubjectID" = "subject_id",
        "Commercial" = "C1_commercial")) %>%
    left_join(
      C2_accuracy,
      by = c(
        "SubjectID" = "subject_id",
        "CommercialCopy" = "C2_commercial"))
  
  subject_dfs[[subj]] <- subject_data
}

same_show_diff_episode_pairs <- bind_rows(subject_dfs)

same_show_diff_episode_pairs <- same_show_diff_episode_pairs %>%
  mutate(
    source_memory = case_when(
      C1_sourceACC == 1 & C2_sourceACC == 1 ~ 1,
      TRUE ~ 0))

same_show_diff_episode_pairs %>%
  group_by(subject_id = SubjectID) %>%
  summarise(
    accuracy = mean(source_memory, na.rm = TRUE),
    .groups = "drop") %>%
  summarise(
    M = mean(accuracy, na.rm = TRUE),
    SD = sd(accuracy, na.rm = TRUE))


# DIFFERENT SHOW
subject_dfs <- list()

for (subj in subject_ids) {
  
  subject_data <- diff_show %>%
    mutate(SubjectID = subj)
  
  C1_accuracy <- combined_data %>%
    filter(subject_id == subj) %>%
    select(subject_id, commercial_name, accuracy) %>%
    rename(
      C1_commercial = commercial_name,
      C1_sourceACC = accuracy)
  
  C2_accuracy <- combined_data %>%
    filter(subject_id == subj) %>%
    select(subject_id, commercial_name, accuracy) %>%
    rename(
      C2_commercial = commercial_name,
      C2_sourceACC = accuracy)
  
  subject_data <- subject_data %>%
    left_join(
      C1_accuracy,
      by = c(
        "SubjectID" = "subject_id",
        "Commercial" = "C1_commercial" )) %>%
    left_join(
      C2_accuracy,
      by = c(
        "SubjectID" = "subject_id",
        "CommercialCopy" = "C2_commercial"))
  
  subject_dfs[[subj]] <- subject_data
}

diff_show_pairs <- bind_rows(subject_dfs)

diff_show_pairs <- diff_show_pairs %>%
  mutate(
    source_memory = case_when(
      C1_sourceACC == 1 & C2_sourceACC == 1 ~ 1,
      TRUE ~ 0))

diff_show_pairs %>%
  group_by(subject_id = SubjectID) %>%
  summarise(
    accuracy = mean(source_memory, na.rm = TRUE),
    .groups = "drop") %>%
  summarise(
    M = mean(accuracy, na.rm = TRUE),
    SD = sd(accuracy, na.rm = TRUE))
