import QtQuick 2.9
import Ubuntu.Components 1.3
import QtQml.Models 2.1
import "../components"
import "../components/Common"

Page {
    id: root

    property Flickable flickable: switch (root.currentPage) {
                                  case "Statistics":
                                      statisticsView.listView
                                      break
                                  case "Dashboard":
                                      dashboardView.listView
                                      break
                                  case "Detail":
                                      detailView.listView
                                      break
                                  default:
                                      dashboardView.listView
                                      break
                                  } //: listView.currentItem.item.listView
    property alias listView: listView
    property alias statisticsView: statsLoader.item
    property alias detailView: detailLoader.item
    property alias dashboardView: dashLoader.item

    property string currentPage: {
        switch (listView.currentIndex) {
        case 0:
            "Statistics"
            break
        case 1:
            "Dashboard"
            break
        case 2:
            "Detail"
            break
        default:
            "Other"
            break
        }
    }

    header: MainPageHeader {
        title: switch (root.currentPage) {
               case "Statistics":
                   i18n.tr("Statistics")
                   break
               case "Dashboard":
                   i18n.tr("Dashboard")
                   break
               case "Detail":
                   i18n.tr("Expenses")
                   break
               default:
                   i18n.tr("Dashboard")
                   break
               }

        flickable: root.currentPage === "Detail" ? root.flickable : null

        trailingActionBar {
            actions: [detailAction]
        }

        leadingActionBar {
            numberOfSlots: 3
            actions: [settingsAction, statsAction]
        }
    }


    onCurrentPageChanged: {
        root.header.show()
        headerTimer.restart()

        switch (currentPage) {
        case "Statistics":
            header.trailingActionBar.actions = [homeAction]
            header.leadingActionBar.actions = [settingsAction]
            break
        case "Dashboard":
            header.trailingActionBar.actions = [detailAction]
            header.leadingActionBar.actions = [settingsAction, statsAction]
            break
        case "Detail":
            header.leadingActionBar.actions = [settingsAction, homeAction]
            break
        default:
            header.leadingActionBar.actions = [homeAction]
            header.trailingActionBar.actions = []
            break
        }
    }
    /****************Functions*****************/
    function activateStatisticsView() {
        listView.positionViewAtIndex(0,ListView.SnapPosition)
    }

    function activateDashboardView() {
        listView.positionViewAtIndex(1,ListView.SnapPosition)
    }

    function activateDetailView() {
        listView.positionViewAtIndex(2,ListView.SnapPosition)
    }



    //Show header on mouse hover
    MouseArea {
        id: showHeaderMouseArea
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        height: units.gu(1)
        z: 1000

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        onContainsMouseChanged: {
            if (containsMouse) {
                headerTimer.stop()
                root.header.show()
            } else {
                headerTimer.restart()
            }
        }
    }

    Timer {
        id: headerTimer
        interval: 2000
        running: true
        onTriggered: {
            if (root.currentPage !== "Detail") {
                root.header.hide()
            }
        }
    }

    Connections {
        target: root.flickable
        onMovingChanged: {
            if (target.moving) {
                headerTimer.stop()
                root.header.show()
            } else {
                headerTimer.restart()
            }
        }
    }

    Action {
        id: homeAction

        iconName: "go-home"
        text: i18n.tr("Dashboard")
        onTriggered: {
            activateDashboardView()
        }
    }

    Action {
        id: settingsAction

        iconName: "settings"
        text: i18n.tr("Settings")
        onTriggered: {
            mainPageStack.push(settingsComponent)
        }
    }

    Action {
        id: detailAction

        iconName: "view-list-symbolic"
        text: i18n.tr("View Details")
        onTriggered: {
            activateDetailView()
        }
    }

    Action {
        id: statsAction

        iconName: "x-office-presentation-symbolic"
        text: i18n.tr("Dashboard")
        onTriggered: {
            activateStatisticsView()
        }
    }

    ObjectModel{
        id: pageModel
        Loader {
            id: statsLoader
            width: root.width
            anchors {
                top: parent.top
                bottom: parent.bottom
            }


            asynchronous: true
            sourceComponent: StatisticsView {
                id: statisticsViewPage
            }
            visible: status == Loader.Ready
        }
        Loader {
            id: dashLoader


            width: root.width
            anchors {
                top: parent.top
                bottom: parent.bottom
            }


            asynchronous: true
            sourceComponent: Dashboard {
                id: dashboardPage
            }
            visible: status == Loader.Ready

        }

        Loader {
            id: detailLoader
            width: root.width
            anchors {
                top: parent.top
                bottom: parent.bottom
            }


            asynchronous: true
            sourceComponent: DetailView {
                id: detailViewPage
            }
            visible: status == Loader.Ready
        }
    }

    ListView{
        id: listView
        model: pageModel
        anchors {
            fill: root
            topMargin: root.header.visible
                       && root.currentPage !== "Detail" ? root.header.height : 0
        }
        opacity: visible ? 1 : 0
//        visible: tempSettings.startingPageIndex !== 0 ? false : true

        boundsBehavior: Flickable.StopAtBounds
        highlightRangeMode: ListView.StrictlyEnforceRange
        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        interactive: true
        currentIndex: tempSettings.startDashboard ? 1 : tempSettings.startingPageIndex

        onCurrentIndexChanged: {
            tempSettings.startingPageIndex = currentIndex
        }

        Behavior on anchors.topMargin {
            UbuntuNumberAnimation {
                easing: UbuntuAnimation.StandardEasing
                duration: UbuntuAnimation.BriskDuration
            }
        }

        Behavior on opacity {
            UbuntuNumberAnimation {
                easing: UbuntuAnimation.StandardEasing
                duration: UbuntuAnimation.BriskDuration
            }
        }

    }

    Component {
        id: dashboardComponent
        Dashboard {
            id: dashboardPage
        }
    }

    Component {
        id: detailViewComponent
        DetailView {
            id: detailViewPage
        }
    }

    Component {
        id: statisticsViewComponent
        StatisticsView {
            id: statisticsViewPage
        }
    }

    Component {
        id: settingsComponent
        SettingsPage {
            id: settingsPage
        }
    }
}
