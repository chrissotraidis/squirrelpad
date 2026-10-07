#pragma once
#include <string>
#include <cstdint>
struct SquirrelPadTextureRequest { std::string path; uint64_t revision; };
SquirrelPadTextureRequest squirrelpad_texture_request();
void squirrelpad_texture_result(int status, unsigned matches);
