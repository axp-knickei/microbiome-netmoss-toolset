#!/usr/bin/env Rscript
# Description: Generates longitudinal mock data for transition dynamics analysis.
# Schema: Timepoint, Subject_ID, Feature, Value

set.seed(42)
library(dplyr)
library(tidyr)

n_subjects <- 10
n_timepoints <- 10
n_features <- 2000  # Scaled to reflect higher gut microbiome diversity

# Define Categories
shared_count <- floor(n_features * 0.10)
early_count  <- floor(n_features * 0.15)
late_count   <- floor(n_features * 0.15)
stable_count <- n_features - (shared_count + early_count + late_count)

# Create Feature list and assign categories
feature_list <- sprintf("Taxon_%04d", 1:n_features)
shuffled_features <- sample(feature_list)

shared_feats <- shuffled_features[1:shared_count]
early_feats  <- shuffled_features[(shared_count + 1):(shared_count + early_count)]
late_feats   <- shuffled_features[(shared_count + early_count + 1):(shared_count + early_count + late_count)]
stable_feats <- shuffled_features[(shared_count + early_count + late_count + 1):n_features]

# Create the full grid
df <- expand.grid(
  Subject_ID = sprintf("S%02d", 1:n_subjects),
  Timepoint = 1:n_timepoints,
  Feature = feature_list,
  stringsAsFactors = FALSE
)

# Apply dynamic logic based on category
message("Generating dynamics for 2,000 features...")
df <- df %>%
  mutate(
    Value = case_when(
      Feature %in% shared_feats ~ ifelse(Timepoint < 5, runif(n(), 0.1, 0.2), 
                                  ifelse(Timepoint < 8, runif(n(), 0.7, 0.9), runif(n(), 0.1, 0.3))),
      
      Feature %in% early_feats  ~ ifelse(Timepoint < 5, runif(n(), 0.1, 0.2), runif(n(), 0.7, 0.9)),
      
      Feature %in% late_feats   ~ ifelse(Timepoint < 8, runif(n(), 0.1, 0.3), runif(n(), 0.7, 0.9)),
      
      TRUE ~ ifelse(runif(n()) > 0.5, runif(n(), 0.4, 0.6), runif(n(), 0.0, 1.0)) # Stable/Noise
    )
  )

# Add Missing Values for robustness (approx 2%)
message("Adding random missingness...")
df$Value[sample(1:nrow(df), floor(nrow(df) * 0.02))] <- NA

# Save to CSV
dir.create("data", showWarnings = FALSE)
write.csv(df, "data/mock_longitudinal_transitions.csv", row.names = FALSE)

message("Success! R-generated mock data saved to: data/mock_longitudinal_transitions.csv")
message("Scale: ", n_subjects, " subjects, ", n_timepoints, " timepoints, ", n_features, " features.")
