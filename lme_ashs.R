#Libraries 
library(tidyverse)
library(afex)
library(lme4)
library(nlme)
library(lmerTest)
library(ggplot2)
library(ggsignif)
library(ggdist)
library(emmeans)
library(performance)
library(permuco)
library(coin)

###########################
######## FOR STATS ########
###########################

# Define paths
subject_numbers <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16",
                     "18", "19", "20", "21", "22", "23", "24", "25", "27", "28", "29", "30", "31", "32", "33", "34")

subject_ids <- paste0("sub-", subject_numbers)
base_path <- "/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST-PRE"

# List of ROIs
rois <- c("left_Hippocampus-SUB_MNI-BOLD", "left_Hippocampus_MNI-BOLD", "left_PHC_MNI-BOLD", "left_PRC_MNI-BOLD", 
          "right_Hippocampus-SUB_MNI-BOLD", "right_Hippocampus_MNI-BOLD", "right_PHC_MNI-BOLD", "right_PRC_MNI-BOLD")
#rois <- c("left_Hippocampus_anterior_MNI-BOLD", "left_Hippocampus_posterior_MNI-BOLD", "right_Hippocampus_anterior_MNI-BOLD", "right_Hippocampus_posterior_MNI-BOLD")

# Conditions of interest
conditions <- c("same_show_episode", "same_show_diff_episode", "diff_show", "same_show_episode_SAME-COMS", "same_show_episode_DIFF-COMS")

# Define function to load condition data for each ROI
load_condition_data <- function(condition, roi, subject_ids, base_path) {
  all_corrs <- list()
  
  for (sub in subject_ids) {
    # Path updated to include ROI
    file_path <- file.path(base_path, paste0("Model3_", sub, "_", roi, "_DIFF_", condition, "_corrs.csv"))
    
    # Create df
    df <- read_csv(file_path, show_col_types = FALSE) %>%
      mutate(
        Subject = sub,
        Condition = condition,
        ROI = roi
      )
    
    all_corrs[[sub]] <- df
  }
  
  # Combine all subjects for the given condition and ROI
  bind_rows(all_corrs)
}

# Create empty list to store the data for each ROI
all_data <- list()

# Loop over ROIs and load data for each
for (roi in rois) {
  roi_data <- map_dfr(conditions, ~load_condition_data(.x, roi, subject_ids, base_path))
  
  # Append the data for the current ROI to the list
  all_data[[roi]] <- roi_data
}

# Combine all data across ROIs into one data frame
final_data_STATS <- bind_rows(all_data)

# Check
print(head(final_data_STATS))

# Add columns for hemishepre and roi (called region)
final_data_STATS <- final_data_STATS %>%
  # Remove "_mask_resampled" 
  mutate(ROI = gsub("_MNI-BOLD|_mask_resampled", "", ROI)) %>%
  # Grab hemisphere info & region/roi
  mutate(Hemisphere = str_extract(ROI, "^[^_-]+"), Region = str_extract(ROI, "(?<=[_-]).*"))

# Check
print(head(final_data_STATS))

# FILTER FOR MAIN ANALYSES 
main_data <- final_data_STATS %>%
  filter(Condition %in% c("same_show_episode", "same_show_diff_episode", "diff_show"))

print(head(main_data))

#################################
######## FOR PLOTS (RAW) ########
#################################

# Define paths
subject_numbers <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16",
                     "18", "19", "20", "21", "22", "23", "24", "25", "27", "28", "29", "30", "31", "32", "33", "34")

subject_ids <- paste0("sub-", subject_numbers)
base_path <- "/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST-PRE"

# List of ROIs
 rois <- c("left_Hippocampus-SUB_MNI-BOLD", "left_Hippocampus_MNI-BOLD", "left_PHC_MNI-BOLD", "left_PRC_MNI-BOLD", 
            "right_Hippocampus-SUB_MNI-BOLD", "right_Hippocampus_MNI-BOLD", "right_PHC_MNI-BOLD", "right_PRC_MNI-BOLD")
#rois <- c("left_Hippocampus_anterior_MNI-BOLD", "left_Hippocampus_posterior_MNI-BOLD", "right_Hippocampus_anterior_MNI-BOLD", "right_Hippocampus_posterior_MNI-BOLD")

# Conditions of interest
conditions <- c("same_show_episode", "same_show_diff_episode", "diff_show", "same_show_episode_SAME-COMS", "same_show_episode_DIFF-COMS")

# Define function to load condition data for each ROI
load_condition_data <- function(condition, roi, subject_ids, base_path) {
  all_corrs <- list()
  
  for (sub in subject_ids) {
    # Path 
    file_path <- file.path(base_path, paste0("Model3_", sub, "_", roi, "_DIFF_", condition, "_corrs_RAW.csv"))
    
    # Create df
    df <- read_csv(file_path, show_col_types = FALSE) %>%
      mutate(
        Subject = sub,
        Condition = condition,
        ROI = roi
      )
    
    all_corrs[[sub]] <- df
  }
  
  # Combine all subjects for the given condition and ROI
  bind_rows(all_corrs)
}

# Create empty list to store the data for each ROI
all_data <- list()

# Loop over ROIs and load data for each
for (roi in rois) {
  roi_data <- map_dfr(conditions, ~load_condition_data(.x, roi, subject_ids, base_path))
  
  # Append the data for the current ROI to the list
  all_data[[roi]] <- roi_data
}

# Combine all data across ROIs into one data frame
final_data_PLOTS <- bind_rows(all_data)

# Check
print(head(final_data_PLOTS))

# Add columns for hemishepre and roi (called region)
final_data_PLOTS <- final_data_PLOTS %>%
  # Remove "_mask_resampled" 
  mutate(ROI = gsub("_MNI-BOLD|_mask_resampled", "", ROI)) %>%
  # Grab hemisphere info & region/roi
  mutate(Hemisphere = str_extract(ROI, "^[^_-]+"), Region = str_extract(ROI, "(?<=[_-]).*"))

