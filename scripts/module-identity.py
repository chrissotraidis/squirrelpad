#!/usr/bin/env python3
"""Identify the exact runtime/translated-code contract without reading game inputs."""
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def identity():
    digest = hashlib.sha256()
    paths = [ROOT / "sources.lock.json", *sorted((ROOT / "patches").glob("*.patch")),
             ROOT / "cmake/host-tools/CMakeLists.txt", ROOT / "cmake/host-tools/windows-utf8.manifest",
             *sorted((ROOT / "Support/Conker").rglob("*.h")),
             *sorted((ROOT / "Support/Conker").rglob("*.cpp")),
             ROOT / "Support/Conker/game_module_functions.inc"]
    # pathlib orders Windows paths without case; sort exact portable names instead.
    for path in sorted(paths, key=lambda item: item.relative_to(ROOT).as_posix()):
        digest.update(path.relative_to(ROOT).as_posix().encode() + b"\0")
        digest.update(path.read_bytes().replace(b"\r\n", b"\n") + b"\0")
    return digest.hexdigest()


if __name__ == "__main__":
    print(identity())
