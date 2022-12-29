import QtQuick 2.9
import Lomiri.Components 1.3
import "../components/Common"
import "../components/Dashboard"

Page {
    id: root

    property alias listView: mainFlickable

    header: PageHeader {
        visible: false
        title: i18n.tr("Dashboard")
        flickable: mainFlickable
        trailingActionBar {
            actions: [
                Action {
                    property bool nightMode: tempSettings.currentTheme
                                             === "Ubuntu.Components.Themes.SuruDark" ? true : false

                    iconName: nightMode ? "torch-off" : "torch-on"
                    text: i18n.tr("Night-mode")
                    onTriggered: {
                        nightMode = !nightMode
                        tempSettings.currentTheme = nightMode ? "Ubuntu.Components.Themes.SuruDark" : "Ubuntu.Components.Themes.Ambiance"
                    }
                }
            ]
        }
    }

    Component.onCompleted: {
        mainView.listModels.dashboardModel.initialise()
        mainView.listModels.modelThisWeekExpenses.load("Category")
    }


//    PageBackGround {
//    }

//    LomiriListView {
//        id: mainFlickable
//        interactive: true
//        anchors.fill: parent

//        clip: true
//        currentIndex: -1

//        delegate: DashboardItem {
//            id: todayItem
//            detailViewMode: viewMode
//            headerText: textHeader
//            emptyText: textEmpty
//            loadingText: textLoading
//            model: itemModel
//        }
//    }

    Connections{
        target: mainView.listModels.dashboardModel
        onReady:{
            itemsRepeater.model = target
        }
    }


    Flickable {
        id: mainFlickable

        contentHeight: column.childrenRect.height + units.gu(3)
        anchors.fill: parent
        clip: true
        interactive: true

        Column {
            id: column
            width: parent.width

            Repeater {
                id: itemsRepeater
                clip: true

                delegate: DashboardItem {
                    id: todayItem
                    detailViewMode: viewMode
                    headerText: textHeader
                    emptyText: textEmpty
                    loadingText: textLoading
                    model: itemModel
                }
            }


        }
    }
}
