import QtQuick 2.4
import Ubuntu.Components 1.3
import "PopupItemSelector"

ListItem {
    id: root

    property alias popupParent: poppingDialog.parent
    property bool forceFullscreen: false
    property bool multipleSelect: false
    property bool withOrdering: true
    property var model

    //Public APIs
    property string titleText
    property string subText
    property string iconName

    width: parent.width

    action: Action {
        onTriggered: {
            poppingDialog.show(root)
        }
    }

    ListItemLayout {
        id: listItemLayout

        title.text: root.titleText
        subtitle.text: root.subText

        Icon {
            name: iconName
            SlotsLayout.position: SlotsLayout.Leading
            width: units.gu(3)
            visible: iconName !== "" ? true : false
        }
    }

    PoppingDialog {
        id: poppingDialog

        explicitHeight: units.gu(60)
        explicitWidth: units.gu(40)
        fullscreen: root.forceFullscreen ? true : false
        delegate: itemSelectorComponent

        onClosed: {
              console.log(returnValue)
            root.subText = "listView.ViewItems.selectedIndices"
        }

    }

    Component {
        id: itemSelectorComponent

        ItemSelector {
            id: itemSelector
            model: root.model
            title: root.titleText

        }
    }
}
