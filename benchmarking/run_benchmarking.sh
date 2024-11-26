#!/bin/bash

# Step 1: Generate dataset
python3 generate_dataset.py

# Step 2: Adjust Noir code
python3 adjust_noir_code.py

# Step 3: Run Noir tests
cd noir_project
nargo test --show-output
