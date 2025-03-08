@echo off

set OUT_DIR=build\web

python -m http.server -d %OUT_DIR%