"""Private-input preservation and stale-generation checks for portable builds."""
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
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


class UnicodePythonTests(unittest.TestCase):
    def test_redirected_isolated_python_accepts_non_english_paths(self):
        code = """import importlib.util, sys, types
spec = importlib.util.spec_from_file_location('setup', sys.argv[1])
setup = importlib.util.module_from_spec(spec)
spec.loader.exec_module(setup)
setup.os = types.SimpleNamespace(name='nt')
sys.stdout.reconfigure(encoding='cp1252')
sys.stderr.reconfigure(encoding='cp1252')
setup.configure_output()
print('private \\u96ea folder')
print('private \\u96ea error', file=sys.stderr)
"""
        result = subprocess.run([sys.executable, '-I', '-c', code, str(ROOT / 'scripts/setup-source.py')],
                                capture_output=True, check=True)
        self.assertEqual(result.stdout.decode('utf-8').strip(), 'private 雪 folder')
        self.assertEqual(result.stderr.decode('utf-8').strip(), 'private 雪 error')

    def test_private_generator_child_explicitly_uses_utf8(self):
        with mock.patch.object(BUILD, 'build_generators', return_value=ROOT / 'host build'), \
                mock.patch.object(BUILD, 'run') as run:
            BUILD.generate(ROOT / 'source 雪', 1)
        self.assertEqual(run.call_args.args[:3], (sys.executable, '-X', 'utf8'))


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
                "cmake/host-tools/CMakeLists.txt": b"host build\n",
                "cmake/host-tools/windows-utf8.manifest": b"manifest\n",
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
            for name in ("Support/Conker/Z.cpp", "Support/Conker/a.cpp", "Support/Conker/game_module_functions.inc", "cmake/host-tools/CMakeLists.txt", "cmake/host-tools/windows-utf8.manifest", "patches/source.patch", "sources.lock.json"):
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



class WindowsCompilerTests(unittest.TestCase):
    def check_selection(self, host, arm_available, expected_arch):
        import types
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            installer = root / 'Microsoft Visual Studio/Installer/vswhere.exe'
            installer.parent.mkdir(parents=True); installer.touch()
            old, new = root / 'older-x64 雪', root / 'newer-arm 雪'
            for installation, arch in ((old, 'x64'), (new, 'arm64')):
                compiler = installation / f'VC/Tools/MSVC/14.44/bin/Host{arch}/{arch}/cl.exe'
                compiler.parent.mkdir(parents=True); compiler.touch()
            selected = new if expected_arch == 'arm64' else old
            calls = []
            def query(command, **kwargs):
                calls.append(command)
                self.assertEqual(kwargs['encoding'], 'utf-8')
                self.assertEqual(command[-1], '-utf8')
                return str(new if '-requiresAny' in command and arm_available else old)
            original = {'ProgramFiles(x86)': str(root), 'TEMP': 'private 雪 path'}
            process = types.SimpleNamespace(stdout='PATH=prepared-compiler\nTEMP=private 雪 path\n')
            with mock.patch.object(BUILD, 'os', types.SimpleNamespace(name='nt', environ=original)), \
                    mock.patch.object(BUILD.platform, 'machine', return_value=host), \
                    mock.patch.object(BUILD.shutil, 'which', side_effect=[None, 'cl.exe']), \
                    mock.patch.object(BUILD.subprocess, 'check_output', side_effect=query), \
                    mock.patch.object(BUILD.subprocess, 'run', return_value=process) as run:
                prepared = BUILD.generator_environment()
            self.assertEqual('-requiresAny' in calls[0], host == 'ARM64')
            self.assertIn(str(selected / 'VC/Auxiliary/Build/vcvarsall.bat'), run.call_args.args[0])
            self.assertIn(' ' + expected_arch + ' >nul', run.call_args.args[0])
            self.assertIn(' /d /u /s /c ', run.call_args.args[0])
            self.assertEqual(run.call_args.kwargs['encoding'], 'utf-16-le')
            self.assertEqual(prepared['TEMP'], 'private 雪 path')
            self.assertEqual(original, {'ProgramFiles(x86)': str(root), 'TEMP': 'private 雪 path'})

    def test_newer_arm_only_install_does_not_hide_x64_compiler(self):
        self.check_selection('AMD64', True, 'x64')

    def test_arm_host_keeps_native_compiler_preference(self):
        self.check_selection('ARM64', True, 'arm64')

    def test_arm_host_keeps_x64_fallback(self):
        self.check_selection('ARM64', False, 'x64')


class GeneratorCacheTests(unittest.TestCase):
    def test_relative_build_override_uses_the_command_working_directory(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            build = root / 'relative build'
            build.mkdir()
            (build / 'CMakeCache.txt').write_text('CMAKE_HOME_DIRECTORY:INTERNAL=/old/upstream\n', encoding='utf-8')
            with mock.patch.object(BUILD, 'ROOT', root), mock.patch.object(BUILD, 'run') as run:
                result = BUILD.build_generators(root / 'source', Path('relative build'), 1)
            self.assertEqual(result, build.resolve())
            self.assertEqual(run.call_args_list[0].args[:2], ('cmake', '--fresh'))
            self.assertEqual(run.call_args_list[0].args[5], build.resolve())

    def test_old_upstream_cache_gets_one_fresh_configure(self):
        with tempfile.TemporaryDirectory() as temporary:
            build = Path(temporary)
            cache = build / 'CMakeCache.txt'
            cache.write_text('CMAKE_HOME_DIRECTORY:INTERNAL=/old/upstream\n', encoding='utf-8')
            with mock.patch.object(BUILD, 'run') as run:
                BUILD.build_generators(build / 'source', build, 1)
            self.assertEqual(run.call_args_list[0].args[:2], ('cmake', '--fresh'))
            cache.write_text('CMAKE_HOME_DIRECTORY:INTERNAL=' + str((ROOT / 'cmake/host-tools').resolve()) + '\n', encoding='utf-8')
            with mock.patch.object(BUILD, 'run') as run:
                BUILD.build_generators(build / 'source', build, 1)
            self.assertNotIn('--fresh', run.call_args_list[0].args)

if __name__ == "__main__":
    unittest.main()
