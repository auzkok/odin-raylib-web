#!/bin/bash -eu

OUT_DIR="build/web"

python3 -m http.server -d $OUT_DIR