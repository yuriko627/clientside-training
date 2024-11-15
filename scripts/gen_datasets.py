from sklearn import datasets
import pandas as pd
import numpy as np

SCALE = 2 ** 16
SAMPLES = 30

if __name__ == "__main__":
    iris = datasets.load_iris()
    dataset = pd.DataFrame(
        data=iris.data,
        columns=iris.feature_names
    )

    # Add the target column as species
    dataset['species'] = iris.target

    dataset.iloc[:, :-1] = (dataset.iloc[:, :-1].to_numpy() * SCALE).astype(int)
    filtered_dataset = dataset[dataset["species"].isin([0, 1])]

    trimed_dataset = filtered_dataset[:SAMPLES]

    print("[")
    for i in range(SAMPLES):
        print("\t[")
        for j in range(4):
            print("\t\tQuantized { x:", int(trimed_dataset.iloc[i, j]), "}, ")
        print("\t],")
    print("]")

    print("================== LABELS ===========================")

    print("[")
    for i in range(SAMPLES):
        print("\tQuantized { x:", int(trimed_dataset.iloc[i, -1]), "}, ")
    print("]")

    