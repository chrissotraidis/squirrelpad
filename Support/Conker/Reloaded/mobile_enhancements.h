#pragma once
#include <cstdint>
#include <string>
// Persisted option bits shared with EnhancementSettings.swift.
enum SquirrelOption : uint32_t {
    FreeCamera=1u<<0, CameraInvertX=1u<<1, CameraInvertY=1u<<2, AimInvert=1u<<3,
    Crosshair=1u<<4, SkipIntro=1u<<5, HoldSkip=1u<<6, ToggleLook=1u<<7,
    ToggleCrouch=1u<<8, Walk=1u<<9, Swim=1u<<10, ReduceMotion=1u<<11,
    HealthHUD=1u<<12, LongerSpin=1u<<13, LedgeGrab=1u<<14
};
bool squirrelpad_option(SquirrelOption option);
extern "C" void squirrelpad_camera_axes(float* x, float* y);
extern "C" void squirrelpad_enhancement_frame(uint8_t* rdram);
extern "C" void squirrelpad_enhancement_input(uint16_t* buttons, float* x, float* y);
extern "C" void squirrelpad_enhancement_reset();
extern "C" int squirrelpad_skip_buttons(uint16_t pressed, bool enabled);
extern "C" void squirrelpad_skip_consumed();
namespace conker {
    bool camera_inverted(); bool camera_tilt_inverted(); float camera_turn_speed();
    bool free_camera_enabled(); bool free_camera_mouse(); bool normal_camera();
    void free_camera_stick(float*,float*);
    bool skip_intro(); void skip_intro_on_vi(uint8_t*); bool skip_intro_pressing_start();
    namespace testing { double game_seconds(); }
    namespace look_aim { void on_input_poll(); void reset(); }
    namespace crosshair { bool aiming_active(); void reset(); void aiming(bool); void look_mode(float); void set_buttons(uint16_t); }
    namespace qol {
        bool ledge_grab(); bool cutscene_playing(); bool longer_spin(); bool always_show_hud();
        bool toggle_r_look(); bool toggle_crouch(); bool invert_swimming(); int walk_button(); int cash_counter();
        uint16_t apply_toggles(uint16_t); void apply_walk(uint16_t,float*,float*); void apply_swim(float*);
        void on_vi_memory(uint8_t*); void longer_spin_on_vi(uint8_t*);
    }
}
