#!/usr/bin/env python3

import argparse
import sys
import time
from matplotlib import pyplot as plt

try:
    from jtag_uart_raw import JtagAtlantic
except ImportError as e:
    print("ERROR: cannot import jtag_uart_raw / JtagAtlantic")
    print("Make sure jtag_uart_raw.py is in the SAME folder as this script.")
    print("Original error:", e)
    sys.exit(1)


NUM_SAMPLES = 1024


def build_config_packet(sel: int, phase_inc: int) -> bytes:
    if not (0 <= sel <= 255):
        raise ValueError("sel must be 0..255")
    if not (0 <= phase_inc <= 0xFFFF):
        raise ValueError("phase_inc must be 0..65535")

    return bytes([
        sel & 0xFF,
        (phase_inc >> 8) & 0xFF,
        phase_inc & 0xFF,
    ])


def write_all(ja, data: bytes) -> None:
    offset = 0
    while offset < len(data):
        n = ja.write(data[offset:])
        if n < 0:
            raise IOError("Write failed")
        if n == 0:
            time.sleep(0.01)
            continue
        offset += n
    ja.flush()


def read_exact(ja, nbytes: int, timeout: float = 5.0) -> bytes:
    start = time.time()
    data = bytearray()

    while len(data) < nbytes:
        chunk = ja.read(nbytes - len(data))
        if chunk:
            data.extend(chunk)
        else:
            time.sleep(0.005)

        if time.time() - start > timeout:
            raise TimeoutError(
                f"Timeout: expected {nbytes} bytes, got {len(data)}"
            )

    return bytes(data)


def signed8_to_float_list(raw: bytes, normalize: bool = False):
    out = []
    for b in raw:
        val = b if b < 128 else b - 256   # convert unsigned byte to signed int8
        if normalize:
            out.append(float(val) / 128.0)
        else:
            out.append(float(val))
    return out


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--sel", type=int, required=True)
    parser.add_argument("--phase", type=int, required=True)
    parser.add_argument("--timeout", type=float, default=5.0)
    parser.add_argument("--cable", default=None)
    parser.add_argument("--device", type=int, default=-1)
    parser.add_argument("--instance", type=int, default=-1)
    parser.add_argument("--normalize", action="store_true")
    args = parser.parse_args()

    packet = build_config_packet(args.sel, args.phase)

    print("Opening JTAG Atlantic...")
    with JtagAtlantic(
        cable=args.cable,
        device=args.device,
        instance=args.instance,
        progname="signal_capture"
    ) as ja:
        print("Sending packet:", [f"0x{x:02X}" for x in packet])
        write_all(ja, packet)

        print(f"Reading {NUM_SAMPLES} samples...")
        raw_samples = read_exact(ja, NUM_SAMPLES, timeout=args.timeout)

    y = signed8_to_float_list(raw_samples, normalize=args.normalize)
    x = list(range(len(y)))

    print("First 16 samples:", y[:16])

    plt.figure(figsize=(12, 5))
    plt.plot(x, y)
    plt.title("Captured signal")
    plt.xlabel("Sample index")
    plt.ylabel("Amplitude")
    plt.grid(True)
    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    main()