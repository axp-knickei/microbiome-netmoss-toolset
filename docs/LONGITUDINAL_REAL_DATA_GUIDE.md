# 🕒 Real Longitudinal Data Analysis Guide

This guide explains how to use your real-world longitudinal data with the NetMoss toolset to identify microbial drivers over time.

---

## 1. Data Preparation

Your input file must be a **Longitudinal Table** in CSV format. Unlike the static cohort analysis which uses square matrices, this workflow starts with raw abundance values.

### Required CSV Schema:
| Column | Description | Example |
| :--- | :--- | :--- |
| **Timepoint** | The specific visit or time period. | `Day_0`, `Week_2`, `Month_6` |
| **Subject_ID** | Unique identifier for each patient/sample. | `Patient_001` |
| **Feature** | The name of the microbe or OTU. | `Bacteroides_fragilis` |
| **Value** | The abundance (should be normalized). | `0.045` |

> **Pro Tip:** Ensure your feature names are consistent across all timepoints. If "Taxon A" is spelled "Taxon_A" in one timepoint, the alignment logic will treat them as two different microbes.

---

## 2. Customizing the Wrapper (Script 06b)

The script `scripts/06b_real_temporal_workflow_wrapper.R` is a template. To produce publication-quality results, you must replace the "placeholders" with real algorithms.

### A. Implementing SparCC (Step 2 in script)
Microbiome data is "compositional." Simple correlation can be misleading. Replace the basic `cor()` call in the script with **SparCC**:

```R
# Inside generate_real_network()
# Replace basic correlation with:
library(SpiecEasi)
sparcc_out <- sparcc(t(tp_data))
adj <- as.matrix(sparcc_out$cor)
```

### B. Implementing NetMoss2 (Step 3 in script)
Replace the simulated shift calculation with the actual **NetMoss2** package logic:

```R
# Inside run_real_netmoss()
# Replace the math with:
library(NetMoss2)
# 1. Detect modules
mod_results <- divModule(case_union = mat_late, control_union = mat_early)
# 2. Calculate Shift Scores
nodes_result <- NetzGo(
  control_mat = mat_early, 
  case_mat = mat_late, 
  control_dist = mod_results[[2]], 
  case_dist = mod_results[[1]], 
  control_mod = as.numeric(mod_results[[4]]), 
  case_mod = as.numeric(mod_results[[3]])
)
return(nodes_result$NetMoss_Score)
```

---

## 3. Running the Analysis

Once your data is ready and the script is customized, run it from your terminal using your specific timepoint labels:

```bash
Rscript scripts/06b_real_temporal_workflow_wrapper.R \
  --input data/your_real_data.csv \
  --t1 "Baseline" \
  --t2 "Post_Treatment" \
  --t3 "Follow_Up" \
  --output_dir results/longitudinal_study \
  --threshold 0.6
```

### Parameters:
*   `--t1, --t2, --t3`: The exact names used in your "Timepoint" column.
*   `--threshold`: The score above which a microbe is considered a "Driver" (usually 0.5 to 0.7).

---

## 4. Interpreting the Transition Plot

The script will produce a file named `transition_T2_T5_T8.pdf` (Note: the filename uses internal placeholders, but the data represents your T1, T2, and T3).

*   **Shared Drivers (Green):** Microbes that changed significantly in *both* the first and second transitions. These are your most consistent biomarkers.
*   **Early Drivers (Blue):** Microbes that were influential during the first transition (e.g., immediate response to treatment) but stabilized later.
*   **Late Drivers (Red):** Microbes that only showed significant network shifts in the final stage of the study.

---

## ⚠️ Common Pitfalls

1.  **Low Sample Size:** Network inference (SparCC) requires a sufficient number of subjects at *each* timepoint. Aim for at least 20 subjects per timepoint for stable results.
2.  **Normalization:** Ensure your data is normalized (e.g., CLR or TSS) *before* running the script.
3.  **Memory:** Running NetMoss2 on 1000+ features can be memory-intensive. Consider filtering rare taxa (e.g., keeping only those present in >10% of samples) before analysis.
