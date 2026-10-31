# OBS Titler

A fast, distraction-free desktop utility to control lower-third text in OBS Studio during live services.

Built with Python and QtQuick (QML). Runs standalone on Windows and Linux without requiring Python or OBS plugins.

---

## Downloads

Precompiled binaries are available on the [Releases](https://github.com/sam1425/obs-titler/releases) page:

* **Windows Instant Launch (`obs-titler-windows.zip`):** Unzip and run `obs-titler.exe`. Launches in under 1 second with zero decompression delay.
* **Windows Portable (`obs-titler-windows-portable.exe`):** Single standalone file.
* **Linux:** Available as `obs-titler-linux.tar.gz` and `obs-titler-linux-portable`.

---

## How It Works

Type the sermon title and speaker, hit **Guardar en OBS / Save to OBS** (or press `Enter`), and the app writes them to text files inside `obs_output/`:

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
git clone https://github.com/sam1425/obs-titler.git
cd obs-titler
uv run main.py
```

---

## Building Binaries

### Linux
```bash
./build_linux.sh
```

### Windows
```cmd
build_windows.bat
```
