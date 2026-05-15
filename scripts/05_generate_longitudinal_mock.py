import csv
import random
import os

# Set seed for reproducibility
random.seed(42)

n_subjects = 10
n_timepoints = 10
features = ["Feature_A", "Feature_B", "Feature_C"]

data = []

for feature in features:
    for subject in range(1, n_subjects + 1):
        subj_id = f"S{subject:02d}"
        
        # Determine dynamics for this subject/feature
        if feature == "Feature_A":
            # Transition from low (~0.2) to high (~0.8) at T5
            # Except for S08 who stays low
            if subj_id == "S08":
                base_values = [random.uniform(0.1, 0.3) for _ in range(n_timepoints)]
            else:
                base_values = [random.uniform(0.1, 0.3) for _ in range(4)] + \
                              [random.uniform(0.7, 0.9) for _ in range(6)]
        elif feature == "Feature_B":
            # Stable state around 0.5
            base_values = [random.uniform(0.45, 0.55) for _ in range(n_timepoints)]
        else:
            # Random noise 0-1
            base_values = [random.uniform(0.0, 1.0) for _ in range(n_timepoints)]
            
        for t in range(1, n_timepoints + 1):
            val = base_values[t-1]
            
            # Add missing values for S05 at T3 and T7
            if subj_id == "S05" and t in [3, 7]:
                val = "" # Representing NA in CSV
            
            # Add random drops (approx 3% of data)
            elif random.random() < 0.03:
                val = ""
                
            data.append({
                "Timepoint": t,
                "Subject_ID": subj_id,
                "Feature": feature,
                "Value": val
            })

# Ensure directory exists
os.makedirs("data", exist_ok=True)

# Save to CSV using csv module
output_path = "data/mock_longitudinal_transitions.csv"
with open(output_path, 'w', newline='') as csvfile:
    fieldnames = ["Timepoint", "Subject_ID", "Feature", "Value"]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

    writer.writeheader()
    for row in data:
        writer.writerow(row)

print(f"Mock longitudinal data generated: {output_path}")
print(f"Schema: {fieldnames}")
print(f"Scale: {n_subjects} subjects, {n_timepoints} timepoints, {len(features)} features.")
