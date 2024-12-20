# Co-noir project

This can execute the functionality in `main.nr` using co-noir. 

A bare-bones conoir starter can be found [here](https://github.com/ewynx/conoir_starter).

## Important

In additional to git clone, it is necessary to obtain the missing `.dat` files from Git LFS (one of them is very large, and couldn't be commited to Git directly):
```bash
git lfs install
git lfs pull
```

## Run full flow

The script will execute the following steps:
- compile nargo project
- split the `Prover.toml` input into shares
- generate witnesses using MPC
- prove using MPC
- create verification key
- verify proof

```bash
$ ./run_full_mpc_flow.sh
```