# Check
print(head(final_data_PLOTS))

# FILTER FOR MAIN ANALYSES 
plot_data <- final_data_PLOTS %>%
  filter(Condition %in% c("same_show_episode", "same_show_diff_episode", "diff_show"))

print(head(plot_data))

###########################
######## ANALYSIS ########
###########################

######################
#### HIPPOCAMPUS ####
#####################

# Filter to only hippocampus ROIs
hippocampus_data_stats <- main_data %>%
  filter(ROI %in% c("left_Hippocampus", "right_Hippocampus"))

hippocampus_data_plots <- plot_data %>%
  filter(ROI %in% c("left_Hippocampus", "right_Hippocampus"))

# Model 
#hippocampus_model <- lme(Correlation ~  Condition, random = ~1 | Subject, data = hippocampus_data_stats)

hippocampus_model2 <- lm(Correlation ~ Condition, data = hippocampus_data_stats)

# Results
#ummary(hippocampus_model)
#anova(hippocampus_model)
summary(hippocampus_model2)
anova(hippocampus_model2)

TukeyHSD(aov(Correlation ~ Condition, data = hippocampus_data_stats))


# Bar plot  
dodge <- position_dodge(width = 0.8)  # spacing between bars so don;t overlap 

ggplot(hippocampus_data_plots, aes(x = Condition, y = Correlation)) +
  stat_summary(fun = mean, geom = "bar", 
               position = dodge, color = "black", width = 0.7) +
  stat_summary(fun.data = mean_cl_boot, geom = "errorbar", 
               position = dodge, width = 0.2) +
  theme_minimal() +
  labs(title = "Mean correlation by Condition and Hemisphere in hippocampus",
       y = "Mean Correlation", x = "Condition") 
#scale_fill_manual(values = c("left" = "rosybrown1", "right" = "seagreen"))

# Compute mean correlation per subject
subject_means_hippocampus <- hippocampus_data_plots %>%
  group_by(Subject, Condition) %>%
  summarise(MeanCorrelation = mean(Correlation, na.rm = TRUE), .groups = "drop")

# Violin plot 
ggplot(subject_means_hippocampus, aes(x = Condition, y = MeanCorrelation)) +
  geom_violin(trim = FALSE, alpha = 0.6, fill = "grey") +
  stat_summary(fun = mean, geom = "point", color = "black", size = 3) +
  scale_x_discrete(labels = c("same_show_episode" = "Same show, \nsame episode",
                              "same_show_diff_episode" = "Same show, \ndifferent episode", 
                              "diff_show" = "Different shows")) +
  geom_jitter(shape = 21, color = "black", fill = "grey", 
              position = position_jitter(width = 0.15),
              size = 2, alpha = 0.5, show.legend = FALSE) +
  theme_minimal() +
  theme(
    axis.line = element_line(color = "black"),       
    axis.text.x = element_text(color = "black", size = 14),
    axis.text.y = element_text(color = "black", size = 14),
    axis.title.x = element_text(color = "black", size = 16, face = "bold"),
    axis.title.y = element_text(color = "black", size = 16, face = "bold"),
    plot.title = element_text(hjust = 0.5, size = 18, face = "bold") 
  ) +
  labs(title = "Hippocampus",
       y = "Mean pattern similarity", x = "")

# Raincloud plot 
ggplot(subject_means_hippocampus, aes(x = Condition, y = MeanCorrelation, fill = Condition)) +
  stat_halfeye(
    alpha = 0.5,
    adjust = 0.6,
    width = 0.6,
    justification = -0.25,
    point_interval = mean_qi,
    .width = c(0.66, 0.95)) +
  geom_boxplot(
    width = 0.15,
    outlier.shape = NA,
    alpha = 0.6,
    color = "black",
    linetype = "solid",
    median.linewidth = 0.5) +
  geom_jitter(
    width = 0.08,
    size = 1.8,
    shape = 21,
    color = "black",
    fill = "white") +
  stat_summary(
    fun = mean,
    geom = "point",
    color = "black",
    size = 3) +
  scale_x_discrete(labels = c(
    "same_show_episode" = "Same show, \nsame episode",
    "same_show_diff_episode" = "Same show, \ndifferent episode",
    "diff_show" = "Different shows")) +
  scale_fill_manual(values = c(
    "same_show_episode" = "cornflowerblue",
    "same_show_diff_episode" = "hotpink",
    "diff_show" = "limegreen")) +
  theme_minimal(base_size = 14) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_text(size = 25),
    axis.text.x = element_text(size = 20, color = "black"),
    axis.text.y = element_text(size = 20, color = "black"),
    axis.line = element_line(color = "black", linewidth = 0.5),
    axis.line.x = element_line(color = "black"),
    axis.line.y = element_line(color = "black"),
    legend.position = "none",
    plot.title = element_text(hjust = 0.5, face = "bold", size = 30)) +
  labs(
    title = "Hippocampus",
    y = "Mean pattern similarity")

