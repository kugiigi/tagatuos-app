import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import Lomiri.Components 1.3 as UT
import QtQuick.Layouts 1.12
import "dashboardpage"
import ".." as Components
import "../../common" as Common
import "../../common/pages" as Pages
import "../../common/menus" as Menus
import "../../common/dialogs" as Dialogs
import "../../library/functions.js" as Functions
import "../../library/ApplicationFunctions.js" as AppFunctions

Pages.BasePage {
    id: dashboardPage

    property bool isTravelMode: false
    property string travelCurrency

    title: mainView.profiles.currentName()
    focus: !mainView.newExpenseView.isOpen

//~     signal refresh

    headerLeftActions: [ settingsAction ]
    headerRightActions: [ searchAction, detailedPageAction, addAction  ]

//~     Connections {
//~         target: mainView.settings
//~         onActiveProfileChanged: {
//~             refresh()
//~         }
//~     }

    Common.BaseAction {
        id: addAction

        text: i18n.tr("New Entry")
        shortText: i18n.tr("New")
        iconName: "add"
        shortcut: StandardKey.New

        onTrigger: mainView.newExpenseView.openInSearchMode()
    }

    Common.BaseAction {
        id: settingsAction

        text: i18n.tr("Settings")
        iconName: "settings"
    }

    Common.BaseAction {
        id: detailedPageAction

        text: i18n.tr("View expenses")
        shortText: i18n.tr("Expenses")
        iconName: "view-list-symbolic"

        onTrigger: dashboardPage.pageManager.push("qrc:///components/pages/DetailedListPage.qml", { isTravelMode: dashboardPage.isTravelMode, travelCurrency: dashboardPage.travelCurrency })
    }

    Common.BaseAction {
        id: searchAction

        text: i18n.tr("Search")
        iconName: "search"
    }

    Common.BaseAction {
        id: separatorAction

        separator: true
    }

    UT.LiveTimer {
        frequency: UT.LiveTimer.Hour
//~         onTrigger: navigationRow.labelRefresh()
    }

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            id: pageIndicator

            Layout.topMargin: Suru.units.gu(1)
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: indicatorLayout.width
            Layout.preferredHeight: indicatorLayout.height

            z: 1
            radius: height / 2
            color: Suru.backgroundColor

            RowLayout {
                id: indicatorLayout

                PageIndicator {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    count: swipeView.count
                    currentIndex: swipeView.currentIndex
                }
            }
        }

        SwipeView {
            id: swipeView

            currentIndex: 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            BreakdownChartsView {
                id: breakdownChartsView

                pageHeader: dashboardPage.pageManager.pageHeader
            }

            TrendChartsView {
                id: trendChartsView

                pageHeader: dashboardPage.pageManager.pageHeader
            }
        }
    }

    QtObject {
        id: internal
    }
}
