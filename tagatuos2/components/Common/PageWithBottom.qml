import QtQuick 2.4
import Ubuntu.Components 1.3

Page {
    id: root

    property list<RadialAction> actions
    property bool enableBottom
    property string bottomMode
    property int leadingActionsCount: root.header.leadingActionBar.actions.length

    onLeadingActionsCountChanged: {
        if(root.enableBottom){
            loadModel()
        }
    }

    function loadModel() {

        listModel.clear()

        var leadingActionBarActions = root.header.leadingActionBar.actions

        if (leadingActionsCount > 0) {
            for (var i = 0; i < leadingActionBarActions.length; i++) {

                if (leadingActionBarActions[i].visible
                        && leadingActionBarActions[i].iconName === "back") {
                    listModel.append({
                                         action: leadingActionBarActions[i]
                                     })
                }
            }
        }

        if(bottomMenuLoader.item !== null){
            bottomMenuLoader.item.leadingActions = listModel
        }
    }

    ListModel {
        id: listModel
    }

    Loader {
        id: bottomMenuLoader
        active: root.enableBottom
        anchors.fill: parent
        z: 100
        sourceComponent: bottomMenuComponent
        asynchronous: true
        visible: status == Loader.Ready

        onLoaded: {
            bottomMenuLoader.item.leadingActions = listModel
        }
    }

    Component {
        id: bottomMenuComponent
        RadialBottomEdge {
            id: radialBottomMenu
            hintColor: "#513838"
            hintIconColor: "white"
            bgColor: "black"
            bgOpacity: 0.3
            actionButtonDistance: units.gu(10)
            visible: keyboard.target.visible ? false : true
            actions: root.actions
            mode: root.bottomMode //settingsTab.radialBottomMenu
            semiHideOpacity: 30
            timeoutSeconds: 2
            //leadingActions: listModel
        }
    }

    Connections {
        id: keyboard
        target: Qt.inputMethod
    }
}
