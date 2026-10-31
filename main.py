import sys
import os
from pathlib import Path

try:
    from PySide6.QtCore import QObject, Slot, Property, Signal
    from PySide6.QtGui import QGuiApplication
    from PySide6.QtQml import QQmlApplicationEngine
except ImportError:
    try:
        from PyQt6.QtCore import QObject, pyqtSlot as Slot, pyqtProperty as Property, pyqtSignal as Signal
        from PyQt6.QtGui import QGuiApplication
        from PyQt6.QtQml import QQmlApplicationEngine
    except ImportError:
        raise SystemExit("Error: Please install PySide6: pip install PySide6")


def get_bundle_dir() -> Path:
    """Returns the base directory for bundled assets (e.g. main.qml in PyInstaller)."""
    if getattr(sys, "frozen", False):
        return Path(getattr(sys, "_MEIPASS", Path(sys.executable).parent))
    return Path(__file__).resolve().parent


def get_app_dir() -> Path:
    """Returns the user directory where the executable or script is located."""
    if getattr(sys, "frozen", False):
        return Path(sys.executable).resolve().parent
    return Path(__file__).resolve().parent


class ObsFileSaver(QObject):
    directoryChanged = Signal(str)

    def __init__(self):
        super().__init__()
        # Output directory: 'obs_output' next to the executable / script
        default_dir = get_app_dir() / "obs_output"
        default_dir.mkdir(parents=True, exist_ok=True)
        self._target_dir = str(default_dir)

    @Property(str, notify=directoryChanged)
    def targetDirectory(self):
        return self._target_dir

    @Slot(str)
    def setTargetDirectory(self, path):
        clean_path = path.replace("file:///", "").replace("file://", "")
        if os.name == 'nt':
            clean_path = clean_path.replace("/", "\\")
        self._target_dir = clean_path
        Path(self._target_dir).mkdir(parents=True, exist_ok=True)
        self.directoryChanged.emit(self._target_dir)

    @Slot(str, str, result=bool)
    def saveToFiles(self, sermon_title, speaker):
        """
        Saves title and speaker to separate files, plus a combined file.
        """
        try:
            folder = Path(self._target_dir)
            folder.mkdir(parents=True, exist_ok=True)

            t_title = sermon_title.strip()
            t_speaker = speaker.strip()

            combined = []
            if t_title:
                combined.append(t_title)
            if t_speaker:
                combined.append(t_speaker)

            files = {
                "sermon_title.txt": t_title,
                "sermon_speaker.txt": t_speaker,
                "sermon_combined.txt": "\n".join(combined),
            }

            for filename, content in files.items():
                file_path = folder / filename
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(content)

            return True
        except Exception as err:
            print(f"Error writing to files: {err}")
            return False


def main():
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("OBSController")
    app.setApplicationName("SermonOverlay")

    engine = QQmlApplicationEngine()
    saver = ObsFileSaver()
    engine.rootContext().setContextProperty("fileSaver", saver)

    qml_file = get_bundle_dir() / "main.qml"
    engine.load(str(qml_file))

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
