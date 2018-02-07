import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../AddFullPage"
import "../Common"
import "../../library/DataProcess.js" as DataProcess
import "../../library/ProcessFunc.js" as Process

Dialog {

    id: root

    property string mode
    property int quickID
    property string itemName
    property string itemDescr
    property string itemCategory
    property string itemValue

    signal saveQuickExpense
    signal addQuickExpense

    onSaveQuickExpense: {
        PopupUtils.close(root)
    }

    onAddQuickExpense: {
        PopupUtils.close(root)
    }

    title: i18n.tr("Quick Expense")

    onVisibleChanged: {
        if (visible) {
            if (root.mode === "edit" || root.mode === "custom") {
                categoryPopupItemSelector.selectedValue = root.itemCategory
                textName.text = root.itemName
                autoCompletePopover.show = false //Do not show autoCompletePopover
                textareaDescr.text = root.itemDescr
                valueTextField.text = root.itemValue !== "0" ? root.itemValue : ""
            }
        }
    }

    CategoryField {
        id: categoryPopupItemSelector

        popupParent: root

        visible: root.mode !== "custom"

        onConfirmSelection: {
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
        visible: root.mode !== "custom"
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

    ValueField {
        id: valueTextField
    }

    CommentsField {
        id: textareaDescr
    }
    Button {
        text: "OK"
        color: theme.palette.normal.positive


        action: Action{
            shortcut: valueTextField.focused ? StandardKey.InsertParagraphSeparator : undefined
            onTriggered: {
                /*Commits the OSK*/
                keyboard.target.commit()

                var intID = root.quickID
                var txtName = textName.text
                var txtDescr = textareaDescr.text
                var txtCategory = categoryPopupItemSelector.selectedValue
                var realValue = valueTextField.text
                realValue = realValue !== "" ? parseFloat(realValue) : 0

                if (Process.checkRequired(
                            [txtName]) === false) {
                    textName.forceActiveFocus()
                } else {
                    var quickExpense

                    switch(root.mode){
                    case "add":
                        quickExpense = DataProcess.saveQuickExpense(txtCategory,
                                                                       txtName,
                                                                       txtDescr,
                                                                       realValue)
                        mainView.listModels.addQuickItem(quickExpense)
                        console.log("Quick Expense Added:" + quickExpense.quickname)
                        root.saveQuickExpense()
                        break
                    case "edit":
                        quickExpense = DataProcess.updateQuickExpense(intID, txtCategory,
                                                                    txtName,
                                                                    txtDescr,
                                                                    realValue)
                        mainView.listModels.updateQuickItem(quickExpense)
                        root.saveQuickExpense()
                        break
                    case "custom":
                        root.itemDescr = txtDescr
                        root.itemValue = realValue
                        root.addQuickExpense()
                        break
                    }
                }
            }
        }
    }


    Button {
        text: "Cancel"
        action: Action{
            shortcut: "Esc"
            onTriggered: PopupUtils.close(root)
        }
    }
}
