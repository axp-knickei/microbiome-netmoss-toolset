import csv
import random
import os

# Set seed for reproducibility
random.seed(42)

n_subjects = 10
n_timepoints = 10
n_features = 2000  # Scaled to reflect higher gut microbiome diversity

# Define Categories for Features
# 10% Shared, 15% Early, 15% Late, 60% Stable/Noise
shared_count = int(n_features * 0.10)
early_count = int(n_features * 0.15)
late_count = int(n_features * 0.15)
stable_count = n_features - (shared_count + early_count + late_count)

feature_list = [f"Taxon_{i:04d}" for i in range(1, n_features + 1)]
random.shuffle(feature_list)

categories = {}
categories['Shared'] = feature_list[:shared_count]
categories['Early'] = feature_list[shared_count:shared_count + early_count]
categories['Late'] = feature_list[shared_count + early_count:shared_count + early_count + late_count]
categories['Stable'] = feature_list[shared_count + early_count + late_count:]

data = []

for cat_name, taxons in categories.items():
    for taxon in taxons:
        for subject in range(1, n_subjects + 1):
            subj_id = f"S{subject:02d}"
            
            # Generate baseline values based on category
            if cat_name == 'Shared':
                # Big shift T1->T5 AND Big shift T5->T10
                base_values = [random.uniform(0.1, 0.2) for _ in range(4)] + \
                              [random.uniform(0.7, 0.9) for _ in range(3)] + \
                              [random.uniform(0.1, 0.3) for _ in range(3)]
            elif cat_name == 'Early':
                # Shift T1->T5, then stable
                base_values = [random.uniform(0.1, 0.2) for _ in range(4)] + \
                              [random.uniform(0.7, 0.9) for _ in range(6)]
            elif cat_name == 'Late':
                # Stable T1->T5, then shift T5->T10
                base_values = [random.uniform(0.1, 0.3) for _ in range(7)] + \
                              [random.uniform(0.7, 0.9) for _ in range(3)]
            else:
                # Stable or random noise
                if random.random() > 0.5:
                    base_values = [random.uniform(0.4, 0.6) for _ in range(n_timepoints)]
                else:
                    base_values = [random.uniform(0.0, 1.0) for _ in range(n_timepoints)]
            
            for t in range(1, n_timepoints + 1):
                val = base_values[t-1]
                
                # Add missingness for robustness
                if random.random() < 0.02:
                    val = ""
                
                data.append({
                    "Timepoint": t,
                    "Subject_ID": subj_id,
                    "Feature": taxon,
                    "Value": val
                })

# Save to CSV
os.makedirs("data", exist_ok=True)
output_path = "data/mock_longitudinal_transitions.csv"
with open(output_path, 'w', newline='') as csvfile:
    fieldnames = ["Timepoint", "Subject_ID", "Feature", "Value"]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    for row in data:
        writer.writerow(row)

print(f"High-scale mock data generated: {output_path}")
print(f"Total features: {n_features} ({shared_count} Shared, {early_count} Early, {late_count} Late)")