# MANUSCRIPT FIG 
ggplot(
  subject_means_hippocampus, 
  aes(x = Condition, y = MeanCorrelation, fill = Condition)) +
  stat_halfeye(
    alpha = 0.5, 
    adjust = 0.6, 
    width = 0.6, 
    justification = -0.25, 
    point_interval = mean_qi, 
    .width = c(0.66, 0.95)) +
  geom_boxplot(
    width = 0.15, 
    outlier.shape = NA, 
    alpha = 0.6,
    color = "black", 
    linetype = "solid",
    median.linewidth = 0.5) +
  geom_jitter(
    width = 0.08, 
    size = 1.2, 
    shape = 21, 
    color = "black", 
    fill = "white",
    alpha = 0.5) +
  stat_summary(
    fun = mean, 
    geom = "point", 
    color = "black", 
    size = 3) +
  scale_x_discrete(
    labels = c(
      "same_show_episode" = "Same show,\nsame\nepisode",
      "same_show_diff_episode" = "Same show,\ndifferent\nepisode", 
      "diff_show" = "Different\nshows")) +
  scale_fill_manual(
    values = c(
      "same_show_episode" = "cornflowerblue",
      "same_show_diff_episode" = "hotpink",
      "diff_show" = "limegreen")) +
  theme_minimal(base_size = 10) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_text(
      size = 10),
    axis.text.x = element_text(
      size = 8.5, 
      color = "black"),
    axis.text.y = element_text(
      size = 8.5, 
      color = "black"),
    axis.line = element_line(
      color = "black", 
      linewidth = 0.5),
    axis.line.x = element_line(
      color = "black"),
    axis.line.y = element_line(
      color = "black"),
    legend.position = "none",
    plot.title = element_text(
      hjust = 0.5, 
      face = "bold", 
      size = 11,
      margin = margin(b = 10)),
    plot.margin = margin(
      t = 15,
      r = 5.5,
      b = 5.5,
      l = 5.5)) +
  labs(
    title = "Hippocampus",
    y = "Mean pattern similarity")

ggsave(
  filename = "/Volumes/BrusselsGriffon/CommCon/manuscript-figures/hippocampus_pattern_similarity.pdf",
  plot = last_plot(),
  width = 3.5,
  height = 2.5,
  units = "in")

################################
#### PARAHIPPOCAMPUS CORTEX ####
###############################

# Filter to only parahippocampus ROIs
parahippocampus_data_stats <- main_data %>%
  filter(ROI %in% c("left_PHC", "right_PHC"))

parahippocampus_data_plots <- plot_data %>%
  filter(ROI %in% c("left_PHC", "right_PHC"))

# Model 
parahippocampus_model2 <- lm(Correlation ~ Condition, data = parahippocampus_data_stats)

# Results
summary(parahippocampus_model2)
anova(parahippocampus_model2)

TukeyHSD(aov(Correlation ~ Condition, data = parahippocampus_data_stats))


# Bar plot  
dodge <- position_dodge(width = 0.8)  # spacing between bars so don;t overlap 

ggplot(parahippocampus_data_plots, aes(x = Condition, y = Correlation)) +
  stat_summary(fun = mean, geom = "bar", 
               position = dodge, color = "black", width = 0.7) +
  stat_summary(fun.data = mean_cl_boot, geom = "errorbar", 
               position = dodge, width = 0.2) +
  theme_minimal() +
  labs(title = "Mean correlation by Condition and Hemisphere in parahippocampus",
       y = "Mean Correlation", x = "Condition") 
#scale_fill_manual(values = c("left" = "rosybrown1", "right" = "seagreen"))

# Compute mean correlation per subject
subject_means_parahippocampus<- parahippocampus_data_plots %>%
  group_by(Subject, Condition) %>%
  summarise(MeanCorrelation = mean(Correlation, na.rm = TRUE), .groups = "drop")

# Position of sig bars
y_max <- max(subject_means_parahippocampus$MeanCorrelation, na.rm = TRUE)

# Violin plot 
ggplot(subject_means_parahippocampus, aes(x = Condition, y = MeanCorrelation)) +
  geom_violin(trim = FALSE, alpha = 0.6, fill = "grey") +
  stat_summary(fun = mean, geom = "point", color = "black", size = 3) +
  scale_x_discrete(labels = c("same_show_episode" = "Same show, same episode",
                              "same_show_diff_episode" = "Same show, different episode", 
                              "diff_show" = "Different shows")) +
  geom_jitter(shape = 21, color = "black", fill = "grey", 
              position = position_jitter(width = 0.15),
              size = 2, alpha = 0.5, show.legend = FALSE) +
  geom_signif(comparisons = list(c("diff_show", "same_show_episode"),
                                 c("same_show_diff_episode", "same_show_episode")),
              annotations = c("*p = 0.000", "*p = 0.02"),
              y_position = c(y_max + 0.13, y_max + 0.15),
              tip_length = 0.02, textsize = 6) +
  theme_minimal() +
  theme(
    axis.line = element_line(color = "black"),       
    axis.text.x = element_text(color = "black", size = 14),
    axis.text.y = element_text(color = "black", size = 14),
    axis.title.x = element_text(color = "black", size = 16, face = "bold"),
    axis.title.y = element_text(color = "black", size = 16, face = "bold"),
    plot.title = element_text(hjust = 0.5, size = 18, face = "bold") ) +
  labs(title = "Parahippocampus",
       y = "Mean pattern similarity", x = "")

# Raincloud plot 
ggplot(subject_means_parahippocampus,
       aes(x = Condition, y = MeanCorrelation, fill = Condition)) +
  stat_halfeye(
    alpha = 0.5,
    adjust = 0.6,
    width = 0.6,
    justification = -0.25,
    point_interval = mean_qi,
    .width = c(0.66, 0.95)) +
  geom_boxplot(
    width = 0.15,
    outlier.shape = NA,
    alpha = 0.6,
    color = "black",
    linetype = "solid",
    median.linewidth = 0.5) +
  geom_jitter(
    width = 0.08,
    size = 1.8,
    shape = 21,
    color = "black",
    fill = "white") +
  stat_summary(
    fun = mean,
    geom = "point",
    color = "black",
    size = 3) +
  scale_x_discrete(labels = c(
    "same_show_episode" = "Same show, \nsame episode",
    "same_show_diff_episode" = "Same show, \ndifferent episode",
    "diff_show" = "Different shows")) +
  scale_fill_manual(values = c(
    "same_show_episode" = "cornflowerblue",
    "same_show_diff_episode" = "hotpink",
    "diff_show" = "limegreen")) +
  geom_signif(
    comparisons = list(
      c("diff_show", "same_show_episode"),
      c("same_show_diff_episode", "same_show_episode") ),
    annotations = c("*p = 0.000", "*p = 0.02"),
    y_position = c(y_max + 0.02, y_max + 0.04),
    tip_length = 0.02,
    textsize = 6) +
  theme_minimal(base_size = 14) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_text(size = 25),
    axis.text.x = element_text(size = 20, color = "black"),
    axis.text.y = element_text(size = 20, color = "black"),
    axis.line = element_line(color = "black", linewidth = 0.5),
    axis.line.x = element_line(color = "black"),
    axis.line.y = element_line(color = "black"),
    legend.position = "none",
    plot.title = element_text(hjust = 0.5, face = "bold", size = 30)) +
  labs(
    title = "Parahippocampus",
    y = "Mean pattern similarity")

