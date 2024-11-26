import pandas as pd
from sklearn import datasets, model_selection, preprocessing
import json
import os

SAMPLES_TRAIN = 30
SAMPLES_TEST = 20
SCALE = 2**16

def quantize_row(features):
    """Quantize the feature row using SCALE."""
    return [round(feature * SCALE) for feature in features]

if __name__ == "__main__":
    # Ensure the `datasets` folder exists
    os.makedirs("./datasets", exist_ok=True)

    # Load the Iris dataset
    iris = datasets.load_iris()
    iris_dataset = pd.DataFrame(data=iris.data, columns=iris.feature_names)
    iris_dataset["species"] = iris.target

    # Select SAMPLES_TRAIN + SAMPLES_TEST random elements from the dataset.
    dataset = iris_dataset.resample(n=SAMPLES_TRAIN + SAMPLES_TEST, random_state=1)

    # Split into training and testing sets
    X_train, X_test, y_train, y_test = model_selection.train_test_split(
        dataset.iloc[:, :4],
        dataset["species"],
        train_size=SAMPLES_TRAIN,
        random_state=1
    )

    # Assemble test dataset and save it to a CSV file
    test_df = pd.DataFrame(X_test, columns=iris.feature_names)
    test_df["species"] = y_test
    test_df.to_csv("./datasets/test_data.csv", index=False)

    # Assemble train dataset
    train_df = pd.DataFrame(X_train, columns=iris.feature_names)
    train_df["species"] = y_train

    # Binarize the target labels
    label_binarizer = preprocessing.LabelBinarizer()
    label_binarizer_output = label_binarizer.fit_transform(train_df["species"])
    label_df = pd.DataFrame(
        label_binarizer_output,
        columns=[f"label_{cls}" for cls in label_binarizer.classes_],
        index=train_df.index
    )

    # Merge binarized labels with train dataset
    train_df_binarized = pd.concat([train_df, label_df], axis=1)

    # Save the binarized training dataset to a CSV file
    train_df_binarized.to_csv("./datasets/train_data.csv", index=False)

    # Prepare dataset for Noir
    noir_data = []
    for _, row in train_df_binarized.iterrows():
        quantized_features = quantize_row(row[iris.feature_names])
        noir_data.append({
            "features": quantized_features,
            "label_0": int(row["label_0"]),
            "label_1": int(row["label_1"]),
            "label_2": int(row["label_2"])
        })

    # Save dataset as JSON for Noir
    with open("./datasets/train_data.json", "w") as f:
        json.dump(noir_data, f, indent=4)

    print("Dataset prepared and saved to:")
    print("- CSV (train): ./datasets/train_data.csv")
    print("- CSV (test): ./datasets/test_data.csv")
    print("- JSON (Noir): ./datasets/train_data.json")
