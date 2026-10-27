"""Exercise the production ROM import with synthetic files, never game data."""
from pathlib import Path
import platform
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(platform.system() == "Darwin", "Requires Apple file coordination")
class ROMImportTests(unittest.TestCase):
    def test_rom_import(self):
        with tempfile.TemporaryDirectory() as folder:
            binary = Path(folder) / "rom-import-test"
            subprocess.run(["swiftc", str(ROOT / "Sources/ROMImport.swift"),
                            str(ROOT / "tests/rom_import_runtime.swift"),
                            "-o", str(binary)], check=True)
            subprocess.run([str(binary)], check=True, timeout=60)
