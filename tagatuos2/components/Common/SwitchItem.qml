import QtQuick 2.4
import Ubuntu.Components 1.3

ListItem {
    id: root

    //Public APIs
    property bool bindValue
    property bool switchValue: bindValue
    property alias titleText: listItemLayout.title
    property alias subText: listItemLayout.subtitle

    width: parent.width

    ListItemLayout {
        id: listItemLayout

        Switch {
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
                switchValue = !bindValue
            }
        }
    }
    onClicked: {
        switchValue = !bindValue
    }
}
