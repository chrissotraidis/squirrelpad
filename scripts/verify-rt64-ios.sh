#!/usr/bin/env bash
set -euo pipefail

project=$(cd "$(dirname "$0")/.." && pwd)
checkout=${SQUIRRELPAD_CHECKOUT:-"$project/work/CBFD-Recompiled"}
build_tag=${SQUIRRELPAD_RT64_BUILD_TAG:-}
source="$checkout/tools/rt64"
host_build="$checkout/host/build-macos-metal"
file_to_c="$host_build/rt64/src/tools/file_to_c/file_to_c"
sdk=${1:-iphonesimulator}
case "$sdk" in
    iphonesimulator) target=arm64-apple-ios17.0-simulator; metal_target=air64-apple-ios17.0-simulator ;;
    iphoneos) target=arm64-apple-ios17.0; metal_target=air64-apple-ios17.0 ;;
    *) echo "Usage: $0 [iphonesimulator|iphoneos]" >&2; exit 2 ;;
esac

if [ ! -x "$file_to_c" ]; then
    echo "Build the macOS Metal host first to generate RT64 shaders and file_to_c." >&2
    exit 1
fi
generated="$project/work/generated-rt64-$sdk$build_tag"
build="$project/work/build-rt64-$sdk$build_tag"
mkdir -p "$generated/src/shaders"
rsync -a --include '*/' --include '*.spirv.c' --include '*.spirv.h' \
    --include '*.rw.c' --include '*.rw.h' --exclude '*' "$host_build/" "$generated/"

shader_count=0
while IFS= read -r -d '' metal_source; do
    relative=${metal_source#"$host_build/"}
    output_base="$generated/$relative"
    array_name=$(awk '/extern const char/ {gsub("\\[.*", "", $4); print $4; exit}' "$metal_source.c")
    if [ -z "$array_name" ]; then
        echo "Missing array name in $metal_source.c" >&2
        exit 1
    fi
    # SDK 26 defaults to Metal 4, which iOS 17/18 cannot load at runtime.
    xcrun -sdk "$sdk" metal -target "$metal_target" -std=metal3.1 -c "$metal_source" -o "$output_base.air"
    xcrun -sdk "$sdk" metallib "$output_base.air" -o "$output_base.metallib"
    "$file_to_c" "$output_base.metallib" "$array_name" "$output_base.c" "$output_base.h"
    shader_count=$((shader_count + 1))
done < <(find "$host_build/src/shaders" -type f -name '*.metal' -print0)
if [ "$shader_count" -ne 56 ]; then
    echo "Expected 56 RT64 Metal shaders, found $shader_count" >&2
    exit 1
fi

cmake -S "$source" -B "$build" -G Ninja \
    -DCMAKE_SYSTEM_NAME=iOS -DCMAKE_OSX_SYSROOT="$sdk" \
    -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_OSX_DEPLOYMENT_TARGET=17.0 \
    -DCMAKE_BUILD_TYPE=Release -DRT64_STATIC=ON \
    -DRT64_EMBEDDED_APPLE=ON \
    -DRT64_PREGENERATED_SHADER_DIR="$generated" \
    -DRT64_EMBEDDED_APPLE_SOURCE_DIR="$project/Support/RT64"
cmake --build "$build" --target rt64 --parallel 4 > "$build/build.log" 2>&1 || {
    rg -n 'FAILED:|error:' "$build/build.log" | tail -n 40 >&2 || true
    exit 1
}

archives=(
    "$build/rt64.a"
    "$build/src/contrib/plume/libplume.a"
    "$build/src/contrib/re-spirv/libre-spirv.a"
    "$build/src/contrib/zstd/build/cmake/lib/libzstd.a"
)
link_args=()
for archive in "${archives[@]}"; do
    test -f "$archive"
    link_args+=( -Wl,-force_load,"$archive" )
done
probe="$build/rt64-link-probe"
xcrun -sdk "$sdk" clang++ -target "$target" \
    "$project/Support/RT64/rt64_link_probe.cpp" "${link_args[@]}" \
    -framework Metal -framework QuartzCore -framework CoreGraphics \
    -framework Foundation -framework UIKit -o "$probe"
if xcrun -sdk "$sdk" nm -u "$probe" | rg 'SDL|NFD|AppKit|IOKit|X11|vkCreateMacOSSurface'; then
    echo "Desktop-only undefined symbol in iOS RT64 closure" >&2
    exit 1
fi
echo "$sdk RT64 archive: $(shasum -a 256 "${archives[0]}" | cut -d' ' -f1)"
echo "$sdk force-loaded closure: $(lipo -archs "$probe") $(shasum -a 256 "$probe" | cut -d' ' -f1)"
