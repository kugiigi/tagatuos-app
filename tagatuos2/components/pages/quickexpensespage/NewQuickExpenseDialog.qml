import QtQuick 2.12
import Lomiri.Components 1.3 as UT
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../../../common/dialogs" as Dialogs
import "../.." as Components
import "../../pages/newexpenseview" as NewExepenseView

Dialogs.DialogWithContents {
    id: newQuickExpenseDialog

    readonly property bool isAddMode: mode == "add"
    readonly property bool isEditMode: mode == "edit"

    property string mode: "add"
    property string currencySymbol
    property Components.ExpenseData expenseData

    signal proceed(string category, string name, string description, real value, string payeeName, string payeeLocation, string payeeOtherDescr)
    signal cancel

    preferredWidth: parent.width
    maximumWidth: Suru.units.gu(60)
    bottomMargin: 0
    anchorToKeyboard: true
    destroyOnClose: true
    title: isAddMode ? i18n.tr("New Quick Expense") : i18n.tr("Edit Quick Expense")

    onAboutToShow: {
        if (isEditMode) {
            nameField.text = expenseData.name
            descriptionField.text = expenseData.description
            valueField.text = expenseData.value
            categoryField.setCategory(expenseData.category)
            payeeFields.payeeName = expenseData.payeeName
            payeeFields.payeeLocation = expenseData.payeeLocation
            payeeFields.payeeOtherDescr = expenseData.payeeOtherDescription
        }
    }

    onCancel: close()

    CategoryField {
        id: categoryField

        Layout.fillWidth: true
        flickable: newQuickExpenseDialog.flickable
    }

    NameField {
        id: nameField

        Layout.fillWidth: true
        flickable: newQuickExpenseDialog.flickable
    }

    ValueField {
        id: valueField

        Layout.fillWidth: true
        currencySymbol: newQuickExpenseDialog.currencySymbol
        flickable: newQuickExpenseDialog.flickable
    }

    DescriptionField {
        id: descriptionField

        Layout.fillWidth: true
        flickable: newQuickExpenseDialog.flickable
    }

    NewExepenseView.PayeeFields {
        id: payeeFields

        Layout.fillWidth: true
        flickable: newQuickExpenseDialog.flickable
        useCustomBackground: false
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Suru.units.gu(2)

        UT.Button {
            Layout.fillWidth: true
            text: i18n.tr("Save")
            enabled: nameField.text.trim() !== ""
                        && (
                                (newQuickExpenseDialog.isEditMode
                                                && (newQuickExpenseDialog.expenseData.name !== nameField.text
                                                  || newQuickExpenseDialog.expenseData.description !== descriptionField.text
                                                  || newQuickExpenseDialog.expenseData.value != valueField.text
                                                  || newQuickExpenseDialog.expenseData.category !== categoryField.category
                                                  || newQuickExpenseDialog.expenseData.payeeName !== payeeFields.payeeName
                                                  || newQuickExpenseDialog.expenseData.payeeLocation !== payeeFields.payeeLocation
                                                  || newQuickExpenseDialog.expenseData.payeeOtherDescription !== payeeFields.payeeOtherDescr)
                                )
                            || !newQuickExpenseDialog.isEditMode
                           )
            color: mainView.uitkColors.normal.positive

            onClicked: {
                mainView.keyboard.commit()
                let _value = valueField.text.trim() !== "" ? valueField.text : 0
                newQuickExpenseDialog.proceed(categoryField.category, nameField.text, descriptionField.text, _value
                                                , payeeFields.payeeName, payeeFields.payeeLocation, payeeFields.payeeOtherDescr)
            }
        }

        UT.Button {
            Layout.fillWidth: true
            enabled: visible
            text: i18n.tr("Cancel")
            color: Suru.neutralColor

            onClicked: newQuickExpenseDialog.cancel()
        }
    }
}

