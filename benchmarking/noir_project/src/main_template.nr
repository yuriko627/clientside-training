use noir_mpc_ml::ml::{train, train_multi_class};
use noir_mpc_ml::quantized::Quantized;

fn main(x: Field, y: pub Field) {
    assert(x != y);
}

#[test]
fn test_train() {
    let inputs = [
        // INPUTS_PLACEHOLDER
    ];

    let labels_0 = [
        // LABELS_0_PLACEHOLDER
    ];

    let labels_1 = [
        // LABELS_1_PLACEHOLDER
    ];

    let label_2 = [
        // LABELS_2_PLACEHOLDER
    ];

    let epochs = // EPOCHS_PLACEHOLDER;

    let learning_rate = Quantized::new(6554); // 0.1
    let ratio = Quantized::new(2185); // 1/nr samples = 1/30
    let parameters = train_multi_class(
        epochs,
        inputs,
        [labels_0, labels_1, label_2],
        learning_rate,
        ratio,
    );
    println(parameters);
}