# MANUSCRIPT FIGS 
ggplot(
  subject_means_parahippocampus, 
  aes(x = Condition, y = MeanCorrelation, fill = Condition)) +
  stat_halfeye(
    alpha = 0.5, 
    adjust = 0.6, 
    width = 0.6, 
    justification = -0.25, 
    point_interval = mean_qi, 
    .width = c(0.66, 0.95)) +
  geom_boxplot(
    width = 0.15, 
    outlier.shape = NA, 
    alpha = 0.6,
    color = "black", 
    linetype = "solid",
    median.linewidth = 0.5) +
  geom_jitter(
    width = 0.08, 
    size = 1.2, 
    shape = 21, 
    color = "black", 
    fill = "white",
    alpha = 0.5) +
  stat_summary(
    fun = mean, 
    geom = "point", 
    color = "black", 
    size = 3) +
  scale_x_discrete(
    labels = c(
      "same_show_episode" = "Same show,\nsame\nepisode",
      "same_show_diff_episode" = "Same show,\ndifferent\nepisode", 
      "diff_show" = "Different\nshows")) +
  scale_fill_manual(
    values = c(
      "same_show_episode" = "cornflowerblue",
      "same_show_diff_episode" = "hotpink",
      "diff_show" = "limegreen")) +
  geom_signif(
    comparisons = list(
      c("diff_show", "same_show_episode"),
      c("same_show_diff_episode", "same_show_episode")),
    annotations = c("*p < .001", "*p = .011"),
    y_position = c(y_max + 0.01, y_max + 0.02),
    tip_length = 0.02, 
    textsize = 3.2) +
  coord_cartesian(clip = "off") +
  theme_minimal(base_size = 10) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_text(
      size = 10),
    axis.text.x = element_text(
      size = 8.5, 
      color = "black"),
    axis.text.y = element_text(
      size = 8.5, 
      color = "black"),
    axis.line = element_line(
      color = "black", 
      linewidth = 0.5),
    axis.line.x = element_line(
      color = "black"),
    axis.line.y = element_line(
      color = "black"),
    legend.position = "none",
    plot.title = element_text(
      hjust = 0.5, 
      face = "bold", 
      size = 11,
      margin = margin(b = 10)),
    plot.margin = margin(
      t = 15,
      r = 5.5,
      b = 5.5,
      l = 5.5)) +
  labs(
    title = "Parahippocampus",
    y = "Mean pattern similarity")

ggsave(
  filename = "/Volumes/BrusselsGriffon/CommCon/manuscript-figures/parahippocampus_pattern_similarity.pdf",
  plot = last_plot(),
  width = 3.5,
  height = 2.5,
  units = "in")

###########################
#### PERIRHINAL CORTEX ####
##########################

# Filter to only perirhinal ROIs
perirhinal_data_stats <- main_data %>%
  filter(ROI %in% c("left_PRC", "right_PRC"))

perirhinal_data_plots <- plot_data %>%
  filter(ROI %in% c("left_PRC", "right_PRC"))

# Model 
perirhinal_model2 <- lm(Correlation ~ Condition, data = perirhinal_data_stats)

# Results
summary(perirhinal_model2)
anova(perirhinal_model2)

TukeyHSD(aov(Correlation ~ Condition, data = perirhinal_data_stats))


# Bar plot  
dodge <- position_dodge(width = 0.8)  # spacing between bars so don;t overlap 

ggplot(perirhinal_data_plots, aes(x = Condition, y = Correlation)) +
  stat_summary(fun = mean, geom = "bar", 
               position = dodge, color = "black", width = 0.7) +
  stat_summary(fun.data = mean_cl_boot, geom = "errorbar", 
               position = dodge, width = 0.2) +
  theme_minimal() +
  labs(title = "Mean correlation by Condition and Hemisphere in perirhinal cx",
       y = "Mean Correlation", x = "Condition") 
#scale_fill_manual(values = c("left" = "rosybrown1", "right" = "seagreen"))

# Compute mean correlation per subject
subject_means_perirhinal<- perirhinal_data_plots %>%
  group_by(Subject, Condition) %>%
  summarise(MeanCorrelation = mean(Correlation, na.rm = TRUE), .groups = "drop")

# Position of sig bars
y_max <- max(subject_means_perirhinal$MeanCorrelation, na.rm = TRUE)

# Violin plot 
ggplot(subject_means_perirhinal, aes(x = Condition, y = MeanCorrelation)) +
  geom_violin(trim = FALSE, alpha = 0.6, fill = "grey") +
  stat_summary(fun = mean, geom = "point", color = "black", size = 3) +
  scale_x_discrete(labels = c("same_show_episode" = "Same show, same episode",
                              "same_show_diff_episode" = "Same show, different episode", 
                              "diff_show" = "Different shows")) +
  geom_jitter(shape = 21, color = "black", fill = "grey", 
              position = position_jitter(width = 0.15),
              size = 2, alpha = 0.5, show.legend = FALSE) +
  scale_fill_manual(values = c(
    "same_show_episode" = "cornflowerblue",
    "same_show_diff_episode" = "hotpink",
    "diff_show" = "limegreen")) +
  geom_signif(
    comparisons = list(
      c("diff_show", "same_show_episode")),
    annotations = c("*p = 0.0015"),
    y_position = c(y_max + 0.02, y_max + 0.04),
    tip_length = 0.02,
    textsize = 6) +
  theme_minimal() +
  theme(
    axis.line = element_line(color = "black"),       
    axis.text.x = element_text(color = "black", size = 14),
    axis.text.y = element_text(color = "black", size = 14),
    axis.title.x = element_text(color = "black", size = 16, face = "bold"),
    axis.title.y = element_text(color = "black", size = 16, face = "bold"),
    plot.title = element_text(hjust = 0.5, size = 18, face = "bold") ) +
  labs(title = "Perirhinal cx",
       y = "Mean pattern similarity", x = "")

