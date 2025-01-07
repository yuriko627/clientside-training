#!/bin/bash

# Default values
EPOCHS_LIST=(5 10 15)
SAMPLES_TRAIN_LIST=(10 20 30)
LEARNING_RATE=0.1
DATASET_NAME="iris"
PROJECT_DIR="./noir_project"
TARGET_DIR="$PROJECT_DIR/target"
OUT_DIR="output"
OUTPUT_BENCH="$OUT_DIR/benchmarks.txt"

# Parse arguments
for arg in "$@"; do
    case $arg in
        --epochs-list=*)
            IFS=',' read -r -a EPOCHS_LIST <<< "${arg#*=}" # Extract and split EPOCHS_LIST
            ;;
        --samples-train-list=*)
            IFS=',' read -r -a SAMPLES_TRAIN_LIST <<< "${arg#*=}" # Extract and split SAMPLES_TRAIN_LIST
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

# Ensure output directory exists
if [ ! -d "$OUT_DIR" ]; then
    mkdir -p "$OUT_DIR"
fi

# Clear the benchmark file
> "$OUTPUT_BENCH" 

# Loop through parameter combinations
for EPOCHS in "${EPOCHS_LIST[@]}"; do
    for SAMPLES_TRAIN in "${SAMPLES_TRAIN_LIST[@]}"; do
        echo "Running benchmark with epochs=$EPOCHS, samples_train=$SAMPLES_TRAIN"

        # Step 1: Generate dataset
        echo "Generating dataset..."
        python3 helpers/generate_dataset.py --dataset "$DATASET_NAME" --samples-train "$SAMPLES_TRAIN"
        if [ $? -ne 0 ]; then
            echo "Error: Dataset generation failed for epochs=$EPOCHS, samples_train=$SAMPLES_TRAIN."
            continue
        fi

        # Step 2: Load metadata
        METADATA_FILE="./datasets/metadata.json"
        TRAIN_DATA_FILE="./datasets/train_data.json"
        if [ ! -f "$METADATA_FILE" ] || [ ! -f "$TRAIN_DATA_FILE" ]; then
            echo "Error: Metadata or training data file not found for epochs=$EPOCHS, samples_train=$SAMPLES_TRAIN."
            continue
        fi

        # Step 3: Generate Noir files
        echo "Generating Noir main.nr and Prover.toml..."
        python3 helpers/write_noir_main.py --metadata "$METADATA_FILE" --data "$TRAIN_DATA_FILE" --epochs "$EPOCHS" --samples-train "$SAMPLES_TRAIN" --learning-rate "$LEARNING_RATE" --output-dir "$PROJECT_DIR"
        if [ $? -ne 0 ]; then
            echo "Error: Noir file generation failed for epochs=$EPOCHS, samples_train=$SAMPLES_TRAIN."
            continue
        fi

        # Step 4: Compile the Noir project
        echo "Compiling Noir project..."
        if [ ! -d "$PROJECT_DIR" ]; then
            echo "Error: Project directory $PROJECT_DIR does not exist!"
            continue
        fi

        pushd "$PROJECT_DIR" > /dev/null || (echo "pushd failed" && exit 1)
        nargo execute
        if [ $? -ne 0 ]; then
            echo "Error: Failed to compile the Noir project for epochs=$EPOCHS, samples_train=$SAMPLES_TRAIN."
            popd > /dev/null || (echo "popd failed" && exit 1)
            continue
        fi
        popd > /dev/null || (echo "popd failed" && exit 1)

        # Step 5: Check for compiled output
        echo "Checking for compiled output..."
        if [ ! -f "$TARGET_DIR/noir_project.json" ]; then
            echo "Error: Compiled file noir_project.json not found in $TARGET_DIR for epochs=$EPOCHS, samples_train=$SAMPLES_TRAIN."
            continue
        fi

        # Step 6: Get gatecount for current params
        echo "Getting gatecount..."
        {
            echo "epochs=$EPOCHS, samples_train=$SAMPLES_TRAIN" 
            bb gates -b "$TARGET_DIR/noir_project.json"
        } >> "$OUTPUT_BENCH"
        echo "===" >> "$OUTPUT_BENCH"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to get gatecount for epochs=$EPOCHS, samples_train=$SAMPLES_TRAIN."
            continue
        fi

        echo "Gatecount completed for epochs=$EPOCHS, samples_train=$SAMPLES_TRAIN."
    done
done

# Generate a timestamp for the CSV file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_CSV="benches/benchmarks__${DATASET_NAME}_${TIMESTAMP}.csv"

# Step 7: Generate CSV from benchmarks
python3 helpers/generate_gatecounts_csv.py --output "$OUTPUT_CSV"

echo "Benchmarking completed. CSV file created at $OUTPUT_CSV." | tee -a "$OUTPUT_BENCH"
