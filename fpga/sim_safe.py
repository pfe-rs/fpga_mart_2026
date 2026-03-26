#!/usr/bin/env python3
import argparse
import csv
import sys
import time

from jtag_uart_raw import JtagAtlantic

NUM_SAMPLES = 1024


def build_config_packet(sel: int, phase_inc: int) -> bytes:
    if not (0 <= sel <= 255):
        raise ValueError("sel must be 0..255")
    if not (0 <= phase_inc <= 0xFFFF):
        raise ValueError("phase_inc must be 0..65535")
    return bytes([sel & 0xFF, (phase_inc >> 8) & 0xFF, phase_inc & 0xFF])


def write_all(ja, data: bytes) -> None:
    off = 0
    while off < len(data):
        n = ja.write(data[off:])
        if n == 0:
            time.sleep(0.01)
            continue
        off += n
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
            raise TimeoutError(f"Timeout: expected {nbytes}, got {len(data)}")
    return bytes(data)


def signed8_to_float_list(raw: bytes, normalize: bool = False):
    out = []
    for b in raw:
        val = b if b < 128 else b - 256
        out.append(float(val) / 128.0 if normalize else float(val))
    return out


def ascii_plot(samples, width=100, height=24):
    if not samples:
        return
    mn = min(samples)
    mx = max(samples)
    span = mx - mn if mx != mn else 1.0
    step = max(1, len(samples) // width)
    reduced = samples[::step][:width]
    canvas = [[" " for _ in range(len(reduced))] for _ in range(height)]
    for x, val in enumerate(reduced):
        y = int((val - mn) / span * (height - 1))
        y = height - 1 - y
        canvas[y][x] = "*"
    for row in canvas:
        print("".join(row))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--sel", type=int, required=True)
    ap.add_argument("--phase", type=int, required=True)
    ap.add_argument("--timeout", type=float, default=5.0)
    ap.add_argument("--device", type=int, default=2)
    ap.add_argument("--instance", type=int, default=0)
    ap.add_argument("--normalize", action="store_true")
    ap.add_argument("--csv", default="samples.csv")
    args = ap.parse_args()

    packet = build_config_packet(args.sel, args.phase)
    with JtagAtlantic(device=args.device, instance=args.instance) as ja:
        print("Connected:", ja.get_info())
        # flush stale data
        time.sleep(0.1)
        _ = ja.read(4096)
        print("Sending packet:", [f"0x{x:02X}" for x in packet])
        write_all(ja, packet)
        raw = read_exact(ja, NUM_SAMPLES, timeout=args.timeout)

    y = signed8_to_float_list(raw, normalize=args.normalize)
    print("First 16 samples:", y[:16])
    with open(args.csv, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["index", "value"])
        for i, v in enumerate(y):
            w.writerow([i, v])
    print(f"Saved {len(y)} samples to {args.csv}")
    ascii_plot(y)


if __name__ == "__main__":
    sys.exit(main())
