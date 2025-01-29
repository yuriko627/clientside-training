use noir_mpc_ml::ml::{train, train_multi_class};
use fixedpoint::quantized::Quantized;

fn main(x: Field, y: pub Field) {
    assert(x != y);
}

#[test]
fn test_train() {
    let inputs = [
        // INPUTS_PLACEHOLDER
    ];

    let labels = [
        // LABELS_PLACEHOLDER
    ];

    let epochs = // EPOCHS_PLACEHOLDER;

    let learning_rate_ratio = Quantized::new(
        // LEARNING_RATE_RATIO_PLACEHOLDER
    );

    let parameters = train_multi_class(
        epochs,
        inputs,
        labels,
        learning_rate_ratio,
    );

    println(parameters);
}
