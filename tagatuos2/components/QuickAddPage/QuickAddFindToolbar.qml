import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../Common"

Toolbar {
    id: toolBar

    height: units.gu(6)

    visible: bottomBarNavigation.currentIndex <= 1 ? true : false

    anchors {
        left: parent.left
        right: parent.right
        bottom: parent.top
    }

    //Force focus on the textfield when it has contents
    function forceFocus(){
        if(findField.text !== ""){
            findField.forceActiveFocus()
        }
    }


    trailingActionBar {
        z:1

        actions: Action {
            id: addAction

            property color color: theme.palette.normal.foreground

            visible: bottomBarNavigation.currentIndex == 1
            shortcut: "Ctrl+A"
            //            text: i18n.tr("Add")
            iconName: "add"
            onTriggered: {
                PopupUtils.open(addDialog, null, {mode: "add"})
            }
        }
        delegate: ActionButtonDelegate{
            activeFocusOnPress: false
        }
    }


    Rectangle {
//        z: -1
        anchors.fill: parent
        color: theme.palette.normal.foreground
    }

    TextField {
        id: findField

        // Disable predictive text
        inputMethodHints: Qt.ImhNoPredictiveText


        placeholderText: bottomBarNavigation.currentIndex == 1 ?  i18n.tr("Find") + "..." : i18n.tr("Search History") + "..."

        anchors {
            left: parent.left
            leftMargin: units.gu(1)

            //WORKAROUND: Width of trailingActionBar is incorrect in Xenial
//            right: toolBar.trailingActionBar.left
//            rightMargin: units.gu(1)
            right: parent.right
            rightMargin: bottomBarNavigation.currentIndex === 1 ? units.gu(7) : units.gu(1)
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

        Connections{
            id: bottomNavigationConnection

            target: bottomBarNavigation

            onCurrentIndexChanged: findField.text = ""
        }
    }
}
