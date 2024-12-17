# Co-noir project

This can execute the functionality in `main.nr` using co-noir. 

A bare-bones conoir starter can be found [here](https://github.com/ewynx/conoir_starter).

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
