"""Private-input preservation and stale-generation checks for portable builds."""
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]


def module(name):
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / (name + ".py"))
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


SETUP = module("setup-source")
GENERATED = module("check-generated")
BUILD = module("build-game-module")


class InputStagingTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="Squirrel input with spaces ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.data = b"test-owned-synthetic-input"
        (self.root / "sources.lock.json").write_text(json.dumps({"rom": {
            "size": len(self.data), "header": self.data[:4].hex(),
            "sha1": hashlib.sha1(self.data).hexdigest()}}))
        self.rom = self.root / "input.bin"
        self.rom.write_bytes(self.data)
        self.target = self.root / "stage/input.bin"
        patcher = mock.patch.object(SETUP, "ROOT", self.root)
        patcher.start()
        self.addCleanup(patcher.stop)

    def test_stage_and_retry_leave_original_and_matching_destination_intact(self):
        SETUP.stage_rom(self.rom, self.target)
        SETUP.stage_rom(self.rom, self.target)
        self.assertEqual(self.rom.read_bytes(), self.data)
        self.assertEqual(self.target.read_bytes(), self.data)
        self.assertFalse(self.target.is_symlink())

    def test_existing_different_input_is_preserved(self):
        self.target.parent.mkdir()
        self.target.write_bytes(b"another person's input")
        with self.assertRaises(ValueError):
            SETUP.stage_rom(self.rom, self.target)
        self.assertEqual(self.target.read_bytes(), b"another person's input")

    def test_changed_source_is_rejected_before_creating_destination(self):
        self.rom.write_bytes(b"wrong")
        with self.assertRaises(ValueError):
            SETUP.stage_rom(self.rom, self.target)
        self.assertFalse(self.target.exists())

    def test_concurrent_destination_is_not_overwritten(self):
        def raced_link(source, target):
            target.write_bytes(b"concurrent input")
            raise FileExistsError("destination appeared")
        with mock.patch.object(SETUP.os, "link", side_effect=raced_link):
            with self.assertRaises(FileExistsError):
                SETUP.stage_rom(self.rom, self.target)
        self.assertEqual(self.target.read_bytes(), b"concurrent input")


class GeneratedInputTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "recomp").mkdir()
        (self.root / "recomp/recompile.py").write_text("RECOMP_INPUTS = ['settings.txt']\n")
        (self.root / "settings.txt").write_bytes(b"first\r\nsecond\r\n")
        output = self.root / "RecompiledFuncs"
        (output / "rsp").mkdir(parents=True)
        for name in ("tlb_pages.c", "rsp/audio_ucode.cpp", "recomp_overlays.inl", "funcs.h", "funcs_0.c"):
            (output / name).write_text("synthetic\n")
        (output / "inputs.sha256").write_text(hashlib.sha256(b"first\nsecond\n").hexdigest() + " settings.txt\n")

    def test_crlf_input_matches_normalized_generation(self):
        GENERATED.check(self.root)

    def test_changed_input_refuses_stale_code(self):
        (self.root / "settings.txt").write_text("changed")
        with self.assertRaisesRegex(ValueError, "stale"):
            GENERATED.check(self.root)

    def test_missing_audio_is_not_accepted_by_existing_stamp(self):
        (self.root / "RecompiledFuncs/rsp/audio_ucode.cpp").unlink()
        with self.assertRaisesRegex(ValueError, "Incomplete"):
            GENERATED.check(self.root)

    def test_missing_input_from_stamp_is_rejected(self):
        (self.root / "RecompiledFuncs/inputs.sha256").write_text("")
        with self.assertRaisesRegex(ValueError, "stale"):
            GENERATED.check(self.root)


class ModuleIdentityTests(unittest.TestCase):
    def test_contract_order_uses_case_sensitive_repository_names_on_every_host(self):
        identity = module("module-identity")
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            files = {
                "sources.lock.json": b"pins\n",
                "patches/source.patch": b"patch\r\n",
                "Support/Conker/Z.cpp": b"upper\n",
                "Support/Conker/a.cpp": b"lower\n",
                "Support/Conker/game_module_functions.inc": b"table\n",
            }
            for name, data in files.items():
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(data)
            expected = hashlib.sha256()
            for name in ("Support/Conker/Z.cpp", "Support/Conker/a.cpp", "Support/Conker/game_module_functions.inc", "patches/source.patch", "sources.lock.json"):
                expected.update(name.encode() + b"\0" + files[name].replace(b"\r\n", b"\n") + b"\0")
            with mock.patch.object(identity, "ROOT", root):
                self.assertEqual(identity.identity(), expected.hexdigest())


class ToolchainPreflightTests(unittest.TestCase):
    def test_older_padmint_sdk_stops_before_fetching_or_generating(self):
        with tempfile.TemporaryDirectory() as temporary:
            toolchain = Path(temporary) / "toolchain.cmake"
            toolchain.write_text("# old SDK fixture\n")
            argv = ["build-game-module.py", "--rom", str(Path(temporary) / "private.rom"), "--toolchain", str(toolchain)]
            with mock.patch.object(BUILD.sys, "argv", argv), mock.patch.object(BUILD.setup, "prepare") as prepare:
                with self.assertRaises(SystemExit) as stopped:
                    BUILD.main()
                self.assertEqual(stopped.exception.code, 2)
                prepare.assert_not_called()


if __name__ == "__main__":
    unittest.main()
