#!/usr/bin/env python3
"""Generate Prompto's source app-icon PNGs with no third-party deps.

Produces:
  assets/icon/icon.png             1024x1024 opaque — teal square + white ">_"
  assets/icon/icon_foreground.png  1024x1024 transparent — white ">_" only
                                   (Android adaptive foreground; safe-zone padded)

The glyph is a terminal-style prompt mark (>_), fitting a prompt-engineering app.
Re-run after tweaking geometry; flutter_launcher_icons consumes the output.
"""
from __future__ import annotations

import math
import struct
import zlib
from pathlib import Path

W = H = 1024
TEAL = (18, 165, 148)  # #12A594 brand seed
WHITE = (255, 255, 255)

# Glyph strokes as (x0, y0, x1, y1, half_thickness).
SEGMENTS = [
    (372, 372, 580, 512, 42),  # chevron upper arm
    (580, 512, 372, 652, 42),  # chevron lower arm
    (612, 648, 768, 648, 34),  # underscore / cursor
]
BBOX = (320, 320, 812, 700)  # where glyph pixels can live (perf guard)


def _dist_to_segment(px: float, py: float, ax: float, ay: float, bx: float, by: float) -> float:
    dx, dy = bx - ax, by - ay
    length_sq = dx * dx + dy * dy
    if length_sq == 0:
        return math.hypot(px - ax, py - ay)
    t = max(0.0, min(1.0, ((px - ax) * dx + (py - ay) * dy) / length_sq))
    return math.hypot(px - (ax + t * dx), py - (ay + t * dy))


def _glyph_coverage(x: int, y: int) -> float:
    """0..1 white coverage at pixel center, with ~1.5px anti-aliased edge."""
    if not (BBOX[0] <= x <= BBOX[2] and BBOX[1] <= y <= BBOX[3]):
        return 0.0
    best = 0.0
    for ax, ay, bx, by, half in SEGMENTS:
        d = _dist_to_segment(x + 0.5, y + 0.5, ax, ay, bx, by)
        cov = max(0.0, min(1.0, (half + 0.75 - d) / 1.5))
        if cov > best:
            best = cov
    return best


def _build(opaque_bg: bool) -> bytes:
    """Return PNG scanlines (filter byte 0 per row) for the RGBA raster."""
    rows = bytearray()
    for y in range(H):
        rows.append(0)  # filter: none
        row = bytearray(W * 4)
        for x in range(W):
            cov = _glyph_coverage(x, y)
            if opaque_bg:
                r = round(TEAL[0] * (1 - cov) + WHITE[0] * cov)
                g = round(TEAL[1] * (1 - cov) + WHITE[1] * cov)
                b = round(TEAL[2] * (1 - cov) + WHITE[2] * cov)
                a = 255
            else:
                r, g, b = WHITE
                a = round(255 * cov)
            i = x * 4
            row[i:i + 4] = bytes((r, g, b, a))
        rows += row
    return bytes(rows)


def _write_png(path: Path, raw: bytes) -> None:
    def chunk(tag: bytes, data: bytes) -> bytes:
        return (
            struct.pack(">I", len(data))
            + tag
            + data
            + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
        )

    ihdr = struct.pack(">IIBBBBB", W, H, 8, 6, 0, 0, 0)  # 8-bit RGBA
    png = (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", ihdr)
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )
    path.write_bytes(png)
    print(f"wrote {path} ({len(png) // 1024} KiB)")


def main() -> None:
    out = Path("assets/icon")
    out.mkdir(parents=True, exist_ok=True)
    _write_png(out / "icon.png", _build(opaque_bg=True))
    _write_png(out / "icon_foreground.png", _build(opaque_bg=False))


if __name__ == "__main__":
    main()
