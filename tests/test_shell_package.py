"""Package synthetic app files without replacing a player's prior output."""
import contextlib
import importlib.util
import io
from pathlib import Path
import platform
import sys
import tempfile
import unittest
from unittest import mock
import zipfile

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("shell_builder", ROOT / "scripts/build-module-shell.py")
SHELL = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(SHELL)


class ShellPackageTests(unittest.TestCase):
    @unittest.skipUnless(platform.system() == "Darwin", "Uses Apple's ditto packager")
    def test_archive_contains_only_the_supplied_app(self):
        with tempfile.TemporaryDirectory(prefix="Squirrel shell ") as temporary:
            root = Path(temporary)
            app = root / "input.app"
            app.mkdir()
            (app / "Info.plist").write_text("synthetic app metadata")
            (app / "ThirdPartyNotices").mkdir()
            (app / "ThirdPartyNotices/test.txt").write_text("synthetic notice")
            (root / "unrelated.txt").write_text("must remain outside the archive")
            output = root / "output/shell.ipa"
            SHELL.package_app(app, output)
            with zipfile.ZipFile(output) as archive:
                files = {name: archive.read(name) for name in archive.namelist() if not name.endswith("/")}
            self.assertEqual(files, {
                "Payload/SquirrelPad.app/Info.plist": b"synthetic app metadata",
                "Payload/SquirrelPad.app/ThirdPartyNotices/test.txt": b"synthetic notice",
            })

    def test_existing_output_is_preserved_before_packaging(self):
        with tempfile.TemporaryDirectory() as temporary:
            output = Path(temporary) / "existing.ipa"
            output.write_bytes(b"prior personal build")
            with mock.patch.object(SHELL, "run") as run:
                with self.assertRaisesRegex(ValueError, "Preserving existing output"):
                    SHELL.package_app(Path(temporary) / "missing.app", output)
                run.assert_not_called()
            self.assertEqual(output.read_bytes(), b"prior personal build")

    def test_simulator_cannot_be_packaged_as_device_ipa(self):
        with mock.patch.object(sys, "argv", ["build-module-shell.py", "--sdk", "iphonesimulator", "--output", "unused.ipa"]), \
                mock.patch.object(SHELL, "run") as run, contextlib.redirect_stderr(io.StringIO()):
            with self.assertRaises(SystemExit) as error:
                SHELL.main()
            self.assertEqual(error.exception.code, 2)
            run.assert_not_called()


if __name__ == "__main__":
    unittest.main()
