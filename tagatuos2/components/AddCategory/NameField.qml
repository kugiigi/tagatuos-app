import QtQuick 2.9
import Lomiri.Components 1.3
import Lomiri.Components.Themes.Ambiance 1.3

Column {

    id: root

    property alias text: textName.text

    spacing: units.gu(1)


    anchors {
        left: parent.left
        leftMargin: units.gu(2)
        right: parent.right
        rightMargin: units.gu(2)
    }

    function forceActiveFocus(){
        textName.forceActiveFocus()
    }

    Label {
        id: nameLabel
        text: i18n.tr("Name")
        font.weight: Text.Normal
        color: theme.palette.normal.foregroundText
        anchors {
            left: parent.left
            right: parent.right
        }
    }

    TextField {
        id: textName
        placeholderText: i18n.tr("Enter category name ")
        hasClearButton: true
        anchors {
            left: parent.left
            right: parent.right
        }

        style: TextFieldStyle {
            //overlaySpacing: 0
            //frameSpacing: 0
            background: Item {
            }
            color: theme.palette.normal.overlayText
        }
    }

}
