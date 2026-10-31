import sys
import os
from pathlib import Path

try:
    from PySide6.QtCore import QObject, Slot, Property, Signal, QSettings
    from PySide6.QtWidgets import QApplication, QFileDialog
    from PySide6.QtQml import QQmlApplicationEngine
except ImportError:
    raise SystemExit("Error: PySide6 required. Run: uv add pyside6")


TRANSLATIONS = {
    "es": {
        "title": "Detalles del Sermón",
        "subtitle": "Actualiza fuentes de texto en vivo en OBS Studio",
        "sermon_title_label": "Título",
        "sermon_title_placeholder": "Ingresa el título del sermón...",
        "speaker_label": "Orador / Persona que habla",
        "speaker_placeholder": "Ingresa el nombre del orador...",
        "clear_btn": "Limpiar",
        "save_btn": "Guardar en OBS",
        "saved_toast": "Guardado en OBS",
        "error_toast": "Error al guardar archivos",
        "settings_btn": "Ajustes",
        "settings_title": "Configuración",
        "language_label": "Idioma",
        "output_folder_label": "Carpeta de salida OBS",
        "default_folder_hint": "(Por defecto: obs_output)",
        "browse_btn": "Examinar...",
        "reset_btn": "Restablecer",
        "close_btn": "Listo",
    },
    "en": {
        "title": "Sermon Details",
        "subtitle": "Updates text sources live in OBS Studio",
        "sermon_title_label": "Title",
        "sermon_title_placeholder": "Enter sermon title...",
        "speaker_label": "Speaker / Person talking",
        "speaker_placeholder": "Enter speaker name...",
        "clear_btn": "Clear",
        "save_btn": "Save to OBS",
        "saved_toast": "Saved to OBS",
        "error_toast": "Failed to save files",
        "settings_btn": "Settings",
        "settings_title": "Settings",
        "language_label": "Language",
        "output_folder_label": "OBS Output Folder",
        "default_folder_hint": "(Default: obs_output)",
        "browse_btn": "Browse...",
        "reset_btn": "Reset",
        "close_btn": "Done",
    },
}


def get_bundle_dir() -> Path:
    """Returns directory of bundled assets (e.g. main.qml in PyInstaller)."""
    if getattr(sys, "frozen", False):
        return Path(getattr(sys, "_MEIPASS", Path(sys.executable).parent))
    return Path(__file__).resolve().parent


def get_app_dir() -> Path:
    """Returns directory where the script or binary is installed."""
    if getattr(sys, "frozen", False):
        return Path(sys.executable).resolve().parent
    return Path(__file__).resolve().parent


class AppController(QObject):
    languageChanged = Signal(str)
    directoryChanged = Signal(str)
    stringsChanged = Signal()

    def __init__(self):
        super().__init__()
        self._settings = QSettings("ChurchMedia", "ObsSermonController")

        # Spanish default
        self._language = self._settings.value("language", "es")
        if self._language not in TRANSLATIONS:
            self._language = "es"

        # Output directory: saved preference or default 'obs_output'
        self._default_dir = str(get_app_dir() / "obs_output")
        saved_dir = self._settings.value("output_dir", "")
        if saved_dir and Path(saved_dir).exists():
            self._target_dir = saved_dir
        else:
            self._target_dir = self._default_dir

        Path(self._target_dir).mkdir(parents=True, exist_ok=True)

    # --- Language Properties & Slots ---
    @Property(str, notify=languageChanged)
    def language(self):
        return self._language

    @Slot(str)
    def setLanguage(self, lang):
        if lang in TRANSLATIONS and lang != self._language:
            self._language = lang
            self._settings.setValue("language", lang)
            self.languageChanged.emit(self._language)
            self.stringsChanged.emit()

    @Property("QVariantMap", notify=stringsChanged)
    def strings(self):
        return TRANSLATIONS.get(self._language, TRANSLATIONS["es"])

    # --- Directory Properties & Slots ---
    @Property(str, notify=directoryChanged)
    def targetDirectory(self):
        return self._target_dir

    @Property(bool, notify=directoryChanged)
    def isCustomDirectory(self):
        return self._target_dir != self._default_dir

    @Slot()
    def selectDirectory(self):
        dialog_title = (
            "Seleccionar carpeta de salida para OBS"
            if self._language == "es"
            else "Select Output Folder for OBS"
        )
        selected = QFileDialog.getExistingDirectory(None, dialog_title, self._target_dir)
        if selected:
            clean_path = str(Path(selected).resolve())
            self._target_dir = clean_path
            self._settings.setValue("output_dir", clean_path)
            self.directoryChanged.emit(self._target_dir)

    @Slot()
    def resetDirectory(self):
        self._target_dir = self._default_dir
        self._settings.setValue("output_dir", "")
        Path(self._target_dir).mkdir(parents=True, exist_ok=True)
        self.directoryChanged.emit(self._target_dir)

    # --- File Writing ---
    @Slot(str, str, result=bool)
    def saveToFiles(self, sermon_title, speaker):
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
            print(f"Error saving files: {err}")
            return False


def main():
    app = QApplication(sys.argv)
    app.setOrganizationName("ChurchMedia")
    app.setApplicationName("ObsSermonController")

    engine = QQmlApplicationEngine()
    controller = AppController()
    engine.rootContext().setContextProperty("appCtrl", controller)

    qml_file = get_bundle_dir() / "main.qml"
    engine.load(str(qml_file))

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
