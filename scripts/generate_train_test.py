"""
This script loads the Iris dataset and takes the samples labeled as 0 and 1.
Then it splits the dataset according to the SAMPLES_TRAIN and SAMPLES_TEST and
stored the splitted dataset into CSV files in the datasets/ folder.
"""

from sklearn import model_selection
from sklearn import datasets
from sklearn import utils
import pandas as pd

SAMPLES_TRAIN = 30
SAMPLES_TEST = 20

if __name__ == "__main__":
    # Loads the dataset.
    iris = datasets.load_iris()
    iris_dataset = pd.DataFrame(data=iris.data, columns=iris.feature_names)

    # Add the target column as species
    iris_dataset["species"] = iris.target

    # Choose the classes 0 and 1.
    filtered_dataset = iris_dataset[iris_dataset["species"].isin([0, 1])]

    # Select SAMPLES_TRAIN + SAMPLES_TEST random elements from the dataset.
    dataset = utils.resample(filtered_dataset, n_samples=SAMPLES_TRAIN + SAMPLES_TEST)

    # Divide the dataset into train and test.
    X_train, X_test, y_train, y_test = model_selection.train_test_split(dataset.iloc[:, :4], dataset.iloc[:, -1], train_size=SAMPLES_TRAIN, random_state=1)

    print("Size train dataset:", X_train.shape)
    print("Size test dataset:", X_test.shape)

    train_data = pd.DataFrame(X_train, columns=iris.feature_names)
    train_data["species"] = y_train
    test_data = pd.DataFrame(X_test, columns=iris.feature_names)
    test_data["species"] = y_test

    print(train_data.head())
    print(test_data.head())

    train_data.to_csv("./datasets/train_data.csv", index=False)
    test_data.to_csv("./datasets/test_data.csv", index=False)





