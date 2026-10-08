// Synthetic N64 RAM checks: real mobile bridge, input, camera, audio and assists.
#include <cassert>
#include <chrono>
#include <cmath>
#include <cstring>
#include <thread>
#include <vector>
#include "recomp.h"
#include "mobile_enhancements.h"
extern "C" {
void squirrelpad_set_enhancements(uint32_t,float,int);
void squirrelpad_set_mix(float,float,float);
void squirrelpad_set_mods(unsigned);
int squirrelpad_mod_skip(uint8_t*,int);
void squirrelpad_controller_set_state(uint16_t,float,float);
void squirrelpad_controller_camera(float,float);
void squirrelpad_controller_clear();
void squirrelpad_touch_button(uint16_t,int);
void squirrelpad_touch_clear();
bool squirrelpad_mobile_get_input(int,uint16_t*,float*,float*);
void conker_note_volume(uint8_t*,recomp_context*);
void conker_voice_start_volume(uint8_t*,recomp_context*);
void conker_voice_set_volume(uint8_t*,recomp_context*);
int32_t conker_stream_volume(uint8_t*,int32_t);
void conker_ledge_grab_mask(uint8_t*,recomp_context*);
void conker_motion_blur(uint8_t*,recomp_context*);
void squirrelpad_save_completed();
uint64_t squirrelpad_save_serial();
// Generated game functions are outside this RAM fixture. Never silently emulate them.
void func_15044380(uint8_t*,recomp_context*) { assert(false && "collision requires game runtime"); }
void func_1501C730(uint8_t*,recomp_context*) { assert(false && "room transition requires game runtime"); }
}
int main() {
    std::vector<uint8_t> ram(8*1024*1024); auto*rdram=ram.data();
    constexpr int32_t player=int32_t(0x800CC2D0);
    auto write=[&](int off,float f){int32_t w;std::memcpy(&w,&f,4);MEM_W(off,player)=w;};
    auto read=[&](int off){int32_t w=MEM_W(off,player);float f;std::memcpy(&f,&w,4);return f;};
    auto input=[](uint16_t b,float &x,float &y){squirrelpad_enhancement_input(&b,&x,&y);return b;};
    float x=1,y=1;
    squirrelpad_set_enhancements(ToggleLook|ToggleCrouch,1,0);
    assert(input(0x2010,x,y)==0x2010); assert(input(0,x,y)==0x2010);
    assert(input(0x2010,x,y)==0); assert(input(0x2010,x,y)==0);
    squirrelpad_enhancement_reset(); assert(input(0,x,y)==0);
    squirrelpad_set_enhancements(Walk|Swim|LongerSpin|HealthHUD,1,0);
    MEM_W(0x100,player)=0x01000000; MEM_W(0x84,player)=0x00010000;
    squirrelpad_enhancement_frame(rdram); x=y=1; input(0x20,x,y);
    assert(std::abs(std::hypot(x,y)-0.3f)<0.0001f);
    MEM_W(0x84,player)=0x00D10000; squirrelpad_enhancement_frame(rdram);
    x=y=1;input(0x20,x,y);assert(x==1 && y==-1);
    assert(MEM_W(0,S32(0x800D2444))==240);
    write(0x24,1);write(0x28,10);write(0x20,-10);squirrelpad_enhancement_frame(rdram);
    assert(read(0x24)==0.55f && read(0x20)==-6);
    squirrelpad_set_enhancements(0,1,0);squirrelpad_enhancement_frame(rdram);assert(read(0x24)==1);
    // Ledge assistance only descending, only player one, at most once per fall.
    recomp_context ctx{};ctx.r7=player;ctx.r8=0x0E000000;
    MEM_W(0x100,player)=0;MEM_W(0x84,player)=0;write(0x20,-1);
    conker_ledge_grab_mask(rdram,&ctx);assert(ctx.r8==0x0E000000);
    squirrelpad_set_enhancements(LedgeGrab,1,0);write(0x20,1);
    conker_ledge_grab_mask(rdram,&ctx);assert(ctx.r8==0x0E000000);
    write(0x20,-1);conker_ledge_grab_mask(rdram,&ctx);assert(ctx.r8==0);
    MEM_W(0x84,player)=0x00420000;ctx.r8=0x0E000000;
    conker_ledge_grab_mask(rdram,&ctx);assert(ctx.r8==0x0E000000);
    MEM_W(0x84,player)=0;conker_ledge_grab_mask(rdram,&ctx);assert(ctx.r8==0x0E000000);
    // Camera axes clamp/deadzone, pause clearing, and no duplicate C-buttons while aiming.
    squirrelpad_set_enhancements(FreeCamera,1,0);squirrelpad_controller_clear();
    squirrelpad_controller_camera(2,0);conker::free_camera_stick(&x,&y);assert(x==1 && y==0);
    squirrelpad_controller_camera(0.1,0);conker::free_camera_stick(&x,&y);assert(x==0 && y==0);
    uint16_t b=0;squirrelpad_mobile_get_input(0,&b,&x,&y); // consume reset before aim notification
    squirrelpad_controller_set_state(0xF,0,0);conker::crosshair::aiming(false);
    squirrelpad_touch_button(1,1);squirrelpad_mobile_get_input(0,&b,&x,&y);assert((b&0xF)==1);
    squirrelpad_touch_button(1,0);squirrelpad_controller_clear();squirrelpad_mobile_get_input(0,&b,&x,&y);assert(b==0);
    conker::free_camera_stick(&x,&y);assert(x==0 && y==0);
    squirrelpad_touch_button(0x8000,1);squirrelpad_touch_button(0x8000,0);
    squirrelpad_mobile_get_input(0,&b,&x,&y);assert(b==0x8000);
    squirrelpad_mobile_get_input(0,&b,&x,&y);assert(b==0);
    squirrelpad_touch_button(0x8000,1);squirrelpad_touch_clear();
    squirrelpad_mobile_get_input(0,&b,&x,&y);assert(b==0);
    // Independent synth music/effects and streamed speech; malformed values are clamped.
    squirrelpad_set_mix(0.5,0.25,0.75);ctx.r4=0x80001000;conker_note_volume(rdram,&ctx);
    ctx.r4=0x80001004;ctx.r7=10000;conker_voice_start_volume(rdram,&ctx);assert(int32_t(ctx.r7)==5000);
    ctx.r4=0x80002004;ctx.r5=10000;conker_voice_set_volume(rdram,&ctx);assert(int32_t(ctx.r5)==2500);
    MEM_W(0,S32(0x800BE9F0))=1;assert(conker_stream_volume(rdram,10000)==7500);
    MEM_W(0,S32(0x800BE9F0))=0x21;assert(conker_stream_volume(rdram,10000)==5000);
    squirrelpad_set_mix(-1,2,NAN);assert(conker_stream_volume(rdram,10000)==0);
    ctx.r5=10000;conker_voice_set_volume(rdram,&ctx);assert(ctx.r5==10000);
    // Hold L does not trigger early or get consumed by an ineligible first slot.
    squirrelpad_set_enhancements(HoldSkip,1,0);squirrelpad_set_mods(8);
    MEM_W(0,S32(0x800BE9F0))=1;MEM_HU(0,S32(0x800BE710))=0x20;
    MEM_W(0,S32(0x800C3640))=0;MEM_W(4,S32(0x800C3640))=400;
    x=y=0;input(0x20,x,y);
    for(int i=0;i<14;i++){assert(squirrelpad_mod_skip(rdram,0)==0);if(i<12)assert(squirrelpad_mod_skip(rdram,1)==0);std::this_thread::sleep_for(std::chrono::milliseconds(100));}
    assert(squirrelpad_mod_skip(rdram,1)==1);assert(squirrelpad_mod_skip(rdram,1)==0);
    input(0,x,y);assert(squirrelpad_mod_skip(rdram,1)==0);
    input(0x20,x,y);assert(squirrelpad_mod_skip(rdram,1)==0);
    squirrelpad_enhancement_reset();assert(squirrelpad_mod_skip(rdram,1)==0);
    assert(squirrelpad_skip_buttons(0x20,false)==0x20); // disabled mod never intercepts L
    squirrelpad_set_enhancements(ReduceMotion,1,0);ctx.r3=4;conker_motion_blur(rdram,&ctx);assert(ctx.r3==0);
    const auto serial=squirrelpad_save_serial();squirrelpad_save_completed();assert(squirrelpad_save_serial()==serial+1);
}
