#!/bin/bash

# Default epochs
EPOCHS=10

# Parse optional --epochs argument
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --epochs) EPOCHS="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Step 1: Generate dataset
python3 generate_dataset.py

# Step 2: Adjust Noir code
python3 adjust_noir_code.py --epochs $EPOCHS

# Step 3: Run Noir tests
cd noir_project
nargo test --show-output
