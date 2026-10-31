function(squirrelpad_module_identity output root)
    find_package(Python3 REQUIRED COMPONENTS Interpreter)
    file(GLOB_RECURSE contract_sources CONFIGURE_DEPENDS
        "${root}/Support/Conker/*.h" "${root}/Support/Conker/*.cpp")
    file(GLOB contract_patches CONFIGURE_DEPENDS "${root}/patches/*.patch")
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
        ${contract_sources} ${contract_patches} "${root}/sources.lock.json"
        "${root}/cmake/host-tools/CMakeLists.txt" "${root}/cmake/host-tools/windows-utf8.manifest"
        "${root}/Support/Conker/game_module_functions.inc" "${root}/scripts/module-identity.py")
    execute_process(COMMAND "${Python3_EXECUTABLE}" "${root}/scripts/module-identity.py"
        OUTPUT_VARIABLE identity OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
    set(${output} "${identity}" PARENT_SCOPE)
endfunction()
