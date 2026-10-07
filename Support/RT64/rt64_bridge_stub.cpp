extern "C" const char *squirrelpad_rt64_initialize(void *, void *) { return nullptr; }
extern "C" void squirrelpad_rt64_shutdown() {}
extern "C" void squirrelpad_rt64_release_probe() {}

extern "C" int squirrelpad_validate_texture_pack(const char *) { return -7; }
extern "C" void squirrelpad_set_texture_pack(const char *) {}
extern "C" int squirrelpad_texture_status() { return -1; }
extern "C" unsigned squirrelpad_texture_matches() { return 0; }
