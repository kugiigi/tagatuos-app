import QtQuick 2.9
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import QtQuick.Layouts 1.3
import "../Common"


Rectangle {
    id: toolBar

	height: units.gu(6)
        
    color: theme.palette.normal.foreground
    
    visible: bottomBarNavigation.currentIndex <= 1 ? true : false
    
    anchors {
        left: parent.left
        right: parent.right
        bottom: parent.top
    }
    
    //Force focus on the textfield when it has contents
    function forceFocus(){
        if(findField.text !== "" && keyboard.target.visible){
            findField.forceActiveFocus()
        }
    }

    RowLayout {
        
        anchors.fill: parent

        TextField {
            id: findField
            
            Layout.fillWidth: true
            Layout.leftMargin: units.gu(1)
            Layout.rightMargin: bottomBarNavigation.currentIndex === 1 ? 0 : units.gu(1)
            

            // Disable predictive text
            inputMethodHints: Qt.ImhNoPredictiveText


            placeholderText: bottomBarNavigation.currentIndex == 1 ?  i18n.tr("Find") + "..." : i18n.tr("Search History") + "..."

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
        
        ActionButtonDelegate {
            
            Layout.rightMargin: units.gu(1) 
            Layout.fillHeight: true
            
            activeFocusOnPress: false
            
            action: Action {
                id: addAction

                property color color: theme.palette.normal.foreground

                visible: bottomBarNavigation.currentIndex == 1
                shortcut: "Ctrl+A"
                iconName: "add"
                onTriggered: {
                    PopupUtils.open(addDialog, null, {mode: "add"})
                }
            }
        }
    }
}
