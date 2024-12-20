# Compile latest version
nargo compile

# Ensure the output directory exists
mkdir -p output

# split input into shares
co-noir split-input --circuit target/conoir_project.json --input Prover.toml --protocol REP3 --out-dir output

# run witness extension in MPC
co-noir generate-witness --input output/Prover.toml.0.shared --circuit target/conoir_project.json --protocol REP3 --config configs/party1.toml --out noir_mpc_ml.gz.0.shared &
co-noir generate-witness --input output/Prover.toml.1.shared --circuit target/conoir_project.json --protocol REP3 --config configs/party2.toml --out noir_mpc_ml.gz.1.shared &
co-noir generate-witness --input output/Prover.toml.2.shared --circuit target/conoir_project.json --protocol REP3 --config configs/party3.toml --out noir_mpc_ml.gz.2.shared
wait $(jobs -p)

# run proving in MPC
co-noir build-and-generate-proof --witness noir_mpc_ml.gz.0.shared --circuit target/conoir_project.json --crs bn254_g1.dat --protocol REP3 --hasher KECCAK --config configs/party1.toml --out proof.0.proof --public-input public_input.json &
co-noir build-and-generate-proof --witness noir_mpc_ml.gz.1.shared --circuit target/conoir_project.json --crs bn254_g1.dat --protocol REP3 --hasher KECCAK --config configs/party2.toml --out proof.1.proof &
co-noir build-and-generate-proof --witness noir_mpc_ml.gz.2.shared --circuit target/conoir_project.json --crs bn254_g1.dat --protocol REP3 --hasher KECCAK --config configs/party3.toml --out proof.2.proof
wait $(jobs -p)

# Create verification key
co-noir create-vk --circuit target/conoir_project.json --crs bn254_g1.dat --hasher KECCAK --vk output/verification_key

# verify proof
co-noir verify --proof proof.0.proof --vk output/verification_key --hasher KECCAK --crs bn254_g2.dat

