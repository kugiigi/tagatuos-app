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

    property bool isWideLayout: false
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
        visible: !mainView.sidePageIsOpen

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
        visible: !mainView.sidePageIsOpen

        onTrigger: {
            if (mainView.sidePage) {
                mainView.sidePage.show()
            }
        }
    }

    Common.BaseAction {
        id: searchAction

        text: i18n.tr("Search")
        iconName: "find"
        shortcut: StandardKey.Find
        visible: !mainView.sidePageIsOpen
        enabled: visible

        onTrigger: {
            if (mainView.detailedListPage) {
                mainView.detailedListPage.showInSearchMode()
            }
        }
    }

    Common.BaseAction {
        id: nextAction

        enabled: !dashboardPage.isWideLayout && !mainView.sidePageIsOpen && dashboardPage.focus
        text: i18n.tr("Next")
        iconName: "go-next"
        shortcut: StandardKey.MoveToNextChar
        onTrigger: swipeView.incrementCurrentIndex()
    }

    Common.BaseAction {
        id: previousAction

        enabled: !dashboardPage.isWideLayout && !mainView.sidePageIsOpen && dashboardPage.focus
        text: i18n.tr("Previous")
        iconName: "go-previous"
        shortcut: StandardKey.MoveToPreviousChar
        onTrigger: swipeView.decrementCurrentIndex()
    }

    Common.BaseAction {
        id: separatorAction

        separator: true
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
            visible: swipeView.visible
            radius: height / 2
            color: Suru.backgroundColor

            RowLayout {
                id: indicatorLayout

                PageIndicator {
                    id: pageIndicatorItem

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    count: swipeView.count
                    currentIndex: swipeView.currentIndex
                    interactive: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 0
            visible: dashboardPage.isWideLayout

            Item {
                id: breakdownChartWideContainer

                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Item {
                id: trendChartWideContainer

                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }

        SwipeView {
            id: swipeView

            Layout.fillWidth: true
            Layout.fillHeight: true

            visible: !dashboardPage.isWideLayout
            currentIndex: pageIndicatorItem.currentIndex

            Item {
                id: breakdownChartDefaultContainer

                BreakdownChartsView {
                    id: breakdownChartsView

                    anchors.fill: parent
                    pageHeader: dashboardPage.pageManager.pageHeader
                    state: "normal"
                    states: [
                        State {
                            name: "normal"
                            when: !dashboardPage.isWideLayout
                            ParentChange {
                                target: breakdownChartsView
                                parent: breakdownChartDefaultContainer
                            }
                        }
                        , State {
                            name: "wide"
                            when: dashboardPage.isWideLayout
                            ParentChange {
                                target: breakdownChartsView
                                parent: breakdownChartWideContainer
                            }
                        }
                    ]
                }
            }

            Item {
                id: trendChartDefaultContainer

                TrendChartsView {
                    id: trendChartsView

                    pageHeader: dashboardPage.pageManager.pageHeader
                    anchors.fill: parent
                    state: "normal"
                    states: [
                        State {
                            name: "normal"
                            when: !dashboardPage.isWideLayout
                            ParentChange {
                                target: trendChartsView
                                parent: trendChartDefaultContainer
                            }
                        }
                        , State {
                            name: "wide"
                            when: dashboardPage.isWideLayout
                            ParentChange {
                                target: trendChartsView
                                parent: trendChartWideContainer
                            }
                        }
                    ]
                }
            }
        }
    }

    QtObject {
        id: internal
    }
}
