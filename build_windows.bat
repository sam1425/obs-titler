@echo off
rem Build optimized Windows executable
cd /d "%~dp0"

echo Installing dependencies...
uv add --dev pyinstaller

echo Building fast Windows executable...
uv run pyinstaller ^
  --noconsole ^
  --onefile ^
  --name "obs-titler" ^
  --exclude-module PySide6.QtWebEngineCore ^
  --exclude-module PySide6.QtPdf ^
  --exclude-module PySide6.QtQuick3D ^
  --add-data "main.qml;." ^
  main.py

echo.
echo Build complete! Executable is in: dist\obs-titler.exe
pause
