#!/usr/bin/env Rscript
# Description: Integrates networks and delineates Moss (conserved) vs Net (variable) modules using NetMoss2.
# Usage: Rscript scripts/02_netmoss_analysis.R --input_dir data --output_dir results/modules --groups "Control,Control,Disease"

suppressPackageStartupMessages({
  library(here)
  library(NetMoss2)
  library(optparse)
})

# Define command-line arguments
option_list <- list(
  make_option(c("-i", "--input_dir"), type = "character", default = "data", 
              help = "Directory containing the input network CSVs [default %default]", metavar = "character"),
  make_option(c("-o", "--output_dir"), type = "character", default = "results/modules", 
              help = "Directory to save the assignment CSV [default %default]", metavar = "character"),
  make_option(c("-g", "--groups"), type = "character", default = "Control,Control,Disease", 
              help = "Comma-separated group labels for the cohorts [default %default]", metavar = "character")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

input_dir <- opt$input_dir
output_dir <- opt$output_dir
group_vector <- unlist(strsplit(opt$groups, ","))

# --- Error Handling: Verify Input Files ---
required_inputs <- here::here(input_dir, "Cohort1_network.csv")
if (!file.exists(required_inputs)) {
  stop(paste0("\n[Error]: Input data missing at ", required_inputs, 
              "\n -> Please run 01_generate_mock_data.R first or run 'make data'."))
}

message("Input directory: ", input_dir)
message("Output directory: ", output_dir)
message("Groups: ", paste(group_vector, collapse = ", "))

# Note: NetMoss2 typically takes abundance matrices as input to build networks, 
# or can work with pre-existing network objects.
# For this workflow, we assume the user provides abundance tables in the 'data' folder.

message("Loading data from: ", here::here(input_dir))
# In a real scenario, we would load files from input_dir
# Example: list.files(here::here(input_dir), pattern = "*.csv")

message("Initiating NetMoss2 Integration (Simulated)...")

# 2. CORE NETMOSS ANALYSIS
# The NetMoss function calculates scores to identify significant shifts.
# result <- NetMoss(networks, group_label = group_vector)

# ----------------------------------------------------------------------
# For the purpose of this pipeline demonstration, we will assume 
# 'result' contains the module assignments and NetMoss scores.
# ----------------------------------------------------------------------

# We need to determine the number of features from the input data.
# For this mock script, we'll try to detect it from an input file if it exists, 
# otherwise default to 100.
example_file <- list.files(here::here(input_dir), pattern = "Cohort1_network.csv", full.names = TRUE)
if (length(example_file) > 0) {
  temp_df <- read.csv(example_file[1], row.names = 1, nrows = 1)
  n_features <- ncol(temp_df)
} else {
  n_features <- 100
}

# Mocking the output format of NetMoss2
features <- paste0("Feature_", 1:n_features)
modules <- rep("Unassigned", length(features))

moss_end <- round(n_features * 0.4)
net1_end <- round(n_features * 0.7)

modules[1:moss_end] <- "Moss_Mod_1"
modules[(moss_end + 1):net1_end] <- "Net_Mod_1"
modules[(net1_end + 1):n_features] <- "Net_Mod_2"

results_df <- data.frame(Feature = features, Assigned_Module = modules)

dir.create(here::here(output_dir), showWarnings = FALSE, recursive = TRUE)
out_path <- here::here(output_dir, "netmoss_assignments.csv")
write.csv(results_df, out_path, row.names = FALSE)

message("NetMoss2 analysis complete. Assignments saved to: ", out_path)
