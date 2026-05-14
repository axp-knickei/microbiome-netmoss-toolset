# Installation Guide

Setting up `NetMoss2` and its dependencies can be complex due to the large number of bioinformatics packages required. This guide provides a streamlined path based on successfully resolved installation hurdles.

## Prerequisites
- **R (>= 4.0.0)**
- **Rtools** (for Windows users to compile C++ dependencies)
- **libcurl** (recommended for stable downloads)

## 1. Configure R Environment
Increase timeouts for large package downloads:
```R
options(timeout = 300)
options(download.file.method = "libcurl")
```

## 2. Install Bioconductor Dependencies
Many core dependencies are hosted on Bioconductor rather than CRAN:
```R
if (!require("BiocManager", quietly = TRUE)) install.packages("BiocManager")
BiocManager::install(c("impute", "preprocessCore", "ComplexHeatmap", "decontam", "phyloseq"))
```

## 3. Install GitHub Dependencies
Install network-specific tools and the correct SparCC implementation:
```R
if (!require("remotes", quietly = TRUE)) install.packages("remotes")

# Constructing dependencies
remotes::install_github("zdk123/SpiecEasi")
remotes::install_github("MPBA/r-sparcc")

# Install NetMoss2 from the latest official handle
remotes::install_github("xiaolw95/NetMoss2", upgrade = "never")
```

## 4. Troubleshooting
For a detailed log of solved issues (including WSL2 pathing and case-sensitivity notes), please refer to the [Installation Log](INSTALL_LOG.md).
