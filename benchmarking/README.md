# Benchmarking for ML lib

The current script does the following:
1. Takes train & test data from a dataset in sklearn
2. Fills a Noir test with the training data that calls `train_multi_class`
3. Runs Noir test and saves printed weights & bias
4. Calculates accuracy of those parameters according to the test data

Note that there are conversions happening of the data in between because the original data is in floats and the Noir library works with Quantized. 

## Run

```bash
$ ./run_benchmarking.sh
```

Make executionable with `$ chmod +x run_benchmarking.sh`. 

Optionally, define the following parameters
- `--epochs=`
- `--samples-train=`
- `--samples-test=`
- `--dataset=` available options: "iris, wine, digits, diabetes, linnerud"

Default values:
- epochs 10
- train samples 30
- test samples 20
- dataset "iris"

## Examples

Dataset [digits](https://scikit-learn.org/stable/modules/generated/sklearn.datasets.load_digits.html), 20 epochs, 50 training samples and 20 (default) test samples. 
```bash
$ ./run_benchmarking.sh --dataset=digits --epochs=20 --samples-train=50
```