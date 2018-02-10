import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes.Ambiance 1.3
import Ubuntu.Components.Popups 1.3
//import Ubuntu.Components.Pickers 1.3
import "../library/DataProcess.js" as DataProcess
import "../components"
import "../components/BaseComponents"
import "../components/Common"
import "../components/AddCategory"
import "../library"
import "../library/ProcessFunc.js" as Process

Page {
    id: root

    property string mode
    property string category_name
    property string description
    property color categoryColor: "white"

    signal cancel
    signal saved

    header: BaseHeader {
        title: root.mode === "add" ? i18n.tr(
                                         "Add New Category") : i18n.tr(
                                         "Edit Category - " + category_name)
        flickable: flickDialog

    }

    onActiveChanged: {
        if (active === true) {
            if (mainView.listModels.modelCategories.count === 0) {
                mainView.listModels.modelCategories.getCategories()
            }

            mainView.listModels.modelCategories.isListOnly = false
            textName.forceActiveFocus()

            //loads data when in edit mode
            if (mode === "edit") {
                textName.text = category_name
                textareaDescr.text = description
            }
        }
    }

    PageBackGround {
        id: pageBackground
        size: "Medium"
    }

    Flickable {
        id: flickDialog
        boundsBehavior: Flickable.DragAndOvershootBounds
        contentHeight: columnContent.height + units.gu(1)
        interactive: true

        anchors {
            left: parent.left
            right: parent.right
            bottom: toolBar.top
            top: parent.top
            topMargin: units.gu(2)
            bottomMargin: units.gu(2)
        }

        flickableDirection: Flickable.VerticalFlick
        clip: true
        Column {
            id: columnContent

            spacing: units.gu(2)
            anchors {
                left: parent.left
                right: parent.right
            }


            NameField{
                id: textName
            }

            DescriptionField{
                id: textareaDescr
            }

            ColorField{
                id: colorPicker
            }
        }
    }

    Component {
        id: buttonComponent
        ActionButtonDelegate {
        }
    }

    Toolbar {
        id: toolBar

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        trailingActionBar {
            delegate: buttonComponent
            actions: Action {
                property color color: theme.palette.normal.background

                shortcut: "Ctrl+S"
                text: root.mode === "add" ? i18n.tr(
                                                "Add") : i18n.tr("Save")
                onTriggered: {

                    /*Commits the OSK*/
                    keyboard.target.commit()


                    var txtName = textName.text
                    var txtDescr = textareaDescr.text
                    var txtIcon = ""
                    var txtColor = colorPicker.color;

                    if (Process.checkRequired([txtName]) === false) {
                        textName.forceActiveFocus()
                    } else if (txtName !== category_name
                               && DataProcess.categoryExist(txtName) === true) {
                        PopupUtils.open(dialog)
                    } else {
                        switch (mode) {
                        case "edit":
                            DataProcess.updateCategory(category_name, txtName,
                                                       txtDescr, txtIcon, txtColor)
                            break
                        case "add":
                            DataProcess.saveCategory(txtName, txtDescr, txtIcon, txtColor)
                            break
                        }

                        listModels.modelCategories.getItems()
                        //checkEmpty()
                        root.saved()
                    }
                }
            }
        }
        leadingActionBar {
            delegate: buttonComponent
            actions: Action {
                property color color: theme.palette.normal.background

                shortcut: "Esc"
                text: i18n.tr("Cancel")
                onTriggered: {
                    root.cancel()
                }
            }
        }
    }
    Component {
        id: dialog
        Dialog {
            id: dialogue
            title: i18n.tr("Category already exists!")
            text: i18n.tr("That category already exists. Please choose a different name.")
            Button {
                text: "OK"
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }
    Connections {
        id: keyboard
        target: Qt.inputMethod
    }
}
