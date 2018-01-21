import QtQuick 2.4
import Ubuntu.Components 1.3
import "../Common"

ExpandableListItem {
    id: dateRangeField

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
//    titleText.text: i18n.tr("Report Type")
//    valueRoleName: "category_name"
//    textRoleName: "category_name"
    savedValue: model.get(0).value //root.date_range


    onToggle: {
        savedValue = newValue
    }


    ListModel {
        id: typesModel
        Component.onCompleted: initialise()

        function initialise() {
            typesModel.append({
                                   value: "Today",
                                   text: i18n.tr("Today")
                               })
            typesModel.append({
                                   value: "Yesterday",
                                   text: i18n.tr("Yesterday")
                               })
            typesModel.append({
                                   value: "This Week",
                                   text: i18n.tr("This Week")
                               })
            typesModel.append({
                                   value: "This Month",
                                   text: i18n.tr("This Month")
                               })
            typesModel.append({
                                   value: "This Year",
                                   text: i18n.tr("This Year")
                               })
            typesModel.append({
                                   value: "Recent",
                                   text: i18n.tr("Recent")
                               })
            typesModel.append({
                                   value: "Last Week",
                                   text: i18n.tr("Last Week")
                               })
            typesModel.append({
                                   value: "Last Month",
                                   text: i18n.tr("Last Month")
                               })
            typesModel.append({
                                   value: "Last Year",
                                   text: i18n.tr("Last Year")
                               })
            typesModel.append({
                                   value: "Custom",
                                   text: i18n.tr("Custom Range")
                               })
            dateRangeField.model = typesModel
        }
    }

}
