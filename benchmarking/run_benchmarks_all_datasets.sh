#!/bin/bash

# Datasets to benchmark
DATASETS=("iris" "wine" "digits")

# Parameter ranges
EPOCHS_LIST=(10 20 30)
SAMPLES_TRAIN_LIST=(20 60 100)

# Benchmark script location
BENCHMARK_SCRIPT="./run_get_multiple_gatecount.sh"

# Check if the benchmark script exists
if [ ! -f "$BENCHMARK_SCRIPT" ]; then
    echo "Error: Benchmark script '$BENCHMARK_SCRIPT' not found!"
    exit 1
fi

# Output directory for logs
LOG_DIR="logs"
mkdir -p "$LOG_DIR"

# Convert lists to comma-separated strings
EPOCHS_LIST_STR=$(IFS=','; echo "${EPOCHS_LIST[*]}")
SAMPLES_TRAIN_LIST_STR=$(IFS=','; echo "${SAMPLES_TRAIN_LIST[*]}")

# Loop through datasets
for DATASET in "${DATASETS[@]}"; do
    echo "Starting benchmarks for dataset: $DATASET"

    # Generate a log file for the current dataset
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    LOG_FILE="$LOG_DIR/benchmark_${DATASET}_${TIMESTAMP}.log"

    # Execute the benchmark script once per dataset
    "$BENCHMARK_SCRIPT" --dataset="$DATASET" --epochs-list="$EPOCHS_LIST_STR" --samples-train-list="$SAMPLES_TRAIN_LIST_STR" >> "$LOG_FILE" 2>&1

    # Check the exit status of the benchmark script
    if [ $? -ne 0 ]; then
        echo "Error: Benchmark failed for dataset=$DATASET. Check log: $LOG_FILE"
    else
        echo "Benchmark completed for dataset=$DATASET. Results logged in: $LOG_FILE"
    fi
done

echo "All benchmarks completed. Logs are available in the '$LOG_DIR' directory."
