import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import "../.." as Components
import "../../../common" as Common
import "../../../library/ApplicationFunctions.js" as AppFunctions

TextField {
    id: valueField

    property Flickable flickable

    placeholderText: AppFunctions.formatMoney(0, true)
    font.pixelSize: Suru.units.gu(3)
    horizontalAlignment: TextInput.AlignHCenter
    wrapMode: TextInput.WordWrap
    inputMethodHints: Qt.ImhDigitsOnly
    validator: DoubleValidator {
//~         decimals: root.travelCurData ? root.travelCurData.precision : (tempSettings.travelMode ? tempSettings.travelCurrencyPrecision : tempSettings.currentCurrencyPrecision)
        decimals: mainView.settings.travelMode ? mainView.settings.travelCurrencyPrecision : mainView.settings.currentCurrencyPrecision
    }

    color: mainView.settings.coloredText ? Suru.highlightColor : Suru.foregroundColor

    Suru.highlightType: mainView.settings.coloredText ? Suru.PositiveHighlight : Suru.InformationHighlight

//~     function focusPrevious() {
//~         let _prevItem = nextItemInFocusChain(false)
//~         _prevItem.forceActiveFocus()
//~     }

//~     function focusNext() {
//~         let _nextItem = nextItemInFocusChain(true)
//~         _nextItem.forceActiveFocus()
//~     }

//~     onAccepted: focusNext()
    Keys.onUpPressed: focusScrollConnections.focusPrevious()
    Keys.onDownPressed: focusScrollConnections.focusNext()

    onActiveFocusChanged: {
        if (activeFocus) {
            selectAll()
        }
    }

    Components.FocusScrollConnections {
        id: focusScrollConnections

        target: valueField
        flickable: valueField.flickable
    }

    background: Common.BaseBackgroundRectangle {
        control: valueField
        radius: Suru.units.gu(1)
        
        Label {
            id: currencySymbolLabel

            Suru.textLevel: Suru.HeadingThree
    //            text: root.withTravelData ? (typeof root.travelCurData.symbol !== 'undefined' ? root.travelCurData.symbol : "") : (tempSettings.travelMode ? tempSettings.travelCurrencySymbol : tempSettings.currentCurrencySymbol)
    //~         text: if (root.mode === "edit") {
    //~                   root.withTravelData ? (typeof root.travelCurData.symbol !== 'undefined' ? root.travelCurData.symbol : "") : tempSettings.currentCurrencySymbol
    //~               } else {
            text: mainView.settings.travelMode ? mainView.settings.travelCurrencySymbol : mainView.settings.currentCurrencySymbol
    //~               }
            color: Suru.secondaryForegroundColor
            anchors {
                left: parent.left
                leftMargin: Suru.units.gu(2)
                verticalCenter: parent.verticalCenter
            }
        }
    }
}
