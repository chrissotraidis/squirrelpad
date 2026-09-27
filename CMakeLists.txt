cmake_minimum_required(VERSION 3.28)
project(SquirrelPad LANGUAGES Swift C CXX OBJC OBJCXX)

if (NOT CMAKE_SYSTEM_NAME STREQUAL "iOS")
    message(FATAL_ERROR "SquirrelPad is an iOS/iPadOS app")
endif()

set(CMAKE_OSX_DEPLOYMENT_TARGET "17.0" CACHE STRING "Minimum iOS version")
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CONKER_RT64 OFF CACHE BOOL "Build the current core without the desktop frontend" FORCE)
set(conker_source "${CMAKE_CURRENT_SOURCE_DIR}/work/CBFD-Recompiled")
if (NOT EXISTS "${conker_source}/RecompiledFuncs/inputs.sha256")
    message(FATAL_ERROR "Run scripts/setup-source.sh and generate RecompiledFuncs first")
endif()
add_subdirectory("${conker_source}/host" "${CMAKE_CURRENT_BINARY_DIR}/conker-host")

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
    Sources/RT64Surface.swift
    Support/Conker/mobile_entry.cpp
    ${rt64_bridge}
)
target_link_libraries(SquirrelPad PRIVATE ConkerRecomp
    "-framework SwiftUI" "-framework UniformTypeIdentifiers" "-framework CryptoKit"
    "-framework Metal" "-framework MetalKit" "-framework QuartzCore" "-framework UIKit")
if (SQUIRRELPAD_RT64_ARCHIVE_DIR)
    target_sources(SquirrelPad PRIVATE Support/Conker/mobile_rt64_renderer.cpp)
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
    XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "17.0"
    XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.chrissotraidis.squirrelpad"
    XCODE_ATTRIBUTE_SUPPORTED_PLATFORMS "iphoneos iphonesimulator"
    XCODE_ATTRIBUTE_SUPPORTS_MACCATALYST "NO"
    XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2"
    XCODE_ATTRIBUTE_SWIFT_VERSION "5.0"
)
