#!/bin/bash

# Default values
EPOCHS=10
SAMPLES_TRAIN=30
SAMPLES_TEST=20
DATASET_NAME="iris"
LEARNING_RATE=0.1
PROJECT_DIR="./conoir_project"

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
            DATASET_NAME="${arg#*=}" # Extract value for dataset
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
echo "Generating dataset..."
python3 helpers/generate_dataset.py --dataset "$DATASET_NAME" --samples-train "$SAMPLES_TRAIN" --samples-test "$SAMPLES_TEST"
if [ $? -ne 0 ]; then
    echo "Error: Dataset generation failed."
    exit 1
fi

# Step 2: Load metadata
METADATA_FILE="./datasets/metadata.json"
TRAIN_DATA_FILE="./datasets/train_data.json"
if [ ! -f "$METADATA_FILE" ] || [ ! -f "$TRAIN_DATA_FILE" ]; then
    echo "Error: Metadata or training data file not found!"
    exit 1
fi

# Step 3: Generate Noir files
echo "Generating Noir main.nr and Prover.toml..."
python3 helpers/write_noir_main.py --metadata "$METADATA_FILE" --data "$TRAIN_DATA_FILE" --epochs "$EPOCHS" --samples-train "$SAMPLES_TRAIN" --learning-rate "$LEARNING_RATE" --output-dir "$PROJECT_DIR"
if [ $? -ne 0 ]; then
    echo "Error: Noir file generation failed."
    exit 1
fi

# Step 4: Run the full MPC flow script in conoir_project
CONOIR_SCRIPT="run_full_mpc_flow.sh"

echo "Running full flow with conoir..."
if [ -f "$PROJECT_DIR/$CONOIR_SCRIPT" ]; then
    # Change to the project directory
    cd "$PROJECT_DIR" || { echo "Error: Could not change to $PROJECT_DIR"; exit 1; }
    
    # Capture start time
    START_TIME=$(date +%s)
    
    # Run the script
    bash "$CONOIR_SCRIPT"
    if [ $? -ne 0 ]; then
        echo "Error: Full MPC flow script failed."
        exit 1
    fi
    
    # Capture end time
    END_TIME=$(date +%s)
    
    # Calculate and display elapsed time
    ELAPSED_TIME=$((END_TIME - START_TIME))
    echo "Full MPC flow script completed in $ELAPSED_TIME seconds."
    
    # Return to the parent directory
    cd ..
else
    echo "Error: Script '$PROJECT_DIR/$CONOIR_SCRIPT' not found."
    exit 1
fi
