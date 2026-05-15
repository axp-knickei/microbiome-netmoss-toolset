# NetMoss Data Input Guide

This document clarifies the data requirements, formats, and the position of the NetMoss toolset within a standard metagenomic analysis pipeline.

## 1. Metagenomic Pipeline Context

The NetMoss analysis is **not** a primary analysis tool for raw sequence data (FastQ). It is a **downstream integration and network analysis tool**. 

In a typical metagenomic workflow, NetMoss fits into the following sequence:

1.  **Preprocessing:** Quality control (e.g., FastP) and host depletion.
2.  **Taxonomic Profiling:** Mapping reads to a database to quantify microbial abundance (e.g., **Kraken2/Bracken**, **MetaPhlAn**, or **QIIME2**).
3.  **Abundance Quantification:** Generation of a Feature/OTU/ASV table (Taxa vs. Samples).
4.  **Normalization:** Correcting for sequencing depth (e.g., **CLR transformation**, **CSS normalization**, or **Rarefaction**).
5.  **Network Inference:** Calculating associations between taxa to create an adjacency matrix (e.g., **SparCC**, **SPIEC-EASI**, or **Pearson/Spearman correlation**).
6.  **NetMoss Analysis (This Tool):** Integrating these networks across cohorts to identify "Moss" (conserved) and "Net" (variable) modules.

---

## 2. Input Data Requirements

### Primary Input: Adjacency Matrices (Networks)
The core scripts in this repository (`02_netmoss_analysis.R` and `02b_netmoss_real_analysis.R`) expect **Adjacency Matrices** as input.

| Property | Requirement |
| :--- | :--- |
| **Format** | CSV (.csv) |
| **Structure** | Square Matrix (N x N) where N is the number of features/taxa. |
| **Identifiers** | Row names must exactly match Column names (Feature IDs). |
| **Values** | Association strength (typically between 0 and 1, or -1 and 1). |
| **Consistency** | All cohort matrices must have the **exact same dimensions and feature sets**. |

### Recommended: Abundance Tables
If you are starting from abundance tables, you must first convert them into adjacency matrices. We provide a utility script `scripts/01b_abundance_to_network.R` for this purpose.

| Property | Requirement |
| :--- | :--- |
| **Format** | CSV (.csv) |
| **Structure** | Taxa (Rows) x Samples (Columns). |
| **Normalization** | Data should be normalized (e.g., CLR) prior to network inference to account for compositionality. |

---

## 3. Data Templates

Templates are provided in the `data/templates/` directory:

-   `abundance_table_template.csv`: Example of a normalized abundance table.
-   `adjacency_matrix_template.csv`: Example of the square matrix required by NetMoss scripts.

## 4. Pre-analysis Checklist

Before running the analysis, ensure:
1.  **Feature Alignment:** All cohorts have the same taxa names in the same order.
2.  **Symmetry:** Your adjacency matrices are symmetric (undirected networks).
3.  **Missing Values:** There are no `NA` or `Inf` values in your matrices.
4.  **Diagonal:** The diagonal of your adjacency matrices should ideally be 1 (self-correlation).
