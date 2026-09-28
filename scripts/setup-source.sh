#!/usr/bin/env bash
set -euo pipefail

project=$(cd "$(dirname "$0")/.." && pwd)
checkout=${SQUIRRELPAD_CHECKOUT:-"$project/work/CBFD-Recompiled"}
expected=c55359c579448fe5c212faf4bb5c2415d6ec7fa8

if [ ! -d "$checkout/.git" ]; then
    mkdir -p "$project/work"
    git clone https://github.com/sciaschi/CBFD-Recompiled.git "$checkout"
    git -C "$checkout" checkout --detach "$expected"
fi
if [ "$(git -C "$checkout" rev-parse HEAD)" != "$expected" ]; then
    echo "Unexpected Conker source commit; preserving checkout: $checkout" >&2
    exit 1
fi

git -C "$checkout" submodule update --init --recursive \
    tools/N64Recomp tools/N64ModernRuntime tools/rt64 tools/RecompFrontend

apply_once() {
    local directory=$1 patch_file=$2
    if git -C "$directory" apply --reverse --check "$patch_file" 2>/dev/null; then
        return
    fi
    git -C "$directory" apply --check "$patch_file"
    git -C "$directory" apply "$patch_file"
}

apply_once "$checkout/tools/N64Recomp" "$checkout/recomp/n64recomp.patch"
apply_once "$checkout/tools/N64ModernRuntime" "$checkout/recomp/n64modernruntime.patch"
apply_once "$checkout/tools/N64ModernRuntime" "$project/patches/n64modernruntime-ios-mods.patch"
apply_once "$checkout/tools/rt64" "$checkout/recomp/rt64.patch"
apply_once "$checkout" "$project/patches/conker-host.patch"
apply_once "$checkout" "$project/patches/conker-mobile-audio.patch"
apply_once "$checkout" "$project/patches/conker-mobile-lifecycle.patch"
apply_once "$checkout/tools/rt64/src/contrib/hlslpp" "$project/patches/hlslpp-stdlib.patch"
apply_once "$checkout/tools/rt64" "$project/patches/rt64-ios.patch"
apply_once "$checkout/tools/rt64" "$project/patches/rt64-ios-sampler-limit.patch"
apply_once "$checkout/tools/rt64" "$project/patches/rt64-ios-debug-capability.patch"
apply_once "$checkout/tools/rt64" "$project/patches/rt64-static-fb-params.patch"
apply_once "$checkout/tools/rt64" "$project/patches/rt64-metal-sdk-scope.patch"
apply_once "$checkout/tools/rt64/src/contrib/plume" "$project/patches/plume-ios-metal.patch"
apply_once "$checkout/tools/N64ModernRuntime/N64Recomp/lib/sljit" "$project/patches/sljit-ios-allocator.patch"

if [ "${1:-}" != "" ]; then
    python3 - "$1" "$checkout/conker/baserom.us.z64" <<'PY'
import hashlib
import os
import pathlib
import sys

rom = pathlib.Path(sys.argv[1]).resolve(strict=True)
link = pathlib.Path(sys.argv[2])
with rom.open('rb') as stream:
    header = stream.read(4)
    stream.seek(0)
    digest = hashlib.file_digest(stream, 'sha1').hexdigest()
if rom.stat().st_size != 67108864 or header != bytes.fromhex('80371240') or digest != '4cbadd3c4e0729dec46af64ad018050eada4f47a':
    raise SystemExit('ROM does not match the supported US big-endian bytes')
if link.is_symlink() and link.resolve() == rom:
    pass
elif link.exists() or link.is_symlink():
    raise SystemExit(f'Preserving existing ROM path: {link}')
else:
    link.symlink_to(rom)
print('Supported private ROM verified; link created or already correct.')
PY
fi

echo "Pinned and patched source ready at $checkout"
