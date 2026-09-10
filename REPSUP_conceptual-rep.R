#############################################################
### MODEL 3 - PRE-ONLY CONCEPTUAL REPETITION SUPPRESSION ###
############################################################

# Subject IDs
subject_numbers <- c(
  "01","02","03","04","05","06","07","08","09","10", "11","12","13","14","15","16","18","19","20","21",
  "22","23","25","27","28","29","30","31","32","33","34")

# ROIs
rois <- c(
  "left_Hippocampus_MNI-BOLD", "right_Hippocampus_MNI-BOLD",
  "left_A1_mask_resampled", "right_A1_mask_resampled",
  "left_PHC_MNI-BOLD", "right_PHC_MNI-BOLD",
  "left_PRC_MNI-BOLD", "right_PRC_MNI-BOLD",
  "vmPFC_right_resampled", "vmPFC_left_resampled",
  "PMC_3mm_resampled_bin")

# Commercial names
commercial_names <- readLines(
  "/Volumes/BrusselsGriffon/CommCon/SPM_results/Model3_scripts/CommercialNames.txt")

# PRE data path
base_path <- "/Volumes/Chi/Model3_PRE"

# Empty list
all_pre_data <- list()

##########################
### LOAD PRE BETA DATA ###
##########################

for (subject_number in subject_numbers) {
  
  subject_id <- paste0("sub-", subject_number)
  
  for (roi in rois) {
    
    mat_file_path <- file.path(
      base_path,
      paste0(
        "Model3_", subject_id,
        "/Model3_", subject_id, "_",
        roi,
        "_beta_values_PRE.mat"))
    
    if (file.exists(mat_file_path)) {
      
      data <- readMat(mat_file_path)
      
      if ("roi.combined.beta.values.PRE" %in% names(data)) {
        beta_matrix <- as.matrix(data$roi.combined.beta.values.PRE)
      } else if ("roi.combined.beta.values" %in% names(data)) {
        beta_matrix <- as.matrix(data$roi.combined.beta.values)
      }
      
      
      # Check
      if (ncol(beta_matrix) != length(commercial_names)) {
        warning(
          paste(
            "Skipping due to column mismatch:",
            mat_file_path
          ))
        next
      }
      
      # Add commercial names
      colnames(beta_matrix) <- commercial_names
      
      # Convert to long format
      df_long <- as.data.frame(beta_matrix) %>%
        mutate(
          observation_id = 1:nrow(beta_matrix)) %>%
        pivot_longer(
          cols = all_of(commercial_names),
          names_to = "commercial_name",
          values_to = "beta_value") %>%
        mutate(
          subject = subject_id,
          ROI = roi)
      
      all_pre_data[[length(all_pre_data) + 1]] <- df_long
      
    } else {
      
      warning(
        paste(
          "Missing file:",
          mat_file_path
        ))}}}


# Combine all PRE data
pre_alldata <- bind_rows(all_pre_data)

head(pre_alldata)


# CLEAN
pre_alldata <- pre_alldata %>%
  mutate(
    
    # Hemisphere
    hemisphere = case_when(
      grepl("left", ROI, ignore.case = TRUE) ~ "left",
      grepl("right", ROI, ignore.case = TRUE) ~ "right",
      TRUE ~ NA_character_),
    
    # Region
    region = case_when(
      grepl("Hippocampus", ROI) ~ "Hippocampus",
      grepl("A1", ROI) ~ "A1",
      grepl("PHC", ROI) ~ "PHC",
      grepl("PRC", ROI) ~ "PRC",
      grepl("vmPFC", ROI) ~ "vmPFC",
      grepl("PMC", ROI) ~ "PMC",
      TRUE ~ NA_character_),
    
    # Segment
    segment = case_when(
      grepl("seg-0", commercial_name) ~ "seg-0",
      grepl("seg-1", commercial_name) ~ "seg-1",
      grepl("seg-2", commercial_name) ~ "seg-2",
      TRUE ~ NA_character_))

head(pre_alldata)

