#!/usr/bin/env Rscript
# Description: Generates 3 mock metagenomic adjacency matrices with Net & Moss modules.

suppressPackageStartupMessages(library(here))

set.seed(42)
n_features <- 100

generate_adj <- function(cohort_name, net_state) {
  # Baseline biological noise
  adj <- matrix(runif(n_features^2, 0.0, 0.2), n_features, n_features)
  
  # "Moss" Module (Features 1-40) - Consistent across all cohorts
  adj[1:40, 1:40] <- runif(1600, 0.6, 0.9)
  
  # "Net" Modules - Condition specific
  if (net_state == "State_A") {
    # Active in Cohorts 1 & 2
    adj[41:70, 41:70] <- runif(900, 0.7, 0.95)
  } else if (net_state == "State_B") {
    # Active in Cohort 3
    adj[71:100, 71:100] <- runif(900, 0.7, 0.95)
  }
  
  # Ensure symmetry for undirected graph
  adj[lower.tri(adj)] = t(adj)[lower.tri(adj)]
  diag(adj) <- 1
  
  colnames(adj) <- rownames(adj) <- paste0("Feature_", 1:n_features)
  
  out_path <- here("data", paste0(cohort_name, "_network.csv"))
  write.csv(adj, out_path)
  message("Generated: ", out_path)
}

# Create output directories
dir.create(here("data"), showWarnings = FALSE, recursive = TRUE)

# Generate cohorts
generate_adj("Cohort1", "State_A")
generate_adj("Cohort2", "State_A")
generate_adj("Cohort3", "State_B")
