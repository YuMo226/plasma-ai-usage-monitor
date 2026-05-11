import QtQuick
import QtQuick.Controls as QtControls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    switchWidth: 0
    switchHeight: 0

    // State
    readonly property bool loading: d.loading
    readonly property bool error: d.error
    readonly property string errorMsg: d.errorMsg
    readonly property real balance: d.balance
    readonly property real limit: d.limit
    readonly property real usage: d.usage
    readonly property bool success: d.success

    // Config
    readonly property string scriptPath: Qt.resolvedUrl("../get_ai_usage.py").toString().replace("file://", "")
    readonly property int refreshInterval: 30 * 60 * 1000

    QtObject {
        id: d
        property bool loading: false
        property bool error: false
        property string errorMsg: ""
        property real balance: 0
        property real limit: 0
        property real usage: 0
        property bool success: false
    }

    Timer {
        id: refreshTimer
        interval: root.refreshInterval
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    P5Support.DataSource {
        id: dataSource
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            d.loading = false;

            if (data["exit code"] !== 0) {
                d.error = true;
                d.errorMsg = data.stderr || "Script execution failed";
                disconnectSource(sourceName);
                return;
            }

            var output = data.stdout || "";
            try {
                var json = JSON.parse(output);
                d.success = json.success || false;
                d.limit = json.limit || 0;
                d.usage = json.usage || 0;
                d.balance = json.balance || 0;
                d.errorMsg = json.error_msg || "";
                d.error = !json.success;
            } catch (e) {
                d.error = true;
                d.errorMsg = "JSON parse error: " + e.message;
                d.success = false;
            }

            disconnectSource(sourceName);
        }
    }

    function refresh() {
        if (d.loading) return;
        d.loading = true;
        d.error = false;
        d.errorMsg = "";
        dataSource.connectSource("python3 " + root.scriptPath);
    }

    compactRepresentation: Item {
        Layout.minimumWidth: compact.implicitWidth
        Layout.minimumHeight: compact.implicitHeight

        CompactRepresentation {
            id: compact
            anchors.fill: parent
            balance: root.balance
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.expanded = !root.expanded
        }
    }

    fullRepresentation: FullRepresentation {
        balance: root.balance
        limit: root.limit
        usage: root.usage
        loading: root.loading
        error: root.error
        errorMsg: root.errorMsg
        success: root.success

        onRefreshRequested: root.refresh()
    }
}
