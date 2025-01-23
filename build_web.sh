#!/bin/bash -eu

# Note RAYLIB_WASM_LIB=env.o -- This env.o thing is the object file that
# contains things linked into the WASM binary. You can see how RAYLIB_WASM_LIB
# is used inside <odin>/vendor/raylib/raylib.odin.
#
# We have to do it this way because the emscripten compiler (emcc) needs to be
# fed the precompiled raylib library file. That stuff will end up in env.o,
# which our Odin code is instructed to link to.
#
# Note that we use a separate define for raygui: -define:RAYGUI_WASM_LIB=env.o

OUT_DIR="build/web"

# Setting EMSCRIPTEN_SDK_DIR is optional on some Linux systems, if you've
# installed emscripten through a package manager, since emcc might then already
# be in your path.
EMSCRIPTEN_SDK_DIR="$HOME/repos/emsdk"

mkdir -p $OUT_DIR

export EMSDK_QUIET=1
# shellcheck disable=SC1091
[[ -f "$EMSCRIPTEN_SDK_DIR/emsdk_env.sh" ]] && . "$EMSCRIPTEN_SDK_DIR/emsdk_env.sh"

# Note RAYLIB_WASM_LIB=env.o -- This env.o thing is the object file that 
# contains things linked into the WASM binary. You can see how RAYLIB_WASM_LIB
# is used inside <odin>/vendor/raylib/raylib.odin.
#
# We have to do it this way because the emscripten compiler (emcc) needs to be
# fed the precompiled raylib library file. That stuff will end up in env.o,
# which our Odin code is instructed to link to.
#
# Note that we use a separate define for raygui: -define:RAYGUI_WASM_LIB=env.o
odin build source/main_web -target:js_wasm32 -build-mode:obj -define:RAYLIB_WASM_LIB=env.o -define:RAYGUI_WASM_LIB=env.o -vet -strict-style -o:speed -out:$OUT_DIR/game

ODIN_PATH=$(odin root)

cp $ODIN_PATH/core/sys/wasm/js/odin.js $OUT_DIR

# Tell emscripten to compile the `main_web.c` file, which is the emscripten
# entry point. We also link in the build Odin code, raylib and raygui
files="source/main_web/main_web.c $OUT_DIR/game.wasm.o ${ODIN_PATH}/vendor/raylib/wasm/libraylib.a ${ODIN_PATH}/vendor/raylib/wasm/libraygui.a"
flags="-sUSE_GLFW=3 -sWASM_BIGINT -sWARN_ON_UNDEFINED_SYMBOLS=0 -sASSERTIONS --shell-file source/main_web/index_template.html --preload-file assets"

# shellcheck disable=SC2086
# Add `-g` to `emcc` call to enable debug symbols (works in chrome).
emcc -o $OUT_DIR/index.html $files $flags && rm $OUT_DIR/game.wasm.o

echo "Web build created in ${OUT_DIR}"