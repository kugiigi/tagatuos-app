import QtQuick 2.9
import Ubuntu.Components 1.3
import "PopupItemSelector"

ListItem {
    id: root

    property alias popupParent: poppingDialog.parent
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

    width: parent.width
    height: units.gu(8)

    action: Action {
        onTriggered: {
            keyboard.target.hide()
            poppingDialog.show(root)
        }
    }

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

    PoppingDialog {
        id: poppingDialog

        explicitHeight: root.model.count <  8 ? units.gu(60) : 0
        explicitWidth: root.model.count <  8 ?units.gu(40) : 0
        fullscreen: root.forceFullscreen ? true : false
        delegate: itemSelectorComponent
    }

    Component {
        id: itemSelectorComponent

        ItemSelector {
            id: itemSelector
            model: root.model
            title: root.titleText
//            anchors.fill: parent

//            Component.onCompleted: itemSelector.initializeSelectedValues(root.selectedValue)
        }
    }

    Connections {
        id: keyboard
        target: Qt.inputMethod
    }
}
