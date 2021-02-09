import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../components/Common"
import "../components/Dialogs"
import "../components/BaseComponents"

Page {
    id: aboutPage

    header: BaseHeader {
        title: i18n.tr("About") + " Tagatuos"
    }

    function externalLinkConfirmation(link, continueFunction){
        var dialogConfirm = PopupUtils.open(
                    dialogExternalLink,null,{"externalURL": link})

        var continueDialog = function (answer) {
            if(answer){
                Qt.openUrlExternally(link)
            }
        }

        dialogConfirm.proceed.connect(
                    continueDialog)
    }

    PageBackGround {
    }

    ScrollView {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: aboutPage.header.bottom
        }
        Flickable {
            id: flickableAbout
            boundsBehavior: Flickable.DragAndOvershootBounds
            interactive: true
            contentHeight: bodyColumn.height + iconlabelGroup.height + units.gu(
                               5)
            anchors.fill: parent

            flickableDirection: Flickable.VerticalFlick
            clip: true

            UbuntuNumberAnimation on opacity {
                running: flickableAbout.visible
                from: 0
                to: 1
                easing: UbuntuAnimation.StandardEasing
                duration: UbuntuAnimation.FastDuration
            }

            Item {
                id: iconlabelGroup
                //spacing: units.gu(1)
                height: units.gu(30)

                anchors {
                    left: parent.left
                    right: parent.right
                }

                UbuntuShape {
                    id: iconShape
                    width: units.gu(20)
                    height: width
                    aspect: UbuntuShape.Flat

                    radius: "medium"
                    relativeRadius: 0.5
                    anchors {
                        top: iconlabelGroup.top
                        topMargin: units.gu(3)
                        horizontalCenter: parent.horizontalCenter
                    }
                    source: Image {
//                        source: "../tagatuos2.png"
                        source: "../icon.svg"
                        sourceSize.width: parent.width
                        sourceSize.height: parent.height
                        asynchronous: true
                    }
                }
                Label {
                    id: labelName
                    text: "© Tagatuos " + i18n.tr("Version") + " " + mainView.current_version
                    textSize: Label.Medium
                    horizontalAlignment: Text.AlignHCenter
                    anchors {
                        top: iconShape.bottom
                        topMargin: units.gu(1)
                        horizontalCenter: parent.horizontalCenter
                    }
                }
                Label {
                    text: i18n.tr("Released under license") + " <a href='https://www.gnu.org/licenses/gpl-3.0.en.html' title='GNU GPL v3'>GNU GPL v3</a>"
                    textSize: Label.Medium
                    horizontalAlignment: Text.AlignHCenter
                    anchors {
                        top: labelName.bottom
                        topMargin: units.gu(1)
                        horizontalCenter: parent.horizontalCenter
                    }

                    onLinkActivated: {
                        externalLinkConfirmation(link)
                    }
                }
            }

            Column {
                id: bodyColumn
                anchors {
                    //margins: units.gu(3)
                    top: iconlabelGroup.bottom
                    topMargin: units.gu(3)
                    left: parent.left
                    right: parent.right
                }
                ListItemSectionHeader {
                    title: i18n.tr("Support")
                }

                NavigationItem {
                    titleText.text: i18n.tr("Rate this App")
                    iconName: "starred"

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    action: Action {
                        onTriggered: {
                            externalLinkConfirmation(
                                        "openstore://tagatuos2.kugiigi")
                        }
                    }
                }

                NavigationItem {
                    titleText.text: i18n.tr("Report a bug")
                    iconName: "mail-mark-important"

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    action: Action {
                        onTriggered: {
                            externalLinkConfirmation(
                                        "https://github.com/kugiigi/tagatuos-app/issues")
                        }
                    }
                }
                NavigationItem {
                    titleText.text: i18n.tr("Contact Developer")
                    iconName: "stock_email"

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    action: Action {
                        onTriggered: {
                            externalLinkConfirmation('mailto:kugi_igi@yahoo.com')
                        }
                    }
                }
                NavigationItem {
                    titleText.text: "View source"
                    iconName: "stock_document"

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    action: Action {
                        onTriggered: {
                            externalLinkConfirmation(
                                        'https://github.com/kugiigi/tagatuos-app')
                        }
                    }
                }
                NavigationItem {
                    titleText.text: i18n.tr("Donate via PayPal")
                    iconName: "like"

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    action: Action {
                        onTriggered: {
                            externalLinkConfirmation(
                                        'https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=2GBQRJGLZMBCL')
                        }
                    }
                }
                NavigationItem {
                    titleText.text: i18n.tr("Donate via LibrePay")
                    iconName: "unlike"

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    action: Action {
                        onTriggered: {
                            externalLinkConfirmation(
                                        'https://liberapay.com/kugi_eusebio/donate')
                        }
                    }
                }
                NavigationItem {
                    titleText.text: i18n.tr("View in OpenStore")
                    iconName: "ubuntu-store-symbolic"

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    action: Action {
                        onTriggered: {
                            externalLinkConfirmation(
                                        "openstore://tagatuos2.kugiigi")
                        }
                    }
                }
                NavigationItem {
                    titleText.text: i18n.tr("Other apps by the developer")
                    iconName: "stock_application"

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    action: Action {
                        onTriggered: {
                            externalLinkConfirmation(
                                        "https://open-store.io/?search=author%3AKugi%20Eusebio")
                        }
                    }
                }

                ListItemSectionHeader {
                    title: i18n.tr("Developers")
                }
                NavigationItem {
                    titleText.text: "Kugi Eusebio"
                    subText.text: "Main developer"

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    action: Action {
                        onTriggered: {
                            externalLinkConfirmation(
                                        'https://github.com/kugiigi')
                        }
                    }
                }
                ListItemSectionHeader {
                    title: i18n.tr("Icon")
                }
                NavigationItem {
                    titleText.text: "Joan CiberSheep"
                    subText.text: "coin icon under license CC By Nimal Raj, chart icon under license CC By Gregor Cresnar"

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    action: Action {
                        onTriggered: {
                            externalLinkConfirmation(
                                        'mailto:cibersheep@gmail.com')
                        }
                    }
                }
                ListItemSectionHeader {
                    title: i18n.tr("Powered by")
                }
                NavigationItem {
                    titleText.text: "accounting.js"
                    subText.text: i18n.tr("Money formatting")

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    action: Action {
                        onTriggered: {
                            externalLinkConfirmation(
                                        'http://openexchangerates.github.io/accounting.js/')
                        }
                    }
                }
                NavigationItem {
                    titleText.text: "OpenExchangeRates.org"
                    subText.text: i18n.tr("Exchange rates data")

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    action: Action {
                        onTriggered: {
                            externalLinkConfirmation(
                                        'http://openexchangerates.org')
                        }
                    }
                }
                NavigationItem {
                    titleText.text: "moment.js"
                    subText.text: i18n.tr("Date and Time manipulation and formatting")

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    action: Action {
                        onTriggered: {
                            externalLinkConfirmation('http://momentjs.com/')
                        }
                    }
                }
                NavigationItem {
                    titleText.text: "chart.js for QML"
                    subText.text: i18n.tr("Charts and graphs")

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    action: Action {
                        onTriggered: {
                            externalLinkConfirmation('http://jwintz.me/blog/2014/02/15/qchart-dot-js-qml-binding-for-chart-dot-js/')
                        }
                    }
                }
                NavigationItem {
                    titleText.text: "chart.js core"
                    subText.text: i18n.tr("Charts and graphs")

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    action: Action {
                        onTriggered: {
                            externalLinkConfirmation('http://www.chartjs.org')
                        }
                    }
                }
            }
        }
    }

    DialogExternalLink {
        id: dialogExternalLink
    }
}
