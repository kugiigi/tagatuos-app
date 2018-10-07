import QtQuick 2.9
import Ubuntu.Components 1.3
import "../Common"

ExpandableListItemAdvanced {
    id: typeField

//    width: parent.width <= units.gu(60) ? parent.width : units.gu(60)
    listViewHeight: model.count <= 4? model.count * units.gu(7) : units.gu(28)
    listViewInteractive: true
    listBackground: true
    listBackgroundColor: theme.palette.normal.background
    titleText.textSize: Label.Medium
    titleText.font.weight: Text.Normal
    subText.textSize: Label.Medium
    subText.color: theme.palette.normal.backgroundText
    expansionBottomDivider: false
    divider.visible: false
    headerDivider.visible: false
    highlightColor: theme.palette.highlighted.background
    iconColor: theme.palette.normal.backgroundText
    savedValue: model.get(0).value //root.report_type


    onToggle: {
        report_type
        savedValue = newValue
    }


    ListModel {
        id: typesModel
        Component.onCompleted: initialise()

        function initialise() {
            typesModel.append({
                                   value: "LINE",
                                   text: i18n.tr("Trends")
                               })
            typesModel.append({
                                   value: "PIE",
                                   text: i18n.tr("Breakdown")
                               })
            typeField.model = typesModel
        }
    }

}
