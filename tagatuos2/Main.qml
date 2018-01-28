import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Layouts 1.0
//import Ubuntu.Components.Labs 1.0
import Qt.labs.settings 1.0
import "components"
import "components/ListModels"
import "components/Common"
import "ui"
import "library/DataProcess.js" as DataProcess

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    id: mainView
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "tagatuos2.kugiigi"

    readonly property string displayMode: "Phone" //"Desktop" //"Phone" //"Tablet"

    width: switch(displayMode){
           case "Phone":
               units.gu(50)
               break
           case"Tablet":
               units.gu(100)
               break
           case "Desktop":
               units.gu(120)
               break
           default:
               units.gu(120)
               break
           }
    height: switch(displayMode){
            case "Phone":
                units.gu(89)
                break
            case"Tablet":
                units.gu(56)
                break
            case "Desktop":
                units.gu(68)
                break
            default:
                units.gu(68)
                break
            }

    anchorToKeyboard: true
    theme.name: tempSettings.currentTheme

    property string current_version: "0.70"
    property alias mainPage: mainPageLoader.item
    property alias addBottomEdge: addBottomEdge
    property alias listModels: listModels


    Component.onCompleted: {
        /*Meta data processing*/
        var currentDataBaseVersion = DataProcess.checkUserVersion()

        if(currentDataBaseVersion === 0){
            DataProcess.createInitialData()
        }


        DataProcess.databaseUpgrade(currentDataBaseVersion)
        listModels.modelCategories.getItems()
        mainPageLoader.active = true
    }

    Item{
        id: tempSettings
        property string currentTheme: "Ubuntu.Components.Themes.Ambiance"
        property string currentCurrency: "PHP"
        property string dashboardItems: "Today;Recent;This Week"
        property string dashboardItemsOrder: "Today;Yesterday;Recent;This Week;This Month;Last Week;Last Month"
        property bool startDashboard: true
        property int startingPageIndex: 1

        Settings {
            property alias currentTheme: tempSettings.currentTheme
            property alias currentCurrency: tempSettings.currentCurrency
            property alias dashboardItems: tempSettings.dashboardItems
            property alias dashboardItemsOrder: tempSettings.dashboardItemsOrder
            property alias startDashboard: tempSettings.startDashboard
            property alias startingPageIndex: tempSettings.startingPageIndex
        }

    }


//    ListView {
//        id: listView
//        anchors {
//            left: parent.left
//            right: parent.right
//            top: skipLabel.bottom
//            bottom: separator.top
//        }

//        model: []
//        snapMode: ListView.SnapOneItem
//        orientation: Qt.Horizontal
//        highlightMoveDuration: UbuntuAnimation.FastDuration
//        highlightRangeMode: ListView.StrictlyEnforceRange
//        highlightFollowsCurrentItem: true

//        delegate: Item {
//            width: listView.width
//            height: listView.height
//            clip: true

//        }
//    }

//    SplitView {
//            anchors.fill: parent
//            layouts: [
//                SplitViewLayout {
//                    when: main.width < units.gu(80)
//                    ViewColumn {
//                        fillWidth: true
//                    }
//                },
//                SplitViewLayout {
//                    when: main.width >= units.gu(80)
//                    ViewColumn {
//                        minimumWidth: units.gu(30)
//                        maximumWidth: units.gu(100)
//                        preferredWidth: units.gu(40)
//                    }
//                    ViewColumn {
//                        minimumWidth: units.gu(40)
//                        fillWidth: true
//                    }
//                }
//            ]
//        }

//    Layouts {
//        id: layouts
//        width: units.gu(40)
//        height: units.gu(40)
//        layouts: [
//            ConditionalLayout {
//                name: "flow"
//                when: layouts.width > units.gu(60)
//                Flow {
//                    anchors.fill: parent
//                    spacing: units.dp(3)
//                    flow: Flow.LeftToRight
//                    ItemLayout {
//                        item: "item1"
//                        width: units.gu(30)
//                        height: units.gu(20)
//                    }
//                    ItemLayout {
//                        item: "item2"
//                        width: units.gu(30)
//                        height: units.gu(20)
//                    }
//                    ItemLayout {
//                        item: "item3"
//                        width: units.gu(30)
//                        height: units.gu(20)
//                    }
//                }
//            }
//        ]
//        Column {
//            spacing: units.dp(2)
//            Button {
//                text: "Button #1"
//                Layouts.item: "item1"
//            }
//            Button {
//                text: "Button #2"
//                Layouts.item: "item2"
//            }
//            Button {
//                text: "Button #3"
//                Layouts.item: "item3"
//            }
//        }
//    }

    PopupDialog{
        id: popupDialog
    }

PageStack{
    id: mainPageStack

        Loader {
            id: mainPageLoader
            active: false
            asynchronous: true
            source: "ui/MainPage.qml"//"ui/Dashboard.qml"

            visible: status == Loader.Ready

            onLoaded: {
                mainPageStack.push(mainPageLoader.item)
                mainPage.detailView.applyLayoutChanges()
            }
        }

        Loader {
            id: addFullPageLoader

            property string mode: "add"
            property string itemID
            active: false
            asynchronous: true
            sourceComponent: addFullPageComponent

            visible: status == Loader.Ready

            onLoaded: {
                addBottomEdge.collapse()
                switch(mode){
                case "add":
                    addBottomEdge.collapse()
                    addFullPageLoader.item.mode = "add"
                    addFullPageLoader.item.type = "expense"
                    mainPageStack.push(addFullPageLoader.item)
                    break
                case "edit":
                    addBottomEdge.collapse()
                    addFullPageLoader.item.mode = "edit"
                    addFullPageLoader.item.type = "expense"
                    addFullPageLoader.item.itemID = itemID
                    mainPageStack.push(addFullPageLoader.item)
                    break
                }
            }
        }


            Component {
                id: addFullPageComponent
                AddFullPage {
                    id: addFullPage
                    onCancel: {
                        mainPageStack.pop()
                        //addFullPageLoader.active = false
                    }

                    onSaved: {
                        mainPageStack.pop()
                        //addFullPageLoader.active = false
                    }

                }
            }

            function addExpense(){
                addFullPageLoader.mode = "add"
                addFullPageLoader.active = true
                addFullPageLoader.item.mode = "add"
                addFullPageLoader.item.type = "expense"
                mainPageStack.push(addFullPageLoader.item)
            }

            function editExpense(expense_id){
                addFullPageLoader.mode = "edit"
                addFullPageLoader.itemID = expense_id
                addFullPageLoader.active = true
                addFullPageLoader.item.mode = "edit"
                addFullPageLoader.item.type = "expense"
                addFullPageLoader.item.itemID = expense_id
                mainPageStack.push(addFullPageLoader.item)
            }
}

//    Loader {
//        id: bottomEdgeLoader
////        active: false
//        asynchronous: true
//        source: "components/AddBottomEdge.qml"
//        visible: status == Loader.Ready
//    }


    AddBottomEdge{
        id: addBottomEdge
        onCommitCompleted: {
            visible = false
            enabled = false
            hint.visible = false
        }
//        onCollapseCompleted: {
//            visible = true
//            enabled = true
//            hint.visible = true
//        }

        //Component.onCompleted: QuickUtils.mouseAttached = true
    }

    ListModels{
        id: listModels
//        Component.onCompleted: {
//            modelCategories.getItems()
//        }
    }


}
