#!/bin/bash

# Default values
OUTPUT_FILE="benches/conoir_results.csv"
SINGLE_RUN_SCRIPT="./run_with_conoir.sh"
EPOCHS_LIST=(10 20)
SAMPLES_TRAIN_LIST=(30 50)
SAMPLES_TEST_LIST=(20)
DATASETS=("iris")
LEARNING_RATE_LIST=(0.1)

# Parse arguments for overriding parameters
for arg in "$@"; do
    case $arg in
        --epochs-list=*)
            IFS=',' read -r -a EPOCHS_LIST <<< "${arg#*=}"
            ;;
        --samples-train-list=*)
            IFS=',' read -r -a SAMPLES_TRAIN_LIST <<< "${arg#*=}"
            ;;
        --samples-test-list=*)
            IFS=',' read -r -a SAMPLES_TEST_LIST <<< "${arg#*=}"
            ;;
        --datasets=*)
            IFS=',' read -r -a DATASETS <<< "${arg#*=}"
            ;;
        --learning-rate-list=*)
            IFS=',' read -r -a LEARNING_RATE_LIST <<< "${arg#*=}"
            ;;
        --output-file=*)
            OUTPUT_FILE="${arg#*=}"
            ;;
        *)
            echo "Unknown argument: $arg"
            exit 1
            ;;
    esac
done

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Create or overwrite the output file and write the header
echo "Dataset,Epochs,Samples_Train,Samples_Test,Learning_Rate,Elapsed_Time_Seconds" > "$OUTPUT_FILE"

# Run combinations of parameters
for DATASET in "${DATASETS[@]}"; do
    for EPOCHS in "${EPOCHS_LIST[@]}"; do
        for SAMPLES_TRAIN in "${SAMPLES_TRAIN_LIST[@]}"; do
            for SAMPLES_TEST in "${SAMPLES_TEST_LIST[@]}"; do
                for LEARNING_RATE in "${LEARNING_RATE_LIST[@]}"; do
                    echo "Running with Dataset=$DATASET, Epochs=$EPOCHS, Samples_Train=$SAMPLES_TRAIN, Samples_Test=$SAMPLES_TEST, Learning_Rate=$LEARNING_RATE"

                    # Capture the start time
                    START_TIME=$(date +%s)

                    # Run the single-run script with the current parameters
                    bash "$SINGLE_RUN_SCRIPT" \
                        --epochs="$EPOCHS" \
                        --samples-train="$SAMPLES_TRAIN" \
                        --samples-test="$SAMPLES_TEST" \
                        --dataset="$DATASET" \
                        --learning-rate="$LEARNING_RATE"

                    # Capture the end time
                    END_TIME=$(date +%s)
                    ELAPSED_TIME=$((END_TIME - START_TIME))

                    # Append results to the output file
                    echo "$DATASET,$EPOCHS,$SAMPLES_TRAIN,$SAMPLES_TEST,$LEARNING_RATE,$ELAPSED_TIME" >> "$OUTPUT_FILE"

                    echo "Run completed in $ELAPSED_TIME seconds."
                done
            done
        done
    done
done

echo "All runs completed. Results saved in $OUTPUT_FILE."
