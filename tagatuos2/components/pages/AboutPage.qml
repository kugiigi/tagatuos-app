import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import "aboutpage"
import "../../common" as Common
import "../../common/pages" as Pages
import "../../common/listitems" as ListItems

Pages.BasePage {
    id: aboutPage

    title: i18n.tr("About %1").arg("Tagatuos")
    flickable: aboutFlickable

    Common.BaseFlickable {
        id: aboutFlickable
        
        anchors.fill: parent
        contentHeight: listView.height + iconComponent.height + Suru.units.gu(5)
        boundsBehavior: Flickable.DragOverBounds
        pageHeader: aboutPage.pageManager ? aboutPage.pageManager.pageHeader : null

        ScrollIndicator.vertical: ScrollIndicator { }

        function externalLinkConfirmation(link) {
            let _popup = externalDialogComponent.createObject(aboutPage, { externalURL: link })
            _popup.openDialog();
        }

        IconComponent{
            id: iconComponent

            anchors {
                top: parent.top
                topMargin: Suru.units.gu(2)
                left: parent.left
                right: parent.right
            }
        }

        ListView {
            id: listView

            model: aboutModel
            height: contentHeight
            interactive: false

            anchors {
                top: iconComponent.bottom
                topMargin: Suru.units.gu(2)
                left: parent.left
                right: parent.right
            }

            section {
                property: "section"
                delegate: SectionItem { text: section }
            }

            delegate: ListItems.NavigationDelegate {
                text: model.text
                icon.name: model.icon
                progressionIcon.name: "external-link"
                tooltipText: model.subText

                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Suru.units.gu(1)
                }

                onClicked: {
                    flickable.externalLinkConfirmation(model.urlText)
                }
            }
        }

        ListModel {
            id: aboutModel
            
            Component.onCompleted: fillData()
    
            function fillData() {
                append({"section": i18n.tr("Support"), "text": i18n.tr("Report a bug"), "subText": "", "icon": "mail-mark-important"
                                                                , "urlText": "https://github.com/kugiigi/tagatuos-app/issues"})
                append({"section": i18n.tr("Support"), "text": i18n.tr("Contact Developer"), "subText": "", "icon": "stock_email"
                                                                , "urlText": "mailto:kugi_eusebio@protonmail.com"})
                append({"section": i18n.tr("Support"), "text": i18n.tr("View source"), "subText": "", "icon": "stock_document"
                                                                , "urlText": "https://github.com/kugiigi/tagatuos-app"})
                append({"section": i18n.tr("Support"), "text": i18n.tr("Donate via LibrePay"), "subText": "", "icon": "like"
                                                                , "urlText": "https://liberapay.com/kugi_eusebio/donate"})
                append({"section": i18n.tr("Support"), "text": i18n.tr("Donate via PayPal"), "subText": "", "icon": "like"
                                                                , "urlText": "http://www.paypal.me/Kugi"})
                append({"section": i18n.tr("Support"), "text": i18n.tr("View in OpenStore"), "subText": "", "icon": "ubuntu-store-symbolic"
                                                                , "urlText": "openstore://tagatuos2.kugiigi"})
                append({"section": i18n.tr("Support"), "text": i18n.tr("Other apps by the developer"), "subText": "", "icon": "stock_application"
                                                                , "urlText": "https://open-store.io/?search=author%3AKugi%20Eusebio"})
                append({"section": i18n.tr("Developers"), "text": "Kugi Eusebio", "subText": i18n.tr("Main developer"), "icon": ""
                                                                , "urlText": "https://github.com/kugiigi"})
                append({"section": i18n.tr("Icon"), "text": "Joan CiberSheep", "subText": i18n.tr("coin icon under license CC By Nimal Raj, chart icon under license CC By Gregor Cresnar"), "icon": ""
                                                                , "urlText": "https://github.com/kugiigi"})
                append({"section": i18n.tr("Powered by"), "text": "accounting.js", "subText": i18n.tr("Money formatting"), "icon": ""
                                                                , "urlText": "http://openexchangerates.github.io/accounting.js/"})
                append({"section": i18n.tr("Powered by"), "text": "chart.js for QML", "subText": i18n.tr("Charts and graphs"), "icon": ""
                                                                , "urlText": "http://jwintz.me/blog/2014/02/15/qchart-dot-js-qml-binding-for-chart-dot-js/"})
                append({"section": i18n.tr("Powered by"), "text": "chart.js core", "subText": i18n.tr("Charts and graphs"), "icon": ""
                                                                , "urlText": "http://www.chartjs.org"})
                append({"section": i18n.tr("Powered by"), "text": "OpenExchangeRates.org", "subText": i18n.tr("Exchange rates data"), "icon": ""
                                                                , "urlText": "http://openexchangerates.org"})
                append({"section": i18n.tr("Powered by"), "text": "moment.js", "subText": i18n.tr("Date and Time manipulation and formatting"), "icon": ""
                                                                , "urlText": "http://momentjs.com/"})
                append({"section": i18n.tr("Powered by"), "text": "Nymea app components", "subText": i18n.tr("Date and time pickers"), "icon": ""
                                                                , "urlText": "https://github.com/nymea/nymea-app"})
            }
        }
    }

    Component {
        id: externalDialogComponent

        ExternalDialog{
            id: externalDialog
        }
    }
}
