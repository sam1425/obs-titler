#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

echo "Building optimized Linux binary..."
uv run pyinstaller \
  --noconsole \
  --onefile \
  --name "obs-titler" \
  --exclude-module PySide6.QtWebEngineCore \
  --exclude-module PySide6.QtPdf \
  --exclude-module PySide6.QtQuick3D \
  --add-data "main.qml:." \
  main.py

echo ""
echo "Done! Binary is located at: dist/obs-titler"
