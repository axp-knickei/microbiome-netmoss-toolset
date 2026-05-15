#!/usr/bin/env Rscript
# Description: Real-data wrapper for longitudinal NetMoss analysis to Transition Dynamics plots.
# Workflow: Longitudinal CSV -> SparCC/Network Inference -> NetMoss2 Analysis -> Transition Plot

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(here)
  library(optparse)
  # IMPORTANT: For real data, ensure these are installed and loaded
  # library(NetMoss2)
  # library(SpiecEasi) 
})

# --- CLI Setup ---
option_list <- list(
  make_option(c("-i", "--input"), type = "character", default = NULL, 
              help = "Path to real longitudinal data CSV [required]", metavar = "file"),
  make_option(c("-o", "--output_dir"), type = "character", default = "results/temporal_real", 
              help = "Directory for results [default %default]", metavar = "dir"),
  make_option(c("--t1"), type = "character", default = "1", 
              help = "Label for Timepoint 1 in your data [default %default]", metavar = "string"),
  make_option(c("--t2"), type = "character", default = "5", 
              help = "Label for Timepoint 2 in your data [default %default]", metavar = "string"),
  make_option(c("--t3"), type = "character", default = "10", 
              help = "Label for Timepoint 3 in your data [default %default]", metavar = "string"),
  make_option(c("-t", "--threshold"), type = "numeric", default = 0.5, 
              help = "NMSS threshold for plotting [default %default]", metavar = "numeric")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$input)) {
  stop("Error: Please provide the input CSV containing your longitudinal data.")
}

dir.create(here::here(opt$output_dir), showWarnings = FALSE, recursive = TRUE)

message("--- Real Temporal NetMoss Workflow ---")
message(sprintf("Analyzing Transitions: [%s] -> [%s] and [%s] -> [%s]", opt$t1, opt$t2, opt$t2, opt$t3))

# 1. Load Data
message("\nStep 1: Loading longitudinal data...")
long_df <- read.csv(here::here(opt$input))

# Validate timepoints exist
available_tps <- unique(long_df$Timepoint)
for (tp in c(opt$t1, opt$t2, opt$t3)) {
  if (!(as.character(tp) %in% as.character(available_tps))) {
    stop(sprintf("Error: Timepoint '%s' not found in data. Available timepoints: %s", 
                 tp, paste(available_tps, collapse=", ")))
  }
}

# 2. Network Generation Placeholder (Needs Robust Inference)
generate_real_network <- function(data, tp_label) {
  message(sprintf("  Building network for Timepoint: %s", tp_label))
  
  # Filter and Pivot
  tp_data <- data %>% 
    filter(as.character(Timepoint) == as.character(tp_label)) %>%
    select(Subject_ID, Feature, Value) %>%
    pivot_wider(names_from = Subject_ID, values_from = Value, values_fill = 0) %>% 
    as.data.frame()
  
  rownames(tp_data) <- tp_data$Feature
  tp_data$Feature <- NULL
  
  # --- PLACEHOLDER: ROBUST NETWORK INFERENCE ---
  # Replace basic correlation with SparCC or SPIEC-EASI for publication quality.
  # adj <- SparCC::sparcc(t(tp_data))
  
  message("  [WARNING]: Using basic Spearman correlation. Replace with SparCC for real microbiome data.")
  adj <- cor(t(tp_data), method = "spearman", use = "pairwise.complete.obs")
  adj[is.na(adj)] <- 0
  diag(adj) <- 1
  return(adj)
}

adj_t1 <- generate_real_network(long_df, opt$t1)
adj_t2 <- generate_real_network(long_df, opt$t2)
adj_t3 <- generate_real_network(long_df, opt$t3)

# 3. Feature Alignment
# Ensure all matrices have the exact same dimensions and feature sets (Taxa)
all_features <- sort(unique(c(rownames(adj_t1), rownames(adj_t2), rownames(adj_t3))))

align_matrix <- function(mat, all_feats) {
  new_mat <- matrix(0, nrow=length(all_feats), ncol=length(all_feats))
  rownames(new_mat) <- colnames(new_mat) <- all_feats
  
  common <- intersect(rownames(mat), all_feats)
  new_mat[common, common] <- mat[common, common]
  diag(new_mat) <- 1
  return(new_mat)
}

message("\nStep 2: Aligning feature matrices across timepoints...")
adj_t1 <- align_matrix(adj_t1, all_features)
adj_t2 <- align_matrix(adj_t2, all_features)
adj_t3 <- align_matrix(adj_t3, all_features)

# 4. NetMoss2 Analysis Placeholder
run_real_netmoss <- function(mat_early, mat_late) {
  # --- PLACEHOLDER: ACTUAL NETMOSS2 INTEGRATION ---
  # mod_results <- NetMoss2::divModule(case_union = mat_late, control_union = mat_early, ...)
  # nodes_result <- NetMoss2::NetzGo(control_mat = mat_early, case_mat = mat_late, ...)
  # return(nodes_result$NetMoss_Score)
  
  message("  [WARNING]: NetMoss2 not called. Using simulated Shift Score calculation.")
  nmss <- abs(rowMeans(mat_early) - rowMeans(mat_late))
  if(max(nmss) != min(nmss)) nmss <- (nmss - min(nmss)) / (max(nmss) - min(nmss))
  return(nmss)
}

message(sprintf("\nStep 3: Calculating NetMoss Shift Scores (NMSS)..."))
message(sprintf("  Transition 1: %s -> %s", opt$t1, opt$t2))
nmss_trans1 <- run_real_netmoss(adj_t1, adj_t2)

message(sprintf("  Transition 2: %s -> %s", opt$t2, opt$t3))
nmss_trans2 <- run_real_netmoss(adj_t2, adj_t3)

# 5. Merging Results
message("\nStep 4: Formatting data for the Transition Plot...")
final_df <- data.frame(
  Taxonomy = all_features,
  NMSS_T2_T5 = nmss_trans1, 
  NMSS_T5_T8 = nmss_trans2  
)

merged_path <- here::here(opt$output_dir, "real_merged_temporal_netmoss.csv")
write.csv(final_df, merged_path, row.names = FALSE)
message("Saved results to: ", merged_path)

# 6. Execute Plotting
message("\nStep 5: Executing Plotting Script...")
cmd <- paste0("Rscript scripts/04_transition_dynamics_plot.R ",
              "--input ", merged_path, " ",
              "--output_dir ", opt$output_dir, " ",
              "--threshold ", opt$threshold)

message("Command: ", cmd)
# system(cmd) 

message("\nWorkflow Setup Complete!")
message("--- Instructions ---")
message("1. Replace Step 2 with your network inference tool (e.g., SparCC).")
message("2. Replace Step 3 with actual NetMoss2 package calls.")
message("3. Run the command printed above to generate your plot.")
