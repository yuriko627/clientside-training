Clientside training implementation using [noir-mpc-ml](https://github.com/hashcloak/noir-mpc-ml) implementation.

Notes for myself:
- `nargo --version` - `nargo version = 1.0.0-beta.2`
- `bb --version` - `0.63.0`
- used mocked Iris training dataset having each value in Finite Field

Whole flow:
- `nargo execute --skip-underconstrained-check`: this outputs the trained model
- `bb prove -b ./target/clientside_training.json -w ./target/clientside_training.gz -o ./target/proof`: this outputs the circuit size (currently `num_filled_gates: 660166`)
- `bb write_vk -b ./target/clientside_training.json -o ./target/vk`
- `bb verify -k ./target/vk -p ./target/proof`
