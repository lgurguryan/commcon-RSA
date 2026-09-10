# Libraries
library(readxl)
library(dplyr)
library(tidyr)

# Read the data
data <- read_excel("/Users/yorkie/Documents/CommCon/sequence-files_all-subjects/clip-order-info.xlsx")

# Add segment info
data0 <- data %>%
  mutate(Seg = "seg-0")

data1 <- data %>%
  mutate(Seg = "seg-1")

data2 <- data %>%
  mutate(Seg = "seg-2")

data <- bind_rows(data0, data1, data2)

# New name including commercial name + seg number 
data <- data %>%
  mutate(Commercial = paste(Commercial, Seg, sep = "_"))

# Create copy of df & rename (otherwise gives error that columns are duplicate?)
data_copy <- data %>%
  rename(
    CommercialCopy = Commercial,
    TVShowCopy = TVShow,
    EpisodeCopy = Episode,
    PartCopy = Part, 
    SegCopy = Seg
  )

# Remove rows with NA values
data_copy <- data_copy %>%
  drop_na()

data <- data %>%
  drop_na()

# Create all possible pairs of commercials (use crossing)
pairs <- data %>%
  select(Commercial, TVShow, Episode, Part) %>%
  crossing(data_copy %>%
             select(CommercialCopy, TVShowCopy, EpisodeCopy, PartCopy, SegCopy)) %>%
  filter(Commercial != CommercialCopy)  # Remove when it's with itself (like removing diagonal)

# Create pair_id to include Commercial, CommercialCopy
pairs <- pairs %>%
  mutate(
    pair_id = paste(
      pmin(Commercial, CommercialCopy), 
      pmax(Commercial, CommercialCopy),
      sep = "_"
    )
  )

# Remove redundant pairs 
pairs <- pairs %>%
  distinct(pair_id, .keep_all = TRUE)

# Remove pairs of commercial with itself but diff seg (e.g., adopt-a-pet_seg-0_adopt-a-pet_seg-1
#pairs <- pairs %>%
 # filter(
    # Extract commercial roots before '_seg-' for both parts
 #   str_extract(pair_id, "^[^_]+") !=
 #     str_extract(pair_id, "(?<=_)[^_]+(?=_seg-)")
 # )

# Create a new column to categorize pairs into categories of interest
pairs <- pairs %>%
  mutate(
    category = case_when(
      TVShow == TVShowCopy & Episode == EpisodeCopy ~ "Same TVShow & Same Episode",
      TVShow == TVShowCopy & Episode != EpisodeCopy ~ "Same TVShow, Different Episode",
      TVShow != TVShowCopy ~ "Different TVShow",
      TRUE ~ "Uncategorized"
    )
  )

# Check result
head(pairs)

# Create df for each condition 
same_show_episode <- pairs %>% filter(category == "Same TVShow & Same Episode")
same_show_diff_episode <- pairs %>% filter(category == "Same TVShow, Different Episode")
diff_show <- pairs %>% filter(category == "Different TVShow")
uncategorized <- pairs %>% filter(category == "Uncategorized")

# Print out the results
print(same_show_episode)
print(same_show_diff_episode)
print(diff_show)

# Save out results to txt
output_folder <- "/Volumes/My Passport for Mac/CommCon/SPM_results/Model3_scripts/"

write.table(same_show_episode, file = paste0(output_folder, "same_show_episode.txt"), sep = "\t", row.names = FALSE, col.names = TRUE)
write.table(same_show_diff_episode, file = paste0(output_folder, "same_show_diff_episode.txt"), sep = "\t", row.names = FALSE, col.names = TRUE)
write.table(diff_show, file = paste0(output_folder, "diff_show.txt"), sep = "\t", row.names = FALSE, col.names = TRUE)