# Raincloud plot 
ggplot(subject_means_perirhinal,
       aes(x = Condition, y = MeanCorrelation, fill = Condition)) +
  stat_halfeye(
    alpha = 0.5,
    adjust = 0.6,
    width = 0.6,
    justification = -0.25,
    point_interval = mean_qi,
    .width = c(0.66, 0.95)) +
  geom_boxplot(
    width = 0.15,
    outlier.shape = NA,
    alpha = 0.6,
    color = "black",
    linetype = "solid",
    median.linewidth = 0.5) +
  geom_jitter(
    width = 0.08,
    size = 1.8,
    shape = 21,
    color = "black",
    fill = "white" ) +
  stat_summary(
    fun = mean,
    geom = "point",
    color = "black",
    size = 3) +
  scale_x_discrete(labels = c(
    "same_show_episode" = "Same show, \nsame episode",
    "same_show_diff_episode" = "Same show, \ndifferent episode",
    "diff_show" = "Different shows")) +
  scale_fill_manual(values = c(
    "same_show_episode" = "cornflowerblue",
    "same_show_diff_episode" = "hotpink",
    "diff_show" = "limegreen")) +
  geom_signif(
    comparisons = list(
      c("diff_show", "same_show_episode")),
    annotations = c("*p = 0.0015"),
    y_position = c(y_max + 0.02, y_max + 0.04),
    tip_length = 0.02,
    textsize = 6) +
  theme_minimal(base_size = 14) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_text(size = 25),
    axis.text.x = element_text(size = 20, color = "black"),
    axis.text.y = element_text(size = 20, color = "black"),
    axis.line = element_line(color = "black", linewidth = 0.5),
    axis.line.x = element_line(color = "black"),
    axis.line.y = element_line(color = "black"),
    legend.position = "none",
    plot.title = element_text(hjust = 0.5, face = "bold", size = 30)) +
  labs(
    title = "Perirhinal cx",
    y = "Mean pattern similarity" )

# Manuscript fig
ggplot(
  subject_means_perirhinal, 
  aes(x = Condition, y = MeanCorrelation, fill = Condition)) +
  stat_halfeye(
    alpha = 0.5, 
    adjust = 0.6, 
    width = 0.6, 
    justification = -0.25, 
    point_interval = mean_qi, 
    .width = c(0.66, 0.95)) +
  geom_boxplot(
    width = 0.15, 
    outlier.shape = NA, 
    alpha = 0.6,
    color = "black", 
    linetype = "solid",
    median.linewidth = 0.5) +
  geom_jitter(
    width = 0.08, 
    size = 1.2, 
    shape = 21, 
    color = "black", 
    fill = "white",
    alpha = 0.5) +
  stat_summary(
    fun = mean, 
    geom = "point", 
    color = "black", 
    size = 3) +
  scale_x_discrete(
    labels = c(
      "same_show_episode" = "Same show,\nsame\nepisode",
      "same_show_diff_episode" = "Same show,\ndifferent\nepisode", 
      "diff_show" = "Different\nshows")) +
  scale_fill_manual(
    values = c(
      "same_show_episode" = "cornflowerblue",
      "same_show_diff_episode" = "hotpink",
      "diff_show" = "limegreen")) +
  geom_signif(
    comparisons = list(
      c("diff_show", "same_show_episode")),
    annotations = c("*p = .008"),
    y_position = y_max + 0.01,
    tip_length = 0.02, 
    textsize = 3.2) +
  coord_cartesian(clip = "off") +
  theme_minimal(base_size = 10) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_text(
      size = 10),
    axis.text.x = element_text(
      size = 8.5, 
      color = "black"),
    axis.text.y = element_text(
      size = 8.5, 
      color = "black"),
    axis.line = element_line(
      color = "black", 
      linewidth = 0.5),
    axis.line.x = element_line(
      color = "black"),
    axis.line.y = element_line(
      color = "black"),
    legend.position = "none",
    plot.title = element_text(
      hjust = 0.5, 
      face = "bold", 
      size = 11,
      margin = margin(b = 10)),
    plot.margin = margin(
      t = 15,
      r = 5.5,
      b = 5.5,
      l = 5.5)) +
  labs(
    title = "Perirhinal Cortex",
    y = "Mean pattern similarity")

ggsave(
  filename = "/Volumes/BrusselsGriffon/CommCon/manuscript-figures/perirhinal_pattern_similarity.pdf",
  plot = last_plot(),
  width = 3.5,
  height = 2.5,
  units = "in")

#######################################################################################
#######################################################################################

############################
### PERMUTATION TESTING ###
############################

# List of ROI df names 
roi_list <- list(
  hippocampus = hippocampus_data_stats,
  hippocampusNOSUB = hippocampusNOSUB_data_stats,
  parahippocampus = parahippocampus_data_stats, 
  perirhinal = perirhinal_data_stats
  #ant_hipp = hippocampus_ant_data_stats, 
  #post_hipp = hippocampus_post_data_stats
)

# Cond pairs for post hocs
pairs <- list(
  c("diff_show", "same_show_episode"),
  c("diff_show", "same_show_diff_episode"),
  c("same_show_diff_episode", "same_show_episode")
)

