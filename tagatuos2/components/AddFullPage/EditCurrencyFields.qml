import QtQuick 2.9
import Lomiri.Components 1.3
import "../../components/Common"

Column{
    id: editCurrencyColumn
    spacing: travelFields.spacing

    Row{
        id: currencyRow

        anchors{
            left: parent.left
            right: parent.right
        }

        PopupItemSelector{
            id: homeCurrencyPopupItemSelector

            titleText: i18n.tr("Home Currency")
            selectedValue: travelFields.homeCurrency
            popupParent: root
            model: mainView.listModels.modelCurrencies
            valueRolename: "currency_code"
            textRolename: "descr"
            divider.visible: false
            width: parent.width / 2

            onConfirmSelection: {
                travelFields.homeCurrency = selections
            }

            Component.onCompleted: {
                mainView.listModels.modelCurrencies.getItems()
            }
        }

        PopupItemSelector{
            id: travelCurrencyPopupItemSelector

            titleText: i18n.tr("Travel Currency")
            selectedValue: travelFields.travelCurrency
            popupParent: root
            model: mainView.listModels.modelCurrencies
            valueRolename: "currency_code"
            textRolename: "descr"
            divider.visible: false
            width: parent.width / 2

            onConfirmSelection: {
                travelFields.travelCurrency = selections
            }

            Component.onCompleted: {
                mainView.listModels.modelCurrencies.getItems()
            }
        }
    }

    TextField {
        id: rateTextField

        // this value is to avoid letter being cut off
        height: units.gu(4.3)
        width: parent.width <= units.gu(50) ? parent.width - units.gu(4) : parent.width * 0.5
        inputMethodHints: Qt.ImhDigitsOnly
        visible: travelFields.isEditMode

        anchors {
            left: parent.left
            leftMargin: units.gu(2)
        }

        placeholderText: "1.00"
//        validator: DoubleValidator {
//            decimals: tempSettings.currentCurrencyPrecision //2
//        }
        hasClearButton: true
        text: travelFields.rate

        primaryItem: Label {
            textSize : Label.Large
            text: tempSettings.currentCurrencySymbol
            color: theme.palette.normal.backgroundSecondaryText
        }

        secondaryItem: Label {
            text: "= 1 " + root.travelCurData.symbol

            color: theme.palette.normal.backgroundSecondaryText
        }

        onTextChanged: {
            if(text){
                travelFields.rate = parseFloat(text)
            }else{
                travelFields.rate = 0
            }
        }
    }
}
