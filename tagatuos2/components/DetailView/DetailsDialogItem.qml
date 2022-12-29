import QtQuick 2.9
import Lomiri.Components 1.3


Column {
    id: root

    property alias label: label.text
    property alias text: labelText.text

//    spacing: units.gu(1)

    anchors{
        left: parent.left
        right: parent.right
    }

    Label {
        id: label
            textSize: Label.Medium
            font.weight: Font.Normal
//            fontSizeMode: Text.HorizontalFit
            color: theme.palette.normal.overlayText
//            minimumPixelSize: units.gu(3)
//            elide: Text.ElideRight
            anchors{
                left: parent.left
                right: parent.right
            }
        }

    Label {
        id: labelText
            textSize: Label.Medium
//            font.weight: Font.Normal
//            fontSizeMode: Text.HorizontalFit
            color: theme.palette.normal.overlayText
//            minimumPixelSize: units.gu(3)
//            elide: Text.ElideRight
            wrapMode: Text.WordWrap
            anchors{
                left: parent.left
                right: parent.right
            }
        }

}
