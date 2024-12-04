import json
import argparse

SCALE = 2**16  # Scale factor for quantization

def generate_noir_code(labels, samples_train, epochs, learning_rate, ratio):
    """
    Generate the Noir `main.nr` code with dynamic labels.
    """
    # Scale labels and format as [[Quantized; samples_train]; num_classes]
    labels_formatted = ",\n        ".join(
        f"[{', '.join(f'Quantized {{ x: {label * SCALE} }}' for label in class_labels)}]"
        for class_labels in labels
    )

    noir_code = f"""
use noir_mpc_ml::ml::train_multi_class;
use noir_mpc_ml::quantized::Quantized;

fn main(inputs: [[Quantized; 4]; 30]) -> pub [([Quantized; 4], Quantized); 3] {{
    let learning_rate = {learning_rate};
    let ratio = {ratio};

    let labels: [[Quantized; {samples_train}]; {len(labels)}] = [
        {labels_formatted}
    ];

    let epochs = {epochs};

    let learning_rate = Quantized::new(learning_rate);
    let ratio = Quantized::new(ratio);
    let parameters = train_multi_class(epochs, inputs, labels, learning_rate, ratio);
    parameters
}}
"""
    return noir_code


def generate_prover_toml(features):
    """
    Generate the `Prover.toml` file with the provided features.
    """
    toml_inputs = []
    for sample in features:
        quantized_sample = ", ".join(f'{{ x = "{feature}" }}' for feature in sample)
        toml_inputs.append(f"[{quantized_sample}]")
    
    toml_content = "inputs = [\n    " + ",\n    ".join(toml_inputs) + "\n]"
    return toml_content


def extract_labels(train_data, samples_train):
    """
    Extract labels from the training dataset for Noir.
    """
    label_keys = [key for key in train_data[0] if key.startswith("label_")]
    labels = []

    for key in label_keys:
        class_labels = [int(row[key]) for row in train_data[:samples_train]]
        labels.append(class_labels)

    return labels


def main():
    # Parse arguments
    parser = argparse.ArgumentParser(description="Generate Noir main.nr and Prover.toml files")
    parser.add_argument("--metadata", type=str, required=True, help="Path to metadata.json")
    parser.add_argument("--data", type=str, required=True, help="Path to train_data.json")
    parser.add_argument("--epochs", type=int, required=True, help="Number of epochs for training")
    parser.add_argument("--samples-train", type=int, required=True, help="Number of training samples")
    parser.add_argument("--output-dir", type=str, default="./noir_project", help="Project directory")
    args = parser.parse_args()

    # Load metadata and data
    with open(args.metadata, "r") as meta_file:
        metadata = json.load(meta_file)

    with open(args.data, "r") as data_file:
        train_data = json.load(data_file)

    num_features = metadata["features"]
    samples_train = args.samples_train
    learning_rate = round(0.1 * SCALE)  # Example scaling
    ratio = round(SCALE / samples_train)

    # Extract features and labels
    features = [row["features"] for row in train_data[:samples_train]]
    labels = extract_labels(train_data, samples_train)

    # Generate Noir code and Prover.toml
    noir_code = generate_noir_code(labels, samples_train, args.epochs, learning_rate, ratio)
    prover_toml = generate_prover_toml(features)

    # Write Noir code to /src
    with open(f"{args.output_dir}/src/main.nr", "w") as noir_file:
        noir_file.write(noir_code)

    # Write Prover.toml to project root
    with open(f"{args.output_dir}/Prover.toml", "w") as toml_file:
        toml_file.write(prover_toml)

    print(f"Generated Noir code in {args.output_dir}/src/main.nr")
    print(f"Generated Prover.toml in {args.output_dir}/Prover.toml")


if __name__ == "__main__":
    main()
