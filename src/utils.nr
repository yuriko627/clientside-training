use noir_fixed_point::quantized::{is_negative, Quantized};
use std::field::bn254::decompose;

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

    // Division by 2^16, code as suggested by Tom French @TomAFrench
    // Cast x to a u16 to preserve only the lowest 16 bits.
    let lowest_16_bits = z as u16;

    // Subtract off the lowest 16 bits so they are cleared.
    let x_with_cleared_lower_bits = z - lowest_16_bits as Field;

    // The lowest 16 bits are clear, `x_with_cleared_lower_bits` is divisible by `65536`,
    // therefore field division is equivalent to integer division.
    let mut new_x: Field = x_with_cleared_lower_bits / 65536;

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

// Assert that number of bits <= bitsize
// if quantized is negative, it count the bits backwards
pub fn assert_bitsize<let bitsize: u32>(q: Quantized) {
    // Decomposes into two 128 bits chunks
    let (_, higher_bytes) = decompose(q.x);
    if higher_bytes == 0 {
        // positive number
        q.x.assert_max_bit_size::<bitsize>();
    } else {
        // negative number
        (-q.x).assert_max_bit_size::<bitsize>();
    }
}

#[test]
fn test_assert_bitsize() {
    // 4 bits
    assert_bitsize::<4>(Quantized { x: 10 });
    assert_bitsize::<4>(Quantized { x: -10 });

    // 100 bits
    assert_bitsize::<100>(Quantized { x: 1267650600228229401496703205375 });
    assert_bitsize::<100>(Quantized { x: -1267650600228229401496703205375 });

    // 127 bits
    assert_bitsize::<127>(Quantized { x: 170141183460469231731687303715884105727 });
    assert_bitsize::<127>(Quantized { x: -170141183460469231731687303715884105727 });
}

#[test(should_fail)]
fn test_fail_assert_bitsize127() {
    // 131 bits
    assert_bitsize::<127>(Quantized { x: 1361129467683753853853498429727072845824 });
}

#[test(should_fail)]
fn test_fail_assert_bitsize127_neg() {
    // 131 bits
    assert_bitsize::<127>(Quantized { x: -1361129467683753853853498429727072845824 });
}

#[test(should_fail)]
fn test_fail_assert_bitsize1() {
    // 4 bits
    assert_bitsize::<3>(Quantized { x: 10 });
}

#[test(should_fail)]
fn test_fail_assert_bitsize2() {
    // 4 bits
    assert_bitsize::<3>(Quantized { x: -10 });
}

#[test(should_fail)]
fn test_fail_assert_bitsize3() {
    // 100 bits
    assert_bitsize::<99>(Quantized { x: 1267650600228229401496703205375 });
}

#[test(should_fail)]
fn test_fail_assert_bitsize4() {
    // 100 bits
    assert_bitsize::<99>(Quantized { x: -1267650600228229401496703205375 });
}

#[test(should_fail)]
fn test_fail_assert_bitsize5() {
    // 127 bits
    assert_bitsize::<126>(Quantized { x: 170141183460469231731687303715884105727 });
}

#[test(should_fail)]
fn test_fail_assert_bitsize6() {
    // 127 bits
    assert_bitsize::<126>(Quantized { x: -170141183460469231731687303715884105727 });
}
