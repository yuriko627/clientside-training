use crate::quantized::Quantized;

fn approx_sigmoid(x: Quantized) -> Quantized {
    // TODO implement // https://github.com/data61/MP-SPDZ/blob/master/Compiler/ml.py#L110
    // [-5, -2.5, 2.5, 5]
    let cuts: [Quantized; 4] = [
        Quantized::new(-327680), // -5/2^-16, -327680
        Quantized::new(-163840), // -2.5/2^-16, -163840
        Quantized::new(163840), // 163840
        Quantized::new(327680), // 327680
    ];

    let outputs = [
        Quantized::new(6), // 0.0001, 0.0001 / 2^-16 = 6.5536
        (Quantized::new(1819) * x) + Quantized::new(9502), //0.02776 and 0.145, 0.02776 / 2^-16 = 1819.27936, 0.145/2^-16 = 9502.72
        (Quantized::new(11141) * x) + Quantized::new(32768), //0.17 and 0.5, 0.17 / 2^-16 = 11141.12, 0.5/2^-16 = 32768
        (Quantized::new(1819) * x) + Quantized::new(56031), //0.02776 and 0.85498, 0.85498/2^-16 = 56031.96928
        Quantized::new(65529), //0.9999 / 2^-16 = 65529.4464
    ];

    let mut index = 4; // Default to the last index in case x is above all cuts
    // Determine the correct interval index by checking against each cut
    if x <= cuts[0] {
        index = 0;
    } else if x <= cuts[1] {
        index = 1;
    } else if x <= cuts[2] {
        index = 2;
    } else if x <= cuts[3] {
        index = 3;
    }
    outputs[index]
}

fn get_prediction(weights: [Quantized; 4], inputs: [Quantized; 4], bias: Quantized) -> Quantized {
    // let z = weights dot_product inputs
    let mut z = Quantized::zero();
    for i in 0..4 {
        z += weights[i] * inputs[i];
    }
    approx_sigmoid(z + bias)
}

fn train(
    epochs: u64,
    inputs: [[Quantized; 4]; 30],
    labels: [Quantized],
    learning_rate: Quantized,
    ratio: Quantized, // ratio = 1/number_samples scaled
) -> ([Quantized; 4], Quantized) {
    let mut final_weights = [Quantized::zero(); 4];
    let mut final_bias = Quantized::zero();

    for _ in 0..epochs {
        let mut weight_gradient = [Quantized::zero(); 4];
        let mut bias_gradient = Quantized::zero();

        for j in 0..labels.len() {
            let prediction = get_prediction(final_weights, inputs[j], final_bias);
            let error = prediction - labels[j];

            // Compute gradients
            for m in 0..4 {
                weight_gradient[m] += (inputs[j][m] * error);
            }
            bias_gradient += error;
        }

        // Update weights and bias using the gradients
        for m in 0..4 {
            final_weights[m] -= (weight_gradient[m] * learning_rate * ratio);
        }
        final_bias -= (bias_gradient * learning_rate * ratio);
    }
    (final_weights, final_bias)
}

