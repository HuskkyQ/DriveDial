#!/usr/bin/env python3
"""Decode bitmaps embedded in the v6 HTML. Never synthesizes a car image."""

from __future__ import annotations

import base64
import re
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REVIEW = ROOT / "Tools" / "extracted"
ASSET_ROOT = ROOT / "DriveDial" / "Assets.xcassets"

DATA_URI = re.compile(
    r"data:image/(png|jpeg|jpg|webp);base64,([A-Za-z0-9+/=\s]+)",
    re.IGNORECASE,
)


def dimensions(blob: bytes, kind: str) -> tuple[int, int] | None:
    if kind == "png" and blob.startswith(b"\x89PNG") and len(blob) >= 24:
        width, height = struct.unpack(">II", blob[16:24])
        return width, height
    if kind in {"jpeg", "jpg"}:
        return jpeg_size(blob)
    return None


def jpeg_size(blob: bytes) -> tuple[int, int] | None:
    index = 2
    while index + 9 < len(blob):
        if blob[index] != 0xFF:
            index += 1
            continue
        marker = blob[index + 1]
        if marker in {0xC0, 0xC1, 0xC2}:
            height, width = struct.unpack(">HH", blob[index + 5 : index + 9])
            return width, height
        if marker == 0xD8 or marker == 0xD9:
            index += 2
            continue
        length = struct.unpack(">H", blob[index + 2 : index + 4])[0]
        index += 2 + length
    return None


def classify(window: str) -> str | None:
    rear = ("后上", "后视", "车模", "rear", "car-rear", "driving")
    top = ("胎压", "俯视", "top", "tire", "tyre")
    if any(token in window for token in top):
        return "top"
    if any(token in window for token in rear):
        return "rear"
    return None


def write_imageset(name: str, filename: str, blob: bytes) -> None:
    folder = ASSET_ROOT / f"{name}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    (folder / filename).write_bytes(blob)
    (folder / "Contents.json").write_text(
        """{
  "images" : [
    {
      "filename" : "%s",
      "idiom" : "universal"
    }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
"""
        % filename,
        encoding="utf-8",
    )


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: extract_v6_assets.py DESIGN.html", file=sys.stderr)
        return 2
    html_path = Path(sys.argv[1])
    text = html_path.read_text(encoding="utf-8", errors="replace")
    found = []
    for match in DATA_URI.finditer(text):
        kind = match.group(1).lower()
        blob = base64.b64decode(re.sub(r"\s+", "", match.group(2)))
        start = max(0, match.start() - 240)
        window = text[start : match.start()]
        found.append((kind, blob, classify(window), dimensions(blob, kind)))
    if not found:
        print("no embedded images")
        return 1
    REVIEW.mkdir(parents=True, exist_ok=True)
    assigned: dict[str, tuple[str, bytes]] = {}
    for index, (kind, blob, role, size) in enumerate(found, start=1):
        suffix = "jpg" if kind in {"jpeg", "jpg"} else kind
        review_path = REVIEW / f"embedded-{index}.{suffix}"
        review_path.write_bytes(blob)
        print(f"{review_path.name} role={role or 'unknown'} bytes={len(blob)} size={size}")
        if role and role not in assigned:
            assigned[role] = (review_path.name, blob)
    if set(assigned) == {"rear", "top"}:
        write_imageset("CarRear", assigned["rear"][0], assigned["rear"][1])
        write_imageset("CarTop", assigned["top"][0], assigned["top"][1])
        print("wrote CarRear and CarTop")
        return 0
    print("left images in Tools/extracted; asset catalog unchanged")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
