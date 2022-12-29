import QtQuick 2.9
import Lomiri.Components 1.3
import "../Common"

Item {
    id: root

    property string category
    property string itemName
    property string description
    property string date
    property string value

    signal closed

    anchors.fill: parent

    Column {
        id: column

        spacing: units.gu(1)
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: units.gu(3)
        }

        DetailsDialogItem {
            id: nameItem
            label: i18n.tr("Name:")
            text: root.itemName
        }

        DetailsDialogItem {
            id: descriptionItem
            label: i18n.tr("Description:")
            text: root.description !== "" ? root.description : i18n.tr("<No Description>")
        }

        DetailsDialogItem {
            id: categoryItem
            label: i18n.tr("Category:")
            text: root.category
        }

        DetailsDialogItem {
            id: dateItem
            label: i18n.tr("Date:")
            text: root.date
        }

        DetailsDialogItem {
            id: valueItem
            label: i18n.tr("Value:")
            text: root.value
        }
    }

    Item{
        height: units.gu(5)
        anchors{
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        ActionButtonDelegate{

            anchors.fill: parent

            action: Action{
                iconName: "close"
                text: i18n.tr("Close")
                onTriggered: root.closed()
            }
        }
    }
}
