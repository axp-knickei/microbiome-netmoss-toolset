# Multi-Cohort Metagenomic Network Integration (NetMoss)

This repository contains an automated R pipeline to identify context-specific ("Net") and conserved ("Moss") microbial subnetworks across multiple cohorts.

## 🚀 Quickstart

**1. Install Dependencies**
Execute this one-liner in your R console:
```R
install.packages(c("here", "circlize", "pheatmap")); if(!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
```

**2. Execute the Pipeline (CLI)**
Run the scripts sequentially from your terminal in the project root:
```bash
Rscript scripts/01_generate_mock_data.R
Rscript scripts/02_netmoss_analysis.R
Rscript scripts/03_visualization_publication.R
```

## 📊 How to Interpret Results

*   **`netmoss_assignments.csv`:** Contains the mapping of each microbial feature to a distinct module. Features designated as `Moss_*` form the functional core consistent across all your cohorts, while `Net_*` represents cohort-specific network structures (e.g., disease-state rewiring).
*   **`circlize_moss_cohort1.pdf`:** A circular representation showing edge connectivity. High-density ribbon connections validate the topological strength of the Moss modules.
*   **`heatmap_net_shift.pdf`:** Visualizes the "on/off" switch effect of Net modules. Red indicates strong correlation (edges present) in one condition, contrasting with blue (edges absent) in another, confirming significant module rewiring due to biological conditions or batch effects.
