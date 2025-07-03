#!/usr/bin/env bash

set -e

# Global configuration
MODULE_ROOT='sokol'
SOKOL_FLAGS='-DNDEBUG -DIMPL'
C_FOLDER="$MODULE_ROOT/c"

# Backends
BACKEND_MACOS="SOKOL_METAL"
BACKEND_IOS="SOKOL_METAL"
BACKEND_WINDOWS="SOKOL_GLCORE"
BACKEND_ANDROID="SOKOL_GLES3"

MACOS_SYSROOT=$(xcrun --show-sdk-path --sdk macosx)
IOS_SYSROOT=$(xcrun --show-sdk-path --sdk iphoneos)
NDK_PATH="/opt/homebrew/share/android-commandlinetools/ndk/29.0.13113456"

# Modules to build
MODULES=(
    sokol_log
    sokol_gfx
    sokol_app
    sokol_glue
    sokol_time
    sokol_audio
    sokol_debugtext
    sokol_shape
    sokol_gl
    sokol_fontstash
    sokol_imgui
    sokol_spine
)

# Validate SDK/NDK paths
if [ ! -d "$MACOS_SYSROOT" ]; then
    echo "ERROR: macOS SDK sysroot not found."
    exit 1
fi
if [ ! -d "$IOS_SYSROOT" ]; then
    echo "ERROR: iOS SDK sysroot not found."
    exit 1
fi
if [ ! -d "$NDK_PATH" ]; then
    echo "ERROR: Android NDK path not found: $NDK_PATH"
    exit 1
fi

# Create folder structure
for MODULE in "${MODULES[@]}"; do
    MODNAME=$(echo "$MODULE" | cut -d'_' -f2)
    mkdir -p "$MODULE_ROOT/$MODNAME/bin"
done

build_macos() {
    SRC=$1
    MODNAME=$(echo "$SRC" | cut -d'_' -f2)
    DST="$MODULE_ROOT/$MODNAME/bin/${SRC}_macos"
    echo "Building macOS: $DST"
    cc -c -O2 -x objective-c -isysroot "$MACOS_SYSROOT" -mmacos-version-min=10.15 -arch arm64 $SOKOL_FLAGS -D$BACKEND_MACOS "$C_FOLDER/$SRC.c"
    ar rcs "$DST.a" "$SRC.o"
}

build_windows() {
    SRC=$1
    MODNAME=$(echo "$SRC" | cut -d'_' -f2)
    echo "Building Windows: $DST"
    x86_64-w64-mingw32-gcc -c -O2 -mwin32 $SOKOL_FLAGS -D$BACKEND_WINDOWS "$C_FOLDER/$SRC.c" -o "$SRC.obj"
    x86_64-w64-mingw32-ar rcs "$MODULE_ROOT/$MODNAME/bin/${SRC}_windows.lib" "$SRC.obj"
}

build_ios() {
    SRC=$1
    MODNAME=$(echo "$SRC" | cut -d'_' -f2)
    DST="$MODULE_ROOT/$MODNAME/bin/${SRC}_ios"
    echo "Building iOS: $DST"
    cc -c -O2 -x objective-c -isysroot "$IOS_SYSROOT" -mios-version-min=13 -arch arm64 $SOKOL_FLAGS -D$BACKEND_IOS "$C_FOLDER/$SRC.c"
    ar rcs "$DST.a" "$SRC.o"
}

build_android() {
    SRC=$1
    API=$2
    MODNAME=$(echo "$SRC" | cut -d'_' -f2)
    DST="$MODULE_ROOT/$MODNAME/bin/${SRC}_android"
    echo "Building Android: $DST"

    CLANG="$NDK_PATH/toolchains/llvm/prebuilt/darwin-x86_64/bin/aarch64-linux-android$API-clang"
    AR_BIN="$NDK_PATH/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-ar"

    if [ ! -x "$CLANG" ]; then
        echo "ERROR: Android Clang compiler not found at $CLANG"
        exit 1
    fi
    if [ ! -x "$AR_BIN" ]; then
        echo "ERROR: Android AR tool not found at $AR_BIN"
        exit 1
    fi

    # SOKOL_ANDROID disables SOKOL_NO_ENTRY in sokol_defines.h, see patch_sokol_defines()
    $CLANG -c -O2 $SOKOL_FLAGS -DSOKOL_ANDROID -D$BACKEND_ANDROID "$C_FOLDER/$SRC.c" -o "$SRC.o"
    $AR_BIN rcs "$DST.a" "$SRC.o"
}

create_version_md() {
    echo "Creating VERSION.md ..."

    DATE=$(date)
    COMMIT_HASH=$(git rev-parse --short HEAD)
    HEADER="// -----------------------------------------------------------------------------
// Backends
//  - macOS       : $BACKEND_MACOS
//  - iOS         : $BACKEND_IOS
//  - Windows     : $BACKEND_WINDOWS
//  - Android     : $BACKEND_ANDROID
// -----------------------------------------------------------------------------
// Source Commit  : $COMMIT_HASH from https://github.com/colinbellino/sokol-jai
// Sokol Flags    : $SOKOL_FLAGS
// Generated On   : $DATE
// -----------------------------------------------------------------------------

"

    echo "$HEADER" > "$MODULE_ROOT/VERSION.md"
}

# Run builds
for MODULE in "${MODULES[@]}"; do
    build_macos "$MODULE"
    build_windows "$MODULE"
    build_ios "$MODULE"
    build_android "$MODULE" "26"
done

create_version_md

# Clean up object files
rm -f *.o *.obj
