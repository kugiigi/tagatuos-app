import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    property string title
    property string subtitle


    Column {
        anchors{
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        Label {
            id: labelTitle
            text: title
            textSize: Label.Medium
            font.weight: Font.DemiBold
            color: theme.palette.normal.backgroundText
            fontSizeMode: Text.HorizontalFit
            minimumPixelSize: units.gu(1.5)
            elide: Text.ElideRight
            width: parent !== null ? parent.width : 0
        }
        Label {
            id: labelSubTitle
            text: subtitle
            color: theme.palette.normal.backgroundSecondaryText
            visible: subtitle === "" ? false: true
            fontSizeMode: Text.HorizontalFit
            textSize: Label.Small
            minimumPixelSize: units.gu(1)
            elide: Text.ElideRight
            width: parent !== null ? parent.width : 0
        }
    }
}
