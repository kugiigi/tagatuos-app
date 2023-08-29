import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import Lomiri.Components 1.3 as UT
import QtQuick.Layouts 1.12
import QtCharts 2.3
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
        id: breakdownLayout

        property bool showLegend: false

        anchors.fill: parent
        spacing: 0

        function toggleLegend() {
            showLegend = !showLegend
        }

//~         Item {
//~             Layout.margins: Suru.units.gu(1)
//~             Layout.topMargin: 0
//~             Layout.preferredHeight: chartLegend.visible ? chartLegend.implicitHeight : 0
//~             Layout.fillWidth: true

//~             z: 1
//~             Behavior on Layout.preferredHeight {
//~                 NumberAnimation {
//~                     easing: Suru.animations.EasingOut
//~                     duration: Suru.animations.FastDuration
//~                 }
//~             }

//~             BreakdownPieChartLegend {
//~                 id: chartLegend

//~                 anchors.fill: parent
//~                 visible: opacity > 0
//~                 opacity: breakdownLayout.showLegend ? 1 : 0
//~                 Behavior on opacity {
//~                     NumberAnimation {
//~                         easing: Suru.animations.EasingIn
//~                         duration: Suru.animations.FastDuration
//~                     }
//~                 }
//~             }
//~         }

        Item {
            Layout.leftMargin: Suru.units.gu(1)
            Layout.rightMargin: Suru.units.gu(1)
            Layout.fillHeight: true
            Layout.fillWidth: true

            ButtonGroup { id: breakdownChartButtonGrp }

            Common.BaseFlickable {
                id: mainFlickable

                anchors.fill: parent
                bottomMargin: Suru.units.gu(2)
                pageHeader: dashboardPage.pageManager.pageHeader
                contentHeight: contentsLayout.height

                ColumnLayout {
                    id: contentsLayout

                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    
                    Item {
                        Layout.margins: Suru.units.gu(1)
                        Layout.topMargin: 0
                        Layout.preferredHeight: chartLegend.visible ? chartLegend.implicitHeight : 0
                        Layout.maximumWidth: Suru.units.gu(80)
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true

                        z: 1
                        Behavior on Layout.preferredHeight {
                            NumberAnimation {
                                easing: Suru.animations.EasingOut
                                duration: Suru.animations.FastDuration
                            }
                        }

                        BreakdownPieChartLegend {
                            id: chartLegend

                            anchors.fill: parent
                            visible: opacity > 0
                            opacity: breakdownLayout.showLegend ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    easing: Suru.animations.EasingIn
                                    duration: Suru.animations.FastDuration
                                }
                            }
                        }
                    }

                    GridLayout  {
                        id: gridLayout

                        readonly property real itemPreferredWidth: Suru.units.gu(20)
                        readonly property real itemMaximumWidth: Suru.units.gu(30)

                        Layout.fillWidth: true
                        columns: Math.floor(width / (itemPreferredWidth + Suru.units.gu(2)))
                        columnSpacing: 0
                        rowSpacing: 0

                        Item {
                            id: selectedItem

                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: Suru.units.gu(30)
                            Layout.maximumWidth: Suru.units.gu(40)
                            Layout.fillWidth: true
                            Layout.columnSpan: gridLayout.columns > 0 ? gridLayout.columns : 1
                            implicitHeight: width

                            onChildrenChanged: {
                                if (children.length > 0) {
                                    let _legendModel = []
                                    let _chart = children[0].chart
                                    chartLegend.updateData(_chart)
                                }
                            }
                        }

                        Item {
                            id: dayContainer

                            Layout.fillWidth: true
                            Layout.preferredHeight: width > gridLayout.itemPreferredWidth ? Math.min(gridLayout.itemMaximumWidth, width) : gridLayout.itemPreferredWidth
                            visible: !dayBreakdownChart.checked

                            BreakdownPieChart {
                                id: dayBreakdownChart

                                anchors.fill: parent
                                chartTitle: i18n.tr("Today")
                                checked: true
//~                                 Component.onCompleted: checked = true
                                model: mainView.mainModels.todayBreakdownChartModel
                                selectedParent: selectedItem
                                originalParent: dayContainer
                                ButtonGroup.group: breakdownChartButtonGrp

                                onPressAndHold: breakdownLayout.toggleLegend()
                                onRightClicked: breakdownLayout.toggleLegend()
                            }
                        }

                        Item {
                            id: weekContainer

                            Layout.fillWidth: true
                            Layout.preferredHeight: width > gridLayout.itemPreferredWidth ? Math.min(gridLayout.itemMaximumWidth, width) : gridLayout.itemPreferredWidth
                            visible: !weekBreakdownChart.checked

                            BreakdownPieChart {
                                id: weekBreakdownChart

                                anchors.fill: parent
                                chartTitle: i18n.tr("This Week")
                                model: mainView.mainModels.thisWeekBreakdownChartModel
                                selectedParent: selectedItem
                                originalParent: weekContainer
                                ButtonGroup.group: breakdownChartButtonGrp
                            }
                        }

                        Item {
                            id: recentContainer

                            Layout.fillWidth: true
                            Layout.preferredHeight: width > gridLayout.itemPreferredWidth ? Math.min(gridLayout.itemMaximumWidth, width) : gridLayout.itemPreferredWidth
                            visible: !recentBreakdownChart.checked

                            BreakdownPieChart {
                                id: recentBreakdownChart

                                anchors.fill: parent
                                chartTitle: i18n.tr("Last 7 days")
                                model: mainView.mainModels.recentBreakdownChartModel
                                selectedParent: selectedItem
                                originalParent: recentContainer
                                ButtonGroup.group: breakdownChartButtonGrp
                            }
                        }

                        Item {
                            id: monthContainer

                            Layout.fillWidth: true
                            Layout.preferredHeight: width > gridLayout.itemPreferredWidth ? Math.min(gridLayout.itemMaximumWidth, width) : gridLayout.itemPreferredWidth
                            visible: !monthBreakdownChart.checked

                            BreakdownPieChart {
                                id: monthBreakdownChart

                                anchors.fill: parent
                                chartTitle: i18n.tr("This Month")
                                model: mainView.mainModels.thisMonthBreakdownChartModel
                                selectedParent: selectedItem
                                originalParent: monthContainer
                                ButtonGroup.group: breakdownChartButtonGrp
                            }
                        }

                        Item {
                            id: yearContainer

                            Layout.fillWidth: true
                            Layout.preferredHeight: width > gridLayout.itemPreferredWidth ? Math.min(gridLayout.itemMaximumWidth, width) : gridLayout.itemPreferredWidth
                            visible: !yearhBreakdownChart.checked

                            BreakdownPieChart {
                                id: yearhBreakdownChart

                                anchors.fill: parent
                                chartTitle: i18n.tr("This Year")
                                model: mainView.mainModels.thisYearBreakdownChartModel
                                selectedParent: selectedItem
                                originalParent: yearContainer
                                ButtonGroup.group: breakdownChartButtonGrp
                            }
                        }
                    }
                }
            }
        }
    }

    QtObject {
        id: internal
    }
}
