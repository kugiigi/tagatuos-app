import QtQuick 2.9
import Ubuntu.Components 1.3

SlotsLayout {
    id: root

    property string title
    property string total

    padding{
        trailing: 0
        leading: 0
    }

    mainSlot: Label {
        id: titleLabel
        text: root.title
        textSize: Label.Medium
//        font.bold: true
        font.weight: Font.Normal
        fontSizeMode: Text.HorizontalFit
        color: theme.palette.normal.foregroundText
        minimumPixelSize: units.gu(2)
        elide: Text.ElideRight
    }

    Label {
        id: totalLabel
        text: root.total
        textSize: Label.Medium
        font.weight: Font.Normal
        SlotsLayout.position: SlotsLayout.Trailing
        fontSizeMode: Text.HorizontalFit
        horizontalAlignment: Text.AlignRight
        color: theme.palette.normal.foregroundText
        minimumPixelSize: units.gu(2)
        elide: Text.ElideRight
    }
}
