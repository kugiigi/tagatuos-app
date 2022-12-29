import QtQuick 2.9
import Lomiri.Components 1.3

ListItem {
    id: root

    //Public APIs
    property bool bindValue
    property bool checkboxValue: bindValue
    property alias titleText: listItemLayout.title
    property alias subText: listItemLayout.subtitle
    property alias checked: checkItem.checked

    width: parent.width

    ListItemLayout {
        id: listItemLayout

        CheckBox {
            id: checkItem
            SlotsLayout.position: SlotsLayout.Leading

            //workaround where binding to status gets lost when the checkbox is clicked
            Component.onCompleted: checkItem.checked = bindValue
            Connections {
                target: root
                onBindValueChanged: {
                    checkItem.checked = bindValue
                }
            }
            onClicked: {
                checkboxValue = !bindValue
            }
        }
    }
    onClicked: {
        checkboxValue = !bindValue
    }
}
