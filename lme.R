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
                     "18", "19", "20", "21", "22", "23", "24", "25", "27", "28", "29", "30", "31", "32", "33","34")

subject_ids <- paste0("sub-", subject_numbers)
base_path <- "/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST-PRE"

# List of ROIs
rois <- c("left_V1_mask_resampled", "right_V1_mask_resampled", "left_A1_mask_resampled", "right_A1_mask_resampled", 
          "left_motor_mask_resampled", "right_motor_mask_resampled", "PMC_3mm_resampled_bin", "vmPFC_left_resampled", "vmPFC_right_resampled")

# Conditions of interest
conditions <- c("same_show_episode", "same_show_diff_episode", "diff_show")
#conditions <- c("same_show_episode", "same_show_diff_episode", "diff_show", "same_show_episode_SAME-COMS", "same_show_episode_DIFF-COMS")

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
        ROI = roi)
    
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
  # Remove extras liek _mask_resampled
  mutate(
    ROI = gsub("(_mask_resampled|_3mm_resampled_bin|_resampled)$", "", ROI))
  
# Grab hemisphere info & region/roi
final_data_STATS <- final_data_STATS %>%
  mutate(
    Hemisphere = str_extract(ROI, "(left|right)"),
    Region = str_remove(ROI, "(^|_)(left|right)($|_)") %>%
      str_replace("^_|_$", "")
  )
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
                     "18", "19", "20", "21", "22", "23", "24", "25", "27", "28", "29", "30", "31", "32", "33","34")

subject_ids <- paste0("sub-", subject_numbers)
base_path <- "/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_POST-PRE"

# List of ROIs
rois <- c("left_V1_mask_resampled", "right_V1_mask_resampled", "left_A1_mask_resampled", "right_A1_mask_resampled", 
          "left_motor_mask_resampled", "right_motor_mask_resampled", "PMC_3mm_resampled_bin", "vmPFC_left_resampled", "vmPFC_right_resampled")

# Conditions of interest
conditions <- c("same_show_episode", "same_show_diff_episode", "diff_show")

