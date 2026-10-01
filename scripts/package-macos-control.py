#!/usr/bin/env python3
"""Create a local macOS comparison bundle from an already-built host."""
import argparse
from pathlib import Path
import plistlib
import shutil

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("build_dir", type=Path)
args = parser.parse_args()
build = args.build_dir.resolve()
for name in ("ConkerRecomp", "assets"):
    if not (build / name).exists():
        parser.error(f"Missing build input: {build / name}")

app = build / "SquirrelPad macOS Control.app"
if app.exists():
    parser.error(f"Bundle already exists; preserve it or choose another build: {app}")
mac = app / "Contents" / "MacOS"
resources = app / "Contents" / "Resources"
mac.mkdir(parents=True)
resources.mkdir()
# Launch the native executable directly. A shell wrapper prevented CUA from
# inspecting the SDL window on this machine. Resources resolve inside the bundle.
shutil.copy2(build / "ConkerRecomp", mac / "ConkerRecomp")
(resources / "assets").symlink_to(build / "assets", target_is_directory=True)
with (app / "Contents" / "Info.plist").open("wb") as output:
    plistlib.dump({
        "CFBundleExecutable": "ConkerRecomp",
        "CFBundleIdentifier": "com.chrissotraidis.squirrelpad.macoscontrol.local",
        "CFBundleName": "SquirrelPad macOS Control",
        "CFBundlePackageType": "APPL",
        "NSHighResolutionCapable": True,
    }, output)
print(app)