# Average 
change_scores_conceptual_PRE <- pre_alldata %>%
  group_by(subject, region, segment) %>%
  summarise(
    mean_beta = mean(beta_value, na.rm = TRUE),
    .groups = "drop") %>%
  pivot_wider(
    names_from = segment,
    values_from = mean_beta) %>%
  mutate(
    seg0_minus_seg2 = `seg-0` - `seg-2`)

head(change_scores_conceptual_PRE)

#plot 
ggplot(
  change_scores_conceptual_PRE,
  aes(
    x = region,
    y = seg0_minus_seg2)) +
  stat_summary(
    fun = mean,
    geom = "bar",
    width = 0.7,
    fill = "grey",
    color = "#333333",
    linewidth = 1) +
  stat_summary(
    fun.data = mean_se,
    geom = "errorbar",
    width = 0.2,
    linewidth = 0.6) +
  geom_hline(
    yintercept = 0,
    linetype = "solid",
    linewidth = 0.5 ) +
  scale_x_discrete(
    limits = c("vmPFC", "PMC", "Hippocampus", "PHC", "PRC", "A1")) +
  labs(
    x = "ROI",
    y = "Conceptual repetition suppression\n(Segment 1 − Segment 3)") +
  theme_classic(base_size = 12) +
  theme(
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    axis.ticks = element_line(linewidth = 0.5))

ggsave(
  filename = "/Volumes/BrusselsGriffon/CommCon/manuscript-figures/conceptual-repsup.pdf",
  plot = last_plot(),
  width = 6.5,
  height = 2.5,
  units = "in")

# # 1 tailed ttests 
# # A1
# a1_t1 <- change_scores_conceptual_PRE %>%
#   filter(region == "A1")
# t.test(
#   a1_t1$seg0_minus_seg2,
#   mu = 0, alternative = "greater")
# 
# # Hippocampus
# hippo_t1 <- change_scores_conceptual_PRE %>%
#   filter(region == "Hippocampus")
# t.test(
#   hippo_t1$seg0_minus_seg2,
#   mu = 0, alternative = "greater")
# 
# # PHC
# phc_t1 <- change_scores_conceptual_PRE %>%
#   filter(region == "PHC")
# t.test(
#   phc_t1$seg0_minus_seg2,
#   mu = 0, alternative = "greater")
# 
# # PRC
# prc_t1 <- change_scores_conceptual_PRE %>%
#   filter(region == "PRC")
# t.test(
#   prc_t1$seg0_minus_seg2,
#   mu = 0, alternative = "greater")
# 
# # vmPFC
# vmpfc_t1 <- change_scores_conceptual_PRE %>%
#   filter(region == "vmPFC")
# t.test(
#   vmpfc_t1$seg0_minus_seg2,
#   mu = 0, alternative = "greater")
# 
# # PMC
# pmc_t1 <- change_scores_conceptual_PRE %>%
#   filter(region == "PMC")
# t.test(
#   pmc_t1$seg0_minus_seg2,
#   mu = 0, alternative = "greater")

# PERMUTATIONS (rando assign +/-)
perm_one_sample <- function(x, n_perm = 10000) {
  
  x <- x[!is.na(x)]
  
  observed_mean <- mean(x)
  
  permuted_means <- replicate(n_perm, {
    mean(x * sample(c(-1, 1), length(x), replace = TRUE))
  })
  
  p_value <- (sum(permuted_means >= observed_mean) + 1) /
    (n_perm + 1)
  
  tibble(
    n = length(x),
    mean = observed_mean,
    p_value_perm = p_value
  )}

conceptual_PRE_perm_results <- change_scores_conceptual_PRE %>%
  group_by(region) %>%
  group_modify(~ {
    perm_one_sample(
      .x$seg0_minus_seg2,
      n_perm = 10000
    )}) %>%
  ungroup() %>%
  mutate(
    p_value_fdr = p.adjust(p_value_perm, method = "fdr"))

print(conceptual_PRE_perm_results)

