#!/bin/bash

# Default values
EPOCHS=10
SAMPLES_TRAIN=30
SAMPLES_TEST=20

# Parse arguments
for arg in "$@"; do
    case $arg in
        --epochs=*)
            EPOCHS="${arg#*=}" # Extract value for epochs
            ;;
        --samples-train=*)
            SAMPLES_TRAIN="${arg#*=}" # Extract value for training samples
            ;;
        --samples-test=*)
            SAMPLES_TEST="${arg#*=}" # Extract value for test samples
            ;;
        *)
            echo "Unknown argument: $arg"
            exit 1
            ;;
    esac
done

# Step 1: Generate dataset with dynamic samples
python3 generate_dataset.py --samples-train $SAMPLES_TRAIN --samples-test $SAMPLES_TEST

# Step 2: Adjust Noir code with dynamic epochs and training samples
python3 adjust_noir_code.py --epochs $EPOCHS --samples-train $SAMPLES_TRAIN

# Step 3: Run Noir tests
cd noir_project
nargo test --show-output
