pub mod crypto;

use crate::crypto::ml::train_multi_class;
use crate::crypto::quantized::Quantized;

fn main(
    inputs: [[Quantized; 4]; 30],
    labels: [[Quantized; 30]; 3],
) -> pub [([Quantized; 4], Quantized); 3] {
    let epochs = 10;
    let learning_rate_ratio = Quantized::new(218);
    let parameters_train = train_multi_class(epochs, inputs, labels, learning_rate_ratio);
    parameters_train
}
