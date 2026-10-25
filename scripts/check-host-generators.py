#!/usr/bin/env python3
"""Build the pinned host generators and exercise hand-authored MIPS/RSP inputs.

No game ROM or generated game source is used. CI can run this on Windows x64
without receiving any private input from the maintainer's machine.
"""
import argparse
import importlib.util
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("module_build", ROOT / "scripts/build-game-module.py")
BUILD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(BUILD)


def check(binary, source, env):
    suffix = ".exe" if os.name == "nt" else ""
    with tempfile.TemporaryDirectory(prefix="Squirrel synthetic generator spaces ") as temporary:
        work = Path(temporary)
        # addiu v0,zero,7; jr ra; addiu v0,v0,1 (the delay slot must run).
        (work / "cpu.bin").write_bytes(bytes(0x1000) + struct.pack(">3I", 0x24020007, 0x03E00008, 0x24420001))
        (work / "symbols.toml").write_text('''[[section]]
name = ".text"
rom = 0x1000
vram = 0x80001000
size = 12
functions = [{ name = "recomp_entrypoint", vram = 0x80001000, rom = 0x1000, size = 12 }]
''')
        (work / "cpu.toml").write_text('''[input]
entrypoint = 0x80001000
symbols_file_path = "symbols.toml"
rom_file_path = "cpu.bin"
output_func_path = "output"
''')
        subprocess.run([binary / ("N64Recomp" + suffix), work / "cpu.toml"], cwd=work, check=True)
        generated = sorted((work / "output").glob("funcs_*.c"))
        if len(generated) != 1:
            raise RuntimeError("The synthetic CPU input did not produce one function file")
        (work / "main.c").write_text('''#include "recomp.h"
void recomp_entrypoint(uint8_t*, recomp_context*);
int main(void) {
    uint8_t rdram[8] = {0}; recomp_context ctx = {0};
    recomp_entrypoint(rdram, &ctx);
    return ctx.r2 == 8 ? 0 : 1;
}
''')
        include = source / "tools/N64Recomp/include"
        executable = work / ("cpu-test" + suffix)
        if os.name == "nt":
            compiler = shutil.which("cl", path=env.get("Path", env.get("PATH")))
            if not compiler:
                raise RuntimeError("Visual Studio did not provide a C compiler")
            command = [compiler, "/nologo", "/TC", "/std:c11", "/I" + str(include),
                       *generated, work / "main.c", "/Fe:" + str(executable)]
        else:
            command = ["cc", "-std=c11", "-I" + str(include), *generated, work / "main.c", "-o", executable]
        subprocess.run([str(arg) for arg in command], cwd=work, env=env, check=True)
        subprocess.run([executable], cwd=work, check=True)

        # Independent RSP BREAK instructions and deliberately unsorted dispatch targets.
        (work / "rsp.bin").write_bytes(struct.pack(">3I", 0x0000000D, 0x0000000D, 0x0000000D))
        (work / "rsp.toml").write_text('''text_offset = 0
text_size = 12
text_address = 0x04001000
rom_file_path = "rsp.bin"
output_file_path = "rsp.cpp"
output_function_name = "synthetic_audio"
extra_indirect_branch_targets = [0x1008, 0x1000, 0x1004]
''')
        subprocess.run([binary / ("RSPRecomp" + suffix), work / "rsp.toml"], cwd=work, check=True)
        output = (work / "rsp.cpp").read_text()
        targets = re.findall(r"case 0x([0-9A-Fa-f]+): goto L_", output)
        if targets != ["1000", "1004", "1008"] or "RspExitReason::Broke" not in output:
            raise RuntimeError("The synthetic RSP dispatch or BREAK output changed")
    print("Synthetic CPU execution and ordered RSP dispatch passed.", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bin", type=Path, help="Reuse existing generator executables")
    parser.add_argument("--source", type=Path, default=ROOT / "work/CBFD-Recompiled")
    parser.add_argument("--jobs", type=int, choices=range(1, 17), default=4)
    args = parser.parse_args()
    env = BUILD.generator_environment()
    source = args.source.resolve()
    if args.bin:
        binary = args.bin.resolve()
    else:
        source = BUILD.setup.prepare(source, module_only=True)
        binary = ROOT / "work/host-generator-check"
        BUILD.run("cmake", "--fresh", "-S", source / "tools/N64Recomp", "-B", binary,
                  "-G", "Ninja", "-DCMAKE_BUILD_TYPE=Release", env=env)
        BUILD.run("cmake", "--build", binary, "--target", "N64RecompCLI", "RSPRecomp",
                  "--parallel", args.jobs, env=env)
    check(binary, source, env)


if __name__ == "__main__":
    main()
