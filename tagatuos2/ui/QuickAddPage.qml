import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components/Common"
import "../components/QuickAddPage"
import "../library/ProcessFunc.js" as Process
import "../library/DataProcess.js" as DataProcess
import "../library/ApplicationFunctions.js" as AppFunctions

Item {
    id: root

    property bool isContentShown: false

    signal close
    signal addQuick(string category, string itemName, string itemDescr, real itemValue, real itemTravelValue, string itemHomeCur, string itemTravelCur)

    function loadQuickList(searchText) {
        listView.model.load(
                    bottomBarNavigation.model[bottomBarNavigation.currentIndex].type,searchText)
    }

    onAddQuick: {
        var today = new Date(Process.getToday())
        var txtDate = Qt.formatDateTime(today,
                                        "yyyy-MM-dd 00:00:00.000")
        var realValue //parseFloat()
        var travelData

        //Travel Data
        if(tempSettings.travelMode){
            var realRate = tempSettings.exchangeRate
            var txtHomeCur = tempSettings.currentCurrency
            var txtTravelCur = tempSettings.travelCurrency
            var realTravelValue


            if(itemHomeCur === tempSettings.currentCurrency && itemTravelCur === tempSettings.travelCurrency){
                realTravelValue = itemTravelValue
                realValue = realTravelValue * realRate
            }else{
                realTravelValue = itemValue / realRate
                realValue = itemValue
            }

            travelData = {"rate": realRate, "homeCur": txtHomeCur, "travelCur": txtTravelCur, "value": realTravelValue}
        }else{
            realValue = itemValue
        }

        var newExpense = DataProcess.saveExpense(category,
                                                 itemName,
                                                 itemDescr,
                                                 txtDate, realValue, travelData)
        mainView.listModels.addItem(newExpense)
        close()
    }

    Item {
        id: contents

        visible: root.isContentShown

        anchors.fill: root

        onVisibleChanged: {
            if (visible) {
                bottomBarNavigation.forceActiveFocus()
            }
        }

        Button {
            id: hideButton

            height: units.gu(5)
            width: units.gu(5)
            color: "transparent"
            activeFocusOnPress: false
            anchors {
                bottom: findToolBar.visible ? findToolBar.top : parent.top
                horizontalCenter: parent.horizontalCenter
            }
            action: Action {
                iconName: "go-down"
                shortcut: "Esc"
                onTriggered: {
                    close()
                }
            }

            Rectangle {
                z: -1
                height: parent.height
                width: height
                color: theme.palette.normal.foreground
            }
        }

        QuickAddFindToolbar{
            id: findToolBar
        }

        QuickAddListView{
            id: listView
        }

        Loader {
            id: emptyStateLoader

            asynchronous: true
            visible: status == Loader.Ready
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: bottomBarNavigation.top
            }
            sourceComponent: emptyStateComponent
        }

        Component {
            id: emptyStateComponent
            EmptyState {
                id: emptySate

                z: -1
                title: i18n.tr("No data to display")
                //                subTitle: i18n.tr("Select different report criteria")
                anchors {
                    right: parent.right
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                isLoading: listView.model.loadingStatus === "Loading" ? true : false
                shown: listView.model.count === 0
                       || listView.model.loadingStatus !== "Ready"
            }
        }

        BottomBarNavigation {
            id: bottomBarNavigation

            Component.onCompleted: root.loadQuickList()

            onCurrentIndexChanged: {
                root.loadQuickList()
            }
        }
    }

    Component {
        id: addDialog
        AddQuickExpenseDialog {
            onAddQuickExpense: {
                var travelValue = 0
                var rate = 0
                var homeCur = ""
                var travelCur = ""

                addQuick(itemCategory, itemName, itemDescr, itemValue, travelValue, rate, homeCur, travelCur)
            }
        }
    }

    Connections {
        id: keyboard
        target: Qt.inputMethod
        onVisibleChanged: {
            if (target.visible) {
                bottomBarNavigation.visible = false
            } else {
                bottomBarNavigation.visible = true
            }
        }
    }
}
