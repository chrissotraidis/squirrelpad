"""Run the actual Swift controller adapter against GameController snapshots."""
from pathlib import Path
import platform
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]

@unittest.skipUnless(platform.system() == 'Darwin', 'Requires Apple GameController')
class ControllerInputTests(unittest.TestCase):
    def test_controller_lifecycle(self):
        with tempfile.TemporaryDirectory() as folder:
            binary = Path(folder) / 'controller-test'
            subprocess.run(['swiftc', str(ROOT/'Sources/ControllerInput.swift'),
                            str(ROOT/'tests/controller_runtime.swift'), '-o', str(binary)], check=True)
            subprocess.run([str(binary)], check=True, timeout=15)
