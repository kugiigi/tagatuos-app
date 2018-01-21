import QtQuick 2.4
import Ubuntu.Components 1.3
import "../Common"

ExpandableListItem {
    id: dateModeField

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
    savedValue: model.get(0).value //root.date_mode


    onToggle: {
        savedValue = newValue
    }


    ListModel {
        id: modeModel
        Component.onCompleted: initialise()

        function initialise() {
            modeModel.append({
                                   value: "Day",
                                   text: i18n.tr("By Day")
                               })
            modeModel.append({
                                   value: "Week",
                                   text: i18n.tr("By Week")
                               })
            modeModel.append({
                                   value: "Month",
                                   text: i18n.tr("By Month")
                               })
            dateModeField.model = modeModel
        }
    }

}
