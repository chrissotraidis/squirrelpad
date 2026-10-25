#!/usr/bin/env python3
"""Build the game-free iOS shell on a Mac, without a ROM or translated sources.

This developer route is separate from the existing full Mac build.
Publishing its result still requires PadMint's release gate and a tested module.
"""
import argparse
import importlib.util
import os
from pathlib import Path
import platform
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location("source_setup", ROOT / "scripts/setup-source.py")
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)


def run(*args, env=None):
    subprocess.run([str(arg) for arg in args], cwd=ROOT, check=True, env=env)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sdk", choices=("iphoneos", "iphonesimulator"), default="iphoneos")
    parser.add_argument("--jobs", type=int, choices=range(1, 17), default=4)
    args = parser.parse_args()
    if platform.system() != "Darwin" or platform.machine() != "arm64":
        parser.error("The public shell's Swift and Metal code requires an Apple Silicon Mac with Xcode.")
    run("xcodebuild", "-version")
    run("xcrun", "--sdk", "macosx", "metal", "--version")
    source = setup.prepare(Path(os.environ.get("SQUIRRELPAD_CHECKOUT", ROOT / "work/CBFD-Recompiled")))
    shaders = ROOT / "work/build-shader-host"
    run("cmake", "-S", source / "tools/rt64", "-B", shaders, "-G", "Ninja",
        "-DCMAKE_BUILD_TYPE=Release", "-DRT64_STATIC=ON", "-DZSTD_BUILD_PROGRAMS=OFF")
    run("cmake", "--build", shaders, "--target", "rt64", "--parallel", args.jobs)
    env = dict(os.environ, SQUIRRELPAD_CHECKOUT=str(source), SQUIRRELPAD_SHADER_HOST=str(shaders))
    run("/bin/bash", ROOT / "scripts/verify-rt64-ios.sh", args.sdk, env=env)
    build = ROOT / f"work/build-shell-{args.sdk}"
    run("cmake", "-S", ROOT, "-B", build, "-G", "Xcode", "-DCMAKE_SYSTEM_NAME=iOS",
        f"-DCMAKE_OSX_SYSROOT={args.sdk}", "-DCMAKE_OSX_ARCHITECTURES=arm64",
        "-DCMAKE_OSX_DEPLOYMENT_TARGET=17.0", f"-DSQUIRRELPAD_CONKER_SOURCE={source}",
        f"-DSQUIRRELPAD_RT64_ARCHIVE_DIR={ROOT / ('work/build-rt64-' + args.sdk)}",
        "-DSQUIRRELPAD_MODULE_SHELL=ON", "-DSQUIRRELPAD_SIM_INPUT=OFF")
    run("xcodebuild", "-project", build / "SquirrelPad.xcodeproj", "-target", "SquirrelPad",
        "-configuration", "Release", "-sdk", args.sdk, "-jobs", args.jobs,
        "CODE_SIGNING_ALLOWED=NO", "CODE_SIGNING_REQUIRED=NO")
    app = build / f"Release-{args.sdk}/SquirrelPad.app"
    run(sys.executable, ROOT / "scripts/audit-app.py", app, "--sdk", args.sdk,
        "--source", source, "--output", build / "package-audit.json")
    print(f"Empty module shell (not yet released): {app}", flush=True)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        sys.exit(str(error))
