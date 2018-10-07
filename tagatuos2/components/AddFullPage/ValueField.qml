import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes.Ambiance 1.3
import Ubuntu.Keyboard 0.1
import "../../library/ApplicationFunctions.js" as AppFunctions

Column {
    id: column

    property alias text: valueTextField.text
    property alias homeValue: travelValue.homeValue
    property bool focused: valueTextField.activeFocus
    property bool shortcutInOSK: true

    spacing: units.gu(1)

    anchors {
        left: parent.left
        leftMargin: units.gu(2)
        right: parent.right
        rightMargin: units.gu(2)
    }

    function forceFocus(){
        valueTextField.forceActiveFocus()
    }

    Label {
        id: valueLabel
        text: i18n.tr("Value")
        font.weight: Text.Normal
        color: theme.palette.normal.foregroundText
        anchors {
            left: parent.left
            right: parent.right
        }
    }

    TextField {
        id: valueTextField

        property string enterKeyLabel: switch (root.mode) {
                                       case "add":
                                           i18n.tr("Add")
                                           break
                                       case "edit":
                                           i18n.tr("Save")
                                           break
                                       case "custom":
                                           i18n.tr("Add")
                                           break
                                       default:
                                           ""
                                           break
                                       }

        // this value is to avoid letter being cut off
        height: units.gu(4.3)
        width: parent.width <= units.gu(50) ? parent.width : parent.width * 0.5
        horizontalAlignment: TextInput.AlignRight
        inputMethodHints: Qt.ImhDigitsOnly


        InputMethod.extensions: shortcutInOSK ? {
                                                    enterKeyText: i18n.dtr(
                                                                      "tagatuos-app",
                                                                      enterKeyLabel)
                                                } : {}
        anchors {
            left: parent.left
        }

        primaryItem: Label {
            textSize : Label.Large
//            text: root.withTravelData ? (typeof root.travelCurData.symbol !== 'undefined' ? root.travelCurData.symbol : "") : (tempSettings.travelMode ? tempSettings.travelCurrencySymbol : tempSettings.currentCurrencySymbol)
            text: if(root.mode === "edit"){
                      root.withTravelData ? (typeof root.travelCurData.symbol !== 'undefined' ? root.travelCurData.symbol : "") : tempSettings.currentCurrencySymbol
                  }else{
                      tempSettings.travelMode ? tempSettings.travelCurrencySymbol : tempSettings.currentCurrencySymbol
                  }
            color: theme.palette.normal.backgroundSecondaryText
        }

        placeholderText: "0.00"
        //    validator: DoubleValidator {
        //        decimals: root.travelCurData ? root.travelCurData.precision : (tempSettings.travelMode ? tempSettings.travelCurrencyPrecision : tempSettings.currentCurrencyPrecision)
        //    }
        hasClearButton: true

        onTextChanged: {
            if(travelValue.visible){
                if(typeof travelFields !== "undefined"){
                    travelValue.homeValue = text !== "" ? parseFloat(text) * travelFields.rate : "0.00"
                }else{
                    travelValue.homeValue = text !== "" ? parseFloat(text) * tempSettings.exchangeRate : "0.00"
                }
            }
        }

        onActiveFocusChanged: {
            if(activeFocus && typeof root.elementWithFocus !== "undefined"){
                root.elementWithFocus = "Value"
            }
        }
    }

    Label {
        id: travelValue

        property real homeValue

        visible: typeof travelFields !== "undefined" ? travelFields.visible : (tempSettings.travelMode ? true: visible)
        text: "= " + AppFunctions.formatMoney(homeValue)
        font.weight: Text.Normal
        color: theme.palette.normal.backgroundTertiaryText
        horizontalAlignment: TextInput.AlignRight
        anchors {
            //        left: parent.left
            right: parent.right
            rightMargin: units.gu(2)
        }
    }
}
