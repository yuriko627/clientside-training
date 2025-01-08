# Benchmarking for the logistic regression library 

We created a script to benchmark the logistic regression library. The script does the following:
1. Takes train & test data from a dataset in sklearn.
2. Fills a Noir test with the training data that calls `train_multi_class`.
3. Runs Noir test and saves printed weights & bias.
4. Calculates accuracy of those parameters according to the test data.

Note that there are conversions happening of the data in between as the original data is in floating-point representation and the Noir library works with Quantized which is a fixed point representation. 

## Prerequisites

The execution of the scripts requires `nargo` version `1.0.0-beta.0` and `bb` version `0.63.0`. To install both CLI applications, you can execute the following commands in the terminal:

```bash
$ noirup --version 1.0.0-beta.0
$ bbup -v 0.63.0
```

## How to run

### Single test

To run a single test for the logistic regression library, you can execute the following command:

```bash
$ ./run_single_test.sh
```

Before running the command, you should make sure that the script is executable with `$ chmod +x run_single_test.sh`. 

The script has some optional parameters that you can set. The parameters are presented next:
- `--epochs=<n_epochs>`
- `--samples-train=<n_samples_train>`
- `--samples-test=<n_samples_test>`
- `--dataset=<"iris" | "wine" | "digits" | "diabetes" | "linnerud">` 

The default values for each parameter are:
- `epochs`: 10
- `samples-train`: 30
- `samples-test`: 20
- `dataset`: "iris"

#### Examples

To execute the dataset [digits](https://scikit-learn.org/stable/modules/generated/sklearn.datasets.load_digits.html) with 20 epochs, 50 training samples and 20 (default) test samples, you can execute the following commands:
```bash
$ ./cleanup.sh
$ ./run_single_test.sh --dataset=digits --epochs=20 --samples-train=50
```

### Prove & verify

We implemented scripts that automatically generates Noir code to compile the program, create proofs and verify these proofs using the existing Noir tooling. The command presented next generates the dataset as in the above commands, populates the `Prover.toml`, and creates a Noir `main` function that calls `train_multi_class`. Then, it follows [these steps](https://noir-lang.org/docs/getting_started/quick_start#compiling-and-executing) to execute the program, prove and verify the proof. 

```bash
$ ./cleanup.sh
$ ./run_proof_example.sh
```

### Obtain gatecount

We creates the same Noir program similar to the proving & verifying command presented in the previous section, but instead of executing those steps, this command just obtains the gatecount. For a single set of parameters, the output is saved in `output/benchmarks.txt`. The command to execute the gate count is presented next:

```bash
$ ./cleanup.sh
$ ./run_get_gatecount.sh
```

To run multiple benchmarks at once gathering the output in `benches/benchmarks.csv`, you can execute the following commands:
```bash
$ ./cleanup.sh
$ ./run_get_multiple_gatecounts.sh
```