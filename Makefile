# Makefile for NetMoss Microbial Network Integration Pipeline
# Usage: 
#   make all       - Run the entire pipeline
#   make clean     - Remove all generated data and results

.PHONY: all data analysis visualize clean

# Default target
all: visualize

# Step 1: Generate Mock Data
data: scripts/01_generate_mock_data.R
	@echo "Running Step 1: Mock Data Generation..."
	Rscript scripts/01_generate_mock_data.R

# Step 2: Perform Network Integration & Analysis
analysis: data scripts/02_netmoss_analysis.R
	@echo "Running Step 2: NetMoss Analysis..."
	Rscript scripts/02_netmoss_analysis.R

# Step 3: Generate Publication-Ready Visualizations
visualize: analysis scripts/03_visualization_publication.R
	@echo "Running Step 3: Visualization..."
	Rscript scripts/03_visualization_publication.R

# Clean up generated files
clean:
	@echo "Cleaning up data/ and results/ directories..."
	rm -rf data/*.csv
	rm -rf results/modules/*.csv
	rm -rf results/figures/*.pdf
