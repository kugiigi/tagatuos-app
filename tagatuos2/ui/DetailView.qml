import QtQuick 2.4
import Ubuntu.Components 1.3
import "../components/Common"
import "../components/DetailView"
import "../library/ProcessFunc.js" as Process

Page {
    id: root

    property alias listView: listView
    property alias model: listView.model
    property string sort
    property alias currentMode: pageHeaderExtension.currentValue
    property string currentDate1: Process.getToday()
    property string currentDate2
    //: Process.getToday()
    property string calendarMode: switch (pageHeaderExtension.currentValue) {
                                  case "calendar-daily":
                                      //pageHeaderExtension.currentValue.search('daily') > -1:
                                      "day"
                                      break
                                  case "calendar-weekly":
                                      //pageHeaderExtension.currentValue.search('weekly'):
                                      "week"
                                      break
                                  case "calendar-monthly":
                                      //pageHeaderExtension.currentValue.search('monthly'):
                                      "month"
                                      break
                                  case "calendar-custom":
                                      //pageHeaderExtension.currentValue.search('custom'):
                                      "custom"
                                      break
                                  default:
                                      ""
                                      break
                                  }

    header: PageHeader {
        visible: false
    }

    Component.onCompleted: {
        applyLayoutChanges()
    }

    /*********Functions**********/
    function applyLayoutChanges() {
        if (mainPage) {
            if (mainPage.currentPage === "Detail") {
                //pageHeaderExtension.visible = true
                mainPage.header.extension = pageHeaderExtension
                mainPage.header.trailingActionBar.actions = [addAction]
            } else {
                //pageHeaderExtension.visible = false
                mainPage.header.extension = null
            }
        }
    }

    Connections {
        target: mainPage.listView

        onMovingChanged: {
            if (target.moving) {
                mainPage.header.extension = null
            } else {
                root.applyLayoutChanges()
            }
        }
    }


    PageHeaderExtensionBar {
        id: pageHeaderExtension

        visible: mainPage.currentPage === "Detail"
                 && !mainPage.listView.moving ? true : false
        trailingActions: [forwardAction, backAction]

//        TODO: Temporarily removed since not yet implemented
//        leadingActions: [sortAction]
        Component.onCompleted: {
            mainView.listModels.modelSortFilterExpense.model
                    = mainView.listModels.modelTodayExpenses
        }

        onCurrentValueChanged: {
            var regex = new RegExp(root.sort)
            var dateRange
            mainView.listModels.modelSortFilterExpense.filter.pattern = regex

            switch (currentValue) {
            case "today":
                if (mainView.listModels.modelTodayExpenses.count === 0) {
                    mainView.listModels.modelTodayExpenses.load("Category")
                }
                mainView.listModels.modelSortFilterExpense.model
                        = mainView.listModels.modelTodayExpenses
                break
            case "recent":
                if (mainView.listModels.modelRecentExpenses.count === 0) {
                    mainView.listModels.modelRecentExpenses.load("Category")
                }
                mainView.listModels.modelSortFilterExpense.model
                        = mainView.listModels.modelRecentExpenses
                break
            case "yesterday":
                if (mainView.listModels.modelYesterdayExpenses.count === 0) {
                    mainView.listModels.modelYesterdayExpenses.load("Category")
                }
                mainView.listModels.modelSortFilterExpense.model
                        = mainView.listModels.modelYesterdayExpenses
                break
            case "thisweek":
                if (mainView.listModels.modelThisWeekExpenses.count === 0) {
                    mainView.listModels.modelThisWeekExpenses.load("Category")
                }
                mainView.listModels.modelSortFilterExpense.model
                        = mainView.listModels.modelThisWeekExpenses
                break
            case "thismonth":
                if (mainView.listModels.modelThisMonthExpenses.count === 0) {
                    mainView.listModels.modelThisMonthExpenses.load("Category")
                }
                mainView.listModels.modelSortFilterExpense.model
                        = mainView.listModels.modelThisMonthExpenses
                break
            case "lastweek":
                if (mainView.listModels.modelLastWeekExpenses.count === 0) {
                    mainView.listModels.modelLastWeekExpenses.load("Category")
                }
                mainView.listModels.modelSortFilterExpense.model
                        = mainView.listModels.modelLastWeekExpenses
                break
            case "lastmonth":
                if (mainView.listModels.modelLastMonthExpenses.count === 0) {
                    mainView.listModels.modelLastMonthExpenses.load("Category")
                }
                mainView.listModels.modelSortFilterExpense.model
                        = mainView.listModels.modelLastMonthExpenses
                break
            case "calendar-daily":
                mainView.listModels.modelCalendarExpenses.mode = "Calendar (By Day)"
                if (mainView.listModels.modelCalendarExpenses.count === 0) {
                    mainView.listModels.modelCalendarExpenses.load(
                                "Category", root.currentDate1)
                }
                mainView.listModels.modelSortFilterExpense.model
                        = mainView.listModels.modelCalendarExpenses
                break
            case "calendar-weekly":
                mainView.listModels.modelCalendarExpenses.mode = "Calendar (By Week)"
                if (mainView.listModels.modelCalendarExpenses.count === 0) {
                    dateRange = Process.getStartEndDate(root.currentDate1,
                                                        'week')
                    root.currentDate1 = dateRange.start
                    root.currentDate2 = dateRange.end
                    mainView.listModels.modelCalendarExpenses.load(
                                "Category", root.currentDate1,
                                root.currentDate2)
                }
                mainView.listModels.modelSortFilterExpense.model
                        = mainView.listModels.modelCalendarExpenses
                break
            case "calendar-monthly":
                mainView.listModels.modelCalendarExpenses.mode = "Calendar (By Month)"
                if (mainView.listModels.modelCalendarExpenses.count === 0) {
                    dateRange = Process.getStartEndDate(root.currentDate1,
                                                        'month')
                    root.currentDate1 = dateRange.start
                    root.currentDate2 = dateRange.end
                    mainView.listModels.modelCalendarExpenses.load(
                                "Category", root.currentDate1,
                                root.currentDate2)
                }
                mainView.listModels.modelSortFilterExpense.model
                        = mainView.listModels.modelCalendarExpenses
                break
            default:
                mainView.listModels.modelSortFilterExpense.model
                        = mainView.listModels.modelRecentExpenses
                break
            }
        }
    }

    Connections {
        id: mainPageConnection
        target: mainPage
        onCurrentPageChanged: {
            root.applyLayoutChanges()
        }
    }

    Action {
        id: addAction

        iconName: "add"
        text: i18n.tr("Add")
        onTriggered: {
            mainPageStack.addExpense()
        }
    }

      //TODO: Temporarily removed since not yet implemented
//    Action {
//        id: sortAction

//        iconName: "sort-listitem"
//        text: i18n.tr("Sort / Filter")
//        onTriggered: {

//            //            tempSettings.dashboardItems = "Today;This Week;Recent"
//        }
//    }

    Action {
        id: backAction

        iconName: "previous"
        text: i18n.tr("Previous")
        visible: pageHeaderExtension.currentValue.search(
                     "calendar") > -1 ? true : false
        onTriggered: {
            root.currentDate1 = Process.getPreviousDate(root.calendarMode,
                                                        root.currentDate1)
            root.currentDate2 = Process.getPreviousDate(root.calendarMode,
                                                        root.currentDate2)
            console.log("calendar mode: " + root.calendarMode)
            mainView.listModels.modelCalendarExpenses.load("Category",
                                                           root.currentDate1,
                                                           root.currentDate2)

            var startDate = Process.formatDateCalendar(root.currentDate1)
            var endDate = Process.formatDateCalendar(root.currentDate2)
            if (root.calendarMode === 'day') {
                pageHeaderExtension.calendarDateLabel.text = startDate
            } else {
                pageHeaderExtension.calendarDateLabel.text = startDate + " - " + endDate
            }

            //            mainView.listModels.modelSortFilterExpense.totalValue = mainView.listModels.modelCalendarExpenses.totalValue
        }
    }

    Action {
        id: forwardAction

        iconName: "next"
        text: i18n.tr("Next")
        visible: pageHeaderExtension.currentValue.search(
                     "calendar") > -1 ? true : false
        onTriggered: {
            root.currentDate1 = Process.getNextDate(root.calendarMode,
                                                    root.currentDate1)
            root.currentDate2 = Process.getNextDate(root.calendarMode,
                                                    root.currentDate2)
            mainView.listModels.modelCalendarExpenses.load("Category",
                                                           root.currentDate1,
                                                           root.currentDate2)

            var startDate = Process.formatDateCalendar(root.currentDate1)
            var endDate = Process.formatDateCalendar(root.currentDate2)
            if (root.calendarMode === 'day') {
                pageHeaderExtension.calendarDateLabel.text = startDate
            } else {
                pageHeaderExtension.calendarDateLabel.text = startDate + " - " + endDate
            }
            //            mainView.listModels.modelSortFilterExpense.totalValue = mainView.listModels.modelCalendarExpenses.totalValue
        }
    }

    EmptyState {
        id: emptySate
        z: -1

        title: {
            var suffix
            switch (currentMode) {
            case "today":
                suffix = i18n.tr("Today")
                break
            case "recent":
                suffix = i18n.tr("Recent Days")
                break
            case "yesterday":
                suffix = i18n.tr("Yesterday")
                break
            case "thisweek":
                suffix = i18n.tr("This Week")
                break
            case "thismonth":
                suffix = i18n.tr("This Month")
                break
            case "lastweek":
                suffix = i18n.tr("Last Week")
                break
            case "lastmonth":
                suffix = i18n.tr("Last Month")
                break
            default:
                suffix = i18n.tr("the specified date range")
                break
            }
            i18n.tr("No expense for ") + suffix
        }

        subTitle: i18n.tr("Use the bottom edge to add expenses")
        loadingTitle: i18n.tr("Loading Expenses")
        loadingSubTitle: i18n.tr("Please wait")
        isLoading: mainView.listModels.modelSortFilterExpense.loadingStatus
                   === "Loading" ? true : false
        anchors {
            right: parent.right
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        shown: mainView.listModels.modelSortFilterExpense.count === 0
               || mainView.listModels.modelSortFilterExpense.loadingStatus !== "Ready"
    }

    Component {
        id: detailsDialogComponent
        DetailsDialog {
            id: detailsDialog
        }
    }

    ScrollView {
        id: scrollView

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: statsBar.state === "floating" ? parent.bottom : statsBar.top
        }

        UbuntuListView {
            id: listView
            model: mainView.listModels.modelSortFilterExpense //modelTodayExpenses//sortFilterExpenseModel//modelTodayExpenses
            clip: true
            currentIndex: -1
            anchors.fill: parent

            //            ViewItems.expansionFlags: {
            //                Exclusive: false
            //            }
            delegate: GroupItem {
                delegateChild: SingleItem {
                    model: childModel
                }
            }

            onModelChanged: {
                currentIndex = -1
            }
        }
    }

    StatsBar {
        id: statsBar
        text: listView.model !== null
              || listView.model !== undefined ? listView.model.totalValue : ""
    }
}
