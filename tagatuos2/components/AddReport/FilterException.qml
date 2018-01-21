import QtQuick 2.4
import Ubuntu.Components 1.3
import "../../components/Common"

Column {
    id: root


    property alias title:  header.title
    property alias categories: categoryField.savedValue
    property alias nameField: nameField.text
    property alias categorySavedValue: categoryField.savedValue

    anchors {
        left: parent.left
        right: parent.right
    }

    ListItemSectionHeader {
        id: header
    }

    CategoryField{
        id: categoryField
    }

    NameField{
        id: nameField
        title: i18n.tr("Expense Name")
        placeholderText: i18n.tr("Enter Expense Name")
    }
}