# Define function to load condition data for each ROI
load_condition_data <- function(condition, roi, subject_ids, base_path) {
  all_corrs <- list()
  
  for (sub in subject_ids) {
    # Path updated to include ROI
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
  # Remove extras liek _mask_resampled
  mutate(
    ROI = gsub("(_mask_resampled|_3mm_resampled_bin|_resampled)$", "", ROI))

# Grab hemisphere info & region/roi
final_data_PLOTS <- final_data_PLOTS %>%
  mutate(
    Hemisphere = str_extract(ROI, "(left|right)"),
    Region = str_remove(ROI, "(^|_)(left|right)($|_)") %>%
      str_replace("^_|_$", "")
  )

# Check
print(head(final_data_PLOTS))

# FILTER FOR MAIN ANALYSES 
plot_data <- final_data_PLOTS %>%
  filter(Condition %in% c("same_show_episode", "same_show_diff_episode", "diff_show"))

print(head(plot_data))

###########################
######## ANALYSIS ########
###########################

##############
#### vmPFC ####
#############

# Filter to only vmPFC ROIs
vmpfc_data_stats <- main_data %>%
  filter(ROI %in% c("vmPFC_left", "vmPFC_right"))

vmpfc_data_plots <- plot_data %>%
  filter(ROI %in% c("vmPFC_left", "vmPFC_right"))

# Model 
#mpfc_model <- lme(Correlation ~  Condition, random = ~1 | Subject, data = mpfc_data_stats)

vmpfc_model2 <- lm(Correlation ~ Condition, data = vmpfc_data_stats)
#r2_nakagawa(mpfc_model)

# Results
#summary(mpfc_model)
#anova(mpfc_model)

summary(vmpfc_model2)
anova(vmpfc_model2)

TukeyHSD(aov(Correlation ~ Condition, data = vmpfc_data_stats))

# Estimated marginal means 
#emm_mpfc_condition <- emmeans(mpfc_model, ~ Condition)

# Pairwise comparisons 
#pairs(emm_mpfc_condition, adjust = "tukey")

# Plot 
dodge <- position_dodge(width = 0.8)  # spacing between bars so don;t overlap 

ggplot(vmpfc_data_plots, aes(x = Condition, y = Correlation)) +
  stat_summary(fun = mean, geom = "bar", 
               position = dodge, color = "black", width = 0.7) +
  stat_summary(fun.data = mean_cl_boot, geom = "errorbar", 
               position = dodge, width = 0.2) +
  theme_minimal() +
  labs(title = "Mean correlation by Condition and Hemisphere in vmPFC",
       y = "Mean Correlation", x = "Condition") 
#scale_fill_manual(values = c("left" = "palegreen", "right" = "pink"))


# Compute mean correlation per subject
subject_means_vmpfc <- vmpfc_data_plots %>%
  group_by(Subject, Condition) %>%
  summarise(MeanCorrelation = mean(Correlation, na.rm = TRUE), .groups = "drop")

# Position of sig bars
y_max <- max(subject_means_vmpfc$MeanCorrelation, na.rm = TRUE)

# Violin plot 
ggplot(subject_means_vmpfc, aes(x = Condition, y = MeanCorrelation)) +
  geom_violin(trim = FALSE, alpha = 0.6, fill = "grey") +
  stat_summary(fun = mean, geom = "point", color = "black", size = 3) +
  scale_x_discrete(labels = c("same_show_episode" = "Same show, same episode",
                              "same_show_diff_episode" = "Same show, different episode", 
                              "diff_show" = "Different shows")) +
  geom_jitter(shape = 21, color = "black", fill = "grey", 
              position = position_jitter(width = 0.15),
              size = 2, alpha = 0.5, show.legend = FALSE) +
  #geom_signif(comparisons = list(c("diff_show", "same_show_diff_episode"),
  #                               c("diff_show", "same_show_episode")),
  #            annotations = c("***", "***"),
  #            y_position = c(y_max + 0.009, y_max + 0.02),
  #            tip_length = 0.02, textsize = 20
  #) +
  theme_minimal() +
  theme(
    axis.line = element_line(color = "black"),       
    axis.text.x = element_text(color = "black", size = 14),
    axis.text.y = element_text(color = "black", size = 14),
    axis.title.x = element_text(color = "black", size = 16, face = "bold"),
    axis.title.y = element_text(color = "black", size = 16, face = "bold"),
    plot.title = element_text(hjust = 0.5, size = 18, face = "bold") 
  ) +
  labs(title = "VM Prefrontal Cortex (vmPFC)",
       y = "Mean pattern similarity", x = "")

# Raincloud plot
ggplot(subject_means_vmpfc, aes(x = Condition, y = MeanCorrelation, fill = Condition)) +
  stat_halfeye(alpha = 0.5, adjust = 0.6, width = 0.6, justification = -0.25, point_interval = mean_qi, .width = c(0.66, 0.95)) +
  geom_boxplot( width = 0.15, outlier.shape = NA, alpha = 0.6,color = "black", linetype = "solid",
                median.linewidth = 0.5) +
  geom_jitter(width = 0.08,  size = 1.8, shape = 21, color = "black", fill = "white") +
  stat_summary(fun = mean, geom = "point", color = "black", size = 3) +
  scale_x_discrete(labels = c("same_show_episode" = "Same show, \nsame episode",
                              "same_show_diff_episode" = "Same show, \ndifferent episode", 
                              "diff_show" = "Different shows")) +
  scale_fill_manual(values = c(
    "same_show_episode" = "cornflowerblue",
    "same_show_diff_episode" = "hotpink",
    "diff_show" = "limegreen")) +
  geom_signif(comparisons = list(c("diff_show", "same_show_episode")),
              annotations = c("*p = 0.000"),
              y_position = c(y_max + 0.015, y_max + 0.029),
              tip_length = 0.02, textsize = 4) +
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
    title = "Ventromedial Prefrontal Cortex (vmPFC)\n",
    y = "Mean pattern similarity")


# MANUSCRIPT FIG
ggplot(
  subject_means_vmpfc, 
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
    comparisons = list(c("diff_show", "same_show_episode")),
    annotations = "*p < .001",
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
    title = "Ventromedial Prefrontal Cortex (vmPFC)",
    y = "Mean pattern similarity")

ggsave(
  filename = "/Volumes/BrusselsGriffon/CommCon/manuscript-figures/vmPFC_pattern_similarity.pdf",
  plot = last_plot(),
  width = 3.5,
  height = 2.5,
  units = "in")

##########################
#### pmc - baldassano ####
##########################

# Filter to only pmc ROIs
pmcB_data_stats <- main_data %>%
  filter(ROI %in% c("PMC"))

pmcB_data_plots <- plot_data %>%
  filter(ROI %in% c("PMC"))

# Model 
#pmc_model<- lme(Correlation ~  Condition, random = ~1 | Subject, data = pmc_data_stats)

pmcB_model2 <- lm(Correlation ~ Condition, data = pmcB_data_stats)
#r2_nakagawa(mpfc_model)

# Results
#summary(pmc_model)
#anova(pmc_model)
summary(pmcB_model2)
anova(pmcB_model2)

TukeyHSD(aov(Correlation ~ Condition, data = pmcB_data_stats))


#r2_nakagawa(pmc_model)

# Estimated marginal means 
#emm_pmc_condition <- emmeans(pmc_model, ~ Condition)

# Pairwise comparisons 
#pairs(emm_pmc_condition, adjust = "tukey")

# bar plot 
dodge <- position_dodge(width = 0.8)  # spacing between bars so don;t overlap 

ggplot(pmcB_data_plots, aes(x = Condition, y = Correlation)) +
  stat_summary(fun = mean, geom = "bar", 
               position = dodge, color = "black", width = 0.7) +
  stat_summary(fun.data = mean_cl_boot, geom = "errorbar", 
               position = dodge, width = 0.2) +
  theme_minimal() +
  labs(title = "Mean correlation by Condition and Hemisphere in pmcB",
       y = "Mean Correlation", x = "Condition") 
#scale_fill_manual(values = c("left" = "skyblue", "right" = "lightslateblue"))

# Compute mean correlation per subject
subject_means_pmcB <- pmcB_data_plots %>%
  group_by(Subject, Condition) %>%
  summarise(MeanCorrelation = mean(Correlation, na.rm = TRUE), .groups = "drop")

# Position of sig bars
y_max <- max(subject_means_pmcB$MeanCorrelation, na.rm = TRUE)

# Violin plot 
ggplot(subject_means_pmcB, aes(x = Condition, y = MeanCorrelation)) +
  geom_violin(trim = FALSE, alpha = 0.6, fill = "grey") +
  stat_summary(fun = mean, geom = "point", color = "black", size = 3) +
  scale_x_discrete(labels = c("same_show_episode" = "Same show, same episode",
                              "same_show_diff_episode" = "Same show, different episode", 
                              "diff_show" = "Different shows")) +
  geom_jitter(shape = 21, color = "black", fill = "grey", 
              position = position_jitter(width = 0.15),
              size = 2, alpha = 0.5, show.legend = FALSE) +
  geom_signif(comparisons = list(c("diff_show", "same_show_episode")),
              annotations = c("*p = 0.000"),
              y_position = c(y_max + 0.025, y_max + 0.035),
              tip_length = 0.02) +
  theme_minimal() +
  theme(
    axis.line = element_line(color = "black"),       
    axis.text.x = element_text(color = "black", size = 14),
    axis.text.y = element_text(color = "black", size = 14),
    axis.title.x = element_text(color = "black", size = 16, face = "bold"),
    axis.title.y = element_text(color = "black", size = 16, face = "bold"),
    plot.title = element_text(hjust = 0.5, size = 18, face = "bold")  ) +
  labs(title = "Posterior Medial Cortex Baldassano (pmcB)",
       y = "Mean pattern similarity", x = "")

# Raincloud plot
ggplot(subject_means_pmcB, aes(x = Condition, y = MeanCorrelation, fill = Condition)) +
  stat_halfeye(alpha = 0.5, adjust = 0.6, width = 0.6, justification = -0.25, point_interval = mean_qi, .width = c(0.66, 0.95)) +
  geom_boxplot( width = 0.15, outlier.shape = NA, alpha = 0.6,color = "black", linetype = "solid",
                median.linewidth = 0.5) +
  geom_jitter(width = 0.08,  size = 1.8, shape = 21, color = "black", fill = "white") +
  stat_summary(fun = mean, geom = "point", color = "black", size = 3) +
  scale_x_discrete(labels = c("same_show_episode" = "Same show, \name episode",
                              "same_show_diff_episode" = "Same show, \ndifferent episode", 
                              "diff_show" = "Different shows")) +
  scale_fill_manual(values = c(
    "same_show_episode" = "cornflowerblue",
    "same_show_diff_episode" = "hotpink",
    "diff_show" = "limegreen")) +
  geom_signif(comparisons = list(c("diff_show", "same_show_episode")),
              annotations = c("*p = 0.000"),
              y_position = c(y_max + 0.01),
              tip_length = 0.02, textsize = 6) +
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
    title = "Posterior Medial Cortex - Baldassano (PMC)",
    y = "Mean pattern similarity")

