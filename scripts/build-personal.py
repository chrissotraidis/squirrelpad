#!/usr/bin/env python3
"""Build a private SquirrelPad app from the player's supported US ROM."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import sys
import tempfile
import shutil

ROOT = Path(__file__).resolve().parent.parent


def run(*command, env=None):
    subprocess.run([str(part) for part in command], cwd=ROOT, env=env, check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--rom", required=True, type=Path)
    parser.add_argument("--sdk", choices=("iphoneos", "iphonesimulator", "macosx"), default="iphoneos")
    parser.add_argument("--output", type=Path, help="New unsigned IPA path (iphoneos only)")
    parser.add_argument("--jobs", type=int, default=4, choices=range(1, 17))
    args = parser.parse_args()
    if platform.system() != "Darwin" or platform.machine() != "arm64":
        parser.error("An Apple Silicon Mac with full Xcode is required.")
    if args.output and args.sdk != "iphoneos":
        parser.error("--output packages an iphoneos IPA only.")
    output = args.output.resolve() if args.output else None
    if output and output.exists():
        parser.error(f"Preserving existing output: {output}")
    rom = args.rom.resolve(strict=True)
    expected = json.loads((ROOT / "sources.lock.json").read_text())["rom"]
    with rom.open("rb") as stream:
        header = stream.read(4).hex()
        stream.seek(0)
        digest = hashlib.file_digest(stream, "sha1").hexdigest()
    if rom.stat().st_size != expected["size"] or header != expected["header"] or digest != expected["sha1"]:
        parser.error("Supply the supported 64 MiB US big-endian ROM; see README.md.")

    # Check the toolchain before downloading sources or generating private code.
    run("xcodebuild", "-version")
    run("xcrun", "--sdk", args.sdk, "--show-sdk-version")
    run("xcrun", "--sdk", "macosx", "metal", "--version")
    mac_sdk = subprocess.check_output(["xcrun", "--sdk", "macosx", "--show-sdk-path"], text=True).strip()
    source = Path(os.environ.get("SQUIRRELPAD_CHECKOUT", ROOT / "work/CBFD-Recompiled")).resolve()
    env = dict(os.environ, SQUIRRELPAD_CHECKOUT=str(source))
    run("/bin/bash", ROOT / "scripts/setup-source.sh", rom, env=env)
    generator = source / "tools/N64Recomp/build"
    run("cmake", "-S", source / "tools/N64Recomp", "-B", generator, "-G", "Ninja",
        "-DCMAKE_BUILD_TYPE=Release", f"-DCMAKE_OSX_SYSROOT={mac_sdk}")
    run("cmake", "--build", generator, "--target", "N64RecompCLI", "RSPRecomp", "RecompModTool",
        "--parallel", args.jobs)
    # CMake checks this input ledger against all generator inputs. Regenerate
    # when any input changes; otherwise keep expensive native object caches.
    ledger = source / "RecompiledFuncs/inputs.sha256"
    current = ledger.is_file()
    if current:
        for line in ledger.read_text().splitlines():
            sha, name = line.split(maxsplit=1)
            path = source / name
            if not path.is_file() or hashlib.sha256(path.read_bytes().replace(b"\r", b"")).hexdigest() != sha:
                current = False
                break
    if not current:
        run(sys.executable, source / "recomp/recompile.py")
    host = source / "host/build-macos-metal"
    run("cmake", "-S", source / "host", "-B", host, "-G", "Ninja",
        "-DCMAKE_C_COMPILER=clang", "-DCMAKE_CXX_COMPILER=clang++",
        "-DCMAKE_BUILD_TYPE=RelWithDebInfo", "-DCONKER_RT64=ON", f"-DCMAKE_OSX_SYSROOT={mac_sdk}")
    run("cmake", "--build", host, "--parallel", args.jobs)
    if args.sdk == "macosx":
        print(f"Local Mac executable: {host / 'ConkerRecomp'}")
        return
    run("/bin/bash", ROOT / "scripts/verify-rt64-ios.sh", args.sdk, env=env)
    build = ROOT / f"work/build-app-{args.sdk}"
    tag = os.environ.get("SQUIRRELPAD_RT64_BUILD_TAG", "")
    run("cmake", "-S", ROOT, "-B", build, "-G", "Xcode", "-DCMAKE_SYSTEM_NAME=iOS",
        f"-DCMAKE_OSX_SYSROOT={args.sdk}", "-DCMAKE_OSX_ARCHITECTURES=arm64",
        "-DCMAKE_OSX_DEPLOYMENT_TARGET=17.0", f"-DSQUIRRELPAD_CONKER_SOURCE={source}",
        f"-DSQUIRRELPAD_RT64_ARCHIVE_DIR={ROOT / ('work/build-rt64-' + args.sdk + tag)}",
        "-DSQUIRRELPAD_SIM_INPUT=OFF")
    run("xcodebuild", "-project", build / "SquirrelPad.xcodeproj", "-target", "SquirrelPad",
        "-configuration", "Release", "-sdk", args.sdk, "-jobs", args.jobs,
        "CODE_SIGNING_ALLOWED=NO", "CODE_SIGNING_REQUIRED=NO")
    app = build / f"Release-{args.sdk}/SquirrelPad.app"
    run(sys.executable, ROOT / "scripts/audit-app.py", app, "--sdk", args.sdk,
        "--source", source, "--output", build / "package-audit.json")
    if output:
        output.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(prefix="squirrelpad-", dir=output.parent) as temporary:
            staging = Path(temporary)
            shutil.copytree(app, staging / "Payload/SquirrelPad.app")
            archive = staging / "personal.ipa"
            run("ditto", "-c", "-k", "--norsrc", "--keepParent", staging / "Payload", archive)
            # Never replace another result that appeared during the build.
            os.link(archive, output)
        print(f"Personal unsigned IPA: {output}")
    else:
        print(f"Personal app: {app}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, subprocess.CalledProcessError) as error:
        sys.exit(str(error))
