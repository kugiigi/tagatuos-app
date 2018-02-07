import QtQuick 2.4
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
    signal addQuick(string category, string itemName, string itemDescr, real itemValue)

    function loadQuickList(searchText) {
        listView.model.load(
                    bottomBarNavigation.model[bottomBarNavigation.currentIndex].type,searchText)
    }

    onAddQuick: {
        var today = new Date(Process.getToday())
        var txtDate = Qt.formatDateTime(today,
                                        "yyyy-MM-dd 00:00:00.000")
        var realValue = parseFloat(itemValue)

        var newExpense = DataProcess.saveExpense(category,
                                                 itemName,
                                                 itemDescr,
                                                 txtDate, itemValue)
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
            height: units.gu(5)
            width: units.gu(5)
            color: "transparent"
            activeFocusOnPress: false
            anchors {
                bottom: toolBar.visible ? toolBar.top : parent.top
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

        Toolbar {
            id: toolBar

            height: units.gu(6)

            visible: bottomBarNavigation.currentIndex === 1 ? true : false

            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.top
            }
            
            trailingActionBar {
                actions: Action {
                    shortcut: "Ctrl+A"
                    text: i18n.tr("Add")
                    iconName: "add"
                    onTriggered: {
                        PopupUtils.open(addDialog, null, {mode: "add"})
                    }
                }
                delegate: Button {
                    height: parent.height
                    width: units.gu(5)
                    color: "transparent"
                    activeFocusOnPress: false
                    action: modelData
                    
                    Rectangle {
                        z: -1
                        height: parent.height
                        width: height
                        color: theme.palette.normal.foreground
                    }
                }		
            }

            Rectangle {
                z: -1
                anchors.fill: parent
                color: theme.palette.normal.foreground
            }

            TextField {
                id: findField

                // Disable predictive text
                inputMethodHints: Qt.ImhNoPredictiveText


                placeholderText: i18n.tr("Find") + "..."

                anchors {
                    left: parent.left
                    leftMargin: units.gu(1)
                    right: toolBar.trailingActionBar.left
                    rightMargin: units.gu(1)
                    verticalCenter: parent.verticalCenter
                }

                primaryItem: Icon {
                    height: units.gu(2)
                    width: height
                    name: "find"
                }

                onTextChanged: delayTimer.restart()

                onVisibleChanged:{
                    if(visible){
                        findField.text = ""
                    }
                }

                //Timer to delay searching while typing
                Timer {
                    id: delayTimer
                    interval: 300
                    onTriggered: {
                        root.loadQuickList(findField.text)
                    }
                }
            }
        }

        ListView {
            id: listView

            interactive: true
            model: mainView.listModels.modelQuickAdd
            snapMode: ListView.SnapToItem
            clip: true
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                bottom: bottomBarNavigation.visible ? bottomBarNavigation.top : parent.bottom
            }

            delegate: QuickAddItem {
                itemName: quickname
                itemValue: AppFunctions.formatMoney(quickvalue, false)
                itemDescr: descr
                itemCategory: category_name
                leadingActions: bottomBarNavigation.currentIndex === 1 ? leftListItemActions : null
                trailingActions: rightListItemActions

                onClicked: {
                    addQuick(itemCategory, itemName, itemDescr, quickvalue)
                }

                ListItemActions {
                    id: rightListItemActions
                    actions: [
                        Action {
                            iconName: "edit"
                            text: i18n.tr("Edit")
                            visible: bottomBarNavigation.currentIndex === 1
                            onTriggered: {
                                PopupUtils.open(addDialog, null, {mode: "edit", quickID: quick_id, itemName: quickname, itemValue: quickvalue,itemDescr: descr, itemCategory: category_name})
                            }
                        },
                        Action {
                            iconName: "message-new"
                            text: i18n.tr("Custom Add")
                            onTriggered: {
                                PopupUtils.open(addDialog, null, {mode: "custom", quickID: quick_id, itemName: quickname, itemValue: quickvalue,itemDescr: descr, itemCategory: category_name})
                            }
                        }
                    ]
                }
                ListItemActions {
                    id: leftListItemActions
                    actions: [
                        Action {
                            iconName: "delete"
                            text: i18n.tr("Delete")
                            onTriggered: {
                                DataProcess.deleteQuickExpense(quick_id)
                                mainView.listModels.deleteQuickItem(quick_id)
                            }
                        }
                    ]
                }
            }
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

            model: [{
                    title: i18n.tr("Recent"),
                    icon: "history",
                    type: "recent"
                }, {
                    title: i18n.tr("Quick List"),
                    icon: "bookmark",
                    type: "list"
                }, {
                    title: i18n.tr("Most Used"),
                    icon: "view-list-symbolic",
                    type: "top"
                }]
            height: units.gu(8)
            anchors {
                bottom: contents.bottom
                left: parent.left
                right: parent.right
            }
        }
    }

    Component {
        id: addDialog
        AddQuickExpenseDialog {
            onAddQuickExpense: {
                addQuick(itemCategory, itemName, itemDescr, itemValue)
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
