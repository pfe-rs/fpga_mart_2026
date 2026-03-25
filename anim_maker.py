#!/usr/bin/env python3
"""
Generate a GIF animation of a 4-tap FIR filter with signed 8-bit coefficients.
The animation illustrates the convolution process: for each output sample,
it shows the input samples in the filter's delay line, the coefficient values,
the individual products, and the final sum.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib.patches import Rectangle
import os

# =============================================================================
# Filter parameters
# =============================================================================
# 4 taps, signed 8-bit coefficients (range -128 to 127)
coeffs = np.array([32, 64, 32, 16], dtype=np.int8)   # example coefficients
num_taps = len(coeffs)

# Input signal: 50 samples, signed 8-bit range
t = np.linspace(0, 4 * np.pi, 50)
input_signal = (100 * np.sin(t)).astype(np.int8)   # sine wave, amplitude 100

# Pad input with zeros at start to handle initial delay line
padded_input = np.concatenate((np.zeros(num_taps - 1, dtype=np.int8), input_signal))

# Compute output using convolution
output_signal = np.convolve(padded_input, coeffs, mode='valid')  # length = len(input_signal)

# =============================================================================
# Animation setup
# =============================================================================
fig, axes = plt.subplots(3, 1, figsize=(10, 8), gridspec_kw={'height_ratios': [2, 1, 2]})
fig.subplots_adjust(hspace=0.4)

# Subplot 1: Input signal with moving window
ax1 = axes[0]
ax1.set_title('Input Signal')
ax1.set_xlabel('Sample Index')
ax1.set_ylabel('Amplitude (signed 8-bit)')
ax1.set_ylim(-128, 128)
ax1.grid(True)

# Plot full input signal
x_vals = np.arange(len(input_signal))
line_input, = ax1.plot(x_vals, input_signal, 'b-', label='Input')
# Highlighted window (will be updated)
window_rect = Rectangle((0, -128), num_taps, 256, facecolor='yellow', alpha=0.3, edgecolor='none')
ax1.add_patch(window_rect)

# Subplot 2: Coefficient bar chart
ax2 = axes[1]
ax2.set_title('Filter Coefficients (signed 8-bit)')
ax2.set_xlabel('Tap Index')
ax2.set_ylabel('Value')
ax2.set_xticks(range(num_taps))
ax2.set_ylim(-128, 128)
bars_coeff = ax2.bar(range(num_taps), coeffs, color='orange')

# Subplot 3: Products and sum
ax3 = axes[2]
ax3.set_title('Current Products and Sum')
ax3.set_xlabel('Tap Index')
ax3.set_ylabel('Product Value')
ax3.set_xticks(range(num_taps))
ax3.set_ylim(-20000, 20000)  # allow for product range
products_bars = ax3.bar(range(num_taps), np.zeros(num_taps), color='green')
sum_text = ax3.text(0.5, 0.95, 'Sum = 0', transform=ax3.transAxes,
                    ha='center', va='top', fontsize=12, bbox=dict(facecolor='white', alpha=0.8))

# Additional subplot for output signal (optional) - we add a small inset or another subplot?
# Let's add a small axes within ax3 for output building
ax_out = ax3.inset_axes([0.7, 0.05, 0.28, 0.3])
ax_out.set_title('Output Signal')
ax_out.set_xlabel('Sample')
ax_out.set_ylabel('Value')
ax_out.set_ylim(-40000, 40000)
out_line, = ax_out.plot([], [], 'r-')
out_points, = ax_out.plot([], [], 'ro', markersize=3)

# Pre-compute all products for animation (optional, to avoid recomputation)
# We'll compute on the fly but it's fine.

# =============================================================================
# Animation function
# =============================================================================
def update(frame):
    """Update the plot for output index `frame`."""
    # frame corresponds to output sample index (0..len(output_signal)-1)
    # The input samples used are padded_input[frame : frame+num_taps]
    start_idx = frame
    end_idx = frame + num_taps
    window_samples = padded_input[start_idx:end_idx]
    # Compute products
    products = window_samples * coeffs
    total = np.sum(products)

    # Update input window rectangle
    window_rect.set_xy((start_idx, -128))  # x, y of bottom-left corner
    window_rect.set_width(num_taps)

    # Update products bar heights
    for bar, prod in zip(products_bars, products):
        bar.set_height(prod)

    # Update sum text
    sum_text.set_text(f'Sum = {total}')

    # Update output plot
    out_line.set_data(np.arange(frame+1), output_signal[:frame+1])
    out_points.set_data(np.arange(frame+1), output_signal[:frame+1])

    # Set limits for output plot
    ax_out.set_xlim(0, len(output_signal)-1)
    if frame > 0:
        y_min = min(output_signal[:frame+1])
        y_max = max(output_signal[:frame+1])
        margin = max(1, (y_max - y_min) * 0.1)
        ax_out.set_ylim(y_min - margin, y_max + margin)

    return (line_input, window_rect, *products_bars, sum_text, out_line, out_points)

# Create animation
num_frames = len(output_signal)
ani = animation.FuncAnimation(fig, update, frames=num_frames,
                              interval=200, blit=True, repeat=False)

# =============================================================================
# Save as GIF
# =============================================================================
output_gif = 'fir_filter_animation.gif'
print(f"Saving animation to {output_gif} ...")
# Use PillowWriter to write GIF (requires pillow)
writer = animation.PillowWriter(fps=5, bitrate=500)
ani.save(output_gif, writer=writer)
print("Done.")

# Optionally show the animation
# plt.show()