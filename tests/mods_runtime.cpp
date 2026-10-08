// No ROM required: exercise the static hooks against synthetic N64 RAM.
#include <cassert>
#include <vector>
#include <cstdio>
#include "recomp.h"
extern "C" void squirrelpad_set_mods(unsigned);
extern "C" void squirrelpad_mod_frame(uint8_t*);
extern "C" int squirrelpad_mod_skip(uint8_t*, int);
extern "C" void squirrelpad_enhancement_frame(uint8_t*) {}
extern "C" int squirrelpad_skip_buttons(uint16_t buttons, bool) { return buttons; }
extern "C" void squirrelpad_skip_consumed() {}
int main() {
    std::vector<uint8_t> ram(8 * 1024 * 1024); auto *rdram = ram.data();
    MEM_BU(0,S32(0x800CC49A))=2; MEM_BU(0,S32(0x800D2144))=3; MEM_W(0,S32(0x800D2148))=100;
    squirrelpad_set_mods(0); squirrelpad_mod_frame(rdram);
    assert(MEM_BU(0,S32(0x800CC49A))==2 && MEM_BU(0,S32(0x800D2144))==3 && MEM_W(0,S32(0x800D2148))==100);
    squirrelpad_set_mods(7); squirrelpad_mod_frame(rdram);
    assert(MEM_BU(0,S32(0x800CC49A))==6 && MEM_BU(0,S32(0x800D2144))==9 && MEM_W(0,S32(0x800D2148))==9999);
    MEM_BU(0,S32(0x800CC49A))=0; squirrelpad_mod_frame(rdram); assert(MEM_BU(0,S32(0x800CC49A))==0);
    squirrelpad_set_mods(0); MEM_BU(0,S32(0x800CC49A))=1; squirrelpad_mod_frame(rdram); assert(MEM_BU(0,S32(0x800CC49A))==1);
    assert(squirrelpad_mod_skip(rdram,0)==-1);
    squirrelpad_set_mods(8); MEM_W(0,S32(0x800BE9F0))=0x21; MEM_HU(0,S32(0x800BE710))=0x1000;
    MEM_W(0,S32(0x800C35B0))=300; assert(squirrelpad_mod_skip(rdram,0)==0);
    MEM_W(0,S32(0x800C35B0))=301; assert(squirrelpad_mod_skip(rdram,0)==1);
    MEM_W(0,S32(0x800BE9F0))=1; MEM_HU(0,S32(0x800BE710))=0x20; MEM_W(0,S32(0x800C3640))=400;
    assert(squirrelpad_mod_skip(rdram,0)==1);
    MEM_BU(0,S32(0x800C3C9C))=1; assert(squirrelpad_mod_skip(rdram,0)==0);
    squirrelpad_set_mods(24); assert(squirrelpad_mod_skip(rdram,0)==1);
    assert(squirrelpad_mod_skip(rdram,-1)==0 && squirrelpad_mod_skip(rdram,8)==0);
    MEM_HU(0,S32(0x800BE710))=0; assert(squirrelpad_mod_skip(rdram,0)==0);
    puts("Static mod memory, disabled path, death guard, timing and protected-scene checks passed.");
}
