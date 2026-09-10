# Load packages
library(readxl)
library(dplyr)
library(lubridate)

# Path to Excel file
file_path <- "/Users/yorkie/Documents/CommCon/commcon-demo.xlsx"

# Read Excel file
data <- read_excel(file_path)

# EXCLUDE
data <- data %>%
  filter(!SubjectID %in% c("CommCon17", "CommCon26"))

# Calculate age at scan
data <- data %>%
  mutate(
    
    # Fix the werid date issue
    scan_date = as.Date(as.numeric(`date of scan`), origin = "1899-12-30"),
    
    scan_date = case_when(
      grepl("2/15/23", `date of scan`) ~ as.Date("2023-02-15"),
      TRUE ~ scan_date),
    
    # Convert DOB to date
    dob = as.Date(`Date of birth`),
    
    # Calculate age at scan
    Age_at_scan = floor(time_length(
      interval(dob, scan_date),
      "years")))

# Display results
data %>%
  select(
    SubjectID,
    scan_date,
    dob,
    Age_at_scan) %>%
  print(n = Inf)

# Mean and SD of age
age_summary <- data %>%
  summarise(
    mean_age = mean(Age_at_scan, na.rm = TRUE),
    sd_age = sd(Age_at_scan, na.rm = TRUE))

print(age_summary)

# Count gender
gender_count <- data %>%
  count(Gender)

print(gender_count)
