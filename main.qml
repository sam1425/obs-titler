import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: root
    visible: true
    width: 460
    height: 410
    minimumWidth: 400
    minimumHeight: 370

    // Reference to Python controller with null-safety
    property var ctrl: (typeof appCtrl !== "undefined" && appCtrl) ? appCtrl : null

    // Safe translation lookup helper
    function tr(key) {
        if (ctrl && ctrl.strings && ctrl.strings[key] !== undefined) {
            return ctrl.strings[key];
        }
        return defaultStrings[key] || "";
    }

    // Fallback strings so QML never throws TypeErrors during initial load
    readonly property var defaultStrings: ({
        title: "Detalles del Sermón",
        subtitle: "Actualiza fuentes de texto en vivo en OBS Studio",
        sermon_title_label: "Título",
        sermon_title_placeholder: "Ingresa el título del sermón...",
        speaker_label: "Orador / Persona que habla",
        speaker_placeholder: "Ingresa el nombre del orador...",
        clear_btn: "Limpiar",
        save_btn: "Guardar en OBS",
        saved_toast: "Guardado en OBS",
        error_toast: "Error al guardar archivos",
        settings_btn: "Ajustes",
        settings_title: "Configuración",
        language_label: "Idioma",
        output_folder_label: "Carpeta de salida OBS",
        default_folder_hint: "(Por defecto: obs_output)",
        browse_btn: "Examinar...",
        reset_btn: "Restablecer",
        close_btn: "Listo"
    })

    title: tr("title")
    color: "#09090b"

    Component.onCompleted: titleInput.forceActiveFocus()

    property bool showSettings: false

    Item {
        anchors.fill: parent
        anchors.margins: 32

        // Main View (Inputs & Actions)
        ColumnLayout {
            anchors.fill: parent
            spacing: 20
            opacity: root.showSettings ? 0.2 : 1.0
            enabled: !root.showSettings

            Behavior on opacity { NumberAnimation { duration: 150 } }

            // Header - Using direct anchors to firmly lock settings button to the right edge
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

                // Settings Gear Button - Anchored to the far right
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

            // Form Inputs
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                // Sermon Title Field
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 7

                    Label {
                        text: tr("sermon_title_label")
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
                        border.color: titleInput.activeFocus ? "#52525b" : "#27272a"

                        Behavior on border.color { ColorAnimation { duration: 100 } }

                        TextInput {
                            id: titleInput
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            verticalAlignment: TextInput.AlignVCenter
                            font.pixelSize: 14
                            font.family: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                            color: "#fafafa"
                            selectByMouse: true
                            activeFocusOnTab: true
                            KeyNavigation.tab: speakerInput
                            KeyNavigation.backtab: saveBtn
                            onAccepted: speakerInput.forceActiveFocus()

                            Text {
                                text: tr("sermon_title_placeholder")
                                color: "#52525b"
                                font.pixelSize: 14
                                visible: !titleInput.text && !titleInput.activeFocus
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                // Speaker Field
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 7

                    Label {
                        text: tr("speaker_label")
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
                        border.color: speakerInput.activeFocus ? "#52525b" : "#27272a"

                        Behavior on border.color { ColorAnimation { duration: 100 } }

                        TextInput {
                            id: speakerInput
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            verticalAlignment: TextInput.AlignVCenter
                            font.pixelSize: 14
                            font.family: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                            color: "#fafafa"
                            selectByMouse: true
                            activeFocusOnTab: true
                            KeyNavigation.tab: clearBtn
                            KeyNavigation.backtab: titleInput
                            onAccepted: saveBtn.triggerSave()

                            Text {
                                text: tr("speaker_placeholder")
                                color: "#52525b"
                                font.pixelSize: 14
                                visible: !speakerInput.text && !speakerInput.activeFocus
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
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
                    KeyNavigation.tab: saveBtn
                    KeyNavigation.backtab: speakerInput

                    Behavior on color { ColorAnimation { duration: 80 } }
                    Behavior on border.color { ColorAnimation { duration: 80 } }

                    function triggerClear() {
                        titleInput.text = ""
                        speakerInput.text = ""
                        titleInput.forceActiveFocus()
                    }

                    Keys.onReturnPressed: triggerClear()
                    Keys.onSpacePressed: triggerClear()

                    Text {
                        anchors.centerIn: parent
                        text: tr("clear_btn")
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

                // Save Button
                Rectangle {
                    id: saveBtn
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    radius: 7
                    color: saveMouse.containsPress ? "#d4d4d8" : (saveMouse.containsMouse ? "#e4e4e7" : "#fafafa")
                    border.color: saveBtn.activeFocus ? "#3b82f6" : "transparent"
                    border.width: saveBtn.activeFocus ? 2 : 0
                    activeFocusOnTab: true
                    KeyNavigation.tab: titleInput
                    KeyNavigation.backtab: clearBtn

                    Behavior on color { ColorAnimation { duration: 80 } }

                    function triggerSave() {
                        var success = ctrl ? ctrl.saveToFiles(titleInput.text, speakerInput.text) : true
                        if (success) {
                            toast.show(tr("saved_toast"))
                        } else {
                            toast.showError(tr("error_toast"))
                        }
                    }

                    Keys.onReturnPressed: triggerSave()
                    Keys.onSpacePressed: triggerSave()

                    Text {
                        anchors.centerIn: parent
                        text: tr("save_btn")
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

                // Header with Title and Close X Button
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30

                    Label {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: tr("settings_title")
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
                                titleInput.forceActiveFocus()
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#222226"
                }

                // Language Segmented Control
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Label {
                        text: tr("language_label")
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

                            property string currentLang: (ctrl && ctrl.language) ? ctrl.language : "es"

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
                                    onClicked: if (ctrl) ctrl.setLanguage("es")
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
                                    onClicked: if (ctrl) ctrl.setLanguage("en")
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
                        text: tr("output_folder_label")
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
                                text: (ctrl && ctrl.targetDirectory) ? ctrl.targetDirectory : "obs_output"
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
                                text: tr("browse_btn")
                                color: "#d4d4d8"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                            }

                            MouseArea {
                                id: browseMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (ctrl) ctrl.selectDirectory()
                            }
                        }

                        Rectangle {
                            visible: (ctrl && ctrl.isCustomDirectory) ? true : false
                            Layout.preferredWidth: 85
                            height: 32
                            radius: 6
                            color: resetMouse.containsPress ? "#27272a" : (resetMouse.containsMouse ? "#202024" : "#18181b")
                            border.color: "#27272a"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: tr("reset_btn")
                                color: "#a1a1aa"
                                font.pixelSize: 11
                            }

                            MouseArea {
                                id: resetMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (ctrl) ctrl.resetDirectory()
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Close Settings Button
                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: 7
                    color: closeMouse.containsPress ? "#d4d4d8" : (closeMouse.containsMouse ? "#e4e4e7" : "#fafafa")

                    Text {
                        anchors.centerIn: parent
                        text: tr("close_btn")
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
                            titleInput.forceActiveFocus()
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
