# OBS Sermon Controller

A fast, distraction-free desktop utility to control lower-third text in OBS Studio during live services.

Built with Python and QtQuick (QML). Runs standalone on Windows and Linux without requiring Python or OBS plugins.

---

## How It Works

Type the sermon title and speaker, hit **Save** (or press `Enter`), and the app writes them to text files inside `obs_output/`:

* `sermon_title.txt` — Current title
* `sermon_speaker.txt` — Speaker / host name
* `sermon_combined.txt` — Both fields combined

OBS reads directly from these files. Whenever you save, OBS updates the graphics live on stream without any scene switching.

---

## OBS Setup

1. In OBS, add a **Text (GDI+)** (Windows) or **Text (FreeType 2)** (Linux) source to your scene.
2. Check **Read from file**.
3. Browse and select `obs_output/sermon_title.txt` or `obs_output/sermon_speaker.txt`.
4. Style and position the text over your lower-third banner.

---

## Running from Source

Requires [uv](https://github.com/astral-sh/uv) (or standard Python 3.10+):

```bash
git clone https://github.com/your-username/obs-sermon-controller.git
cd obs-sermon-controller
uv run main.py
```

---

## Building Binaries

Both platforms bundle Python and Qt into a single executable using PyInstaller.

### Linux
```bash
./build_linux.sh
```
Output: `dist/obs-sermon-controller`

### Windows
Run:
```cmd
build_windows.bat
```
Output: `dist\obs-sermon-controller.exe`

---

## Automated Releases

Pushing a version tag triggers the GitHub Actions workflow in `.github/workflows/build.yml`. It compiles both Windows and Linux binaries and publishes them directly to a GitHub Release:

```bash
git tag v1.0.0
git push origin v1.0.0
```
