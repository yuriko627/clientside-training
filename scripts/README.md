# Testing scripts

In this folder you will find three different scripts:

- A script to for splitting the Iris dataset into train and test.
- A script to prepare the dataset as input for Noir.
- A script to evaluate the model trained in Noir.

To be able to test the model training, you should follow the order below:

1. First, you should execute the train/test split script.
2. Then, you should run the script to prepare the input for Noir.
3. Once the trainind is done, you should store the weights in the `scripts/quantized.txt`
   file with the proper format.
4. Finally, you should run the script to evaluate the model to obtain the
   accuracy with respect to the train/test split from Step 1.