cmake_minimum_required(VERSION 3.28)
project(SquirrelPadGameModule LANGUAGES C CXX)
if(NOT CMAKE_SYSTEM_NAME STREQUAL "iOS")
    message(FATAL_ERROR "Use PadMint's iOS module toolchain (or Apple's iOS SDK on a Mac)")
endif()
get_filename_component(SQUIRRELPAD_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../.." ABSOLUTE)
set(SQUIRRELPAD_CONKER_SOURCE "${SQUIRRELPAD_ROOT}/work/CBFD-Recompiled" CACHE PATH "Pinned patched source")
set(source "${SQUIRRELPAD_CONKER_SOURCE}")
set(runtime "${source}/tools/N64ModernRuntime")
if(NOT EXISTS "${source}/RecompiledFuncs/inputs.sha256")
    message(FATAL_ERROR "Generate the game from your own ROM with scripts/build-game-module.py first")
endif()
find_package(Python3 REQUIRED COMPONENTS Interpreter)
execute_process(COMMAND "${Python3_EXECUTABLE}" "${SQUIRRELPAD_ROOT}/scripts/check-generated.py" "${source}"
    COMMAND_ERROR_IS_FATAL ANY)
include("${SQUIRRELPAD_ROOT}/cmake/ModuleIdentity.cmake")
squirrelpad_module_identity(identity "${SQUIRRELPAD_ROOT}")
file(GLOB generated CONFIGURE_DEPENDS "${source}/RecompiledFuncs/funcs_*.c")
add_library(SquirrelPadGame SHARED ${generated}
    "${source}/RecompiledFuncs/tlb_pages.c" "${source}/RecompiledFuncs/rsp/audio_ucode.cpp"
    "${source}/host/src/overlays.cpp" "${SQUIRRELPAD_ROOT}/Support/Conker/game_module_entry.cpp")
set_target_properties(SquirrelPadGame PROPERTIES C_STANDARD 11 CXX_STANDARD 20
    CXX_STANDARD_REQUIRED ON CXX_SCAN_FOR_MODULES OFF C_VISIBILITY_PRESET hidden CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON PREFIX "" OUTPUT_NAME "SquirrelPadGame")
target_include_directories(SquirrelPadGame PRIVATE "${SQUIRRELPAD_ROOT}/Support/Conker"
    "${source}/host/src" "${source}/RecompiledFuncs" "${runtime}/N64Recomp/include"
    "${runtime}/librecomp/include" "${runtime}/ultramodern/include"
    "${runtime}/thirdparty" "${runtime}/thirdparty/sse2neon")
target_compile_definitions(SquirrelPadGame PRIVATE SQUIRRELPAD_STATIC_MODS SQUIRRELPAD_MOBILE_FIXES
    "SQUIRRELPAD_MODULE_ID=\"${identity}\"")
target_compile_options(SquirrelPadGame PRIVATE -include setjmp.h -fno-strict-aliasing
    -Wno-implicit-function-declaration -Wno-unused-label -Wno-unused-variable -Wno-unused-but-set-variable
    "-ffile-prefix-map=${SQUIRRELPAD_ROOT}=.")
target_link_options(SquirrelPadGame PRIVATE "LINKER:-undefined,dynamic_lookup")
# Recompiled C functions must bind to this module, never the app's small forwarders.
# Only squirrelpad_get_game_module has default visibility; check this in the build script.