# Function for permutations 
run_roi_permutation <- function(dat) {
  
  # Clean data
  dat <- dat %>%
    mutate(
      Subject     = factor(Subject),
      Condition   = factor(Condition),
      Correlation = as.numeric(Correlation))
  
  # Overall permutation test (do the correlations differ across conditons?)
  overall <- independence_test(
    Correlation ~ Condition | Subject, #This is the approrpaite setup for repeated measures so only permutes within subject
    data = dat,
    distribution = approximate(nresample = 10000))
  
  # Inspect 
  y_trans_info <- "identity (raw numeric values)"
  
  # Pairwise tests
  pairwise_res <- map_df(pairs, function(pair) {
    
    dat_pair <- dat %>%
      filter(Condition %in% pair) %>%
      mutate(
        Condition = factor(Condition),
        Subject   = factor(Subject))
    
    test <- independence_test(
      Correlation ~ Condition | Subject,
      data = dat_pair,
      distribution = approximate(nresample = 10000))
    
    tibble(
      Condition1 = pair[1],
      Condition2 = pair[2],
      Statistic  = as.numeric(statistic(test)),
      P_value    = as.numeric(pvalue(test))
    )}) %>%
    mutate(P_adj = p.adjust(P_value, method = "holm")) # Apply correction for multiple comparisons 
  
  # Results
  list(
    overall_test     = overall,
    overall_p        = pvalue(overall),
    pairwise_results = pairwise_res
  )}

# Apply function to ROIs
roi_results <- lapply(roi_list, run_roi_permutation)

# Create df of the results for pairwise comparisons (post hocs)
all_pairwise <- bind_rows(
  lapply(names(roi_results), function(region) {
    roi_results[[region]]$pairwise_results %>%
      mutate(ROI = region)
  }),
  .id = NULL
)

# Create df for overall results for each ROI
overall_summary <- bind_rows(
  lapply(names(roi_results), function(region) {
    tibble(
      ROI = region,
      Statistic = as.numeric(statistic(roi_results[[region]]$overall_test)),
      P_value  = as.numeric(roi_results[[region]]$overall_p)
    )
  }))

# Print 
overall_summary
all_pairwise
print(all_pairwise, n = Inf)

#####################################
## PLOT THE PERMUTATION STATISTICS ##
#####################################
set.seed(123) 

######################
#### HIPPOCAMPUS ####
#####################

# Data 
data_perm_plots <- hippocampus_data_stats %>%
  mutate(
    Subject   = factor(Subject),
    Condition = factor(Condition),
    Correlation = as.numeric(Correlation))

# Function 
get_stat <- function(d) {
  as.numeric(
    statistic(
      independence_test(
        Correlation ~ Condition | Subject,   
        data = d,
        distribution = approximate(nresample = 0))))}

# Observed stat
obs_stat <- get_stat(data_perm_plots)

# Permutations 
n_perm <- 10000  # INCREASE TO 10 000

perm_stats <- replicate(n_perm, {
  data_perm <- data_perm_plots %>%
    group_by(Subject) %>%
    mutate(Condition = sample(Condition)) %>%  
    ungroup()
  
  get_stat(data_perm)
})

# Permutation p statistics computed by permutations 
p_perm <- mean(abs(perm_stats) >= abs(obs_stat))

# Plot
ggplot(tibble(stat = perm_stats), aes(x = stat)) +
  geom_histogram(bins = length(perm_stats), fill = "grey", color = "black") +
  geom_vline(xintercept = obs_stat, color = "red", linewidth = 1.2) +
  annotate(
    "text",
    x = obs_stat + 0.4,
    y = 7,  
    label = paste0("Observed statistic= ", round(obs_stat,3), "\n(p = ", signif(p_perm,3), ")"),
    color = "red",
    hjust = 0.5,
    vjust = 0) +
  labs(
    title = "Hippocampus: Distribution of Permutation Statistics",
    x = "Permutation Statistic",
    y = "Count") +
  theme_classic()

###########################
#### PARAHIPPOCAMPUS #####
#########################

# Data 
data_perm_plots <- parahippocampus_data_stats %>%
  mutate(
    Subject   = factor(Subject),
    Condition = factor(Condition),
    Correlation = as.numeric(Correlation))

# Function 
get_stat <- function(d) {
  as.numeric(
    statistic(
      independence_test(
        Correlation ~ Condition | Subject,   
        data = d,
        distribution = approximate(nresample = 0))))}

# Observed stat
obs_stat <- get_stat(data_perm_plots)

# Permutations 
n_perm <- 10000  # INCREASE TO 10 000

perm_stats <- replicate(n_perm, {
  data_perm <- data_perm_plots %>%
    group_by(Subject) %>%
    mutate(Condition = sample(Condition)) %>%  
    ungroup()
  
  get_stat(data_perm)
})

# Permutation p statistics computed by permutations 
p_perm <- mean(abs(perm_stats) >= abs(obs_stat))

# Plot
ggplot(tibble(stat = perm_stats), aes(x = stat)) +
  geom_histogram(bins = length(perm_stats), fill = "grey", color = "black") +
  geom_vline(xintercept = obs_stat, color = "red", linewidth = 1.2) +
  annotate(
    "text",
    x = obs_stat + -0.5,
    y = 7,  
    label = paste0("Observed statistic = ", round(obs_stat,3), "\n(p = ", signif(p_perm,3), ")"),
    color = "red",
    hjust = 0.5,
    vjust = 0) +
  labs(
    title = "Parahippocampus: Distribution of Permutation Statistics",
    x = "Permutation Statistic",
    y = "Count") +
  theme_classic()

#####################
#### PERIRHINAL #####
#####################

# Data 
data_perm_plots <- perirhinal_data_stats %>%
  mutate(
    Subject   = factor(Subject),
    Condition = factor(Condition),
    Correlation = as.numeric(Correlation))

# Function 
get_stat <- function(d) {
  as.numeric(
    statistic(
      independence_test(
        Correlation ~ Condition | Subject,   
        data = d,
        distribution = approximate(nresample = 0))))}

# Observed stat
obs_stat <- get_stat(data_perm_plots)

# Permutations 
n_perm <- 10000  # INCREASE TO 10 000

