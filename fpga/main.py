from scipy import signal
import numpy as np
from pylab import figure, clf, plot, xlabel, ylabel, xlim, ylim, title, grid, axes, show
import json

sample_rate = 10 #1kHz sampling frequency
numTaps = 4
cutoff_freq = 100.0
nyquist = sample_rate /2.0
normalizedCutoff = cutoff_freq / nyquist #0.2

t = np.linspace(0,1,sample_rate,False,dtype=float)
print(t)
x = np.sin(2* np.pi * 3 *t) + np.sin(2 * np.pi * 250 * t)
print(len(x))
#b = signal.firwin(numTaps,normalizedCutoff,window="hamming",pass_zero=True)
b = np.array([0.25, 0.25, 0.25, 0.25])
print(f"B: {b}")
scale = 127
b_q7 = np.round(b*127).astype(np.int8)
x_q7 = np.round(x*127).astype(np.int8)

y_q15 = np.zeros(len(x_q7), dtype=np.int16)

for n in range(len(x_q7)):
    acc = 0
    for k in range(numTaps):
        if n - k >= 0:
            acc += int(x_q7[n-k]) * int(b_q7[k])
    y_q15[n] = acc

a = [1.0]

# fixed point?
x_plot = x_q7 / 127.0
y_plot = y_q15/ (127.0 * 127.0)

figure(1)

plot(t, x_plot) # origininal signal
plot(t, y_plot) # filtriran signal

file_path = "results.json"
data_to_save = {"t": list(t), "x" : list(x),"x_plot": list(x_plot), "y_plot":list(y_plot),"b":list(b)} 
with open(file_path, 'w') as json_file:
    json.dump(data_to_save, json_file, indent=4)



xlabel('t')
grid(True)

show()

# Exportuj ulazne podatke za SystemVerilog
with open("input_samples.hex", "w") as f:
    for val in x_q7:
        # Prvo pretvaramo u običan int, pa onda maskiramo na 8 bita
        safe_val = int(val) & 0xFF
        f.write(f"{safe_val:02x}\n")

# Isto uradi i za rezultate (16-bitni mask 0xFFFF)
with open("expected_results.hex", "w") as f:
    for val in y_q15:
        safe_val = int(val) & 0xFFFF
        f.write(f"{safe_val:04x}\n")