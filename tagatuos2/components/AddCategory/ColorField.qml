import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes.Ambiance 1.3
import "../Common/ColorPicker"

Column {

    id: root

    property alias color: colorPicker.selectedColor

    spacing: units.gu(1)


    anchors {
        left: parent.left
        leftMargin: units.gu(2)
        right: parent.right
        rightMargin: units.gu(2)
    }

    Label {
        id: nameLabel
        text: i18n.tr("Color")
        font.weight: Text.Normal
        color: theme.palette.normal.foregroundText
        anchors {
            left: parent.left
            right: parent.right
        }
    }

    ColorPicker {
        id: colorPicker
        width: units.gu(20)
        height: units.gu(4)
        selectedColor: categoryColor === "default" ? "white" : categoryColor
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
        }
    }

}
