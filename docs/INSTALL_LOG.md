# Installation Log: NetMoss2 & Dependencies

**Date:** May 14, 2026  
**Environment:** 
- **OS:** Windows 11 with WSL2 (Ubuntu)
- **R Version:** 4.6.0 (2026-04-24 ucrt) -- "Because it was There"
- **Platform:** x86_64-w64-mingw32/x64 (Windows-based R accessing WSL filesystem)

## Executive Summary
The installation of the microbiome network integration tool NetMoss2 was performed. Due to its complex dependency tree (100+ packages), several hurdles including repository 404s, case-sensitivity issues, Bioconductor requirements, and hidden GitHub dependencies were resolved.

## Troubleshooting Steps & Solutions

### 1. Connection & Timeout Issues
**Problem:** Large bioinformatics packages timed out during download (default 60s), and the deprecated `wininet` method caused connectivity errors.

**Solution:**
```R
options(timeout = 300) # Increase to 5 minutes
options(download.file.method = "libcurl") # Use modern library for downloads
```

### 2. Missing Bioconductor Dependencies
**Problem:** Packages like `impute`, `preprocessCore`, `ComplexHeatmap`, and `phyloseq` are not on CRAN.

**Solution:**
```R
if (!require("BiocManager", quietly = TRUE)) install.packages("BiocManager")
# Note: Case sensitivity matters (e.g., 'ComplexHeatmap' not 'complexheatmap')
BiocManager::install(c("impute", "preprocessCore", "ComplexHeatmap", "decontam", "phyloseq"))
```

### 3. Hidden/Renamed GitHub Dependencies
**Problem:** `NetMoss2` requires `rsparcc` and `SpiecEasi`. Standard remotes calls failed because the repository for `rsparcc` is named `r-sparcc` under the MPBA handle. Compilation required Rtools (C++ compiler).

**Solution:**
```R
# Install SpiecEasi (Verification of C++ compiler/Rtools)
remotes::install_github("zdk123/SpiecEasi")

# Install the correct SparCC implementation
remotes::install_github("MPBA/r-sparcc")
```

### 4. Main Tool Installation
**Problem:** Incorrect GitHub handle (`zyf0717`) was initially used.

**Solution:** Use the author's updated repository handle.
```R
remotes::install_github("xiaolw95/NetMoss2", upgrade = "never")
```

## Final Verification
Successfully loaded the library on 2026-05-14 with the following output: `WeightedROC`, `WGCNA`, `pROC`, `igraph`, `randomForest` all loaded.

**Note on Function Masking (The "Unused Argument" Error):**  
`plyr::here` masks `here::here`. If you see `Error in here(...) : unused argument`, it is because R is trying to use the `plyr` version of the function. 

**Fix:** Always use `here::here()` for explicit path management in this project. All scripts have been updated to use this syntax.

```R
library(NetMoss2)
# Output: Success (No errors)
```

## Key Configuration Lessons
- **Case Sensitivity:** R and GitHub are case-sensitive. Always verify `PackageName` vs `packagename`.
- **Repository Locations:** Bioconductor and GitHub are the primary sources for this toolset, not CRAN.
- **WSL Pathing:** When running Windows R on WSL filesystems (`//wsl.localhost/...`), ensure the Windows R instance has all packages installed locally in `win-library`.
