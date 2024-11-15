use crate::quantized::Quantized;

fn approx_sigmoid(x: Quantized) -> Quantized {
    // TODO implement // https://github.com/data61/MP-SPDZ/blob/master/Compiler/ml.py#L110
    Quantized::zero()
}

fn get_prediction(weights: [Quantized; 4], inputs: [Quantized; 4]) -> Quantized {
    // let z = weights dot_product inputs
    let mut z = Quantized::zero();
    for i in 0..4 {
        z += weights[i] * inputs[i];
    }
    approx_sigmoid(z)
}

fn train(
    epochs: u64,
    inputs: [[Quantized; 4]; 30],
    labels: [Quantized],
    learning_rate: Quantized,
    ratio: Quantized,
) -> ([Quantized; 4], Quantized) {
    let mut final_weights = [Quantized::zero(); 4];
    let mut final_bias = Quantized::zero();

    for _ in 0..epochs {
        let mut weight_gradient = [Quantized::zero(); 4];
        let mut bias_gradient = Quantized::zero();

        for j in 0..labels.len() {
            let prediction = get_prediction(final_weights, inputs[j]);
            let error = prediction - labels[j];

            // Compute gradients
            for m in 0..4 {
                weight_gradient[m] = weight_gradient[m] + (inputs[j][m] * error);
            }
            bias_gradient = bias_gradient + error;
        }

        // Update weights and bias using the gradients
        for m in 0..4 {
            final_weights[m] = final_weights[m] - (weight_gradient[m] * learning_rate * ratio);
        }
        final_bias = final_bias - (bias_gradient * learning_rate * ratio);
    }
    (final_weights, final_bias)
}

#[test]
fn test_training() {
    // TODO
}
