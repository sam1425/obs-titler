@echo off
rem Build standalone Windows .exe
cd /d "%~dp0"

echo Installing dependencies...
uv add --dev pyinstaller

echo Building Windows executable...
uv run pyinstaller ^
  --noconsole ^
  --onefile ^
  --name "obs-sermon-controller" ^
  --add-data "main.qml;." ^
  main.py

echo.
echo Build complete! Executable is in: dist\obs-sermon-controller.exe
pause
