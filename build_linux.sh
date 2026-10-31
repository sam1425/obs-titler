#!/usr/bin/env bash
# Build standalone Linux executable
set -e

cd "$(dirname "$0")"

echo "Building Linux executable..."
uv run pyinstaller \
  --noconsole \
  --onefile \
  --name "obs-sermon-controller" \
  --add-data "main.qml:." \
  main.py

echo ""
echo "Done! Executable is located at: dist/obs-sermon-controller"
