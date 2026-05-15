#!/usr/bin/env Rscript
# Description: Converts abundance tables into adjacency matrices (networks).
# Usage: Rscript scripts/01b_abundance_to_network.R --input data/templates/abundance_table_template.csv --output data/Cohort1_network.csv

suppressPackageStartupMessages({
  library(here)
  library(optparse)
})

# Define command-line arguments
option_list <- list(
  make_option(c("-i", "--input"), type = "character", default = NULL, 
              help = "Path to the input abundance CSV (Taxa in rows, Samples in columns) [required]", metavar = "file"),
  make_option(c("-o", "--output"), type = "character", default = NULL, 
              help = "Path to save the generated adjacency matrix CSV [required]", metavar = "file"),
  make_option(c("-m", "--method"), type = "character", default = "spearman", 
              help = "Correlation method (pearson, spearman, kendall) [default %default]", metavar = "string"),
  make_option(c("-t", "--threshold"), type = "double", default = 0, 
              help = "Correlation threshold (values below this will be set to 0) [default %default]", metavar = "number")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$input) || is.null(opt$output)) {
  print_help(opt_parser)
  stop("Input and Output paths must be provided.", call. = FALSE)
}

message("Loading abundance table from: ", opt$input)
# Read abundance table (Taxa as rows, Samples as columns)
abundance <- read.csv(opt$input, row.names = 1)

# NetMoss requires Taxa as both rows and columns in the adjacency matrix.
# We calculate correlation across samples.
message("Calculating ", opt$method, " correlation network...")

# Transpose abundance so taxa are columns for cor() function
adj_matrix <- cor(t(abundance), method = opt$method)

# Handle potential NA values
adj_matrix[is.na(adj_matrix)] <- 0

# Apply thresholding if specified
if (opt$threshold > 0) {
  message("Applying threshold: ", opt$threshold)
  adj_matrix[abs(adj_matrix) < opt$threshold] <- 0
}

# Ensure diagonal is 1
diag(adj_matrix) <- 1

message("Saving adjacency matrix to: ", opt$output)
write.csv(adj_matrix, opt$output)

message("Success! Network generated with ", nrow(adj_matrix), " features.")
