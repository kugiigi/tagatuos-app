import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: root

    property string category
    property string itemName
    property string description
    property string date
    property string value

    height: column.height + units.gu(3)//childrenRect.height + units.gu(3)

//    anchors {
//        left: parent!== null ? parent.left : undefined
//        right: parent!== null ? parent.right : undefined
//    }

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
}
