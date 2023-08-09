import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Suru 2.2
import Lomiri.Components 1.3 as UT


Menu {
    id: contextMenu
    
    property alias actions: instantiator.model
    property var listView
    property var itemProperties

    bottomPadding: 0

    onClosed: {
        if (listView) {
            listView.currentIndex = -1
        }
    }
    
    function popupMenu(parentItem, mouseX, mouseY, properties) {
        itemProperties = properties
        contextMenu.popup(parentItem, mouseX, mouseY)
    }

    Instantiator {
        id: instantiator
        
        delegate: Loader {
            sourceComponent: modelData.separator ? separatorComponent : menuItemComponent
            
            Component {
                id: separatorComponent
                MenuSeparator{
                    topPadding: Suru.units.gu(1)
                    bottomPadding: Suru.units.gu(1)
                }
            }
            
            Component {
                id: menuItemComponent
        
                MenuItem {
                    text: modelData ? modelData.text : ""
                    onTriggered: {
                        contextMenu.close()
                        modelData.trigger(false)
                    }
                    height: 45
                    indicator: UT.Icon {
                         id: iconMenu
                         
                         implicitWidth: name ? 20 : 0
                         implicitHeight: implicitWidth
                         anchors.left: parent.left
                         anchors.leftMargin: 10
                         anchors.verticalCenter: parent.verticalCenter
                         name: modelData ? modelData.iconName : ""
                         color: theme.palette.normal.baseText
                     }
                     leftPadding: iconMenu.implicitWidth + (iconMenu.anchors.leftMargin * 2)
                }
            }
        }

        onObjectAdded: contextMenu.insertItem(index, object)
        onObjectRemoved: contextMenu.removeItem(object)
    }
}
