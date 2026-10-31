import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: root
    visible: true
    width: 470
    height: 440
    minimumWidth: 410
    minimumHeight: 400

    property var ctrl: (typeof appCtrl !== "undefined" && appCtrl) ? appCtrl : null

    function tr(key) {
        if (ctrl && ctrl.strings && ctrl.strings[key] !== undefined) {
            return ctrl.strings[key];
        }
        return defaultStrings[key] || "";
    }

    readonly property var defaultStrings: ({
        title: "Detalles del Servicio",
        subtitle: "Actualiza fuentes de texto en vivo en OBS Studio",
        tab_announcements: "Anuncios",
        tab_sermonette: "Sermoncillo",
        tab_sermon: "Sermón",
        announcements_speaker_label: "Persona encargada de avisos",
        announcements_speaker_placeholder: "Ingresa el nombre...",
        sermonette_title_label: "Título del sermoncillo / mensaje",
        sermonette_title_placeholder: "Tema del sermoncillo...",
        sermonette_speaker_label: "Orador del sermoncillo",
        sermonette_speaker_placeholder: "Nombre del orador...",
        sermon_title_label: "Título del sermón principal",
        sermon_title_placeholder: "Tema del sermón...",
        sermon_speaker_label: "Predicador / Orador",
        sermon_speaker_placeholder: "Nombre del predicador...",
        clear_btn: "Limpiar",
        save_btn: "Guardar en OBS",
        saved_toast: "Archivos guardados en OBS",
        error_toast: "Error al guardar archivos",
        settings_btn: "Ajustes",
        settings_title: "Configuración",
        language_label: "Idioma",
        output_folder_label: "Carpeta de salida OBS",
        browse_btn: "Examinar...",
        reset_btn: "Restablecer",
        close_btn: "Listo"
    })

    title: tr("title")
    color: "#09090b"

    property string activeTab: "sermonette" // "announcements", "sermonette", "sermon"
    property bool showSettings: false

    Component.onCompleted: focusActiveTabInput()

    function focusActiveTabInput() {
        if (activeTab === "announcements") annSpeakerInput.inputItem.forceActiveFocus();
        else if (activeTab === "sermonette") srmTitleInput.inputItem.forceActiveFocus();
        else mainTitleInput.inputItem.forceActiveFocus();
    }

    // DRY Reusable Form Input Field Component
    component FormInput: ColumnLayout {
        id: comp
        property alias labelText: lbl.text
        property alias placeholderText: ph.text
        property alias text: inp.text
        property alias inputItem: inp
        signal accepted()

        spacing: 7
        Layout.fillWidth: true

        Label {
            id: lbl
            font.pixelSize: 13
            font.weight: Font.Medium
            font.family: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
            color: "#a1a1aa"
        }

        Rectangle {
            Layout.fillWidth: true
            height: 42
            radius: 8
            color: "#18181b"
            border.width: 1
            border.color: inp.activeFocus ? "#52525b" : "#27272a"

            Behavior on border.color { ColorAnimation { duration: 100 } }

            TextInput {
                id: inp
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                verticalAlignment: TextInput.AlignVCenter
                font.pixelSize: 14
                font.family: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                color: "#fafafa"
                selectByMouse: true
                activeFocusOnTab: true
                onAccepted: comp.accepted()

                Text {
                    id: ph
                    color: "#52525b"
                    font.pixelSize: 14
                    visible: !inp.text && !inp.activeFocus
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: 30

        ColumnLayout {
            anchors.fill: parent
            spacing: 16
            opacity: root.showSettings ? 0.2 : 1.0
            enabled: !root.showSettings

            Behavior on opacity { NumberAnimation { duration: 150 } }

            // Header - Settings icon pinned to right edge
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(headerTextCol.height, settingsBtn.height)

                Column {
                    id: headerTextCol
                    anchors.left: parent.left
                    anchors.right: settingsBtn.left
                    anchors.rightMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Label {
                        text: tr("title")
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                        font.family: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                        color: "#fafafa"
                    }

                    Label {
                        text: tr("subtitle")
                        font.pixelSize: 12
                        font.family: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                        color: "#71717a"
                    }
                }

                Rectangle {
                    id: settingsBtn
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    height: 36
                    radius: 8
                    color: settingsMouse.containsPress ? "#27272a" : (settingsMouse.containsMouse ? "#1f1f23" : "#141417")
                    border.color: "#27272a"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 80 } }

                    Canvas {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        antialiasing: true
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.strokeStyle = "#a1a1aa";
                            ctx.lineWidth = 1.5;
                            ctx.beginPath();
                            ctx.arc(8, 8, 4, 0, 2 * Math.PI);
                            ctx.stroke();

                            for (var i = 0; i < 6; i++) {
                                var angle = (i * Math.PI) / 3;
                                var x1 = 8 + Math.cos(angle) * 4.5;
                                var y1 = 8 + Math.sin(angle) * 4.5;
                                var x2 = 8 + Math.cos(angle) * 7.0;
                                var y2 = 8 + Math.sin(angle) * 7.0;
                                ctx.beginPath();
                                ctx.moveTo(x1, y1);
                                ctx.lineTo(x2, y2);
                                ctx.stroke();
                            }
                        }
                    }

                    MouseArea {
                        id: settingsMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showSettings = true
                    }
                }
            }

            // Segmented Service Switcher (Avisos | Sermoncillo | Sermón)
            Rectangle {
                Layout.fillWidth: true
                height: 36
                radius: 8
                color: "#141417"
                border.color: "#222226"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Repeater {
                        model: [
                            { id: "sermonette",    labelKey: "tab_sermonette" },
                            { id: "announcements", labelKey: "tab_announcements" },
                            { id: "sermon",        labelKey: "tab_sermon" }
                        ]

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 7
                            color: root.activeTab === modelData.id ? "#27272a" : "transparent"

                            Behavior on color { ColorAnimation { duration: 100 } }

                            Text {
                                anchors.centerIn: parent
                                text: root.tr(modelData.labelKey)
                                color: root.activeTab === modelData.id ? "#fafafa" : "#71717a"
                                font.pixelSize: 12
                                font.weight: root.activeTab === modelData.id ? Font.DemiBold : Font.Normal
                                font.family: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.activeTab = modelData.id
                                    root.focusActiveTabInput()
                                }
                            }
                        }
                    }
                }
            }

            // Form Panels (DRY instances of FormInput)
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 135

                // 1. Announcements: only speaker name needed
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 14
                    visible: root.activeTab === "announcements"

                    FormInput {
                        id: annSpeakerInput
                        labelText: root.tr("announcements_speaker_label")
                        placeholderText: root.tr("announcements_speaker_placeholder")
                        onAccepted: saveBtn.triggerSave()
                    }
                }

                // 2. Sermoncillo / Short Message: title & speaker
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12
                    visible: root.activeTab === "sermonette"

                    FormInput {
                        id: srmTitleInput
                        labelText: root.tr("sermonette_title_label")
                        placeholderText: root.tr("sermonette_title_placeholder")
                        onAccepted: srmSpeakerInput.inputItem.forceActiveFocus()
                    }

                    FormInput {
                        id: srmSpeakerInput
                        labelText: root.tr("sermonette_speaker_label")
                        placeholderText: root.tr("sermonette_speaker_placeholder")
                        onAccepted: saveBtn.triggerSave()
                    }
                }

                // 3. Main Sermon: title & speaker
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12
                    visible: root.activeTab === "sermon"

                    FormInput {
                        id: mainTitleInput
                        labelText: root.tr("sermon_title_label")
                        placeholderText: root.tr("sermon_title_placeholder")
                        onAccepted: mainSpeakerInput.inputItem.forceActiveFocus()
                    }

                    FormInput {
                        id: mainSpeakerInput
                        labelText: root.tr("sermon_speaker_label")
                        placeholderText: root.tr("sermon_speaker_placeholder")
                        onAccepted: saveBtn.triggerSave()
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Action Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Clear Button
                Rectangle {
                    id: clearBtn
                    Layout.preferredWidth: 84
                    Layout.preferredHeight: 38
                    radius: 7
                    color: clearMouse.containsPress ? "#27272a" : (clearMouse.containsMouse ? "#1f1f23" : "#18181b")
                    border.color: clearBtn.activeFocus ? "#71717a" : "#27272a"
                    border.width: 1
                    activeFocusOnTab: true

                    function triggerClear() {
                        if (root.activeTab === "announcements") {
                            annSpeakerInput.text = "";
                        } else if (root.activeTab === "sermonette") {
                            srmTitleInput.text = "";
                            srmSpeakerInput.text = "";
                        } else {
                            mainTitleInput.text = "";
                            mainSpeakerInput.text = "";
                        }
                        root.focusActiveTabInput();
                    }

                    Keys.onReturnPressed: triggerClear()
                    Keys.onSpacePressed: triggerClear()

                    Text {
                        anchors.centerIn: parent
                        text: root.tr("clear_btn")
                        color: clearBtn.activeFocus ? "#ffffff" : "#a1a1aa"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        font.family: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: clearBtn.triggerClear()
                    }
                }

                // Save to OBS Button
                Rectangle {
                    id: saveBtn
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: 7
                    color: saveMouse.containsPress ? "#d4d4d8" : (saveMouse.containsMouse ? "#e4e4e7" : "#fafafa")
                    border.color: saveBtn.activeFocus ? "#3b82f6" : "transparent"
                    border.width: saveBtn.activeFocus ? 2 : 0
                    activeFocusOnTab: true

                    function triggerSave() {
                        var success = root.ctrl ? root.ctrl.saveAll(
                            annSpeakerInput.text,
                            srmTitleInput.text,
                            srmSpeakerInput.text,
                            mainTitleInput.text,
                            mainSpeakerInput.text,
                            root.activeTab
                        ) : true;

                        if (success) {
                            toast.show(root.tr("saved_toast"));
                        } else {
                            toast.showError(root.tr("error_toast"));
                        }
                    }

                    Keys.onReturnPressed: triggerSave()
                    Keys.onSpacePressed: triggerSave()

                    Text {
                        anchors.centerIn: parent
                        text: root.tr("save_btn")
                        color: "#09090b"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        font.family: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                    }

                    MouseArea {
                        id: saveMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: saveBtn.triggerSave()
                    }
                }
            }
        }

        // Settings Overlay Card
        Rectangle {
            id: settingsModal
            anchors.centerIn: parent
            width: parent.width + 12
            height: parent.height + 12
            radius: 12
            color: "#121215"
            border.color: "#27272a"
            border.width: 1
            visible: opacity > 0
            opacity: root.showSettings ? 1.0 : 0.0

            Behavior on opacity { NumberAnimation { duration: 140 } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 18

                // Header with Close X
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30

                    Label {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.tr("settings_title")
                        font.pixelSize: 17
                        font.weight: Font.DemiBold
                        font.family: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                        color: "#fafafa"
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28
                        height: 28
                        radius: 6
                        color: closeXMouse.containsPress ? "#27272a" : (closeXMouse.containsMouse ? "#1f1f23" : "transparent")

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.pixelSize: 12
                            color: "#a1a1aa"
                        }

                        MouseArea {
                            id: closeXMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.showSettings = false
                                root.focusActiveTabInput()
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#222226"
                }

                // Language Selector
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Label {
                        text: root.tr("language_label")
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#a1a1aa"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 7
                        color: "#18181b"
                        border.color: "#27272a"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            spacing: 0

                            property string currentLang: (root.ctrl && root.ctrl.language) ? root.ctrl.language : "es"

                            // Spanish
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 6
                                color: parent.currentLang === "es" ? "#27272a" : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: "Español"
                                    color: parent.parent.currentLang === "es" ? "#fafafa" : "#71717a"
                                    font.pixelSize: 12
                                    font.weight: parent.parent.currentLang === "es" ? Font.DemiBold : Font.Normal
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: if (root.ctrl) root.ctrl.setLanguage("es")
                                }
                            }

                            // English
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 6
                                color: parent.currentLang === "en" ? "#27272a" : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: "English"
                                    color: parent.parent.currentLang === "en" ? "#fafafa" : "#71717a"
                                    font.pixelSize: 12
                                    font.weight: parent.parent.currentLang === "en" ? Font.DemiBold : Font.Normal
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: if (root.ctrl) root.ctrl.setLanguage("en")
                                }
                            }
                        }
                    }
                }

                // Output Folder Section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Label {
                        text: root.tr("output_folder_label")
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: "#a1a1aa"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 38
                        radius: 7
                        color: "#18181b"
                        border.color: "#27272a"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10

                            Text {
                                text: (root.ctrl && root.ctrl.targetDirectory) ? root.ctrl.targetDirectory : "obs_output"
                                color: "#d4d4d8"
                                font.pixelSize: 11
                                elide: Text.ElideMiddle
                                Layout.fillWidth: true
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            height: 32
                            radius: 6
                            color: browseMouse.containsPress ? "#27272a" : (browseMouse.containsMouse ? "#202024" : "#18181b")
                            border.color: "#27272a"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: root.tr("browse_btn")
                                color: "#d4d4d8"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                            }

                            MouseArea {
                                id: browseMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (root.ctrl) root.ctrl.selectDirectory()
                            }
                        }

                        Rectangle {
                            visible: (root.ctrl && root.ctrl.isCustomDirectory) ? true : false
                            Layout.preferredWidth: 85
                            height: 32
                            radius: 6
                            color: resetMouse.containsPress ? "#27272a" : (resetMouse.containsMouse ? "#202024" : "#18181b")
                            border.color: "#27272a"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: root.tr("reset_btn")
                                color: "#a1a1aa"
                                font.pixelSize: 11
                            }

                            MouseArea {
                                id: resetMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (root.ctrl) root.ctrl.resetDirectory()
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Done Button
                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: 7
                    color: closeMouse.containsPress ? "#d4d4d8" : (closeMouse.containsMouse ? "#e4e4e7" : "#fafafa")

                    Text {
                        anchors.centerIn: parent
                        text: root.tr("close_btn")
                        color: "#09090b"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.showSettings = false
                            root.focusActiveTabInput()
                        }
                    }
                }
            }
        }
    }

    // Floating Toast Notification
    Rectangle {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height - height - 76
        width: toastContent.implicitWidth + 30
        height: 38
        radius: 19
        color: isError ? "#1c1012" : "#18181b"
        border.color: isError ? "#7f1d1d" : "#27272a"
        border.width: 1
        opacity: 0.0
        visible: opacity > 0

        property bool isError: false

        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
        }
        Behavior on y {
            NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
        }

        Row {
            id: toastContent
            anchors.centerIn: parent
            spacing: 8

            // Rounded badge in white with checkmark cutout / hole
            Canvas {
                id: toastIconCanvas
                width: 18
                height: 18
                anchors.verticalCenter: parent.verticalCenter
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();

                    var cx = width / 2;
                    var cy = height / 2;
                    var radius = (width / 2) - 0.5;

                    ctx.fillStyle = toast.isError ? "#ef4444" : "#ffffff";
                    ctx.beginPath();
                    ctx.arc(cx, cy, radius, 0, 2 * Math.PI);
                    ctx.fill();

                    ctx.strokeStyle = toast.color;
                    ctx.lineWidth = 2.0;
                    ctx.lineCap = "round";
                    ctx.lineJoin = "round";

                    ctx.beginPath();
                    if (!toast.isError) {
                        ctx.moveTo(cx - 3.5, cy + 0.1);
                        ctx.lineTo(cx - 1.0, cy + 2.6);
                        ctx.lineTo(cx + 3.8, cy - 2.4);
                    } else {
                        ctx.moveTo(cx - 2.6, cy - 2.6);
                        ctx.lineTo(cx + 2.6, cy + 2.6);
                        ctx.moveTo(cx + 2.6, cy - 2.6);
                        ctx.lineTo(cx - 2.6, cy + 2.6);
                    }
                    ctx.stroke();
                }
            }

            Text {
                id: toastText
                text: ""
                color: "#f4f4f5"
                font.pixelSize: 13
                font.weight: Font.Medium
                font.family: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Timer {
            id: toastTimer
            interval: 1200
            onTriggered: {
                toast.opacity = 0.0
                toast.y = root.height - toast.height - 70
            }
        }

        function show(msg) {
            isError = false
            toastText.text = msg
            toast.y = root.height - toast.height - 76
            toast.opacity = 1.0
            toastIconCanvas.requestPaint()
            toastTimer.restart()
        }

        function showError(msg) {
            isError = true
            toastText.text = msg
            toast.y = root.height - toast.height - 76
            toast.opacity = 1.0
            toastIconCanvas.requestPaint()
            toastTimer.restart()
        }
    }
}