# MANUSCRIPT FIG
ggplot(
  subject_means_pmcB, 
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
    comparisons = list(c("diff_show", "same_show_episode")),
    annotations = "*p < .001",
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
    title = "Posterior Medial Cortex (PMC)",
    y = "Mean pattern similarity")

ggsave(
  filename = "/Volumes/BrusselsGriffon/CommCon/manuscript-figures/PMC_pattern_similarity.pdf",
  plot = last_plot(),
  width = 3.5,
  height = 2.5,
  units = "in")

#########################
#### AUDITORY CORTEX ####
########################

# Filter to only auditory cx ROIs
A1_data_stats <- main_data %>%
  filter(ROI %in% c("left_A1", "right_A1"))

A1_data_plots <- plot_data %>%
  filter(ROI %in% c("left_A1", "right_A1"))

# Model 
A1_model2 <- lm(Correlation ~ Condition, data = A1_data_stats)

# Results
summary(A1_model2)
anova(A1_model2)

TukeyHSD(aov(Correlation ~ Condition, data = A1_data_stats))


# Bar plot  
dodge <- position_dodge(width = 0.8)  # spacing between bars so don;t overlap 

ggplot(A1_data_plots, aes(x = Condition, y = Correlation)) +
  stat_summary(fun = mean, geom = "bar", 
               position = dodge, color = "black", width = 0.7) +
  stat_summary(fun.data = mean_cl_boot, geom = "errorbar", 
               position = dodge, width = 0.2) +
  theme_minimal() +
  labs(title = "Mean correlation by Condition and Hemisphere in auditory cortex",
       y = "Mean Correlation", x = "Condition") 
