#!/usr/bin/env Rscript
# Description: Generates longitudinal mock data for transition dynamics analysis.
# Schema: Timepoint, Subject_ID, Feature, Value

set.seed(42)
library(dplyr)
library(tidyr)

n_subjects <- 10
n_timepoints <- 10
features <- c("Feature_A", "Feature_B", "Feature_C")

# Create a grid of all combinations
df <- expand.grid(
  Subject_ID = sprintf("S%02d", 1:n_subjects),
  Timepoint = 1:n_timepoints,
  Feature = features
)

# Generate values based on dynamics
df <- df %>%
  mutate(
    Value = case_when(
      # Feature_A: Shifting from low to high at T5 (mostly)
      Feature == "Feature_A" ~ ifelse(Timepoint < 5, 
                                      runif(n(), 0.1, 0.3), 
                                      runif(n(), 0.7, 0.9)),
      
      # Feature_B: Stable state
      Feature == "Feature_B" ~ runif(n(), 0.45, 0.55),
      
      # Feature_C: Random noise
      Feature == "Feature_C" ~ runif(n(), 0.0, 1.0)
    )
  )

# Add Edge Cases
# 1. Subject S08 is stable for Feature_A (no transition)
df$Value[df$Subject_ID == "S08" & df$Feature == "Feature_A"] <- runif(sum(df$Subject_ID == "S08" & df$Feature == "Feature_A"), 0.1, 0.3)

# 2. Add Missing Values (NAs)
# S05 is missing some T3 and T7
df$Value[df$Subject_ID == "S05" & df$Timepoint %in% c(3, 7)] <- NA

# 3. Add some random drops for robustness testing
drop_indices <- sample(1:nrow(df), 10)
df$Value[drop_indices] <- NA

# Save to CSV
dir.create("data", showWarnings = FALSE)
write.csv(df, "data/mock_longitudinal_transitions.csv", row.names = FALSE)

message("Mock longitudinal data generated: data/mock_longitudinal_transitions.csv")
message("Schema: ", paste(colnames(df), collapse = ", "))
message("Scale: ", n_subjects, " subjects, ", n_timepoints, " timepoints, ", length(features), " features.")
