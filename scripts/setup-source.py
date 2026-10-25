#!/usr/bin/env python3
"""Prepare pinned SquirrelPad sources on any host; game inputs stay local."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent.parent
PATCHES = (
    ('tools/N64Recomp', 'checkout', 'recomp/n64recomp.patch'),
    ('tools/N64ModernRuntime', 'checkout', 'recomp/n64modernruntime.patch'),
    ('tools/N64ModernRuntime', 'project', 'patches/n64modernruntime-rsp-dma-address.patch'),
    ('tools/N64ModernRuntime', 'project', 'patches/n64modernruntime-ios-mods.patch'),
    ('tools/N64ModernRuntime', 'project', 'patches/n64modernruntime-ios-mod-load.patch'),
    ('tools/N64ModernRuntime', 'project', 'patches/n64modernruntime-ios-no-live-recomp.patch'),
    ('tools/N64ModernRuntime', 'project', 'patches/n64modernruntime-ios-qos.patch'),
    ('tools/N64ModernRuntime', 'project', 'patches/n64modernruntime-ios-clock.patch'),
    ('tools/N64ModernRuntime', 'project', 'patches/n64modernruntime-apple-save-atomic.patch'),
    ('tools/N64ModernRuntime', 'project', 'patches/n64modernruntime-save-write-check.patch'),
    ('tools/N64ModernRuntime', 'project', 'patches/n64modernruntime-mobile-save-feedback.patch'),
    ('tools/rt64', 'checkout', 'recomp/rt64.patch'),
    ('', 'project', 'patches/conker-host.patch'),
    ('', 'project', 'patches/conker-macos-audio-device.patch'),
    ('', 'project', 'patches/conker-macos-window-init.patch'),
    ('', 'project', 'patches/conker-mobile-audio.patch'),
    ('', 'project', 'patches/conker-mobile-lifecycle.patch'),
    ('', 'project', 'patches/conker-mobile-mods.patch'),
    ('', 'project', 'patches/conker-mobile-music.patch'),
    ('', 'project', 'patches/conker-mobile-enhancements.patch'),
    ('', 'project', 'patches/conker-mobile-rumble.patch'),
    ('tools/rt64/src/contrib/hlslpp', 'project', 'patches/hlslpp-stdlib.patch'),
    ('tools/rt64', 'project', 'patches/rt64-ios.patch'),
    ('tools/rt64', 'project', 'patches/rt64-ios-sampler-limit.patch'),
    ('tools/rt64', 'project', 'patches/rt64-ios-debug-capability.patch'),
    ('tools/rt64', 'project', 'patches/rt64-static-fb-params.patch'),
    ('tools/rt64', 'project', 'patches/rt64-metal-sdk-scope.patch'),
    ('tools/rt64/src/contrib/plume', 'project', 'patches/plume-ios-metal.patch'),
    ('tools/rt64/src/contrib/plume', 'project', 'patches/plume-ios-device-type.patch'),
    ('tools/rt64', 'project', 'patches/rt64-ios-texture-pair.patch'),
    ('tools/rt64', 'project', 'patches/rt64-visual-effects.patch'),
    ('tools/N64ModernRuntime/N64Recomp/lib/sljit', 'project', 'patches/sljit-ios-allocator.patch'),
    ('', 'project', 'patches/conker-game-module.patch'),
    ('tools/N64Recomp', 'project', 'patches/rsprecomp-stable-targets.patch'),
)


def run(*args):
    subprocess.run([str(arg) for arg in args], check=True)


def check_rom(path):
    expected = json.loads((ROOT / "sources.lock.json").read_text())["rom"]
    digest = hashlib.sha1()
    with path.open("rb") as stream:
        header = stream.read(4).hex()
        stream.seek(0)
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    if path.stat().st_size != expected["size"] or header != expected["header"] or digest.hexdigest() != expected["sha1"]:
        raise ValueError("Supply the supported 64 MiB US big-endian ROM; see README.md.")


def stage_rom(rom, destination):
    """No Windows developer mode/symlink privilege, no overwrite of existing input."""
    rom = rom.resolve(strict=True)
    check_rom(rom)
    if destination.exists() or destination.is_symlink():
        if destination.is_file():
            check_rom(destination)
            return
        raise ValueError(f"Preserving existing ROM path: {destination}")
    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="rom-", dir=destination.parent) as temporary:
        staged = Path(temporary) / "input"
        shutil.copyfile(rom, staged)
        check_rom(staged)
        # Both files are on the same volume. Fails if another build created the destination.
        os.link(staged, destination)


def prepare(checkout, *, module_only=False):
    pins = json.loads((ROOT / "sources.lock.json").read_text())
    checkout = checkout.resolve()
    if not (checkout / ".git").exists():
        if checkout.exists() and any(checkout.iterdir()):
            raise ValueError(f"Preserving non-Git source directory: {checkout}")
        checkout.parent.mkdir(parents=True, exist_ok=True)
        run("git", "clone", "--no-checkout", "-c", "core.autocrlf=false", pins["upstream"]["url"], checkout)
        run("git", "-C", checkout, "checkout", "--detach", pins["upstream"]["commit"])
    actual = subprocess.check_output(["git", "-C", str(checkout), "rev-parse", "HEAD"], text=True).strip()
    if actual != pins["upstream"]["commit"]:
        raise ValueError(f"Unexpected Conker source commit; preserving checkout: {checkout}")
    modules = ["tools/N64Recomp", "tools/N64ModernRuntime"]
    if not module_only:
        modules += ["tools/rt64", "tools/RecompFrontend"]
    run("git", "-C", checkout, "-c", "core.autocrlf=false", "submodule", "update", "--init", "--recursive", "--", *modules)
    for name, expected in pins["gitlinks"].items():
        if module_only and not any(name == item or name.startswith(item + "/") for item in modules):
            continue
        actual = subprocess.check_output(["git", "-C", str(checkout / name), "rev-parse", "HEAD"], text=True).strip()
        if actual != expected:
            raise ValueError(f"Unexpected pinned submodule commit: {name}")
    stack = []
    for folder, origin, patch in PATCHES:
        if module_only and folder.startswith("tools/rt64"):
            continue
        stack.append(f"{checkout / folder}|{(checkout if origin == 'checkout' else ROOT) / patch}")
    run(sys.executable, ROOT / "scripts/apply-source-patches.py", checkout, *stack)
    print(f"Pinned and patched source ready at {checkout}", flush=True)
    return checkout


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rom", nargs="?", type=Path)
    parser.add_argument("--module-only", action="store_true", help="Skip renderer/frontend sources for local game-module builds")
    args = parser.parse_args()
    if args.rom:
        check_rom(args.rom)
    checkout = prepare(Path(os.environ.get("SQUIRRELPAD_CHECKOUT", ROOT / "work/CBFD-Recompiled")), module_only=args.module_only)
    if args.rom:
        stage_rom(args.rom, checkout / "conker/baserom.us.z64")
        print("Supported private ROM verified and staged locally.", flush=True)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        sys.exit(str(error))
