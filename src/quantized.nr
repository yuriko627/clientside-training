use std::ops::{Add, Sub, Mul};

// Scale 2^-16 = 0.0000152587890625 (divide by 65536)
// p = 21888242871839275222246405745257275088548364400416034343698204186575808495617

struct Quantized {
    // if value positive: x*scale
    // if negative: (p-x)*scale, where p is the prime of native Field (in this case from barretenberg)
    // the original value is max 60 bits, positive or negative,
    // this leaves enough space for additions and additions of single multiplications
    // 2^60-1 = 1152921504606846975
    // -1152921504606846975 <= x <= 1152921504606846975
    // -1152921504606846975/65536 <= value <= 1152921504606846975/65536
    x: Field,
}

impl Quantized {

    fn zero() -> Self {
        Quantized { x: 0 }
    }

    fn add(self: Self, other: Self) -> Self {
        Quantized { x: self.x + other.x } // if one is negative, this wraps around automatically
    }

    fn sub(self: Self, other: Self) -> Self {
        Quantized { x: self.x - other.x }
    }

    fn mul(self: Self, other: Self) -> Self {
        let mut temp: Field = self.x * other.x;
        let mut bytes: [u8; 32] = temp.to_be_bytes();

        // check if there are bytes from 0-15, then it is negative
        // This assumes the values that are multiplied have max ~60-63 bits
        let mut negative = false;

        for i in 0..16 {
            if bytes[i] != 0 {
                negative = true;
            }
        }
        // To correctly scale down we temporary flip the sign
        if negative {
            temp = 21888242871839275222246405745257275088548364400416034343698204186575808495616
                - temp
                + 1;
            bytes = temp.to_be_bytes();
        }

        // Chop off 2 bytes to scale down by 2^16 and truncate
        let mut truncated: [u8; 32] = [0; 32];
        for i in 0..30 {
            // [0, 0, am, .., a2] (chop off a0 and a1)
            truncated[i + 2] = bytes[i];
        }

        let mut new_x: Field = Field::from_be_bytes::<32>(truncated);
        // Flip back sign if the output is negative
        if negative {
            new_x = 21888242871839275222246405745257275088548364400416034343698204186575808495616
                - new_x
                + 1;
        }

        Quantized { x: new_x }
    }
}

impl Add for Quantized {
    fn add(self, other: Self) -> Self {
        self.add(other)
    }
}

impl Sub for Quantized {
    fn sub(self, other: Self) -> Self {
        self.sub(other)
    }
}

impl Mul for Quantized {
    fn mul(self, other: Self) -> Self {
        self.mul(other)
    }
}

fn main(x: Field, y: pub Field) {
    assert(x != y);
}

#[test]
fn test_add() {
    // Max value 2^60-1, positive and negative
    let a = 1152921504606846975;
    let b = -1152921504606846975;
    let a_quantized = Quantized { x: a };
    let b_quantized = Quantized { x: b };
    let addition_quantized = a_quantized + b_quantized;
    assert(addition_quantized.x == 0);

    // Test case 1: Max value 2^60 - 1, positive and zero
    let a1 = 1152921504606846975;
    let b1 = 0;
    let a1_quantized = Quantized { x: a1 };
    let b1_quantized = Quantized { x: b1 };
    let addition1_quantized = a1_quantized + b1_quantized;
    assert(addition1_quantized.x == a1);

    // Test case 2: Small positive values
    let a2 = 12345;
    let b2 = 67890;
    let a2_quantized = Quantized { x: a2 };
    let b2_quantized = Quantized { x: b2 };
    let addition2_quantized = a2_quantized + b2_quantized;
    assert(addition2_quantized.x == (a2 + b2));

    // Test case 3: Positive and negative values resulting in a non-zero positive result
    let a3 = 50000;
    let b3 = -30000;
    let a3_quantized = Quantized { x: a3 };
    let b3_quantized = Quantized { x: b3 };
    let addition3_quantized = a3_quantized + b3_quantized;
    assert(addition3_quantized.x == 20000);

    // Test case 4: Positive and negative values resulting in a non-zero negative result
    let a4 = 30000;
    let b4 = -50000;
    let a4_quantized = Quantized { x: a4 };
    let b4_quantized = Quantized { x: b4 };
    let addition4_quantized = a4_quantized + b4_quantized;
    assert(addition4_quantized.x == -20000);

    // Test case 5: Add two negative values resulting in a negative value
    let a5 = -40000;
    let b5 = -20000;
    let a5_quantized = Quantized { x: a5 };
    let b5_quantized = Quantized { x: b5 };
    let addition5_quantized = a5_quantized + b5_quantized;
    assert(addition5_quantized.x == -60000);
}

