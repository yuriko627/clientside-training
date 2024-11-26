import json

SCALE = 2**16

def format_features(features):
    return ", ".join([f"Quantized {{ x: {value} }}" for value in features])

def replace_placeholders(template, inputs, labels_0, labels_1, labels_2):
    """
    Replace placeholders in the Noir template with actual data.
    """
    return (
        template
        .replace("// INPUTS_PLACEHOLDER", ",\n        ".join(inputs))
        .replace("// LABELS_0_PLACEHOLDER", ",\n        ".join(labels_0))
        .replace("// LABELS_1_PLACEHOLDER", ",\n        ".join(labels_1))
        .replace("// LABELS_2_PLACEHOLDER", ",\n        ".join(labels_2))
    )

if __name__ == "__main__":
    # Load dataset
    with open("./datasets/train_data.json", "r") as f:
        dataset = json.load(f)

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
    updated_code = replace_placeholders(template, inputs, labels_0, labels_1, labels_2)

    # Write updated code to main.nr
    with open("./noir_project/src/main.nr", "w") as f:
        f.write(updated_code)

    print("Noir code updated and saved to ./noir_project/src/main.nr")
