#!/bin/bash

# Default values
EPOCHS=10
SAMPLES_TRAIN=30
SAMPLES_TEST=20
DATASET_NAME="iris"
LEARNING_RATE=0.1

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
        --dataset=*)
            DATASET_NAME="${arg#*=}" # Extract value for dataset name
            ;;
        --learning-rate=*)
            LEARNING_RATE="${arg#*=}" # Extract value for learning rate
            ;;
        *)
            echo "Unknown argument: $arg"
            exit 1
            ;;
    esac
done

# Step 1: Generate dataset with dynamic samples
python3 helpers/generate_dataset.py --dataset "$DATASET_NAME" --samples-train "$SAMPLES_TRAIN" --samples-test "$SAMPLES_TEST"

# Step 2: Load metadata
METADATA_FILE="./datasets/metadata.json"
if [ ! -f "$METADATA_FILE" ]; then
    echo "Metadata file not found!"
    exit 1
fi

FEATURES=$(jq .features $METADATA_FILE)
CLASSES=$(jq .classes $METADATA_FILE)

# Step 3: Adjust Noir code with dynamic epochs, training samples, and learning rate
python3 helpers/write_noir_test.py --epochs "$EPOCHS" --samples-train "$SAMPLES_TRAIN" --learning-rate "$LEARNING_RATE"

# Step 4: Run Noir tests
if cd noir_project; then
    # Ensure we are in the correct directory
    nargo test test_train --show-output > ../noir_output.txt 2>&1
    cd .. # Return to the parent directory
else
    echo "The folder 'noir_project' does not exist or could not be accessed!"
    exit 1
fi

# Step 5: Parse Noir output
python3 helpers/parse_noir_output.py --output-file noir_output.txt --quantized-file quantized.txt --features "$FEATURES" --classes "$CLASSES"

# Step 6: Compute accuracy
python3 helpers/compute_accuracy.py --quantized-file quantized.txt --test-data ./datasets/test_data.csv --classes "$CLASSES" --features "$FEATURES" --samples "$SAMPLES_TEST"
