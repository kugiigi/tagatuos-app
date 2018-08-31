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
import "../library/Currencies.js" as Currencies

Page {
    id: root

    property string mode: "add"
    property string type: "expense"
    property string itemID
    property var itemData
    property var travelCurData
    property bool withTravelData: false
    property string elementWithFocus

    signal cancel
    signal saved

    header: PageHeader {
        visible: false
    }

    onVisibleChanged: {
        if (visible === true) {
            resetFields()
            mainView.addBottomEdge.hint.visible = mainView.showBottomEdgeHint
            mainView.addBottomEdge.hint.enabled = mainView.showBottomEdgeHint


            //loads data when in edit mode
            if (root.mode === "edit") {
                root.itemData = listModels.getExpenseDetails(root.itemID)
                categoryPopupItemSelector.selectedValue = root.itemData.category_name
                textName.text = root.itemData.name
                autoCompletePopover.show = false //Do not show autoCompletePopover
                textareaDescr.text = root.itemData.descr
                dateLabel.date = new Date(root.itemData.date)


                if(typeof root.itemData.travel !== 'undefined'){

                    var currency = Currencies.currency(root.itemData.travel.travel_currency)                    

                    root.travelCurData.symbol = currency.symbol
                    root.travelCurData.decimal = currency.decimal
                    root.travelCurData.thousand = currency.thousand
                    root.travelCurData.precision = currency.precision
                    root.travelCurData.format = currency.format

                    valueTextField.text = root.itemData.travel.value
                    valueTextField.homeValue = root.itemData.value

                    //should be last here
                    root.withTravelData = true
                }else{
                    valueTextField.text = root.itemData.value
                }
            }

            textName.forceFocus()

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

        categoryPopupItemSelector.selectedValue = categoryPopupItemSelector.model.get(0)[categoryPopupItemSelector.valueRolename]


        dateLabel.date = new Date()

        travelCurData = {}
        root.withTravelData = false
    }
    PageBackGround {
    }

    function resetFocus(){
        console.log("elementWithFocus: " + elementWithFocus)
        switch(elementWithFocus){
        case "Description":
            textName.forceFocus()
            break
        case "Value":
            valueTextField.forceFocus()
            break
        case "Comments":
            textareaDescr.forceFocus()
            break
        default:
            valueTextField.forceFocus()
            break
        }
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

            TravelFields{
                id: travelFields

                visible: if(root.mode === "edit"){
                             root.withTravelData ? true : false
                         }else{
                             tempSettings.travelMode ? true : false
                         }

                rate: root.withTravelData ? root.itemData.travel.rate : (tempSettings.travelMode ? tempSettings.exchangeRate : 0)
                homeCurrency: root.withTravelData ? root.itemData.travel.home_currency : (tempSettings.travelMode ? tempSettings.currentCurrency : "")
                travelCurrency: root.withTravelData ? root.itemData.travel.travel_currency : (tempSettings.travelMode ? tempSettings.travelCurrency : "")
            }


            CategoryField {
                id: categoryPopupItemSelector

                popupParent: root

                onConfirmSelection: {
                    if (textName.text === "") {
                        textName.forceFocus()
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

        height: units.gu(6)
        trailingActionBar {
            delegate: buttonComponent
            actions: [
                Action {

                    property color color: theme.palette.normal.background

                    //shortcut: "Ctrl+S"
                    shortcut: valueTextField.focused ? StandardKey.InsertParagraphSeparator : undefined
                    text: root.mode === "add" ? i18n.tr(
                                                    "Add") : i18n.tr("Update")
                    onTriggered: {

                        /*Commits the OSK*/
                        keyboard.target.commit()

                        var txtName = textName.text

                        if (Process.checkRequired(
                                    [txtName, valueTextField.text]) === false) {
                            textName.forceFocus()
                        } else {
                            var newExpense
                            var txtDescr = textareaDescr.text
                            var txtCategory = categoryPopupItemSelector.selectedValue
                            var today = new Date(Process.getToday())
                            var txtDate = Process.dateFormat(0, dateLabel.date)
                            var txtType = "Expense" //typeSection.selectedIndex === 0 ? "Expense" : "Debt"
                            var realValue
                            var realTravelValue

                            //Travel Data
                            var travelData

                            if(travelFields.visible){
                                var realRate = travelFields.rate
                                var txtHomeCur = travelFields.homeCurrency
                                var txtTravelCur = travelFields.travelCurrency

                                realTravelValue = parseFloat(valueTextField.text)
                                realValue = valueTextField.homeValue
//                                realValue = realTravelValue * realRate

                                travelData = {"rate": realRate, "homeCur": txtHomeCur, "travelCur": txtTravelCur, "value": realTravelValue}

                            }else{
                                realValue = parseFloat(valueTextField.text)
                            }

                            switch (mode) {
                            case "edit":
                                DataProcess.updateExpense(root.itemID,
                                                          txtCategory, txtName,
                                                          txtDescr, txtDate,
                                                          realValue, travelData)
                                var updatedItem = {
                                    expense_id: root.itemID,
                                    category_name: txtCategory,
                                    name: txtName,
                                    descr: txtDescr,
                                    date: txtDate,
                                    value: realValue,
                                    travel: travelData
                                }
                                mainView.listModels.updateItem(updatedItem)
                                break
                            case "add":
                                if (txtType === "Expense") {
                                    newExpense = DataProcess.saveExpense(
                                                txtCategory, txtName, txtDescr,
                                                txtDate, realValue, travelData)
                                    mainView.listModels.addItem(newExpense)
                                }
                                break
                            }

                            root.saved()
                        }
                    }
                },
                Action {
                    property color color: theme.palette.normal.background

                    text: i18n.tr("Add as Quick")
                    onTriggered: {
                        /*Commits the OSK*/
                        keyboard.target.commit()

                        var txtName = textName.text
                        var txtDescr = textareaDescr.text
                        var txtCategory = categoryPopupItemSelector.selectedValue
                        var realValue = parseFloat(valueTextField.text)

                        if (Process.checkRequired(
                                    [txtName, valueTextField.text]) === false) {
                            textName.forceFocus()
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
                property color color: theme.palette.normal.background

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
