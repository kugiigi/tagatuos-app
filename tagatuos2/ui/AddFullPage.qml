import QtQuick 2.4
import Ubuntu.Components 1.3
//import Ubuntu.Components.Themes.Ambiance 1.3
import Ubuntu.Components.ListItems 1.0 as ListItemOld
import Ubuntu.Components.Popups 1.3
//import Ubuntu.Components.Pickers 1.3
import "../library/DataProcess.js" as DataProcess
import "../components"
import "../components/Common"
import "../components/AddFullPage"
import "../library"
import "../library/ProcessFunc.js" as Process

Page {
    id: root

    property string mode: "add"
    property string type: "expense"
    property string itemID
    property var itemData

    signal cancel
    signal saved

    header: PageHeader {
        visible: false
    }

    // onActiveChanged: {
    onVisibleChanged: {
        if (visible === true) {
            resetFields()
            mainView.addBottomEdge.hint.visible = false
            mainView.addBottomEdge.hint.enabled = false
            //            if (mainView.listModels.modelCategories.count === 0) {
            //                mainView.listModels.modelCategories.getItems()
            //            }

            //            categoryItemSelector.selectedIndex
            //                    = 1 //workaround for the issue on incorrect tem shown in the selector
            //            categoryItemSelector.selectedIndex = 0

            //loads data when in edit mode
            if (root.mode === "edit") {
                root.itemData = listModels.getExpenseDetails(root.itemID)

                //                categoryItemSelector.selectSpecific(root.itemData.category_name)
                categoryExpandable.savedValue = root.itemData.category_name
                textName.text = root.itemData.name
                autoCompletePopover.show = false //Do not show autoCompletePopover
                textareaDescr.text = root.itemData.descr
                dateLabel.date = new Date(root.itemData.date)
                valueTextField.text = root.itemData.value
            }

            textName.forceActiveFocus()

            //btnCancel.action.shortcut = "Esc"
            toolBar.leadingActionBar.actions[0].shortcut = "Esc"
        } else {
            mainView.addBottomEdge.hint.visible = true
            mainView.addBottomEdge.hint.enabled = true
            toolBar.leadingActionBar.actions[0].shortcut = undefined
        }
    }


    /********************Functions*******************/
    function resetFields() {
        textName.text = ""
        textareaDescr.text = ""
        valueTextField.text = ""
        //            categoryItemSelector.selectedIndex
        //                    = 1 //workaround for the issue on incorrect tem shown in the selector
        //            categoryItemSelector.selectedIndex = 0
        categoryExpandable.selectedIndex = 0
        categoryExpandable.savedValue = categoryExpandable.model.get(
                    0).category_name
        categoryExpandable.expansion.expanded = false
        dateLabel.date = new Date()
    }
    PageBackGround {
    }


    //    Connections{
    //        id: categoriesModel
    //        target: listModels.modelCategories
    //        onLoadingStatusChanged:{
    //            if(target.loadingStatus === "Ready"){
    //                if(root.mode === "edit"){
    //                    categoryItemSelector.selectSpecific(root.itemData.category_name)
    //                }
    //            }
    //        }
    //    }
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
            //bottomMargin: units.gu(2)
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

            CategoryField {
                id: categoryExpandable

                onToggle: {
                    if (textName.text === "") {
                        textName.forceActiveFocus()
                    } else {
                        if (valueTextField.text === "") {
                            valueTextField.forceActiveFocus()
                        }
                    }
                }
            }

            DescriptionField {
                id: textName
            }

            DateField {
                id: dateLabel
            }

            ValueField {
                id: valueTextField
            }

            CommentsField {
                id: textareaDescr
            }
        }
    }

    ListViewPopover {
        id: autoCompletePopover

        model: mainView.listModels.modelExpenseAutoComplete

        width: textName.width
        x: textName.x
        y: (textName.y + textName.height + units.gu(2))

        onItemSelected: {
            textName.text = name
            console.log(name + " - " + value)
            valueTextField.text = value
            show = false
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

        //height: units.gu(3)
        trailingActionBar {
            delegate: buttonComponent
            actions: [
                Action {
                    //shortcut: "Ctrl+S"
                    text: root.mode === "add" ? i18n.tr(
                                                    "Add") : i18n.tr("Update")
                    onTriggered: {

                        /*Commits the OSK*/
                        keyboard.target.commit()

                        var txtName = textName.text
                        var txtDescr = textareaDescr.text
                        var txtCategory = categoryExpandable.savedValue /*categoryItemSelector.model.get(
                                                        categoryItemSelector.selectedIndex).category_name*/
                        var today = new Date(Process.getToday())
                        var txtDate = Process.dateFormat(0, dateLabel.date)
                        var realValue = parseFloat(valueTextField.text)
                        var txtType = "Expense" //typeSection.selectedIndex === 0 ? "Expense" : "Debt"

                        if (Process.checkRequired(
                                    [txtName, valueTextField.text]) === false) {
                            textName.forceActiveFocus()
                        } else {
                            var newExpense
                            switch (mode) {
                            case "edit":
                                DataProcess.updateExpense(root.itemID,
                                                          txtCategory, txtName,
                                                          txtDescr, txtDate,
                                                          realValue)
                                var updatedItem = {
                                    expense_id: root.itemID,
                                    category_name: txtCategory,
                                    name: txtName,
                                    descr: txtDescr,
                                    date: txtDate,
                                    value: realValue
                                }
                                mainView.listModels.updateItem(updatedItem)
                                break
                            case "add":
                                if (txtType === "Expense") {
                                    newExpense = DataProcess.saveExpense(
                                                txtCategory, txtName, txtDescr,
                                                txtDate, realValue)
                                    mainView.listModels.addItem(newExpense)
                                }
                                break
                            }

                            root.saved()
                        }
                    }
                },
                Action {
                    text: i18n.tr("Add as Quick")
                    onTriggered: {
                        /*Commits the OSK*/
                        keyboard.target.commit()

                        var txtName = textName.text
                        var txtDescr = textareaDescr.text
                        var txtCategory = categoryExpandable.savedValue
                        var realValue = parseFloat(valueTextField.text)

                        if (Process.checkRequired(
                                    [txtName, valueTextField.text]) === false) {
                            textName.forceActiveFocus()
                        } else {
                            var newQuickExpense

                            newQuickExpense = DataProcess.saveQuickExpense(txtCategory, txtName, txtDescr,
                                                         realValue)
                            mainView.listModels.addQuickItem(newQuickExpense)
                            PopupUtils.open(quickAddConfirmDialog)
                        }
                    }
                }
            ]
        }
        leadingActionBar {
            delegate: buttonComponent
            actions: Action {
                //shortcut: "Esc"
                text: i18n.tr("Cancel")
                onTriggered: {
                    root.cancel()
                }
            }
        }

        //        Sections {
        //            id: typeSection
        //            anchors.centerIn: parent

        //            model: [i18n.tr("Expense"), i18n.tr("Debt")]
        //        }
    }

    Component {
        id: quickAddConfirmDialog
        Dialog {
            id: dialog

            text: i18n.tr("Quick expense successfully added!")

            Button {
                text: "OK"
                onClicked: {
                    PopupUtils.close(dialog)
                }
            }


        }
    }

    Connections {
        id: keyboard
        target: Qt.inputMethod
    }
}
