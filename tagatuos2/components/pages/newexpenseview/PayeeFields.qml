import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../.." as Components
import "../../../common" as Common
import "../../../common/menus" as Menus
import "../../../common/listitems" as ListItems
import "../../../library/functions.js" as Functions

ColumnLayout {
    id: payeeFields

    property Common.BaseFlickable flickable
    readonly property bool highlighted: activeFocus
    readonly property bool isFocused: payeeNameField.isFocused || locationTextField.isFocused || otherDescrTextField.isFocused
    readonly property bool autoCompleteShown: payeeNameField.autoCompleteShown || locationTextField.autoCompleteShown || otherDescrTextField.autoCompleteShown

    property alias payeeName: payeeNameField.text
    property alias payeeLocation: locationTextField.text
    property alias payeeOtherDescr: otherDescrTextField.text
    property bool useCustomBackground: true

    readonly property bool payeeIsValid: payeeName.trim() !== ""

    function clear() {
        payeeNameField.text =""
        locationTextField.text =""
        otherDescrTextField.text =""
    }

    Common.TextFieldWithAutoComplete {
        id: payeeNameField

        readonly property bool hasValue: text.trim() !== ""

        Layout.fillWidth: true

        flickable: payeeFields.flickable
        model: mainView.mainModels.searchExpensePayeesModel
        propertyName: "payeeName"
        overrideCommit: true
        placeholderText: i18n.tr("Enter payee or store name")
        iconName: "contact-group"
        useCustomBackground: payeeFields.useCustomBackground
        delegate: PayeeFieldAutoCompleteDelegate {}
        searchFunction: function() {
            model.mode = "payeeName"
            model.payeeName = ""
            model.payeeLocation = ""
        }

        onCommit: {
            if (data) {
                text = data.payeeName
                locationTextField.text = data.payeeLocation
                otherDescrTextField.text = data.payeeOtherDescr
            }
        }
    }

    Common.TextFieldWithAutoComplete {
        id: locationTextField

        Layout.fillWidth: true
        Layout.leftMargin: Suru.units.gu(2)

        flickable: payeeFields.flickable
        model: mainView.mainModels.searchExpensePayeesModel
        propertyName: "payeeLocation"
        overrideCommit: true
        visible: payeeNameField.hasValue
        placeholderText: i18n.tr("Add location")
        iconName: "location"
        useCustomBackground: payeeFields.useCustomBackground
        delegate: PayeeFieldAutoCompleteDelegate {}
        searchFunction: function() {
            model.mode = "location"
            model.payeeName = payeeNameField.text
            model.payeeLocation = ""
        }

        onCommit: {
            if (data) {
                text = data.payeeLocation
                otherDescrTextField.text = data.payeeOtherDescr
            }
        }
    }

    Common.TextFieldWithAutoComplete {
        id: otherDescrTextField

        Layout.fillWidth: true
        Layout.leftMargin: Suru.units.gu(2)

        flickable: payeeFields.flickable
        model: mainView.mainModels.searchExpensePayeesModel
        propertyName: "payeeOtherDescr"
        overrideCommit: true
        visible: payeeNameField.hasValue
        placeholderText: i18n.tr("Add description")
        iconName: "note"
        useCustomBackground: payeeFields.useCustomBackground
        delegate: PayeeFieldAutoCompleteDelegate {}
        searchFunction: function() {
            model.mode = "otherDescr"
            model.payeeName = payeeNameField.text
            model.payeeLocation = locationTextField.text
        }

        onCommit: {
            if (data) {
                text = data.payeeOtherDescr
            }
        }
    }
}
