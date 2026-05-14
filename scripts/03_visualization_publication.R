#!/usr/bin/env Rscript
# Description: Generates publication-ready figures for Net/Moss transitions.
# Usage: Rscript scripts/03_visualization_publication.R --input_dir data --assignment_file results/modules/real_netmoss_assignments.csv --output_dir results/figures

suppressPackageStartupMessages({
  library(here)
  library(circlize)
  library(pheatmap)
  library(optparse)
})

# Define command-line arguments
option_list <- list(
  make_option(c("-i", "--input_dir"), type = "character", default = "data", 
              help = "Directory containing the input network CSVs [default %default]", metavar = "character"),
  make_option(c("-a", "--assignment_file"), type = "character", default = "results/modules/real_netmoss_assignments.csv", 
              help = "Path to the module assignment CSV [default %default]", metavar = "character"),
  make_option(c("-o", "--output_dir"), type = "character", default = "results/figures", 
              help = "Directory to save the figures [default %default]", metavar = "character")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

input_dir <- opt$input_dir
assignment_file <- opt$assignment_file
output_dir <- opt$output_dir

# Load assignments and data
message("Loading assignments from: ", here::here(assignment_file))
modules <- read.csv(here::here(assignment_file))

message("Loading networks from: ", here::here(input_dir))
net1 <- as.matrix(read.csv(here::here(input_dir, "Cohort1_network.csv"), row.names = 1))
net3 <- as.matrix(read.csv(here::here(input_dir, "Cohort3_network.csv"), row.names = 1))

dir.create(here::here(output_dir), showWarnings = FALSE, recursive = TRUE)

# 1. Circular Layout: Focus on Moss module interactions in Cohort 1
moss_mod_name <- "Moss_Mod_1"
if (!(moss_mod_name %in% modules$Assigned_Module)) {
  # If Moss_Mod_1 isn't there, pick the first Moss module available
  moss_mods <- unique(modules$Assigned_Module[grep("Moss", modules$Assigned_Module)])
  if (length(moss_mods) > 0) moss_mod_name <- moss_mods[1]
}

message("Generating Circlize Plot for: ", moss_mod_name)
pdf(here::here(output_dir, "circlize_moss_cohort1.pdf"), width = 8, height = 8)
moss_features <- modules$Feature[modules$Assigned_Module == moss_mod_name]
if (length(moss_features) > 20) moss_features <- moss_features[1:20]

subset_net <- net1[moss_features, moss_features]
subset_net[subset_net < 0.7] <- 0 # Thresholding for visual clarity
chordDiagram(subset_net, transparency = 0.5, annotationTrack = "grid", preAllocateTracks = 1)
title(paste0("Conserved Moss Subnetwork (", moss_mod_name, ")"))
dev.off()
message("Generated Circlize Plot.")

# 2. Heatmap: Edge consistency shift in Net_Mod_1
net_mod_name <- "Net_Mod_1"
if (!(net_mod_name %in% modules$Assigned_Module)) {
  net_mods <- unique(modules$Assigned_Module[grep("Net", modules$Assigned_Module)])
  if (length(net_mods) > 0) net_mod_name <- net_mods[1]
}

message("Generating Heatmap for: ", net_mod_name)
net_features <- modules$Feature[modules$Assigned_Module == net_mod_name]
if (length(net_features) > 15) net_features <- net_features[1:15]

edge_weights <- cbind(
  Cohort1 = as.vector(net1[net_features, net_features]),
  Cohort3 = as.vector(net3[net_features, net_features])
)

pdf(here::here(output_dir, "heatmap_net_shift.pdf"), width = 5, height = 7)
pheatmap(edge_weights, 
         cluster_cols = FALSE, 
         show_rownames = FALSE,
         color = colorRampPalette(c("navy", "white", "firebrick3"))(50),
         main = paste0("Edge Rewiring in ", net_mod_name, "\n(Cohort 1 vs 3)"))
dev.off()
message("Generated Heatmap.")
