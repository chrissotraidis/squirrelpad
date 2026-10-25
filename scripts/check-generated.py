#!/usr/bin/env python3
"""Reject stale or incomplete N64Recomp output before module compilation."""
import ast
import hashlib
from pathlib import Path
import sys


def check(source):
    # Read the generator's declared inputs, without importing or running its code.
    tree = ast.parse((source / "recomp/recompile.py").read_text())
    inputs = next(ast.literal_eval(node.value) for node in tree.body
                  if isinstance(node, ast.Assign) and any(isinstance(target, ast.Name) and target.id == "RECOMP_INPUTS" for target in node.targets))
    if not isinstance(inputs, list) or not inputs or any(not isinstance(name, str) or Path(name).is_absolute() or ".." in Path(name).parts for name in inputs):
        raise ValueError("The pinned recompiler has an invalid input list")
    expected = "".join(hashlib.sha256((source / name).read_bytes().replace(b"\r", b"")).hexdigest() + " " + name + "\n" for name in inputs)
    ledger = source / "RecompiledFuncs/inputs.sha256"
    if not ledger.is_file() or ledger.read_text() != expected:
        raise ValueError("RecompiledFuncs is stale; run scripts/build-game-module.py with your supported ROM again")
    for name in ["tlb_pages.c", "rsp/audio_ucode.cpp", "recomp_overlays.inl", "funcs.h"]:
        if not (source / "RecompiledFuncs" / name).is_file():
            raise ValueError(f"Incomplete generated game code: {name}")
    if not list((source / "RecompiledFuncs").glob("funcs_*.c")):
        raise ValueError("No generated game functions")


if __name__ == "__main__":
    try:
        check(Path(sys.argv[1]))
    except (OSError, ValueError, StopIteration) as error:
        sys.exit(str(error) or "The pinned recompiler declares no input list")
