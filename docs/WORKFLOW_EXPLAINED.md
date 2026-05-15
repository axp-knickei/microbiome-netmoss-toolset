# 📖 How the NetMoss Pipeline Works (A Simple Guide)

If you are new to coding or bioinformatics, looking at a list of scripts numbered 01 to 06 can be confusing. This guide explains what each script does and how they fit together using simple analogies.

---

## 📸 1. The "Snapshot" Workflow (Static Analysis)

**Goal:** Compare two different groups at a single point in time (e.g., Healthy vs. Sick patients).

Think of this like taking an **X-ray**. You want to see the static structure of the microbial network and identify what is broken or changed in the "Sick" group compared to the "Healthy" group.

| Step | Script | What it does (Analogy) | What it actually does |
| :--- | :--- | :--- | :--- |
| **Step 1** | `01_generate_mock_data` | **The Practice Patients:** Creates fake "Healthy" and "Sick" data so you can practice running the tools. | Generates adjacency matrices (networks) for static cohorts. |
| **Step 2** | `02_netmoss_analysis` | **The Diagnostic Test:** The brain of the operation. It compares the two groups to find the differences. | Integrates the networks and assigns microbes to "Moss" (conserved) or "Net" (changed) modules. |
| **Step 3** | `03_visualization` | **Printing the X-ray:** Creates the final picture you can put in a report. | Generates Heatmaps and Circular plots showing the network changes. |

---

## 🎬 2. The "Time-Lapse" Workflow (Longitudinal Analysis)

**Goal:** Track how microbial networks change *over time* in the same patients (e.g., Day 1 -> Day 5 -> Day 10).

Think of this like a **Side-by-Side Video**. You don't just want one comparison; you want to see if a microbe that was important on Day 1 is *still* important on Day 10.

To do this, the system needs to run the "Diagnostic Test" (Script 02) multiple times.

| Step | Script | What it does (Analogy) | What it actually does |
| :--- | :--- | :--- | :--- |
| **Step 1** | `05_generate_longitudinal` | **The Patient Diary:** Creates fake data tracking the same patients over 10 days. | Generates a raw longitudinal table (Timepoint, Subject, Feature, Value). |
| **Step 2** | `06_temporal_wrapper` | **The Auto-Pilot:** Instead of you manually running Script 02 twice (Day 1 vs 5, then Day 5 vs 10) and merging the results, this script does all the heavy lifting automatically. | Splits data by time, generates networks, calculates shift scores (NMSS), and formats them. |
| **Step 3** | `04_transition_plot` | **The Time-Lapse Video:** The final picture comparing the changes over time. | Generates a scatter plot categorizing microbes as "Early Drivers", "Late Drivers", or "Shared Drivers". |

---

## ❓ Frequently Asked Questions

**Q: Can I take the data from Script 05 (Longitudinal) and run it straight into Script 02 (Static Analysis)?**
*No. Script 05 creates a "Diary" (a list of values over time), but Script 02 needs "X-rays" (Static Networks). The Auto-Pilot (Script 06) is required to turn the Diary into X-rays before it runs the analysis.*

**Q: Why are there `.R` and `.py` versions of Script 05?**
*They do the exact same thing. R is standard for bioinformatics, but Python is provided as a backup in case R is not installed on your computer.*
