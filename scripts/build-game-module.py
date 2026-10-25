#!/usr/bin/env python3
"""Build a private iOS game module locally, using PadMint's shared iOS toolchain."""
import argparse
import importlib.util
import os
import platform
import shutil
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parent.parent
spec = importlib.util.spec_from_file_location("source_setup", ROOT / "scripts/setup-source.py")
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)


def run(*args, env=None):
    subprocess.run([str(arg) for arg in args], cwd=ROOT, check=True, env=env)


def generator_environment():
    env = dict(os.environ)
    if os.name != "nt" or shutil.which("cl", path=env.get("PATH")):
        return env
    installer = Path(env.get("ProgramFiles(x86)", r"C:\Program Files (x86)")) / "Microsoft Visual Studio/Installer/vswhere.exe"
    if not installer.is_file():
        raise ValueError("Install Visual Studio Build Tools with Desktop development with C++ and a Windows SDK, then run PadMint again.")
    native_arm64 = platform.machine().lower() in ("arm64", "aarch64")
    requirements = ["-requires", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64"]
    if native_arm64:
        requirements = ["-requiresAny", *requirements, "Microsoft.VisualStudio.Component.VC.Tools.ARM64"]
    installation = subprocess.check_output([str(installer), "-latest", "-products", "*", *requirements,
                                            "-property", "installationPath"], text=True).strip()
    tools = Path(installation) / "VC/Tools/MSVC"
    versions = sorted(tools.glob("*"), reverse=True)
    arm = native_arm64 and any((version / "bin/Hostarm64/arm64/cl.exe").is_file() for version in versions)
    arch = "arm64" if arm else "x64"
    if not any((version / f"bin/Host{arch}/{arch}/cl.exe").is_file() for version in versions):
        raise ValueError(f"Visual Studio is missing its {arch} C++ compiler. Add Desktop development with C++ and a Windows SDK in Visual Studio Installer.")
    script = Path(installation) / "VC/Auxiliary/Build/vcvarsall.bat"
    command = f'"{script}" {arch} >nul && set'
    command_line = subprocess.list2cmdline([env.get("COMSPEC", "cmd.exe")]) + ' /d /s /c "' + command + '"'
    result = subprocess.run(command_line,
                            capture_output=True, text=True, check=True, env=env)
    for line in result.stdout.splitlines():
        key, separator, value = line.partition("=")
        if separator and key:
            existing = next((name for name in env if name.casefold() == key.casefold()), key)
            env[existing] = value
    if not shutil.which("cl", path=env.get("Path", env.get("PATH"))):
        raise ValueError("Visual Studio could not prepare its C++ compiler; open Visual Studio Installer and check the Windows SDK components.")
    print(f"Host generator: Visual Studio {arch} compiler", flush=True)
    return env


def generate(source, jobs, env=None):
    build = Path(os.environ.get("SQUIRRELPAD_GENERATOR_BUILD", source / ("tools/N64Recomp/build-padmint-" + platform.system().lower() + "-" + platform.machine().lower())))
    run("cmake", "-S", source / "tools/N64Recomp", "-B", build, "-G", "Ninja", "-DCMAKE_BUILD_TYPE=Release", env=env)
    run("cmake", "--build", build, "--target", "N64RecompCLI", "RSPRecomp", "--parallel", jobs, env=env)
    run(sys.executable, source / "recomp/recompile.py", "--bin", build, env=env)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--rom", required=True, type=Path)
    parser.add_argument("--toolchain", type=Path, help="The {ios_toolchain} supplied by PadMint")
    parser.add_argument("--build-dir", type=Path, default=ROOT / "work/build-game-module", help="Native local build directory, normally {work}/module from PadMint")
    parser.add_argument("--generate-only", action="store_true", help="Validate local host generation without compiling iOS code")
    parser.add_argument("--jobs", type=int, choices=range(1, 17), default=4)
    args = parser.parse_args()
    if not args.generate_only and (not args.toolchain or not args.toolchain.is_file()):
        parser.error("--toolchain must name PadMint's existing iOS module toolchain")
    if not args.generate_only:
        include = args.toolchain.resolve().parent / "usr/include"
        missing = [name for name in ("assert.h", "sys/mman.h") if not (include / name).is_file()]
        if missing:
            parser.error("This PadMint build is missing iPhone module headers needed by SquirrelPad. Update PadMint before building again (missing: " + ", ".join(missing) + ").")
    host_env = generator_environment()
    setup.check_rom(args.rom)
    source = setup.prepare(Path(os.environ.get("SQUIRRELPAD_CHECKOUT", ROOT / "work/CBFD-Recompiled")), module_only=True)
    setup.stage_rom(args.rom, source / "conker/baserom.us.z64")
    generate(source, args.jobs, host_env)
    if args.generate_only:
        return
    build = args.build_dir.resolve()
    run("cmake", "--fresh", "-S", ROOT / "cmake/game-module", "-B", build, "-G", "Ninja",
        f"-DCMAKE_TOOLCHAIN_FILE={args.toolchain.resolve()}", "-DCMAKE_BUILD_TYPE=Release",
        f"-DSQUIRRELPAD_CONKER_SOURCE={source}", f"-DPython3_EXECUTABLE={sys.executable}")
    run("cmake", "--build", build, "--parallel", args.jobs)
    print(f"Private game module: {build / 'SquirrelPadGame.dylib'}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        sys.exit(str(error))
