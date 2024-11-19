POWER_SCALE = 16
MODULUS = 21888242871839275222246405745257275088548364400416034343698204186575808495617

if __name__ == "__main__":
    file = open("scripts/quantized.txt")
    for line in file.readlines():
        int_rep = int(line, base=0)
        print("Field value:", int_rep)

        # Check if the values are negative and convert them.


        float_value = int_rep * (2 ** -POWER_SCALE)
        print("Float value:", float_value)