#[test]
fn test_training() {
    let inputs = [
        [
            Quantized { x: 334233 },
            Quantized { x: 229376 },
            Quantized { x: 91750 },
            Quantized { x: 13107 },
        ],
        [
            Quantized { x: 321126 },
            Quantized { x: 196608 },
            Quantized { x: 91750 },
            Quantized { x: 13107 },
        ],
        [
            Quantized { x: 308019 },
            Quantized { x: 209715 },
            Quantized { x: 85196 },
            Quantized { x: 13107 },
        ],
        [
            Quantized { x: 301465 },
            Quantized { x: 203161 },
            Quantized { x: 98304 },
            Quantized { x: 13107 },
        ],
        [
            Quantized { x: 327680 },
            Quantized { x: 235929 },
            Quantized { x: 91750 },
            Quantized { x: 13107 },
        ],
        [
            Quantized { x: 353894 },
            Quantized { x: 255590 },
            Quantized { x: 111411 },
            Quantized { x: 26214 },
        ],
        [
            Quantized { x: 301465 },
            Quantized { x: 222822 },
            Quantized { x: 91750 },
            Quantized { x: 19660 },
        ],
        [
            Quantized { x: 327680 },
            Quantized { x: 222822 },
            Quantized { x: 98304 },
            Quantized { x: 13107 },
        ],
        [
            Quantized { x: 288358 },
            Quantized { x: 190054 },
            Quantized { x: 91750 },
            Quantized { x: 13107 },
        ],
        [
            Quantized { x: 321126 },
            Quantized { x: 203161 },
            Quantized { x: 98304 },
            Quantized { x: 6553 },
        ],
        [
            Quantized { x: 353894 },
            Quantized { x: 242483 },
            Quantized { x: 98304 },
            Quantized { x: 13107 },
        ],
        [
            Quantized { x: 314572 },
            Quantized { x: 222822 },
            Quantized { x: 104857 },
            Quantized { x: 13107 },
        ],
        [
            Quantized { x: 314572 },
            Quantized { x: 196608 },
            Quantized { x: 91750 },
            Quantized { x: 6553 },
        ],
        [
            Quantized { x: 281804 },
            Quantized { x: 196608 },
            Quantized { x: 72089 },
            Quantized { x: 6553 },
        ],
        [
            Quantized { x: 380108 },
            Quantized { x: 262144 },
            Quantized { x: 78643 },
            Quantized { x: 13107 },
        ],
        [
            Quantized { x: 373555 },
            Quantized { x: 288358 },
            Quantized { x: 98304 },
            Quantized { x: 26214 },
        ],
        [
            Quantized { x: 353894 },
            Quantized { x: 255590 },
            Quantized { x: 85196 },
            Quantized { x: 26214 },
        ],
        [
            Quantized { x: 334233 },
            Quantized { x: 229376 },
            Quantized { x: 91750 },
            Quantized { x: 19660 },
        ],
        [
            Quantized { x: 373555 },
            Quantized { x: 249036 },
            Quantized { x: 111411 },
            Quantized { x: 19660 },
        ],
        [
            Quantized { x: 334233 },
            Quantized { x: 249036 },
            Quantized { x: 98304 },
            Quantized { x: 19660 },
        ],
        [
            Quantized { x: 353894 },
            Quantized { x: 222822 },
            Quantized { x: 111411 },
            Quantized { x: 13107 },
        ],
        [
            Quantized { x: 334233 },
            Quantized { x: 242483 },
            Quantized { x: 98304 },
            Quantized { x: 26214 },
        ],
        [
            Quantized { x: 301465 },
            Quantized { x: 235929 },
            Quantized { x: 65536 },
            Quantized { x: 13107 },
        ],
        [
            Quantized { x: 334233 },
            Quantized { x: 216268 },
            Quantized { x: 111411 },
            Quantized { x: 32768 },
        ],
        [
            Quantized { x: 314572 },
            Quantized { x: 222822 },
            Quantized { x: 124518 },
            Quantized { x: 13107 },
        ],
        [
            Quantized { x: 327680 },
            Quantized { x: 196608 },
            Quantized { x: 104857 },
            Quantized { x: 13107 },
        ],
        [
            Quantized { x: 327680 },
            Quantized { x: 222822 },
            Quantized { x: 104857 },
            Quantized { x: 26214 },
        ],
        [
            Quantized { x: 340787 },
            Quantized { x: 229376 },
            Quantized { x: 98304 },
            Quantized { x: 13107 },
        ],
        [
            Quantized { x: 340787 },
            Quantized { x: 222822 },
            Quantized { x: 91750 },
            Quantized { x: 13107 },
        ],
        [
            Quantized { x: 308019 },
            Quantized { x: 209715 },
            Quantized { x: 104857 },
            Quantized { x: 13107 },
        ],
    ];

    let labels = [
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
        Quantized { x: 0 },
    ];

    let epochs = 10;
    let learning_rate = Quantized::new(6553); //0.1  0.1/2^-16 6553.6
    let ratio = Quantized::new(2184); // 1/nr samples = 1/30 => (1/30)/2^-16 = 2184.53
    let (final_weights, final_bias) = train(epochs, inputs, labels, learning_rate, ratio);
    println(final_weights);
    println(final_bias);
    /*
    epoch = 1: [Quantized { x: 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffbfb0 }, Quantized { x: 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffd3dc }, Quantized { x: 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffed27 }, Quantized { x: 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593effffcda }]
    Quantized { x: 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593effff336 }
    epoch = 2: [Quantized { x: 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffabc1 }, Quantized { x: 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffc638 }, Quantized { x: 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffe747 }, Quantized { x: 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593effffbe6 }]
    Quantized { x: 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffef34 }
    epoch = 10:
    [Quantized { x: 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efff7992 }, Quantized { x: 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffa3e1 }, Quantized { x: 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffd880 }, Quantized { x: 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593effff981 }]
    Quantized { x: 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593efffe520 }
    */
}