perm_stats <- replicate(n_perm, {
  data_perm <- data_perm_plots %>%
    group_by(Subject) %>%
    mutate(Condition = sample(Condition)) %>%  
    ungroup()
  
  get_stat(data_perm)
})

# Permutation p statistics computed by permutations 
p_perm <- mean(abs(perm_stats) >= abs(obs_stat))

# Plot
ggplot(tibble(stat = perm_stats), aes(x = stat)) +
  geom_histogram(bins = length(perm_stats), fill = "grey", color = "black") +
  geom_vline(xintercept = obs_stat, color = "red", linewidth = 1.2) +
  annotate(
    "text",
    x = obs_stat + -0.5,
    y = 7,  
    label = paste0("Observed statistic = ", round(obs_stat,3), "\n(p = ", signif(p_perm,3), ")"),
    color = "red",
    hjust = 0.5,
    vjust = 0 ) +
  labs(
    title = "Perirhinal: Distribution of Permutation Statistics",
    x = "Permutation Statistic",
    y = "Count") +
  theme_classic()


# #####################
# #### ANT HIPPO #####
# #####################
# 
# # Data 
# data_perm_plots <- hippocampus_ant_data_stats %>%
#   mutate(
#     Subject   = factor(Subject),
#     Condition = factor(Condition),
#     Correlation = as.numeric(Correlation)
#   )
# 
# # Function 
# get_stat <- function(d) {
#   as.numeric(
#     statistic(
#       independence_test(
#         Correlation ~ Condition | Subject,   
#         data = d,
#         distribution = approximate(nresample = 0))))}
# 
# # Observed stat
# obs_stat <- get_stat(data_perm_plots)
# 
# # Permutations 
# n_perm <- 10000  # INCREASE TO 10 000
# 
# perm_stats <- replicate(n_perm, {
#   data_perm <- data_perm_plots %>%
#     group_by(Subject) %>%
#     mutate(Condition = sample(Condition)) %>%  
#     ungroup()
#   
#   get_stat(data_perm)
# })
# 
# # Permutation p statistics computed by permutations 
# p_perm <- mean(abs(perm_stats) >= abs(obs_stat))
# 
# # Plot
# ggplot(tibble(stat = perm_stats), aes(x = stat)) +
#   geom_histogram(bins = length(perm_stats), fill = "grey", color = "black") +
#   geom_vline(xintercept = obs_stat, color = "red", linewidth = 1.2) +
#   annotate(
#     "text",
#     x = obs_stat + -0.5,
#     y = 7,  
#     label = paste0("Observed statistic = ", round(obs_stat,3), "\n(p = ", signif(p_perm,3), ")"),
#     color = "red",
#     hjust = 0.5,
#     vjust = 0
#   ) +
#   labs(
#     title = "Anterior Hippocampus: Distribution of Permutation Statistics",
#     x = "Permutation Statistic",
#     y = "Count"
#   ) +
#   theme_classic()
# 
# #####################
# #### POST HIPPO #####
# #####################
# 
# # Data 
# data_perm_plots <- hippocampus_post_data_stats %>%
#   mutate(
#     Subject   = factor(Subject),
#     Condition = factor(Condition),
#     Correlation = as.numeric(Correlation)
#   )
# 
# # Function 
# get_stat <- function(d) {
#   as.numeric(
#     statistic(
#       independence_test(
#         Correlation ~ Condition | Subject,   
#         data = d,
#         distribution = approximate(nresample = 0))))}
# 
# # Observed stat
# obs_stat <- get_stat(data_perm_plots)
# 
# # Permutations 
# n_perm <- 10000  # INCREASE TO 10 000
# 
# perm_stats <- replicate(n_perm, {
#   data_perm <- data_perm_plots %>%
#     group_by(Subject) %>%
#     mutate(Condition = sample(Condition)) %>%  
#     ungroup()
#   
#   get_stat(data_perm)
# })
# 
# # Permutation p statistics computed by permutations 
# p_perm <- mean(abs(perm_stats) >= abs(obs_stat))
# 
# # Plot
# ggplot(tibble(stat = perm_stats), aes(x = stat)) +
#   geom_histogram(bins = length(perm_stats), fill = "grey", color = "black") +
#   geom_vline(xintercept = obs_stat, color = "red", linewidth = 1.2) +
#   annotate(
#     "text",
#     x = obs_stat + -0.5,
#     y = 7,  
#     label = paste0("Observed statistic = ", round(obs_stat,3), "\n(p = ", signif(p_perm,3), ")"),
#     color = "red",
#     hjust = 0.5,
#     vjust = 0
#   ) +
#   labs(
#     title = "Posterior Hippocampus: Distribution of Permutation Statistics",
#     x = "Permutation Statistic",
#     y = "Count"
#   ) +
#   theme_classic()
# 
# 

### PLOTS FOR PAIRWISE 

######################
#### HIPPOCAMPUS ####
####################

data_perm_plots <- hippocampus_data_stats %>%
  mutate(
    Subject     = factor(Subject),
    Condition   = factor(Condition),
    Correlation = as.numeric(Correlation))

# Condition pairs
pairs <- list(
  c("diff_show", "same_show_episode"),
  c("diff_show", "same_show_diff_episode"),
  c("same_show_diff_episode", "same_show_episode"))

# Statistic function
get_stat <- function(d) {
  as.numeric(
    statistic(
      independence_test(
        Correlation ~ Condition | Subject,
        data = d,
        distribution = approximate(nresample = 0)
      )))}

# Run permutations for all pairs
n_perm <- 10000

perm_df <- lapply(pairs, function(pair) {
  
  dat_pair <- data_perm_plots %>%
    filter(Condition %in% pair)
  
  # Observed statistic
  obs_stat <- get_stat(dat_pair)
  
  # Permutations
  perm_stats <- replicate(n_perm, {
    dat_perm <- dat_pair %>%
      group_by(Subject) %>%
      mutate(Condition = sample(Condition)) %>%
      ungroup()
    
    get_stat(dat_perm)
  })
  
  # Empirical p-value
  p_perm <- mean(abs(perm_stats) >= abs(obs_stat))
  
  tibble(
    stat     = perm_stats,
    observed = obs_stat,
    p_value  = p_perm,
    contrast = paste(pair[1], "vs", pair[2])
  )}) %>%
  bind_rows()

