#!/usr/bin/env Rscript
# Description: Generates consecutive transition scatter plots for NetMoss scores (Fig C, D, E).
# Usage: Rscript scripts/04_transition_dynamics_plot.R --input results/modules/merged_temporal_netmoss.csv --output results/figures/

suppressPackageStartupMessages({
  library(ggplot2)
  library(ggrepel)
  library(dplyr)
  library(optparse)
  library(here)
})

# --- CLI Setup ---
option_list <- list(
  make_option(c("-i", "--input"), type = "character", default = NULL, 
              help = "Path to merged NetMoss scores across timepoints [required]", metavar = "file"),
  make_option(c("-o", "--output_dir"), type = "character", default = "results/figures", 
              help = "Directory to save the scatter plots [default %default]", metavar = "dir"),
  make_option(c("-t", "--threshold"), type = "numeric", default = 0.5, 
              help = "NMSS threshold for significance [default %default]", metavar = "numeric")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

if (is.null(opt$input)) {
  stop("Error: Please provide the input CSV containing merged temporal NetMoss scores.")
}

dir.create(here::here(opt$output_dir), showWarnings = FALSE, recursive = TRUE)

# --- Function to Generate Transition Plot ---
plot_transition_scatter <- function(data, x_col, y_col, threshold = 0.5) {
  
  # Categorize nodes based on their scores in consecutive transitions
  data <- data %>%
    mutate(
      Driver_Status = case_when(
        .data[[x_col]] > threshold & .data[[y_col]] > threshold ~ "Shared Driver",
        .data[[x_col]] > threshold & .data[[y_col]] <= threshold ~ "Early Driver Only",
        .data[[x_col]] <= threshold & .data[[y_col]] > threshold ~ "Late Driver Only",
        TRUE ~ "Non-Significant"
      )
    )
  
  # Set colors matching the reference figures
  # Grey (Non-Sig), Blue (Early), Red/Pink (Late), Green (Shared)
  status_colors <- c(
    "Non-Significant" = "#D3D3D3", 
    "Early Driver Only" = "#2E86C1", 
    "Late Driver Only" = "#E74C3C", 
    "Shared Driver" = "#82E0AA"
  )
  
  # Create layered ggplot
  p <- ggplot(data, aes(x = .data[[x_col]], y = .data[[y_col]], color = Driver_Status)) +
    # Layer 1: Plot background points first to avoid obscuring significant ones
    geom_point(data = filter(data, Driver_Status == "Non-Significant"), 
               alpha = 0.6, size = 2) +
    # Layer 2: Plot significant points on top
    geom_point(data = filter(data, Driver_Status != "Non-Significant"), 
               alpha = 0.9, size = 3) +
    # Layer 3: Text labels (only for Shared Drivers to prevent clutter)
    geom_text_repel(data = filter(data, Driver_Status == "Shared Driver"),
                    aes(label = Taxonomy),
                    size = 3,
                    box.padding = 0.5,
                    point.padding = 0.3,
                    max.overlaps = 20,
                    show.legend = FALSE) +
    scale_color_manual(values = status_colors) +
    theme_classic() +
    theme(
      legend.position = "none", # Legend removed to match reference aesthetic
      panel.border = element_rect(color = "black", fill = NA, size = 1),
      axis.title = element_text(face = "bold")
    ) +
    labs(
      x = x_col,
      y = y_col
    )
  
  return(p)
}

# --- Execution ---
message("Loading merged NetMoss temporal data...")
df <- read.csv(here::here(opt$input))

# Example Execution: Assuming the dataset has columns NMSS_T2_T5 and NMSS_T5_T8
if(all(c("NMSS_T2_T5", "NMSS_T5_T8") %in% colnames(df))) {
  message("Generating T2->T5 vs T5->T8 transition plot...")
  p1 <- plot_transition_scatter(df, "NMSS_T2_T5", "NMSS_T5_T8", opt$threshold)
  
  out_path <- here::here(opt$output_dir, "transition_T2_T5_T8.pdf")
  ggsave(out_path, plot = p1, width = 6, height = 6)
  message("Saved to: ", out_path)
} else {
  message("Warning: Expected columns NMSS_T2_T5 and NMSS_T5_T8 not found. Please check input column names.")
}