#[test]
fn test_mul() {
    // Test case 1: Small positive values
    let a1 = 12345; // original value 12345/2^16 = 0.1883697509765625
    let b1 = 67890; // original value 67890/2^16 = 1.035919189453125
    let a1_quantized = Quantized { x: a1 };
    let b1_quantized = Quantized { x: b1 };
    // new value = 0.1883697509765625 * 1.035919189453125 = 0.1951358397491276264190673828125
    // x = 0.1951358397491276264190673828125 * 2^16 = 12788.422393798828125 => 12788
    let mult1_quantized = a1_quantized * b1_quantized;
    assert(mult1_quantized.x == 12788);

    // Test case 2: Large positive values
    let a2 = 1152921504606846975; // Max value 2^60 - 1, original 1152921504606846975/2^16 = 17592186044415.9999847412109375
    let b2 = 2; // original 2/2^16 = 0.000030517578125
    let a2_quantized = Quantized { x: a2 };
    let b2_quantized = Quantized { x: b2 };
    let mult2_quantized = a2_quantized * b2_quantized;
    // 17592186044415.9999847412109375 * 0.000030517578125 = 536870911.9999999995343387126922607421875
    // x/2^16 = value;  mult by 2^16 and truncate to whole number => x = 35184372088831
    assert(mult2_quantized.x == 35184372088831);

    // Test case 3: Large positive and small positive value
    let a3 = 1152921504606846975; // Max value 2^60 - 1, original 1152921504606846975/2^16 = 17592186044415.9999847412109375
    let b3 = 1; // original value 1/2^16 = 0.0000152587890625
    let a3_quantized = Quantized { x: a3 };
    let b3_quantized = Quantized { x: b3 };
    // mul = 17592186044415.9999847412109375 * 0.0000152587890625 = 268435455.99999999976716935634613037109375
    let mult3_quantized = a3_quantized * b3_quantized;
    // mul * 2^16 = 17592186044415.9999847412109375
    assert(mult3_quantized.x == 17592186044415);

    // Test case 4: Positive and negative value
    let a4 = 40000; // Original value 40000/2^16 = 0.6103515625
    let b4 = -30000; // Original value -0.457763671875
    let a4_quantized = Quantized { x: a4 };
    let b4_quantized = Quantized { x: b4 };

    // 0.6103515625 * -0.457763671875 = -0.2793967723846435546875
    let mult4_quantized = a4_quantized * b4_quantized;
    // -0.2793967723846435546875 * 2^16 = -18310.546875
    assert(mult4_quantized.x == -18310);

    // Test case 5: Both values negative
    let a5 = -40000; // Original value -40000 / 2^16 = -0.6103515625
    let b5 = -20000; // -0.30517578125
    let a5_quantized = Quantized { x: a5 };
    let b5_quantized = Quantized { x: b5 };
    // -0.6103515625 *  -0.30517578125 = 0.186264514923095703125
    let mult5_quantized = a5_quantized * b5_quantized;
    // Expected result: 12207.03125
    assert(mult5_quantized.x == 12207);
}
