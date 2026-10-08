cmake_minimum_required(VERSION 3.28)
project(SquirrelPad LANGUAGES Swift C CXX OBJC OBJCXX)

if (NOT CMAKE_SYSTEM_NAME STREQUAL "iOS")
    message(FATAL_ERROR "SquirrelPad is an iOS/iPadOS app")
endif()

set(CMAKE_OSX_DEPLOYMENT_TARGET "17.0" CACHE STRING "Minimum iOS version")
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# Keep diagnostic __FILE__ strings and debug paths independent of the local
# checkout location in C-family objects, including pinned subprojects.
foreach(language C CXX OBJC OBJCXX)
    set(CMAKE_${language}_FLAGS
        "${CMAKE_${language}_FLAGS} -ffile-prefix-map=${CMAKE_CURRENT_SOURCE_DIR}=.")
endforeach()
set(CONKER_RT64 OFF CACHE BOOL "Build the current core without the desktop frontend" FORCE)
set(SQUIRRELPAD_CONKER_SOURCE "${CMAKE_CURRENT_SOURCE_DIR}/work/CBFD-Recompiled"
    CACHE PATH "Pinned patched Conker checkout")
set(conker_source "${SQUIRRELPAD_CONKER_SOURCE}")
if (NOT EXISTS "${conker_source}/RecompiledFuncs/inputs.sha256")
    message(FATAL_ERROR "Run scripts/setup-source.sh and generate RecompiledFuncs first")
endif()
add_subdirectory("${conker_source}/host" "${CMAKE_CURRENT_BINARY_DIR}/conker-host")

target_compile_definitions(librecomp PRIVATE SQUIRRELPAD_SAVE_FEEDBACK)
target_compile_definitions(RecompiledFuncs PRIVATE SQUIRRELPAD_STATIC_MODS SQUIRRELPAD_MOBILE_FIXES)

set(SQUIRRELPAD_RT64_ARCHIVE_DIR "" CACHE PATH "Verified RT64 iOS archive directory")
set(rt64_bridge Support/RT64/rt64_bridge_stub.cpp)
if (SQUIRRELPAD_RT64_ARCHIVE_DIR)
    set(rt64_bridge Support/RT64/rt64_metal_bridge.cpp)
    target_compile_definitions(ConkerRecomp PRIVATE SQUIRRELPAD_MOBILE_RT64)
    set(rt64_archives
        "${SQUIRRELPAD_RT64_ARCHIVE_DIR}/rt64.a"
        "${SQUIRRELPAD_RT64_ARCHIVE_DIR}/src/contrib/plume/libplume.a"
        "${SQUIRRELPAD_RT64_ARCHIVE_DIR}/src/contrib/re-spirv/libre-spirv.a"
        "${SQUIRRELPAD_RT64_ARCHIVE_DIR}/src/contrib/zstd/build/cmake/lib/libzstd.a")
    foreach(archive IN LISTS rt64_archives)
        if (NOT EXISTS "${archive}")
            message(FATAL_ERROR "Missing verified RT64 archive: ${archive}")
        endif()
    endforeach()
endif()

add_executable(SquirrelPad MACOSX_BUNDLE
    Sources/SquirrelPadApp.swift
    Sources/SquirrelPadShell.swift
    Sources/RT64Surface.swift
    Sources/TouchControlsView.swift
    Sources/ControllerInput.swift
    Sources/TexturePackStore.swift
    Sources/EnhancementSettings.swift
    Sources/VisualEffectsSettings.swift
    Resources/Assets.xcassets
    Support/Conker/mobile_entry.cpp
    Support/Conker/mobile_audio.cpp
    Support/Conker/mobile_input.cpp
    Support/Conker/mobile_mods.cpp
    Support/Conker/mobile_music.cpp
    Support/Conker/Reloaded/accessibility.cpp
    Support/Conker/Reloaded/look_aim.cpp
    Support/Conker/Reloaded/sound_mix.cpp
    Support/Conker/Reloaded/crosshair.cpp
    Support/Conker/Reloaded/cash_hud.cpp
    Support/Conker/Reloaded/skip_intro.cpp
    Support/Conker/Reloaded/mobile_enhancements.cpp
    Support/Conker/Reloaded/free_camera.cpp
    Support/Conker/Reloaded/ledge_grab.cpp
    ${rt64_bridge}
)
set_source_files_properties(Resources/Assets.xcassets PROPERTIES
    MACOSX_PACKAGE_LOCATION "Resources")
option(SQUIRRELPAD_SIM_INPUT "Enable the opt-in Simulator controller probe" OFF)
if(SQUIRRELPAD_SIM_INPUT)
    if(NOT CMAKE_OSX_SYSROOT MATCHES "iphonesimulator")
        message(FATAL_ERROR "SQUIRRELPAD_SIM_INPUT is Simulator-only")
    endif()
    target_sources(SquirrelPad PRIVATE Sources/SimulatorInputProbe.swift)
    target_compile_options(SquirrelPad PRIVATE "$<$<COMPILE_LANGUAGE:Swift>:-DSQUIRRELPAD_SIM_INPUT>")
