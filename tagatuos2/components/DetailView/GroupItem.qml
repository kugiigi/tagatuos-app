import QtQuick 2.9
import Lomiri.Components 1.3
import "../Common"
import "../../library/ApplicationFunctions.js" as AppFunctions

ExpandableListItemAdvanced {
    id: root

    titleText.text: category_name + " " + "(" + count + ")"
    titleText.textSize: Label.Medium
    titleText.color: theme.palette.normal.backgroundText
    titleText.font.weight: Font.Normal
    highlightColor: theme.palette.highlighted.foreground

    trailingItemComponent: Label {
        id: totalLabel

        property string homeMoney: AppFunctions.formatMoney(total, false)
        property string travelMoney: tempSettings.travelMode ? AppFunctions.formatMoneyTravel(total / tempSettings.exchangeRate, false) : ""

        text: !tempSettings.travelMode ? homeMoney
                                       : (root.expansion.expanded ? '<font color=\"' + theme.palette.normal.backgroundTertiaryText + '\">' + "(" + homeMoney + ") "
                                                                    + '</font>' + travelMoney
                                                                  : travelMoney)
        textSize: Label.Medium
        font.weight: Font.Normal
        SlotsLayout.position: SlotsLayout.Trailing
        fontSizeMode: Text.HorizontalFit
        horizontalAlignment: Text.AlignRight
        color: tempSettings.travelMode ? theme.palette.normal.positive : theme.palette.normal.foregroundText
        minimumPixelSize: units.gu(2)
        elide: Text.ElideRight
    }

    Component.onCompleted: root.expansion.expanded = false

//    arrowVisible: false
}
