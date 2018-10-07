import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../components/Common"
import "../components/Dialogs"
import "../components/BaseComponents"
import "../components/TravelPage"

Page {
    id: travelPage

    header: BaseHeader {
        title: i18n.tr("Travel Mode")
    }


    PageBackGround {
    }

    ScrollView {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: travelPage.header.bottom
        }
        Flickable {
            id: flickableTravel
            boundsBehavior: Flickable.DragAndOvershootBounds
            interactive: true
            contentHeight: bodyColumn.height + travelModeSwitch.height + units.gu(
                               5)
            anchors.fill: parent

            flickableDirection: Flickable.VerticalFlick
            clip: true

            UbuntuNumberAnimation on opacity {
                running: flickableTravel.visible
                from: 0
                to: 1
                easing: UbuntuAnimation.StandardEasing
                duration: UbuntuAnimation.FastDuration
            }

            SwitchItem {
                id: travelModeSwitch

                titleText.text: i18n.tr("Travel Mode")
                subText.text: i18n.tr("Set a temporary currency")
                bindValue: tempSettings.travelMode
                divider.visible: false
                onSwitchValueChanged: {
                    tempSettings.travelMode = switchValue
                }
            }

            Column {
                id: bodyColumn

                visible: travelModeSwitch.switchValue
                anchors {
                    top: travelModeSwitch.bottom
                    left: parent.left
                    right: parent.right
                }



                ListItemSectionHeader {
                    title: i18n.tr("Settings")
                }

                PopupItemSelector{
                    id: currencyPopupItemSelector

                    titleText: i18n.tr("Currency")
                    selectedValue: tempSettings.travelCurrency
                    popupParent: travelPage
                    model: mainView.listModels.modelCurrencies
                    valueRolename: "currency_code"
                    textRolename: "descr"
                    divider.visible: false

                    onConfirmSelection: {
                        tempSettings.travelCurrency = selections
                    }

                    Component.onCompleted: {
                        mainView.listModels.modelCurrencies.getItems()
                    }

                    onSelectedValueChanged: {
                        if(tempSettings.fetchExchangeRate){
                            rateField.updateRate(false)
                        }
                    }

                }

                RateField{
                    id: rateField
                    onDataFetched:{
                        if(!status){
                            PopupUtils.open(fetchFailedDialog)
                        }
                    }
                }
            }
        }
    }
    LoadingComponent {
        id: loadingComponent

        visible: rateField.isLoading
        withBackground: true
        anchors.centerIn: parent
        title: i18n.tr("Fetching exchange rates data")
        //subTitle: i18n.tr("Please wait")
    }

    Component {
        id: fetchFailedDialog
        Dialog {
            id: dialog

            title: i18n.tr("Cannot fetch exchange rate data")
            text: i18n.tr("Please check if you have a working internet connection")


            Button {
                text: "OK"
                onClicked: {
                    PopupUtils.close(dialog)
                }
            }


        }
    }
}
