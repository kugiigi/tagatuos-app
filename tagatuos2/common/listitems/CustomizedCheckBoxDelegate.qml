import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.Controls 2.2 as QQC2
import QtQuick.Layouts 1.12
import QtQuick.Controls.Suru 2.2

RoundedItemDelegate {
    id: customizedCheckBoxDelegate

    enum Position {
        Right
        , Left
    }

    property alias label: mainLabel
    property int checkBoxPosition: CustomizedCheckBoxDelegate.Position.Right

    transparentBackground: true
    checkable: true

    contentItem: RowLayout {
        layoutDirection: checkBoxPosition == CustomizedCheckBoxDelegate.Position.Right ? Qt.LeftToRight : Qt.RightToLeft

        QQC2.Label {
            id: mainLabel

            Layout.fillWidth: true
            text: customizedCheckBoxDelegate.text
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            maximumLineCount: 2
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }

        QQC2.CheckBox {
            id: checkBoxItem
            
            onCheckedChanged: customizedCheckBoxDelegate.checked = checked
            Binding {
                target: checkBoxItem
                property: "checked"
                value: customizedCheckBoxDelegate.checked
            }
        }
    }
}
