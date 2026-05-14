#!/usr/bin/env Rscript
# Description: Initializes renv and installs all project dependencies to create a lockfile.
# Note: This script is intended for developers to set up the initial environment.
# Users should typically use renv::restore() after cloning the repository.

# 1. Configuration & Performance
options(timeout = 600) # Increase timeout for large bioinformatics packages
options(download.file.method = "libcurl")

# 2. Initialize renv
if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv")

# Initialize renv for the project if not already done
if (!file.exists("renv.lock")) {
  message("Initializing renv...")
  renv::init(bare = TRUE)
}

# 3. Install Core Infrastructure
message("Installing BiocManager and remotes...")
install.packages(c("BiocManager", "remotes"))

# 4. Install CRAN Packages
cran_packages <- c("here", "pheatmap", "circlize", "ggplot2", "igraph", "randomForest")
message("Installing CRAN packages...")
renv::install(cran_packages)

# 5. Install Bioconductor Packages
bioc_packages <- c("impute", "preprocessCore", "ComplexHeatmap", "decontam", "phyloseq")
message("Installing Bioconductor packages...")
renv::install(paste0("bioc::", bioc_packages))

# 6. Install GitHub Dependencies
github_packages <- c(
  "zdk123/SpiecEasi",
  "MPBA/r-sparcc",
  "xiaolw95/NetMoss2"
)
message("Installing GitHub packages...")
renv::install(github_packages)

# 7. Snapshot the environment
message("Creating renv.lock file...")
renv::snapshot(prompt = FALSE)

message("Setup complete! Dependency state is now captured in renv.lock.")
