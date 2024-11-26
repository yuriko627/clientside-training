import json
import argparse

SCALE = 2**16
SAMPLES_TRAIN = 30 

def format_features(features):
    return ", ".join([f"Quantized {{ x: {value} }}" for value in features])

def replace_placeholders(template, inputs, labels_0, labels_1, labels_2, epochs, ratio):
    """
    Replace placeholders in the Noir template with actual data.
    """
    return (
        template
        .replace("// INPUTS_PLACEHOLDER", ",\n        ".join(inputs))
        .replace("// LABELS_0_PLACEHOLDER", ",\n        ".join(labels_0))
        .replace("// LABELS_1_PLACEHOLDER", ",\n        ".join(labels_1))
        .replace("// LABELS_2_PLACEHOLDER", ",\n        ".join(labels_2))
        .replace("// EPOCHS_PLACEHOLDER", str(epochs))
        .replace("// RATIO_PLACEHOLDER", str(ratio))
    )

if __name__ == "__main__":
    # Parse command-line arguments
    parser = argparse.ArgumentParser(description="Adjust Noir code with flexible epochs.")
    parser.add_argument(
        "--epochs", type=int, required=True,
        help="Number of epochs for training"
    )
    args = parser.parse_args()

    # Load dataset
    with open("./datasets/train_data.json", "r") as f:
        dataset = json.load(f)

    # Calculate ratio based on the hardcoded samples_train
    ratio = round(SCALE / SAMPLES_TRAIN)  # Compute 1/n * SCALE

    inputs = []
    labels_0 = []
    labels_1 = []
    labels_2 = []

    for row in dataset:
        inputs.append(f"[{format_features(row['features'])}]")
        labels_0.append(f"Quantized {{ x: {row['label_0'] * SCALE} }}")
        labels_1.append(f"Quantized {{ x: {row['label_1'] * SCALE} }}")
        labels_2.append(f"Quantized {{ x: {row['label_2'] * SCALE} }}")

    # Load the Noir template
    with open("./noir_project/src/main_template.nr", "r") as f:
        template = f.read()

    # Replace placeholders in the template
    updated_code = replace_placeholders(template, inputs, labels_0, labels_1, labels_2, args.epochs, ratio)

    # Write updated code to main.nr
    with open("./noir_project/src/main.nr", "w") as f:
        f.write(updated_code)

    print(f"Noir code updated for {args.epochs} epochs and saved to ./noir_project/src/main.nr")
