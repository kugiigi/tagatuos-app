import QtQuick 2.4
import Ubuntu.Components 1.3
import "PopupItemSelector2"

Item {
    id: root

    property alias popupParent: poppingDialog.popupParent
//    property QtObject popupParent
    property bool forceFullscreen: false
    property bool multipleSelection: false
    property bool withOrdering: false
    property bool commitOnSelect: false
    property var model: []

    property string titleText
    property alias title: listItemLayout.title
    property alias subtitle: listItemLayout.subtitle
    property string selectedValue //separated by semicolon (;)
    property string iconName

    property string textRolename: "text"
    property string valueRolename: "value"


    signal confirmSelection(string selections, string selectionsOrder)

//    width: parent.width
    height: units.gu(8)


    onConfirmSelection: poppingDialog.close()

    function getDisplayValues() {
        var result = []
        var arrSelectedValues = root.selectedValue.split(";")

        for (var i = 0; i <= model.count - 1; i++) {

            if (arrSelectedValues.indexOf(model.get(i)[valueRolename]) > -1) {
                result.push(model.get(i)[textRolename])
            }
        }

        return result.join(", ")
    }



    PoppingDialog2 {
        id: poppingDialog

        explicitHeight: root.model.count <  8 ? units.gu(60) : 0
        explicitWidth: root.model.count <  8 ?units.gu(40) : 0
        fullscreen: root.forceFullscreen ? true : false
        delegate: itemSelectorComponent

        anchors.fill: parent

        ListItem {
            id: listItem

            height: units.gu(8)

            anchors{
                left: parent.left
                right: parent.right
                top: parent.top
            }

            action: Action {
                onTriggered: {
                    poppingDialog.show(root)
                }
            }

            ListItemLayout {
                id: listItemLayout

                title.text: root.titleText
                subtitle.text: root.getDisplayValues()

                Icon {
                    name: iconName
                    SlotsLayout.position: SlotsLayout.Leading
                    width: units.gu(3)
                    visible: iconName !== "" ? true : false
                }
            }
        }
    }

    Component {
        id: itemSelectorComponent

        ItemSelector2 {
            id: itemSelector
            model: root.model
            title: root.titleText
        }
    }
}