#scale_fill_manual(values = c("left" = "rosybrown1", "right" = "seagreen"))

# Compute mean correlation per subject
subject_means_A1<- A1_data_plots %>%
  group_by(Subject, Condition) %>%
  summarise(MeanCorrelation = mean(Correlation, na.rm = TRUE), .groups = "drop")

# Position of sig bars
y_max <- max(subject_means_A1$MeanCorrelation, na.rm = TRUE)

# Violin plot 
ggplot(subject_means_A1, aes(x = Condition, y = MeanCorrelation)) +
  geom_violin(trim = FALSE, alpha = 0.6, fill = "grey") +
  stat_summary(fun = mean, geom = "point", color = "black", size = 3) +
  scale_x_discrete(labels = c("same_show_episode" = "Same show, same episode",
                              "same_show_diff_episode" = "Same show, different episode", 
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
    plot.title = element_text(hjust = 0.5, size = 18, face = "bold") ) +
  labs(title = "Primary Auditory Cortex",
       y = "Mean pattern similarity", x = "")

# Raincloud plot 
ggplot(subject_means_A1, aes(x = Condition, y = MeanCorrelation, fill = Condition)) +
  stat_halfeye(alpha = 0.5, adjust = 0.6, width = 0.6, justification = -0.25, point_interval = mean_qi, .width = c(0.66, 0.95)) +
  geom_boxplot( width = 0.15, outlier.shape = NA, alpha = 0.6,color = "black", linetype = "solid",
                median.linewidth = 0.5) +
  geom_jitter(width = 0.08,  size = 1.8, shape = 21, color = "black", fill = "white") +
  stat_summary(fun = mean, geom = "point", color = "black", size = 3) +
  scale_x_discrete(labels = c("same_show_episode" = "Same show, same episode",
                              "same_show_diff_episode" = "Same show, different episode", 
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
    title = "Primary Auditory Cortex",
    y = "Mean pattern similarity")


# MANUSCRIPT FIGS 
ggplot(
  subject_means_A1, 
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
    title = "Primary Auditory Cortex (A1)",
    y = "Mean pattern similarity")

ggsave(
  filename = "/Volumes/BrusselsGriffon/CommCon/manuscript-figures/A1_pattern_similarity.pdf",
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
  vmpfc       = vmpfc_data_stats,
  pmcB         = pmcB_data_stats,
  v1          = V1_data_stats,
  motor       = motor_data_stats, 
  auditory = A1_data_stats 
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
    )}))