# Plot 
ggplot(perm_df, aes(x = stat)) +
  geom_histogram(
    bins = length(unique(perm_df$stat)),
    fill = "grey",
    color = "black") +
  geom_vline(
    aes(xintercept = observed),
    color = "red",
    linewidth = 1.2) +
  facet_wrap(~ contrast, scales = "free_y") +
  geom_text(
    data = distinct(perm_df, contrast, observed, p_value),
    aes(
      x = observed,
      y = Inf,
      label = paste0(
        "Observed statistic = ", round(observed, 3),
        "\n(p = ", signif(p_value, 3), ")")),
    vjust = 1.2,
    hjust = 0.5,
    color = "red",
    inherit.aes = FALSE ) +
  labs(
    title = "Hippocampus: Permutation Distributions of Pairwise Post-hoc Tests",
    x = "Permutation Statistic",
    y = "Count") +
  theme_classic()


############
#### PARAHIPPOCAMPUS ###
############

data_perm_plots <- parahippocampus_data_stats %>%
  mutate(
    Subject     = factor(Subject),
    Condition   = factor(Condition),
    Correlation = as.numeric(Correlation))

# Condition pairs
pairs <- list(
  c("diff_show", "same_show_episode"),
  c("diff_show", "same_show_diff_episode"),
  c("same_show_diff_episode", "same_show_episode"))

# Statistic function
get_stat <- function(d) {
  as.numeric(
    statistic(
      independence_test(
        Correlation ~ Condition | Subject,
        data = d,
        distribution = approximate(nresample = 0))))}

# Run permutations for all pairs
n_perm <- 10000

perm_df <- lapply(pairs, function(pair) {
  
  dat_pair <- data_perm_plots %>%
    filter(Condition %in% pair)
  
  # Observed statistic
  obs_stat <- get_stat(dat_pair)
  
  # Permutations
  perm_stats <- replicate(n_perm, {
    dat_perm <- dat_pair %>%
      group_by(Subject) %>%
      mutate(Condition = sample(Condition)) %>%
      ungroup()
    
    get_stat(dat_perm)
  })
  
  # Empirical p-value
  p_perm <- mean(abs(perm_stats) >= abs(obs_stat))
  
  tibble(
    stat     = perm_stats,
    observed = obs_stat,
    p_value  = p_perm,
    contrast = paste(pair[1], "vs", pair[2])
  )}) %>%
  bind_rows()

# Plot 
ggplot(perm_df, aes(x = stat)) +
  geom_histogram(
    bins = length(unique(perm_df$stat)),
    fill = "grey",
    color = "black") +
  geom_vline(
    aes(xintercept = observed),
    color = "red",
    linewidth = 1.2) +
  facet_wrap(~ contrast, scales = "free_y") +
  geom_text(
    data = distinct(perm_df, contrast, observed, p_value),
    aes(
      x = observed,
      y = Inf,
      label = paste0(
        "Observed statistic= ", round(observed, 3),
        "\n(p = ", signif(p_value, 3), ")")),
    vjust = 1.2,
    hjust = 0.5,
    color = "red",
    inherit.aes = FALSE) +
  labs(
    title = "Parahippocampus: Permutation Distributions of Pairwise Post-hoc Tests",
    x = "Permutation Statistic",
    y = "Count") +
  theme_classic()

###################
#### PERIRHINAL ###
##################

data_perm_plots <- perirhinal_data_stats %>%
  mutate(
    Subject     = factor(Subject),
    Condition   = factor(Condition),
    Correlation = as.numeric(Correlation))

# Condition pairs
pairs <- list(
  c("diff_show", "same_show_episode"),
  c("diff_show", "same_show_diff_episode"),
  c("same_show_diff_episode", "same_show_episode"))

# Statistic function
get_stat <- function(d) {
  as.numeric(
    statistic(
      independence_test(
        Correlation ~ Condition | Subject,
        data = d,
        distribution = approximate(nresample = 0)
      )))}

# Run permutations for all pairs
n_perm <- 10000

perm_df <- lapply(pairs, function(pair) {
  
  dat_pair <- data_perm_plots %>%
    filter(Condition %in% pair)
  
  # Observed statistic
  obs_stat <- get_stat(dat_pair)
  
  # Permutations
  perm_stats <- replicate(n_perm, {
    dat_perm <- dat_pair %>%
      group_by(Subject) %>%
      mutate(Condition = sample(Condition)) %>%
      ungroup()
    
    get_stat(dat_perm)
  })
  
  # Empirical p-value
  p_perm <- mean(abs(perm_stats) >= abs(obs_stat))
  
  tibble(
    stat     = perm_stats,
    observed = obs_stat,
    p_value  = p_perm,
    contrast = paste(pair[1], "vs", pair[2])
  )}) %>%
  bind_rows()

# Plot 
ggplot(perm_df, aes(x = stat)) +
  geom_histogram(
    bins = length(unique(perm_df$stat)),
    fill = "grey",
    color = "black") +
  geom_vline(
    aes(xintercept = observed),
    color = "red",
    linewidth = 1.2) +
  facet_wrap(~ contrast, scales = "free_y") +
  geom_text(
    data = distinct(perm_df, contrast, observed, p_value),
    aes(
      x = observed,
      y = Inf,
      label = paste0(
        "Observed statistic= ", round(observed, 3),
        "\n(p = ", signif(p_value, 3), ")"
      )),
    vjust = 1.2,
    hjust = 0.5,
    color = "red",
    inherit.aes = FALSE) +
  labs(
    title = "Perirhinal: Permutation Distributions of Pairwise Post-hoc Tests",
    x = "Permutation Statistic",
    y = "Count") +
  theme_classic()


