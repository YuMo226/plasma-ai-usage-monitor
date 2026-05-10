import QtQuick
import QtQuick.Controls as QtControls
import QtQuick.Layouts
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami

Item {
    id: root

    property real balance: 0
    property real limit: 0
    property real usage: 0
    property bool loading: false
    property bool error: false
    property string errorMsg: ""
    property bool success: false
    property string lastUpdated: ""

    signal refreshRequested()

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumWidth: 350
    Layout.minimumHeight: 180
    Layout.preferredWidth: 350
    Layout.preferredHeight: 180
    Layout.margins: 0 // Force no margins to prevent system background leakage

    // Semi-transparent background
    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#D9222222" // ~85% opacity
        radius: 24
    }

    // ── Loading ──
    QtControls.BusyIndicator {
        anchors.centerIn: parent
        z: 10
        visible: root.loading
        running: root.loading
    }

    // ── Error ──
    Column {
        anchors.centerIn: parent
        z: 10
        visible: root.error && !root.loading
        spacing: 8

        Kirigami.Icon {
            source: "dialog-error"
            width: 32; height: 32
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: root.errorMsg
            color: Qt.rgba(1, 1, 1, 0.5)
            font.pixelSize: 12
            wrapMode: Text.WordWrap
            width: 280
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // ── Apple-style content ──
    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        visible: root.success && !root.loading && !root.error

        // ── Left: Ring progress ──
        Item {
            Layout.preferredWidth: 90
            Layout.preferredHeight: 90

            // Background ring
            Shape {
                anchors.fill: parent

                ShapePath {
                    strokeColor: Qt.rgba(1, 1, 1, 0.05)
                    strokeWidth: 10
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap

                    PathAngleArc {
                        centerX: 45; centerY: 45
                        radiusX: 35; radiusY: 35
                        startAngle: -90
                        sweepAngle: 360
                    }
                }
            }

            // Progress ring (gradient via Canvas)
            Canvas {
                id: ringCanvas
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();

                    if (root.progressRatio <= 0) return;

                    var cx = 45, cy = 45, r = 35, lw = 10;
                    var startAngle = -Math.PI / 2;
                    var endAngle = startAngle + root.progressRatio * 2 * Math.PI;

                    var gradient = ctx.createConicGradient(startAngle, cx, cy);
                    gradient.addColorStop(0, "#BF5AF2");
                    gradient.addColorStop(root.progressRatio, "#5E5CE6");
                    gradient.addColorStop(1, "transparent");

                    ctx.beginPath();
                    ctx.arc(cx, cy, r, startAngle, endAngle);
                    ctx.strokeStyle = gradient;
                    ctx.lineWidth = lw;
                    ctx.lineCap = "round";
                    ctx.stroke();
                }

                Connections {
                    target: root
                    function onProgressRatioChanged() { ringCanvas.requestPaint(); }
                    function onSuccessChanged() { ringCanvas.requestPaint(); }
                }
            }

            // Center dark circle
            Rectangle {
                anchors.centerIn: parent
                width: 68; height: 68
                radius: 34
                color: "#222222"

                Text {
                    anchors.centerIn: parent
                    text: "🤖"
                    font.pixelSize: 28
                }
            }
        }

        // ── Right: Info ──
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            // Title
            Text {
                text: "用量摘要"
                color: Qt.rgba(1, 1, 1, 0.6)
                font.pixelSize: 13
                font.bold: true
            }

            // Usage row
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "已消耗额度"
                    color: Qt.rgba(1, 1, 1, 0.9)
                    font.pixelSize: 14
                    Layout.fillWidth: true
                }

                Text {
                    text: Math.round(root.progressRatio * 100) + "%"
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Qt.rgba(1, 1, 1, 0.08)
            }

            // Balance row
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "当前余额"
                    color: Qt.rgba(1, 1, 1, 0.9)
                    font.pixelSize: 14
                    Layout.fillWidth: true
                }

                // Gradient text for balance
                Item {
                    implicitWidth: balanceText.implicitWidth
                    implicitHeight: balanceText.implicitHeight

                    Text {
                        id: balanceText
                        text: "$" + root.balance.toFixed(2)
                        color: "white"
                        font.pixelSize: 18
                        font.bold: true
                        visible: false
                    }

                    LinearGradient {
                        anchors.fill: balanceText
                        source: balanceText
                        start: Qt.point(0, 0)
                        end: Qt.point(balanceText.width, balanceText.height)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#BF5AF2" }
                            GradientStop { position: 1.0; color: "#5E5CE6" }
                        }
                    }
                }
            }

            // Spacer
            Item { Layout.fillHeight: true }

            // Footer
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "更新于 " + root.lastUpdated
                    color: Qt.rgba(1, 1, 1, 0.3)
                    font.pixelSize: 11
                    Layout.fillWidth: true
                }

                // Refresh button
                Rectangle {
                    implicitWidth: refreshRow.implicitWidth + 16
                    implicitHeight: refreshRow.implicitHeight + 8
                    radius: 6
                    color: refreshMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.06)

                    Row {
                        id: refreshRow
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: "↻"
                            color: Qt.rgba(1, 1, 1, 0.7)
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "刷新"
                            color: Qt.rgba(1, 1, 1, 0.7)
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.refreshRequested()
                    }
                }
            }
        }
    }
}
