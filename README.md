# Multi-Cohort Metagenomic Network Integration (NetMoss)

This repository contains an automated R pipeline to identify context-specific ("Net") and conserved ("Moss") microbial subnetworks across multiple cohorts.

**New to NetMoss?** Check out our [Beginner's Guide to NetMoss Concepts](docs/CONCEPTS.md) to understand the "What", "Why", and "How" of this project.

**Confused by the scripts?** Read our simple, non-technical guide: [How the Pipeline Works (A Simple Guide)](docs/WORKFLOW_EXPLAINED.md).

## 📊 Data Requirements

Before running the analysis on your own data, please review the **[NetMoss Data Input Guide](docs/DATA_INPUT_GUIDE.md)**. 

### Key Information for Users:
- **Input Type:** This toolset expects **Adjacency Matrices** (square matrices representing microbial networks) as the primary input.
- **Upstream Pipeline:** This analysis typically occurs after taxonomic profiling (e.g., Bracken, MetaPhlAn) and network inference (e.g., SparCC, SPIEC-EASI).
- **Templates:** See `data/templates/` for example CSV structures for both abundance tables and adjacency matrices.

### Utility: Converting Abundance to Network
If you only have an abundance table (Taxa by Samples), use our utility script to generate the required adjacency matrices:
```bash
Rscript scripts/01b_abundance_to_network.R \
  --input path/to/your/abundance.csv \
  --output data/Cohort1_network.csv \
  --method spearman
```

## 🕒 Temporal & Transition Analysis

If you have longitudinal data (multiple timepoints per subject), you can identify "Driver" microbes that shift their importance over time.

### Automated Temporal Workflow:
Run the wrapper to go from raw longitudinal data to transition plots:
```bash
# 1. Generate longitudinal mock data
python3 scripts/05_generate_longitudinal_mock.py

# 2. Run the temporal wrapper (Infers networks -> Calculates NMSS -> Plots)
Rscript scripts/06_temporal_workflow_wrapper.R
```

### Visualizing Dynamics:
The final output (`transition_T2_T5_T8.pdf`) categorizes taxa into:
- **Shared Drivers:** Consistently important across all transitions.
- **Early Drivers:** Important initially, then lose influence.
- **Late Drivers:** Gain importance in later timepoints.

## 🚀 Quickstart

**1. Install Dependencies**
This project uses `renv` to manage R dependencies. This ensures that everyone uses the exact same versions of the 100+ required packages.

To set up your environment:
1. Open this project in RStudio (or your R terminal).
2. Install `renv` if you don't have it: `install.packages("renv")`
3. Restore the environment:
   ```R
   renv::restore()
   ```
   *This will automatically download and install all necessary CRAN, Bioconductor, and GitHub packages.*

For a detailed troubleshooting log or advanced setup instructions, see [docs/INSTALLATION.md](docs/INSTALLATION.md).

**2. Execute the Pipeline (Automation)**
For convenience, a `Makefile` is provided to run the entire pipeline or specific steps with single commands:
```bash
make all        # Run full pipeline (Data -> Analysis -> Visualize)
make data       # Step 1: Generate Mock Data
make analysis   # Step 2: Run NetMoss Analysis
make visualize  # Step 3: Generate Figures
make clean      # Reset the project (deletes generated files)
```

**3. Custom Execution (CLI)**
Alternatively, you can run scripts manually and customize parameters via flags:
```bash
# 1. Generate Data (Custom features and seed)
Rscript scripts/01_generate_mock_data.R --n_features 150 --seed 123 --out_dir data

# 2. Fast Demo Analysis (Specify input/output and groups)
Rscript scripts/02_netmoss_analysis.R --input_dir data --output_dir results/modules --groups "Control,Control,Disease"

# 2b. Real NetMoss Analysis
Rscript scripts/02b_netmoss_real_analysis.R --input_dir data --output_dir results/modules

# 3. Visualization
Rscript scripts/03_visualization_publication.R --input_dir data --assignment_file results/modules/real_netmoss_assignments.csv --output_dir results/figures
```

## ✅ Verification

To ensure your installation is correct and all dependencies are working, run the provided demonstration pipeline. 

Run the entire pipeline automatically:
```bash
make all
```

Or run manually:
```bash
Rscript scripts/01_generate_mock_data.R
Rscript scripts/02b_netmoss_real_analysis.R
Rscript scripts/03_visualization_publication.R
```

**Expected Outputs:**
- **`data/*.csv`**: Three mock network files.
- **`results/modules/real_netmoss_assignments.csv`**: Real feature mapping from NetMoss2.
- **`results/figures/circlize_moss_cohort1.pdf`**: Circular connectivity plot.
- **`results/figures/heatmap_net_shift.pdf`**: Heatmap showing module rewiring.

If these files are generated without errors, your `NetMoss2` environment is fully configured.

## 📊 How to Interpret Results

*   **`real_netmoss_assignments.csv`:** Contains the mapping of each microbial feature to a distinct module using the actual NetMoss2 algorithm. Features designated as `Moss_*` form the functional core consistent across all your cohorts, while `Net_*` represents cohort-specific network structures (e.g., disease-state rewiring).
*   **`circlize_moss_cohort1.pdf`:** A circular representation showing edge connectivity. High-density ribbon connections validate the topological strength of the Moss modules.
*   **`heatmap_net_shift.pdf`:** Visualizes the "on/off" switch effect of Net modules. Red indicates strong correlation (edges present) in one condition, contrasting with blue (edges absent) in another, confirming significant module rewiring due to biological conditions or batch effects.
