# Load packages
library(dplyr)
library(stringr)
library(readr)

############
### PRE ###
###########

# Path to your text file
beta_file_PRE <- "/Volumes/Chi/Model3_PRE/AllSubjects_BetaDescriptions_PRE.txt"

# Read the tab-delimited file
beta_data_PRE <- read_tsv(beta_file_PRE)

# Create new column 'Label' by remove unecessary parts 
beta_data_PRE <- beta_data_PRE %>%
  mutate(
    Label = str_extract(Description, "(?<=Sn\\(1\\)\\s).*"),   # grab text after Sn(1)
    Label = str_remove(Label, "\\*bf\\(1\\)"),                # remove *bf(1)
    Label = str_trim(Label)                                   # no spaces at the end 
  )

# Check
head(beta_data_PRE)

# Filter out nuisance regressors
beta_filtered_PRE <- beta_data_PRE %>%
  filter(!str_detect(Label, "^R\\d+$"),
         Label != "constant")

# Check 
head(beta_filtered_PRE)

# Filter so only keep rows where Commercial = Label 
beta_final_PRE <- beta_filtered_PRE %>%
  filter(Commercial == Label)

# Check 
head(beta_final_PRE)

# Number of unique subjects
num_subjects <- beta_final_PRE %>%
  summarise(UniqueSubjects = n_distinct(Subject))

print(num_subjects)

unique_subjects_PRE <- beta_data_PRE %>%
  distinct(Subject) %>%
  pull(Subject)  

print(unique_subjects_PRE)

# Save clean copy for extracting beatsa in matlab
beta_save_PRE <- beta_final_PRE %>% select(Subject, Label, BetaFile)

write.table(beta_save_PRE, file = "/Volumes/Chi/Model3_PRE/Com-Beta-Maps_PRE.txt", 
            sep = "\t", row.names = FALSE, quote = FALSE)

#############
### POST ###
############

# Path to your text file
beta_file_POST <- "/Volumes/My Passport for Mac/CommCon/SPM_results/Model3_POST/AllSubjects_BetaDescriptions_POST.txt"

# Read the tab-delimited file
beta_data_POST <- read_tsv(beta_file_POST)

# Create new column 'Label' by remove unecessary parts 
beta_data_POST <- beta_data_POST %>%
  mutate(
    Label = str_extract(Description, "(?<=Sn\\(1\\)\\s).*"),   # grab text after Sn(1)
    Label = str_remove(Label, "\\*bf\\(1\\)"),                # remove *bf(1)
    Label = str_trim(Label)                                   # no spaces at the end 
  )

# Check
head(beta_data_POST)

# Filter out nuisance regressors
beta_filtered_POST <- beta_data_POST %>%
  filter(!str_detect(Label, "^R\\d+$"),
         Label != "constant")

# Check 
head(beta_filtered_POST)

# Filter so only keep rows where Commercial = Label 
beta_final_POST <- beta_filtered_POST %>%
  filter(Commercial == Label)

# Check 
head(beta_final_POST)

# Number of unique subjects
num_subjects <- beta_final_POST %>%
  summarise(UniqueSubjects = n_distinct(Subject))

print(num_subjects)

unique_subjects_POST <- beta_data_POST %>%
  distinct(Subject) %>%
  pull(Subject)  

print(unique_subjects_POST)

# Save clean copy for extracting beatsa in matlab
beta_save_POST <- beta_final_POST %>% select(Subject, Label, BetaFile)

write.table(beta_save_POST, file = "/Volumes/My Passport for Mac/CommCon/SPM_results/Model3_POST/Com-Beta-Maps_POST.txt", 
            sep = "\t", row.names = FALSE, quote = FALSE)
