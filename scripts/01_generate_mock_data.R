#!/usr/bin/env Rscript
# Description: Generates 3 mock metagenomic adjacency matrices with Net & Moss modules.
# Usage: Rscript scripts/01_generate_mock_data.R --n_features 100 --seed 42 --out_dir data

suppressPackageStartupMessages({
  library(here)
  library(optparse)
})

# Define command-line arguments
option_list <- list(
  make_option(c("-n", "--n_features"), type = "integer", default = 100, 
              help = "Number of features/taxa to simulate [default %default]", metavar = "number"),
  make_option(c("-s", "--seed"), type = "integer", default = 42, 
              help = "Random seed for reproducibility [default %default]", metavar = "number"),
  make_option(c("-o", "--out_dir"), type = "character", default = "data", 
              help = "Output directory for the mock CSVs [default %default]", metavar = "character")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# Set seed and parameters from arguments
set.seed(opt$seed)
n_features <- opt$n_features
out_dir <- opt$out_dir

# Calculate indices proportional to n_features
moss_end <- round(n_features * 0.4)
net1_start <- moss_end + 1
net1_end <- round(n_features * 0.7)
net2_start <- net1_end + 1
net2_end <- n_features

generate_adj <- function(cohort_name, net_state) {
  message(paste0("Generating network for: ", cohort_name))
  
  # Baseline biological noise
  adj <- matrix(runif(n_features^2, 0.0, 0.2), n_features, n_features)
  
  # "Moss" Module - Consistent across all cohorts (40% of features)
  adj[1:moss_end, 1:moss_end] <- runif(moss_end^2, 0.6, 0.9)
  
  # "Net" Modules - Condition specific (30% each)
  if (net_state == "State_A") {
    # Active in Cohorts 1 & 2
    n_net1 <- net1_end - net1_start + 1
    adj[net1_start:net1_end, net1_start:net1_end] <- runif(n_net1^2, 0.7, 0.95)
  } else if (net_state == "State_B") {
    # Active in Cohort 3
    n_net2 <- net2_end - net2_start + 1
    adj[net2_start:net2_end, net2_start:net2_end] <- runif(n_net2^2, 0.7, 0.95)
  }
  
  # Ensure symmetry for undirected graph
  adj[lower.tri(adj)] = t(adj)[lower.tri(adj)]
  diag(adj) <- 1
  
  colnames(adj) <- rownames(adj) <- paste0("Feature_", 1:n_features)
  
  out_path <- here::here(out_dir, paste0(cohort_name, "_network.csv"))
  write.csv(adj, out_path)
  message("Generated: ", out_path)
}

# Create output directories
dir.create(here::here(out_dir), showWarnings = FALSE, recursive = TRUE)

# Generate cohorts
generate_adj("Cohort1", "State_A")
generate_adj("Cohort2", "State_A")
generate_adj("Cohort3", "State_B")
