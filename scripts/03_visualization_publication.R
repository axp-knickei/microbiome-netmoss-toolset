#!/usr/bin/env Rscript
# Description: Generates publication-ready figures for Net/Moss transitions.

suppressPackageStartupMessages({
  library(here)
  library(circlize)
  library(pheatmap)
})

# Load assignments and data
modules <- read.csv(here("results", "modules", "netmoss_assignments.csv"))
net1 <- as.matrix(read.csv(here("data", "Cohort1_network.csv"), row.names = 1))
net3 <- as.matrix(read.csv(here("data", "Cohort3_network.csv"), row.names = 1))

dir.create(here("results", "figures"), showWarnings = FALSE, recursive = TRUE)

# 1. Circular Layout: Focus on Moss module interactions in Cohort 1
pdf(here("results", "figures", "circlize_moss_cohort1.pdf"), width = 8, height = 8)
moss_features <- modules$Feature[modules$Assigned_Module == "Moss_Mod_1"][1:20]
subset_net <- net1[moss_features, moss_features]
subset_net[subset_net < 0.7] <- 0 # Thresholding for visual clarity
chordDiagram(subset_net, transparency = 0.5, annotationTrack = "grid", preAllocateTracks = 1)
title("Conserved Moss Subnetwork (Cohort 1)")
dev.off()
message("Generated Circlize Plot.")

# 2. Heatmap: Edge consistency shift in Net_Mod_1 (Active C1/C2 vs Inactive C3)
net_features <- modules$Feature[modules$Assigned_Module == "Net_Mod_1"][1:15]

edge_weights <- cbind(
  Cohort1 = as.vector(net1[net_features, net_features]),
  Cohort3 = as.vector(net3[net_features, net_features])
)

pdf(here("results", "figures", "heatmap_net_shift.pdf"), width = 5, height = 7)
pheatmap(edge_weights, 
         cluster_cols = FALSE, 
         show_rownames = FALSE,
         color = colorRampPalette(c("navy", "white", "firebrick3"))(50),
         main = "Edge Rewiring in Net_Mod_1\n(Cohort 1 vs 3)")
dev.off()
message("Generated Heatmap.")
