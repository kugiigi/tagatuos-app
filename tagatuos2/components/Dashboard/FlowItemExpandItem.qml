import QtQuick 2.4
import Ubuntu.Components 1.3

SlotsLayout {
    id: root


    mainSlot: Label {
        id: nameLabel
        text: i18n.tr("View All")
        textSize: Label.Small
        font.weight: Text.Normal
        fontSizeMode: Text.HorizontalFit
        color: theme.palette.normal.foregroundText
        minimumPixelSize: units.gu(2)
        elide: Text.ElideRight
    }

    Icon{
        id: icon
        name: "next"
        height: units.gu(2)
        width: height
        color: theme.palette.normal.foregroundText
        SlotsLayout.position: SlotsLayout.Trailing
    }
}
