import os
import sys
from pathlib import Path

# Suppress harmless internal QtSvg buffer warnings when loading Linux system icons
os.environ.setdefault("QT_LOGGING_RULES", "qt.svg.draw.warning=false;qt.svg.warning=false")

try:
    from PySide6.QtCore import QLoggingCategory, QObject, Property, QSettings, Signal, Slot
    from PySide6.QtQml import QQmlApplicationEngine
    from PySide6.QtWidgets import QApplication, QFileDialog

    QLoggingCategory.setFilterRules("qt.svg.*=false\nqt.svg.draw.*=false")
except ImportError:
    raise SystemExit("Error: PySide6 required. Run: uv add pyside6-essentials")


TRANSLATIONS = {
    "es": {
        "title": "Detalles del Servicio",
        "subtitle": "Actualiza fuentes de texto en vivo en OBS Studio",
        "tab_announcements": "Avisos",
        "tab_sermonette": "Sermoncillo",
        "tab_sermon": "Sermón",
        "announcements_speaker_label": "Persona encargada de avisos",
        "announcements_speaker_placeholder": "Ingresa el nombre...",
        "sermonette_title_label": "Título del sermoncillo / mensaje",
        "sermonette_title_placeholder": "Tema del sermoncillo...",
        "sermonette_speaker_label": "Orador del sermoncillo",
        "sermonette_speaker_placeholder": "Nombre del orador...",
        "sermon_title_label": "Título del sermón principal",
        "sermon_title_placeholder": "Tema del sermón...",
        "sermon_speaker_label": "Predicador / Orador",
        "sermon_speaker_placeholder": "Nombre del predicador...",
        "clear_btn": "Limpiar",
        "save_btn": "Guardar en OBS",
        "saved_toast": "Archivos guardados en OBS",
        "error_toast": "Error al guardar archivos",
        "settings_btn": "Ajustes",
        "settings_title": "Configuración",
        "language_label": "Idioma",
        "output_folder_label": "Carpeta de salida OBS",
        "browse_btn": "Examinar...",
        "reset_btn": "Restablecer",
        "close_btn": "Listo",
    },
    "en": {
        "title": "Service Details",
        "subtitle": "Updates text sources live in OBS Studio",
        "tab_announcements": "Announcements",
        "tab_sermonette": "Sermonette",
        "tab_sermon": "Main Sermon",
        "announcements_speaker_label": "Announcements speaker",
        "announcements_speaker_placeholder": "Enter speaker name...",
        "sermonette_title_label": "Sermonette / message title",
        "sermonette_title_placeholder": "Topic of short message...",
        "sermonette_speaker_label": "Sermonette speaker",
        "sermonette_speaker_placeholder": "Enter speaker name...",
        "sermon_title_label": "Main sermon title",
        "sermon_title_placeholder": "Topic of main sermon...",
        "sermon_speaker_label": "Preacher / main speaker",
        "sermon_speaker_placeholder": "Enter preacher name...",
        "clear_btn": "Clear",
        "save_btn": "Save to OBS",
        "saved_toast": "Files saved to OBS",
        "error_toast": "Failed to save files",
        "settings_btn": "Settings",
        "settings_title": "Settings",
        "language_label": "Language",
        "output_folder_label": "OBS Output Folder",
        "browse_btn": "Browse...",
        "reset_btn": "Reset",
        "close_btn": "Done",
    },
}


def get_bundle_dir() -> Path:
    if getattr(sys, "frozen", False):
        return Path(getattr(sys, "_MEIPASS", Path(sys.executable).parent))
    return Path(__file__).resolve().parent


def get_app_dir() -> Path:
    if getattr(sys, "frozen", False):
        return Path(sys.executable).resolve().parent
    return Path(__file__).resolve().parent


class AppController(QObject):
    languageChanged = Signal(str)
    directoryChanged = Signal(str)
    stringsChanged = Signal()

    def __init__(self):
        super().__init__()
        self._settings = QSettings("ChurchMedia", "ObsTitler")

        # Spanish is default
        self._language = self._settings.value("language", "es")
        if self._language not in TRANSLATIONS:
            self._language = "es"

        self._default_dir = str(get_app_dir() / "obs_output")
        saved_dir = self._settings.value("output_dir", "")
        if saved_dir and Path(saved_dir).exists():
            self._target_dir = saved_dir
        else:
            self._target_dir = self._default_dir

        Path(self._target_dir).mkdir(parents=True, exist_ok=True)

    # --- Language Properties ---
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

    # --- Directory Properties ---
    @Property(str, notify=directoryChanged)
    def targetDirectory(self):
        return self._target_dir

    @Property(bool, notify=directoryChanged)
    def isCustomDirectory(self):
        return self._target_dir != self._default_dir

    @Slot()
    def selectDirectory(self):
        title = "Seleccionar carpeta de salida" if self._language == "es" else "Select Output Folder"
        selected = QFileDialog.getExistingDirectory(None, title, self._target_dir)
        if selected:
            clean = str(Path(selected).resolve())
            self._target_dir = clean
            self._settings.setValue("output_dir", clean)
            self.directoryChanged.emit(self._target_dir)

    @Slot()
    def resetDirectory(self):
        self._target_dir = self._default_dir
        self._settings.setValue("output_dir", "")
        Path(self._target_dir).mkdir(parents=True, exist_ok=True)
        self.directoryChanged.emit(self._target_dir)

    # --- DRY File Writing ---
    @staticmethod
    def _combine(title: str, speaker: str) -> str:
        parts = [p.strip() for p in (title, speaker) if p.strip()]
        return "\n".join(parts)

    @Slot(str, str, str, str, str, str, result=bool)
    def saveAll(self, ann_speaker, srm_title, srm_speaker, main_title, main_speaker, active_tab="sermon"):
        """
        Saves all service sections to dedicated files, plus dynamic current files.
        """
        try:
            folder = Path(self._target_dir)
            folder.mkdir(parents=True, exist_ok=True)

            ann_spk = ann_speaker.strip()
            srm_ttl = srm_title.strip()
            srm_spk = srm_speaker.strip()
            main_ttl = main_title.strip()
            main_spk = main_speaker.strip()

            files = {
                # Announcements
                "announcements_speaker.txt": ann_spk,
                # Sermoncillo / Short Message
                "sermonette_title.txt": srm_ttl,
                "sermonette_speaker.txt": srm_spk,
                "sermonette_combined.txt": self._combine(srm_ttl, srm_spk),
                # Main Sermon
                "sermon_title.txt": main_ttl,
                "sermon_speaker.txt": main_spk,
                "sermon_combined.txt": self._combine(main_ttl, main_spk),
            }

            # Dynamic "current" overlay files based on active tab
            if active_tab == "announcements":
                files["current_title.txt"] = ""
                files["current_speaker.txt"] = ann_spk
                files["current_combined.txt"] = ann_spk
            elif active_tab == "sermonette":
                files["current_title.txt"] = srm_ttl
                files["current_speaker.txt"] = srm_spk
                files["current_combined.txt"] = files["sermonette_combined.txt"]
            else:  # sermon
                files["current_title.txt"] = main_ttl
                files["current_speaker.txt"] = main_spk
                files["current_combined.txt"] = files["sermon_combined.txt"]

            for filename, content in files.items():
                with open(folder / filename, "w", encoding="utf-8") as f:
                    f.write(content)

            return True
        except Exception as err:
            print(f"Error saving service files: {err}")
            return False


def main():
    app = QApplication(sys.argv)
    app.setOrganizationName("ChurchMedia")
    app.setApplicationName("ObsTitler")

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
