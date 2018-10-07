import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.Styles 1.3
import "../Common"
import "../../library/ProcessFunc.js" as Process

SlotsLayout {
    id: root

    property string currentValue: "today"
    property alias trailingActions: trailingActionBar.actions
    property alias leadingActions: leadingActionBar.actions
    property alias calendarDateLabel: titleExpandable.subText
//    property bool calendarMode: currentValue.search("calendar") > -1

    height: units.gu(8.5)
    opacity: visible ? 1 : 0
    padding{
        top: units.gu(-0.5)
    }

    Behavior on opacity {
        UbuntuNumberAnimation {
            easing: UbuntuAnimation.StandardEasing
            duration: UbuntuAnimation.BriskDuration
        }
    }

    //Sets the current value in the ExpandableListItem
//    onCurrentValueChanged:{
//        if (titleModel.count > 0) {
//            var i = 0
//            while (currentValue !== titleModel.get(i).value && i != titleModel.count - 1) {
//                i++
//            }
//            titleExpandable.selectedIndex = i
//        }
//    }

    mainSlot: ExpandableListItemAdvanced {
        id: titleExpandable
        listViewHeight: units.gu(28)
        listViewInteractive: true
        listBackground: true
        listBackgroundColor: theme.palette.normal.overlay//foreground
        dropDownMode: true
        titleText.textSize: Label.Large
        subText.textSize: Label.Small
        expansionBottomDivider: false
        divider.visible: false
        headerDivider.visible: false
        highlightColor: theme.palette.highlighted.foreground
        iconColor: theme.palette.normal.foregroundText
        listDividerVisible: false

        savedValue: root.currentValue

        onToggle: {
            root.currentValue = newValue
            if(newValue.search("calendar") > -1){
                titleText.textSize = Label.Small
                subText.textSize = Label.Large
            }else{
                titleText.textSize = Label.Large
                subText.textSize = Label.Small
            }
        }

        onSelectedIndexChanged: {
            root.calendarDateLabel.text = titleModel.get(selectedIndex).subText
            if(titleModel.get(selectedIndex).value.search("calendar") > -1){
                titleExpandable.iconName = "calendar"
            }else{
                titleExpandable.iconName = ""
            }
        }

        ListModel {
            id: titleModel
            Component.onCompleted: initialise()

            function initialise() {
                var formattedDates = Process.getDateComparisonValuesFormat()

                titleModel.append({
                                      value: "today",
                                      text: i18n.tr("Today"),
                                      subText: formattedDates.today
                                  })
                titleModel.append({
                                      value: "yesterday",
                                      text: i18n.tr("Yesterday"),
                                      subText: formattedDates.yesterday
                                  })
                titleModel.append({
                                      value: "thisweek",
                                      text: i18n.tr("This Week"),
                                      subText: formattedDates.thisWeekFirstDay + " - " + formattedDates.thisWeekLastDay
                                  })
                titleModel.append({
                                      value: "thismonth",
                                      text: i18n.tr("This Month"),
                                      subText: formattedDates.thisMonthFirstDay + " - " + formattedDates.thisMonthLastDay
                                  })
                titleModel.append({
                                      value: "recent",
                                      text: i18n.tr("Recent"),
                                      subText: formattedDates.sevenDaysago + " - " + formattedDates.today
                                  })
                titleModel.append({
                                      value: "lastweek",
                                      text: i18n.tr("Last Week"),
                                      subText: formattedDates.lastWeekFirstDay + " - " + formattedDates.lastWeekLastDay
                                  })
                titleModel.append({
                                      value: "lastmonth",
                                      text: i18n.tr("Last Month"),
                                      subText: formattedDates.lastMonthFirstDay + " - " + formattedDates.lastMonthLastDay
                                  })
                titleModel.append({
                                      value: "calendar-daily",
                                      text: i18n.tr("Calendar (By Day)"),
                                      subText: formattedDates.today
                                  })
                titleModel.append({
                                      value: "calendar-weekly",
                                      text: i18n.tr("Calendar (By Week)"),
                                      subText: formattedDates.today
                                  })
                titleModel.append({
                                      value: "calendar-monthly",
                                      text: i18n.tr("Calendar (By Month)"),
                                      subText: formattedDates.today
                                  })
                titleModel.append({
                                      value: "calendar-custom",
                                      text: i18n.tr("Calendar (Custom)"),
                                      subText: formattedDates.today
                                  })
                titleExpandable.model = titleModel
            }
        }
    }

    ActionBar{
        id: trailingActionBar

        SlotsLayout.position: SlotsLayout.Trailing
        SlotsLayout.overrideVerticalPositioning : true
        anchors.verticalCenter: parent.verticalCenter
        numberOfSlots: 4
        height: parent.height
//        anchors{
//            top: parent.top
//            bottom: parent.bottom
//        }

        StyleHints{
            backgroundColor: theme.palette.normal.overlay
        }
    }

    ActionBar{
        id: leadingActionBar

        SlotsLayout.position: SlotsLayout.Leading
        SlotsLayout.overrideVerticalPositioning : true
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
//        anchors{
//            top: parent.top
//            bottom: parent.bottom
//        }
        numberOfSlots: 4

        StyleHints{
            backgroundColor: theme.palette.normal.overlay
        }

    }

}
