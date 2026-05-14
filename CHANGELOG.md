# Changelog

All notable changes to this project will be documented in this file.

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
