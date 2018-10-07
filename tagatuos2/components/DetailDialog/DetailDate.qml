import QtQuick 2.9
import Ubuntu.Components 1.3

Label {
    id: dateLabel

    text: root.date
    color: theme.palette.normal.backgroundSecondaryText
    font.weight: Font.Normal
    textSize: Label.Small
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    horizontalAlignment: Text.AlignRight
}
