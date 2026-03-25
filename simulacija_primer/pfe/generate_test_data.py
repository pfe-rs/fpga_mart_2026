import random

DIMENSION = 32
DSIZE = 8
INPUT_SIZE = DIMENSION * DIMENSION
OUTPUT_SIZE = (DIMENSION - 2) * (DIMENSION - 2)

# Generate random input data
input_data = [random.randint(0, 255) for _ in range(INPUT_SIZE)]

# Compute expected output
expected_data = []
for row in range(1, DIMENSION - 1):
    for col in range(1, DIMENSION - 1):
        center_idx = row * DIMENSION + col
        center_val = input_data[center_idx]
        result = 2 * center_val
        if result > 255:
            result = 255
        expected_data.append(result)

# Format as SystemVerilog arrays
input_str = "logic [DSIZE-1:0] input_data [] = '{"
for i, val in enumerate(input_data):
    input_str += f"8'h{val:02x}, "
input_str = input_str.rstrip(", ") + "\n};"

expected_str = "logic [DSIZE-1:0] expected_data [] = '{"
for i, val in enumerate(expected_data):
    expected_str += f"8'h{val:02x}, "
expected_str = expected_str.rstrip(", ") + "\n};"

print("Input data:")
print(input_str)
print("\nExpected data:")
print(expected_str)