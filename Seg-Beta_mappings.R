# Load packages
library(dplyr)
library(stringr)
library(readr)

############
### PRE ###
###########

# Path to your text file
beta_file_PRE <- "/Volumes/Poodle/Model4_REPSUP/AllSubjects_BetaDescriptions_PRE.txt"

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

# Filter so only keep the three task regressors
beta_final_PRE <- beta_filtered_PRE %>%
  filter(Label %in% c("seg-0", "seg-1", "seg-2"))

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

# Save clean copy for extracting betas in matlab
beta_save_PRE <- beta_final_PRE %>% select(Subject, Label, BetaFile)

write.table(beta_save_PRE, file = "/Volumes/Poodle/Model4_REPSUP/Seg-Beta-Maps_PRE.txt", 
            sep = "\t", row.names = FALSE, quote = FALSE)
