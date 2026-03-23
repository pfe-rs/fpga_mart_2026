import json

with open('circuit2.json', 'r') as f:
    data = json.load(f)

# Devices are usually basic gates (AND, OR, etc.)
num_devices = len(data.get('devices', {}))

# Subcircuits are typically hierarchical blocks or complex cells
num_subcircuits = len(data.get('subcircuits', {}))

total_cells = num_devices + num_subcircuits

print(f"Devices: {num_devices}")
print(f"Subcircuits: {num_subcircuits}")
print(f"Total 'Cells': {total_cells}")