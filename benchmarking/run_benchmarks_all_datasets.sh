#!/bin/bash

# Datasets to benchmark
DATASETS=("iris" "wine" "digits" "diabetes" "linnerud")

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

# Loop through datasets
for DATASET in "${DATASETS[@]}"; do
    echo "Starting benchmarks for dataset: $DATASET"

    # Loop through epochs and sample train values
    for EPOCHS in "${EPOCHS_LIST[@]}"; do
        for SAMPLES_TRAIN in "${SAMPLES_TRAIN_LIST[@]}"; do
            echo "Running benchmark with dataset=$DATASET, epochs=$EPOCHS, samples_train=$SAMPLES_TRAIN"

            # Generate a log file for the current benchmark
            TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
            LOG_FILE="$LOG_DIR/benchmark_${DATASET}_${EPOCHS}_${SAMPLES_TRAIN}_${TIMESTAMP}.log"

            # Execute the benchmark script
            "$BENCHMARK_SCRIPT" --dataset="$DATASET" --epochs-list="$EPOCHS" --samples-train-list="$SAMPLES_TRAIN" >> "$LOG_FILE" 2>&1

            # Check the exit status of the benchmark script
            if [ $? -ne 0 ]; then
                echo "Error: Benchmark failed for dataset=$DATASET, epochs=$EPOCHS, samples_train=$SAMPLES_TRAIN. Check log: $LOG_FILE"
            else
                echo "Benchmark completed for dataset=$DATASET, epochs=$EPOCHS, samples_train=$SAMPLES_TRAIN. Results logged in: $LOG_FILE"
            fi
        done
    done
done

echo "All benchmarks completed. Logs are available in the '$LOG_DIR' directory."
