import QtQuick 2.4
import Ubuntu.Components 1.3
import "../Common"
import "../../library/ApplicationFunctions.js" as AppFunctions

ExpandableListItem {
    id: root

    titleText.text: category_name + " " + "(" + count + ")"
    titleText.textSize: Label.Medium
    titleText.color: theme.palette.normal.backgroundText
    titleText.font.weight: Font.Normal
    highlightColor: theme.palette.highlighted.foreground

    trailingItemComponent: Label {
        id: totalLabel
        text: AppFunctions.formatMoney(total, false)
        textSize: Label.Medium
        font.weight: Font.Normal
        SlotsLayout.position: SlotsLayout.Trailing
        fontSizeMode: Text.HorizontalFit
        horizontalAlignment: Text.AlignRight
        color: theme.palette.normal.foregroundText
        minimumPixelSize: units.gu(2)
        elide: Text.ElideRight
    }

    Component.onCompleted: root.expansion.expanded = false

//    arrowVisible: false
}
