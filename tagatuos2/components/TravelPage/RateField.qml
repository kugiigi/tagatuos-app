import QtQuick 2.9
import Lomiri.Components 1.3
import Lomiri.Components.Themes.Ambiance 1.3
import Lomiri.Keyboard 0.1
import "../../components/Common"
import "../../library/ProcessFunc.js" as Process

Column {
    id: rateField

    signal dataFetched(bool status)

    property alias text: valueTextField.text
    property bool focused: valueTextField.activeFocus
    property bool isLoading: false
    property bool isUpdated: Process.isToday(tempSettings.exchangeRateDate) ? true : false

    function updateRate(forceUpdate) {
        console.log("updateRate")
        if(!isLoading){
            var ratesData = mainView.listModels.modelExchangeRates.data
            if(ratesData && !forceUpdate){
                var base = tempSettings.travelCurrency
                var destination = tempSettings.currentCurrency

                valueTextField.text = (1 / ratesData.rates[base]) * ratesData.rates[destination];
//                valueTextField.enabled = false
                dataFetched(true)
            }else{
                isLoading = true;
                mainView.listModels.modelExchangeRates.fetchLatestJSON(setRateText);
            }
        }
    }

    function setRateText(isSuccess){
        console.log("setRateText")
        var ratesData = mainView.listModels.modelExchangeRates.data
        if(isSuccess){
            var base = tempSettings.travelCurrency
            var destination = tempSettings.currentCurrency

            if(ratesData.rates[base] && ratesData.rates[destination]){
                valueTextField.text = (1 / ratesData.rates[base]) * ratesData.rates[destination]
//                valueTextField.enabled = false
                tempSettings.fetchExchangeRate = true
                dataFetched(true)
            }else{
                dataFetched(false)
            }
        }else{
//            checkboxItem.checked = false
//            checkboxItem.checkboxValue = false
            if(!ratesData){
                tempSettings.fetchExchangeRate = false
            }
            dataFetched(false)
        }

        isLoading = false;
    }


    anchors {
        left: parent.left
        right: parent.right
    }

    Label {
        id: valueLabel
        text: i18n.tr("Rate")
//        font.weight: Text.Normal
        color: theme.palette.normal.foregroundText
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
        }
    }

    CheckBoxItem {
        id: checkboxItem

        titleText.text: i18n.tr("Use online data")
        subText.text: i18n.tr("Source") + ": OpenExchangeRates.org"
        bindValue: tempSettings.fetchExchangeRate//!valueTextField.enabled
        divider.visible: false
        onCheckboxValueChanged: {
            tempSettings.fetchExchangeRate = checkboxValue
            if(tempSettings.fetchExchangeRate){
                updateRate(false)
            }

//            if(checkboxValue){
//                updateRate()
//            }else{
//                tempSettings.fetchExchangeRate = false
////                valueTextField.enabled = true
//            }
        }
    }


    Row{
        id: textRateRow

        spacing: units.gu(1)
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
        }
        width: parent.width <= units.gu(50) ? parent.width - units.gu(4) : parent.width * 0.5

        TextField {
            id: valueTextField

            // this value is to avoid letter being cut off
            height: units.gu(4.3)
            //        width: parent.width <= units.gu(50) ? parent.width - units.gu(4) : parent.width * 0.5
            width: refreshButton.visible ? parent.width - (refreshButton.width + units.gu(1)) + textRateRow.spacing : parent.width
            inputMethodHints: Qt.ImhDigitsOnly
            text: tempSettings.exchangeRate
            enabled: !tempSettings.fetchExchangeRate

            //        anchors {
            //            left: parent.left
            //            leftMargin: units.gu(2)
            //        }
            placeholderText: "1.00"
            //        validator: DoubleValidator {
            //            decimals: tempSettings.currentCurrencyPrecision
            //        }
            hasClearButton: true

            primaryItem: Label {
                textSize : Label.Large
                text: tempSettings.currentCurrencySymbol
                color: theme.palette.normal.backgroundSecondaryText
            }

            secondaryItem: Label {
                text: "= 1 " + tempSettings.travelCurrency

                color: theme.palette.normal.backgroundSecondaryText
            }

            onTextChanged: {
                if(text){
                    tempSettings.exchangeRate = parseFloat(text)
                }else{
                    tempSettings.exchangeRate = 0
                }
            }
        }
        Button{
            id: refreshButton

            visible: tempSettings.fetchExchangeRate
            iconName: "reload"
            width: units.gu(5)
            color: "transparent"
            onClicked: updateRate(true)
            //        anchors{
            //            left: valueTextField.right
            //            right: parent.right
            //            rightMargin: units.gu(2)
            //        }
        }
    }
    Label {
        id: asofLabel

        visible: tempSettings.fetchExchangeRate
        text: i18n.tr("Exchange rate data as of") + ": " + Process.relativeDate(tempSettings.exchangeRateDate, "dddd, MMMM d, yyyy", "Basic")//Qt.formatDateTime(tempSettings.exchangeRateDate, "dddd, MMMM d, yyyy")
        font.italic: true
        textSize : Label.Small
        height: units.gu(3)
        verticalAlignment: Text.AlignVCenter
        color: rateField.isUpdated ? theme.palette.normal.backgroundTertiaryText : theme.palette.normal.negative
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
        }
    }
}
