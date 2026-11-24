#!/usr/bin/env python3
"""Static checks for the Swift project. This does not compile or launch iOS."""

from __future__ import annotations

import plistlib
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SWIFT = list(ROOT.rglob("*.swift"))
FORBIDDEN = (
    "import WebKit",
    "import CoreBluetooth",
    "import CoreLocation",
    "import MapKit",
    "import AVFoundation",
    "import MediaPlayer",
    "WKWebView",
    "UIWebView",
    "CBCentralManager",
    "CLLocationManager",
    "已连接",
)
errors: list[str] = []


def fail(message: str) -> None:
    errors.append(message)


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


plist = plistlib.loads((ROOT / "Config" / "Info.plist").read_bytes())
orientations = plist.get("UISupportedInterfaceOrientations", [])
if orientations != [
    "UIInterfaceOrientationLandscapeLeft",
    "UIInterfaceOrientationLandscapeRight",
]:
    fail(f"unexpected orientations: {orientations}")
for key in plist:
    if "UsageDescription" in key or key.startswith("NSBluetooth") or key.startswith("NSLocation"):
        fail(f"unexpected permission key {key}")

project = read(ROOT / "DriveDial.xcodeproj" / "project.pbxproj")
for needle in (
    "PRODUCT_BUNDLE_IDENTIFIER = local.drivedial.demo",
    "CODE_SIGNING_ALLOWED = NO",
    "INFOPLIST_FILE = Config/Info.plist",
    "productName = DriveDialCore",
    "PBXFileSystemSynchronizedRootGroup",
    "com.apple.product-type.application",
):
    if needle not in project:
        fail(f"pbxproj missing {needle}")

package = read(ROOT / "Package.swift")
if "DriveDialCore" not in package:
    fail("package product missing")

sources = [path for path in SWIFT if "Tests/" not in path.as_posix()]
joined = "\n".join(read(path) for path in sources)
for token in FORBIDDEN:
    if token in joined:
        fail(f"forbidden text present: {token}")
test_text = "\n".join(read(path) for path in SWIFT if path not in sources)
for token in FORBIDDEN:
    if token == "已连接":
        continue
    if token in test_text:
        fail(f"forbidden text present in tests: {token}")
for token in ("static let width = 874.0", "static let height = 402.0", "height: 83.23", "width: 60.41"):
    if token not in joined:
        fail(f"design constant missing: {token}")
if "RearLineArt" in joined or "TopLineArt" in joined:
    fail("line-art car is still in the app")
if "VehicleDataProvider" not in joined or "func current(now: Date)" not in joined:
    fail("read-only provider missing")
if "import SwiftUI" not in joined:
    fail("SwiftUI app sources missing")
if "drawsUnderline = false" not in joined:
    fail("hero underline flag is not off")
face = read(ROOT / "DriveDial" / "Screens" / "ClusterFace.swift")
if "ruleY" in face or "speedRule" in face:
    fail("hero underline is still drawn")
road = face.split("struct RoadTrapezoid", 1)[-1]
if "closeSubpath" in road:
    fail("road path is still closed")
if "RoadOutline.strokes()" not in face:
    fail("road view does not use the open outline")

icon = ROOT / "DriveDial" / "Assets.xcassets" / "AppIcon.appiconset" / "AppIcon.png"
if not icon.is_file() or icon.read_bytes()[:8] != b"\x89PNG\r\n\x1a\n":
    fail("app icon png missing")
def png_size(path: Path) -> tuple[int, int]:
    blob = path.read_bytes()
    if blob[:8] != b"\x89PNG\r\n\x1a\n":
        fail(f"{path.name} is not a png")
        return (0, 0)
    import struct
    return struct.unpack(">II", blob[16:24])

rear = ROOT / "DriveDial/Assets.xcassets/CarRear.imageset/car-rear-elevated.png"
top = ROOT / "DriveDial/Assets.xcassets/CarTop.imageset/car-topdown.png"
if png_size(rear) != (630, 868):
    fail(f"rear bitmap size {png_size(rear)} is not 630x868")
if png_size(top) != (626, 1004):
    fail(f"top bitmap size {png_size(top)} is not 626x1004")

required = [
    ROOT / "DriveDial.xcodeproj" / "xcshareddata" / "xcschemes" / "DriveDial.xcscheme",
    ROOT / "Docs" / "DESIGN.md",
    ROOT / "Docs" / "GITHUB-MIGRATION.md",
    ROOT / "Tools" / "extract_v6_assets.py",
    ROOT / "Tests" / "DriveDialCoreTests" / "LayoutTests.swift",
]
for path in required:
    if not path.is_file():
        fail(f"missing {path.relative_to(ROOT)}")

print("iOS build: NOT RUN (no Xcode on this machine)")
print(f"swift files: {len(SWIFT)}")
if errors:
    print("FAILED")
    for item in errors:
        print(f"- {item}")
    sys.exit(1)
print("static checks: passed")
