# Changelog

All notable changes to this project will be documented in this file.

## [1.0.1] - 2026-05-14

### Fixed
- **Namespace Conflict (`here` vs `plyr`):** Resolved the `Error in here(...) : unused argument` bug caused by `NetMoss2` dependencies (specifically `plyr`) masking the `here::here()` function.
- **Path Logic:** Updated all R scripts to use explicit namespacing (`here::here()`) for robust directory management.

**Technical Details:**
- **Error addressed:** `Error in here("results", "modules") : unused argument ("modules")`
- **Resolution:** Global search and replace of `here(` with `here::here(`.
- **Estimated Effort:** 15 minutes (Diagnosis + Implementation + Verification).
