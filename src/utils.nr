use noir_fixed_point::quantized::is_negative;

pub unconstrained fn get_bytes(x: Field) -> [u8; 32] {
    x.to_be_bytes()
}

// returns x * 2^-16, interpreted as an integer
// Scaling down is needed for example after multiplying 2 Quantized values
pub fn scale_down(x: Field) -> Field {
    let mut z = x;
    let mut bytes: [u8; 32] = [0; 32];

    let negative = is_negative(z);

    z = negative
        * (
            21888242871839275222246405745257275088548364400416034343698204186575808495616 - z + 1
                - z
        )
        + z;
    unsafe {
        bytes = get_bytes(z);
    }
    assert(Field::from_be_bytes::<32>(bytes) == z);

    // Now scale down with the same trick as in Quantized mul
    let mut truncated: [u8; 32] = [0; 32];
    for i in 0..30 {
        truncated[i + 2] = bytes[i];
    }

    let mut new_x: Field = Field::from_be_bytes::<32>(truncated);

    // Flip back sign if the output is negative
    new_x = negative
        * (
            21888242871839275222246405745257275088548364400416034343698204186575808495616 - new_x
                + 1
                - new_x
        )
        + new_x;

    new_x
}