endif()
# Keep upstream notice texts with the local developer build. These paths are
# resolved from the pinned source checkout, not from a distributable ROM.
set(third_party_notices
    "CBFD-Recompiled|LICENSE"
    "N64ModernRuntime|tools/N64ModernRuntime/COPYING"
    "N64Recomp|tools/N64Recomp/LICENSE"
    "RT64|tools/rt64/LICENSE"
    "Plume|tools/rt64/src/contrib/plume/LICENSE"
    "re-spirv|tools/rt64/src/contrib/re-spirv/LICENSE"
    "zstd|tools/rt64/src/contrib/zstd/LICENSE"
    "hlslpp|tools/rt64/src/contrib/hlslpp/LICENSE"
    "o1heap|tools/N64ModernRuntime/thirdparty/o1heap/LICENSE"
    "miniz|tools/N64ModernRuntime/thirdparty/miniz/LICENSE"
    "xxHash|tools/N64ModernRuntime/thirdparty/xxHash/LICENSE"
    "Rabbitizer|tools/N64ModernRuntime/N64Recomp/lib/rabbitizer/LICENSE"
    "fmt|tools/N64ModernRuntime/N64Recomp/lib/fmt/LICENSE"
    "sljit|tools/N64ModernRuntime/N64Recomp/lib/sljit/LICENSE"
    "ddspp|tools/rt64/src/contrib/ddspp/LICENSE"
    "stb|tools/rt64/src/contrib/stb/LICENSE"
    "im3d|tools/rt64/src/contrib/im3d/LICENSE"
    "ImGui|tools/rt64/src/contrib/imgui/LICENSE.txt"
    "SPIRV-Cross|tools/rt64/src/contrib/spirv-cross/LICENSE"
    "SPIRV-Headers|tools/rt64/src/contrib/re-spirv/external/SPIRV-Headers/LICENSE"
    "metal-cpp|tools/rt64/src/contrib/plume/contrib/metal-cpp/LICENSE.txt"
)
foreach(notice IN LISTS third_party_notices)
    string(REPLACE "|" ";" fields "${notice}")
    list(GET fields 0 notice_name)
    list(GET fields 1 notice_path)
    set(notice_source "${conker_source}/${notice_path}")
    if (NOT EXISTS "${notice_source}")
        message(FATAL_ERROR "Missing pinned notice text: ${notice_source}")
    endif()
    set(notice_copy "${CMAKE_CURRENT_BINARY_DIR}/notices/${notice_name}.txt")
    configure_file("${notice_source}" "${notice_copy}" COPYONLY)
    set_source_files_properties("${notice_copy}" PROPERTIES
        MACOSX_PACKAGE_LOCATION "Resources/ThirdPartyNotices")
    target_sources(SquirrelPad PRIVATE "${notice_copy}")
endforeach()
foreach(notice_name LICENSE THIRD_PARTY_LICENSE)
    set(notice_copy "${CMAKE_CURRENT_BINARY_DIR}/notices/Reloaded-${notice_name}.txt")
    configure_file("Support/Conker/Reloaded/${notice_name}.txt" "${notice_copy}" COPYONLY)
    set_source_files_properties("${notice_copy}" PROPERTIES MACOSX_PACKAGE_LOCATION "Resources/ThirdPartyNotices")
    target_sources(SquirrelPad PRIVATE "${notice_copy}")
endforeach()
foreach(notice_name concurrentqueue lightweightsemaphore sse2neon)
    set(notice_copy "${CMAKE_CURRENT_BINARY_DIR}/notices/${notice_name}.txt")
    configure_file("Support/Notices/${notice_name}.txt" "${notice_copy}" COPYONLY)
    set_source_files_properties("${notice_copy}" PROPERTIES
        MACOSX_PACKAGE_LOCATION "Resources/ThirdPartyNotices")
    target_sources(SquirrelPad PRIVATE "${notice_copy}")
endforeach()
target_include_directories(SquirrelPad PRIVATE "${conker_source}/tools/N64ModernRuntime/N64Recomp/include")
target_link_libraries(SquirrelPad PRIVATE ConkerRecomp
    "-framework SwiftUI" "-framework UniformTypeIdentifiers" "-framework CryptoKit"
    "-framework AudioToolbox" "-framework Metal" "-framework MetalKit" "-framework QuartzCore" "-framework UIKit")
target_link_libraries(SquirrelPad PRIVATE "-framework GameController" "-framework CoreHaptics")
if (SQUIRRELPAD_RT64_ARCHIVE_DIR)
    target_sources(SquirrelPad PRIVATE Support/Conker/mobile_rt64_renderer.cpp Support/Conker/mobile_texture_packs.cpp)
    target_compile_definitions(SquirrelPad PRIVATE HLSL_CPU RT64_EMBEDDED_APPLE)
    target_include_directories(SquirrelPad PRIVATE
        "${conker_source}/tools/rt64/src"
        "${conker_source}/tools/rt64/src/contrib"
        "${conker_source}/tools/rt64/src/contrib/plume"
        "${conker_source}/tools/rt64/src/contrib/hlslpp/include"
        "${conker_source}/tools/N64ModernRuntime/ultramodern/include"
        "${conker_source}/tools/N64ModernRuntime/N64Recomp/include")
    foreach(archive IN LISTS rt64_archives)
        target_link_options(SquirrelPad PRIVATE "LINKER:-force_load,${archive}")
    endforeach()
endif()
set_target_properties(SquirrelPad PROPERTIES
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_BUNDLE_NAME "SquirrelPad"
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.chrissotraidis.squirrelpad"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1.0"
    MACOSX_BUNDLE_BUNDLE_VERSION "1"
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Config/Info.plist.in"
    XCODE_ATTRIBUTE_CODE_SIGNING_ALLOWED "NO"
    XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO"
    XCODE_ATTRIBUTE_GENERATE_INFOPLIST_FILE "NO"
    XCODE_ATTRIBUTE_ASSETCATALOG_COMPILER_APPICON_NAME "AppIcon"
    XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "17.0"
    XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.chrissotraidis.squirrelpad"
    XCODE_ATTRIBUTE_SUPPORTED_PLATFORMS "iphoneos iphonesimulator"
    XCODE_ATTRIBUTE_SUPPORTS_MACCATALYST "NO"
    XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2"
    XCODE_ATTRIBUTE_SWIFT_VERSION "5.0"
)
