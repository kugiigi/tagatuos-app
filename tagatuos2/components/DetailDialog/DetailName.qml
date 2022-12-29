import QtQuick 2.9
import Lomiri.Components 1.3

Label {
    id: nameLabel

    text: root.itemName
    color: theme.palette.normal.backgroundText
    font.weight: Font.DemiBold
    textSize: Label.Large
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    horizontalAlignment: Text.AlignHCenter

}