# Print 
overall_summary
all_pairwise
print(all_pairwise, n = Inf)

#####################################
## PLOT THE PERMUTATION STATISTICS ##
#####################################
set.seed(123) 

###############
#### VMPFC ####
##############

# Data 
data_perm_plots <- vmpfc_data_stats %>%
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
    label = paste0("Observed statistic = ", round(obs_stat,3), "\n(p = ", signif(p_perm,3), ")"),
    color = "red",
    hjust = 0.5,
    vjust = 0) +
  labs(
    title = "VMPFC: Distribution of Permutation Statistics",
    x = "Permutation Statistic",
    y = "Count") +
  theme_classic()

###########################
#### PMC - BALDASSANO #####
##########################

# Data 
data_perm_plots <- pmcB_data_stats %>%
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
    label = paste0("Observed statistic= ", round(obs_stat,3), "\n(p = ", signif(p_perm,3), ")"),
    color = "red",
    hjust = 0.5,
    vjust = 0) +
  labs(
    title = "PMC - Baldassano: Distribution of Permutation Statistics",
    x = "Permutation Statistic",
    y = "Count") +
  theme_classic()

##############
#### A1 #####
#############

# Data 
data_perm_plots <- A1_data_stats %>%
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
    title = "A1: Distribution of Permutation Statistics",
    x = "Permutation Statistic",
    y = "Count") +
  theme_classic()

##############
#### VMPFC ####
#############

data_perm_plots <- vmpfc_data_stats %>%
  mutate(
    Subject     = factor(Subject),
    Condition   = factor(Condition),
    Correlation = as.numeric(Correlation) )

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
  )
}) %>%
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
    inherit.aes = FALSE) +
  labs(
    title = "VMPFC: Permutation Distributions of Pairwise Post-hoc Tests",
    x = "Permutation Statistic",
    y = "Count") +
  theme_classic()

##########################
#### PMC - Baldassano ####
##########################

data_perm_plots <- pmcB_data_stats %>%
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
        "Observed statistic = ", round(observed, 3),
        "\n(p = ", signif(p_value, 3), ")")),
    vjust = 1.2,
    hjust = 0.5,
    color = "red",
    inherit.aes = FALSE) +
  labs(
    title = "PMC - Baldassano: Permutation Distributions of Pairwise Post-hoc Tests",
    x = "Permutation Statistic",
    y = "Count") +
  theme_classic()

############
#### A1 ####
############

data_perm_plots <- A1_data_stats %>%
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
  )
}) %>%
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
    title = "A1: Permutation Distributions of Pairwise Post-hoc Tests",
    x = "Permutation Statistic",
    y = "Count") +
  theme_classic()

