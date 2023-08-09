import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.Controls 2.2 as QQC2
import QtQuick.Layouts 1.12
import QtQuick.Controls.Suru 2.2

RoundedItemDelegate {
    id: customizedSwitchDelegate

    enum Position {
        Right
        , Left
    }

    property alias label: mainLabel
    property int switchPosition: CustomizedSwitchDelegate.Position.Right

    transparentBackground: true
    checkable: true

    contentItem: RowLayout {
        layoutDirection: switchPosition == CustomizedSwitchDelegate.Position.Right ? Qt.LeftToRight : Qt.RightToLeft

        QQC2.Label {
            id: mainLabel

            Layout.fillWidth: true
            text: customizedSwitchDelegate.text
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            maximumLineCount: 2
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }

        QQC2.Switch {
            id: switchItem
            
            onCheckedChanged: customizedSwitchDelegate.checked = checked
            Binding {
                target: switchItem
                property: "checked"
                value: customizedSwitchDelegate.checked
            }
        }
    }
}
