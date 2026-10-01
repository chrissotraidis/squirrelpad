#!/usr/bin/env python3
"""Create a local macOS comparison bundle from an already-built host."""
import argparse
import hashlib
from pathlib import Path
import plistlib
import shutil

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("build_dir", type=Path)
parser.add_argument("--refresh", action="store_true",
                    help="Refresh this script's existing local comparison bundle")
args = parser.parse_args()
build = args.build_dir.resolve()
for name in ("ConkerRecomp", "assets"):
    if not (build / name).exists():
        parser.error(f"Missing build input: {build / name}")

app = build / "SquirrelPad macOS Control.app"
if app.exists():
    if not args.refresh:
        parser.error(f"Bundle already exists; use --refresh to update it: {app}")
    with (app / "Contents" / "Info.plist").open("rb") as source:
        metadata = plistlib.load(source)
    if metadata.get("CFBundleIdentifier") != "com.chrissotraidis.squirrelpad.macoscontrol.local":
        parser.error(f"Refusing to refresh an unrelated bundle: {app}")
mac = app / "Contents" / "MacOS"
resources = app / "Contents" / "Resources"
asset_link = resources / "assets"
if not asset_link.is_symlink() and asset_link.exists():
    parser.error(f"Expected this script's asset symlink: {asset_link}")
mac.mkdir(parents=True, exist_ok=True)
resources.mkdir(exist_ok=True)
# Launch the native executable directly. A shell wrapper prevented CUA from
# inspecting the SDL window on this machine. Resources resolve inside the bundle.
shutil.copy2(build / "ConkerRecomp", mac / "ConkerRecomp")
if asset_link.is_symlink():
    asset_link.unlink()
asset_link.symlink_to(build / "assets", target_is_directory=True)
with (app / "Contents" / "Info.plist").open("wb") as output:
    plistlib.dump({
        "CFBundleExecutable": "ConkerRecomp",
        "CFBundleIdentifier": "com.chrissotraidis.squirrelpad.macoscontrol.local",
        "CFBundleName": "SquirrelPad macOS Control",
        "CFBundlePackageType": "APPL",
        "NSHighResolutionCapable": True,
    }, output)
print(app)
print("Executable SHA256:", hashlib.sha256((mac / "ConkerRecomp").read_bytes()).hexdigest())
