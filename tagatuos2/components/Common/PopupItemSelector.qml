import QtQuick 2.4
import Ubuntu.Components 1.3
import "PopupItemSelector"

ListItem {
    id: root

    property alias popupParent: poppingDialog.parent
    property bool forceFullscreen: false
    property bool multipleSelection: false
    property bool withOrdering: false
    property var model

    property string titleText
    property string selectedValue //separated by semicolon (;)
    property string iconName


    signal confirmSelection(string selections, string selectionsOrder)

    width: parent.width
    height: units.gu(8)

    action: Action {
        onTriggered: {
            poppingDialog.show(root)
        }
    }

    function getDisplayValues() {
        var result = []
        var arrSelectedValues = root.selectedValue.split(";")

        for (var i = 0; i <= model.count - 1; i++) {

            if (arrSelectedValues.indexOf(model.get(i)["value"]) > -1) {
                result.push(model.get(i)["text"])
            }
        }

        return result.join(", ")
    }



    ListItemLayout {
        id: listItemLayout

        title.text: root.titleText
        subtitle.text: root.getDisplayValues()//root.selectedValue

        Icon {
            name: iconName
            SlotsLayout.position: SlotsLayout.Leading
            width: units.gu(3)
            visible: iconName !== "" ? true : false
        }
    }

    PoppingDialog {
        id: poppingDialog

        explicitHeight: root.model.count <  8 ? units.gu(60) : null
        explicitWidth: root.model.count <  8 ?units.gu(40) : null
        fullscreen: root.forceFullscreen ? true : false
        delegate: itemSelectorComponent
    }

    Component {
        id: itemSelectorComponent

        ItemSelector {
            id: itemSelector
            model: root.model
            title: root.titleText

            Connections{
                id: poppingDialogConnection

                target: poppingDialog

                onOpened:{
                    itemSelector.initializeSelectedValues(root.selectedValue)
                }
            }

        }
    }
}
