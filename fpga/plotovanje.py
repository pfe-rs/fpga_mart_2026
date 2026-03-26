from matplotlib import pyplot as plt

x = []
y = []

with open("samples.txt", "r") as f:
    for line in f:
        i, val = line.strip().split()
        x.append(int(i))
        y.append(float(val))

plt.figure(figsize=(12, 5))
plt.plot(x, y)
plt.title("Captured signal")
plt.xlabel("Sample index")
plt.ylabel("Amplitude")
plt.grid(True)
plt.tight_layout()
plt.show()