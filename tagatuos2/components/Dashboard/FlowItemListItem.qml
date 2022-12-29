import QtQuick 2.9
import Lomiri.Components 1.3

SlotsLayout {
    id: root

    property string itemName
    property string itemValue

    mainSlot: Label {
        id: nameLabel
        text: root.itemName
        textSize: Label.Small
        fontSizeMode: Text.HorizontalFit
        color: theme.palette.normal.foregroundText
        minimumPixelSize: units.gu(2)
        elide: Text.ElideRight
    }

    Label {
        id: valueLabel
        text: root.itemValue
        textSize: Label.Small
        SlotsLayout.position: SlotsLayout.Trailing
        fontSizeMode: Text.HorizontalFit
        horizontalAlignment: Text.AlignRight
        color: theme.palette.normal.foregroundText
        minimumPixelSize: units.gu(2)
        elide: Text.ElideRight
    }
}
