import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: root
    visible: true
    width: 440
    height: 380
    minimumWidth: 380
    minimumHeight: 340
    title: "Sermon Lower Third"

    // Refined neutral zinc palette (Vercel / Linear style)
    color: "#09090b"

    Component.onCompleted: titleInput.forceActiveFocus()

    Item {
        anchors.fill: parent
        anchors.margins: 32

        ColumnLayout {
            anchors.fill: parent
            spacing: 24

            // Clean, understated title with breathing room
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Label {
                    text: "Sermon Details"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    font.family: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                    color: "#fafafa"
                }

                Label {
                    text: "Updates text sources live in OBS Studio"
                    font.pixelSize: 13
                    font.family: "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
                    color: "#71717a"
                }
            }

            // Input Fields
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                // Sermon Title Field
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Label {
                        text: "Title"
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
                                text: "Enter sermon title..."
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
                    spacing: 8

                    Label {
                        text: "Speaker"
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
                                text: "Enter speaker name..."
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

            // Actions
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Minimal Ghost Clear Button
                Rectangle {
                    id: clearBtn
                    Layout.preferredWidth: 80
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
                        text: "Clear"
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

                // Clean Modern High-Contrast Button (White on Dark)
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
                        var success = fileSaver.saveToFiles(titleInput.text, speakerInput.text)
                        if (success) {
                            toast.show("Saved to OBS")
                        } else {
                            toast.showError("Failed to save")
                        }
                    }

                    Keys.onReturnPressed: triggerSave()
                    Keys.onSpacePressed: triggerSave()

                    Text {
                        anchors.centerIn: parent
                        text: "Save to OBS"
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
    }

    // Clean Floating Toast
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

                    // Rounded circle badge in white (or red for error)
                    ctx.fillStyle = toast.isError ? "#ef4444" : "#ffffff";
                    ctx.beginPath();
                    ctx.arc(cx, cy, radius, 0, 2 * Math.PI);
                    ctx.fill();

                    // Checkmark hole cut out
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
