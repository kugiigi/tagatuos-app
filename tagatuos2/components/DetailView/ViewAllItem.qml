import QtQuick 2.9
import Ubuntu.Components 1.3

Rectangle {
    id: root

    height: slotLayout.height
//    width: slotLayout.width

    anchors{
        left: parent.left
        right: parent.right
    }

    SlotsLayout {
        id: slotLayout

        anchors.fill: parent

        mainSlot: Label {
            id: nameLabel

            text: i18n.tr("See More")
            textSize: Label.Medium
            font.weight: Text.Normal
            fontSizeMode: Text.HorizontalFit
            color: theme.palette.normal.foregroundText
            minimumPixelSize: units.gu(2)
            elide: Text.ElideRight
        }

        Icon {
            id: icon

            name: "next"
            height: units.gu(3.5)
            width: height
            color: theme.palette.normal.foregroundText
            SlotsLayout.position: SlotsLayout.Trailing
        }
    }
}
