import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

RowLayout {
    id: compact

    property real balance: 0

    spacing: Kirigami.Units.smallSpacing

    Text {
        text: "🤖"
        font.pixelSize: Kirigami.Units.iconSizes.small * 0.9
        verticalAlignment: Text.AlignVCenter
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        text: "$" + compact.balance.toFixed(2)
        color: Kirigami.Theme.textColor
        font.pixelSize: Kirigami.Theme.defaultFont.pointSize * 0.9
        font.weight: Font.Medium
        verticalAlignment: Text.AlignVCenter
        Layout.alignment: Qt.AlignVCenter
    }
}
