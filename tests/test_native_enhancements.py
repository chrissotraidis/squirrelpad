"""Native mod regressions and bounded archive import (no ROM or texture artwork)."""
from pathlib import Path
import json
import shutil
import struct
import subprocess
import tempfile
import unittest
import zipfile
import zlib

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / 'work/CBFD-Recompiled'

class NativeEnhancementTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        if not shutil.which('clang++') or not SOURCE.exists():
            raise unittest.SkipTest('Run setup-source.sh; native checks require clang++ and pinned headers.')
        cls.temp = tempfile.TemporaryDirectory()
        cls.addClassCleanup(cls.temp.cleanup)
        cls.folder = Path(cls.temp.name)

    def test_static_mods(self):
        executable = self.folder / 'mods'
        subprocess.run(['clang++', '-std=c++20', '-I' + str(SOURCE/'tools/N64ModernRuntime/N64Recomp/include'),
                        str(ROOT/'tests/mods_runtime.cpp'), str(ROOT/'Support/Conker/mobile_mods.cpp'),
                        '-o', str(executable)], check=True, capture_output=True)
        subprocess.run([str(executable)], check=True, capture_output=True)

    def test_adventure_controls_and_audio(self):
        executable = self.folder / 'adventure'
        ports = ROOT/'Support/Conker/Reloaded'
        files = ['mobile_enhancements', 'accessibility', 'look_aim', 'free_camera',
                 'crosshair', 'sound_mix', 'skip_intro', 'ledge_grab']
        subprocess.run(['clang++', '-std=c++20', '-I'+str(ports),
                        '-I'+str(SOURCE/'tools/N64ModernRuntime/N64Recomp/include'),
                        str(ROOT/'tests/adventure_runtime.cpp'),
                        str(ROOT/'Support/Conker/mobile_input.cpp'),
                        str(ROOT/'Support/Conker/mobile_mods.cpp'),
                        *[str(ports/(name+'.cpp')) for name in files],
                        '-o', str(executable)], check=True)
        subprocess.run([str(executable)], check=True)

    def test_music_transitions(self):
        executable = self.folder / 'music'
        subprocess.run(['clang++', '-std=c++20', '-I' + str(SOURCE/'tools/N64ModernRuntime/N64Recomp/include'),
                        str(ROOT/'tests/music_runtime.cpp'), str(ROOT/'Support/Conker/mobile_music.cpp'),
                        '-o', str(executable)], check=True, capture_output=True)
        subprocess.run([str(executable)], check=True, capture_output=True)

    def test_pack_validation(self):
        archive = SOURCE/'host/build-macos-metal/rt64/rt64.a'
        if not archive.exists():
            self.skipTest('Build the pinned macOS RT64 archive to run texture parser checks.')
        runner = self.folder/'runner.cpp'
        runner.write_text('#include <cstdio>\nextern "C" int squirrelpad_validate_texture_pack(const char*);\n'
                          'int main(int argc,char**argv){if(argc!=2)return 2;std::printf("%d\\n",squirrelpad_validate_texture_pack(argv[1]));}\n')
        executable = self.folder/'packs'
        rt = SOURCE/'tools/rt64/src'
        subprocess.run(['clang++','-std=c++17','-DHLSL_CPU',*['-I'+str(p)for p in [rt,rt/'contrib',rt/'contrib/hlslpp/include']],
                        str(ROOT/'Support/Conker/mobile_texture_packs.cpp'),str(runner),str(archive),
                        str(archive.parent/'src/contrib/zstd/build/cmake/lib/libzstd.a'),'-o',str(executable)],check=True,capture_output=True)
        def chunk(kind,data):
            return struct.pack('>I',len(data))+kind+data+struct.pack('>I',zlib.crc32(kind+data))
        png=b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',1,1,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(b'\x00\xff\x00\xff\xff'))+chunk(b'IEND',b'')
        db={'configuration':{'configurationVersion':3,'hashVersion':5,'autoPath':'rt64'},
            'textures':[{'hashes':{'rt64':'0123456789abcdef'},'path':'texture'}]}
        valid={'rt64.json':json.dumps(db).encode(),'texture.png':png}
        cases=[('valid',valid,1),('missing-json',{'texture.png':png},-4),
               ('bad-json',{'rt64.json':b'{'},-2),('missing-texture',{'rt64.json':valid['rt64.json']},-5),
               ('bad-png',{**valid,'texture.png':b'broken'},-6),('traversal',{**valid,'../escape':b'no'},-3),
               ('mip-cache',{**valid,'rt64-low-mip-cache.bin':b'bad'},-4)]
        db['configuration']['hashVersion']=99
        cases.append(('future-hash',{**valid,'rt64.json':json.dumps(db).encode()},-4))
        for name,entries,expected in cases:
            with self.subTest(name=name):
                path=self.folder/(name+'.rtz')
                with zipfile.ZipFile(path,'w',zipfile.ZIP_DEFLATED) as pack:
                    for entry,data in entries.items(): pack.writestr(entry,data)
                actual=subprocess.check_output([str(executable),str(path)],text=True).strip()
                self.assertEqual(int(actual),expected)
