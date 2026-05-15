# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2026-05-15

### Added
- **Project Automation (`Makefile`):** Introduced a `Makefile` to orchestrate the full pipeline (`data`, `analysis`, `visualize`) and provide a `clean` utility.
- **CLI Support (`optparse`):** Added command-line argument parsing to R scripts (`02b_netmoss_real_analysis.R`, `03_visualization_publication.R`), allowing for flexible input/output directory configuration.
- **Data Input Guide:** Created `docs/DATA_INPUT_GUIDE.md` to clarify the metagenomic pipeline context and input requirements.
- **Input Templates:** Added `data/templates/` containing example CSVs for abundance tables and adjacency matrices.
- **Utility Script:** Added `scripts/01b_abundance_to_network.R` to help users convert normalized abundance tables into the required adjacency matrices.

### Changed
- **Robustness:** Improved error handling in scripts with explicit dimension checks and descriptive file verification.
- **Documentation:** Updated `README.md` with instructions for using the new `Makefile` automation and a dedicated "Data Requirements" section.

## [1.1.0] - 2026-05-14

### Added
- **Dependency Management (`renv`):** Transitioned the project to use `renv` for reproducible package management.
- **Setup Script:** Added `scripts/00_setup_renv.R` to programmatically build the `renv.lock` file.

### Changed
- **Installation Workflow:** Updated `README.md` to use `renv::restore()` as the primary installation method.

## [1.0.1] - 2026-05-14

### Fixed
- **Namespace Conflict (`here` vs `plyr`):** Resolved the `Error in here(...) : unused argument` bug caused by `NetMoss2` dependencies (specifically `plyr`) masking the `here::here()` function.
- **Path Logic:** Updated all R scripts to use explicit namespacing (`here::here()`) for robust directory management.

**Technical Details:**
- **Error addressed:** `Error in here("results", "modules") : unused argument ("modules")`
- **Resolution:** Global search and replace of `here(` with `here::here(`.
- **Estimated Effort:** 15 minutes (Diagnosis + Implementation + Verification).
