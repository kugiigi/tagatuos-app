import QtQuick 2.4
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
                        source: "../tagatuos2.png"
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

                // Removed for now since OpenStore don't have rating support yet
//                NavigationItem {
//                    titleText.text: i18n.tr("Rate this App")
//                    iconName: "starred"

//                    anchors {
//                        left: parent.left
//                        right: parent.right
//                    }

//                    action: Action {
//                        onTriggered: {
//                            externalLinkConfirmation(
//                                        "scope://com.canonical.scopes.clickstore?q=Tagatuos")
//                        }
//                    }
//                }

                // No direct equivalent in Github. Perhaps think of a replacement in the future
//                NavigationItem {
//                    titleText.text: i18n.tr("Ask a question")
//                    iconName: "help"

//                    anchors {
//                        left: parent.left
//                        right: parent.right
//                    }

//                    action: Action {
//                        onTriggered: {
//                            externalLinkConfirmation(
//                                        "https://answers.launchpad.net/tagatuos-app")
//                        }
//                    }
//                }
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
                    titleText.text: i18n.tr("Donate")
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
                    titleText.text: i18n.tr("Other apps by the developer")
                    iconName: "stock_application"

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    action: Action {
                        onTriggered: {
                            externalLinkConfirmation(
                                        "https://open.uappexplorer.com/?sort=relevance&search=author%3AKugi%20Eusebio")
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
                //                ListItemSectionHeader {
                //                    title: i18n.tr("Logo")
                //                }
                //                NavigationItem {
                //                    titleText.text: "Sander Klootwijk"

                //                    anchors {
                //                        left: parent.left
                //                        right: parent.right
                //                    }

                //                    action: Action {
                //                        onTriggered: {
                //                            externalLinkConfirmation(
                //                                        'mailto:sander.k1007@kpnmail.nl')
                //                        }
                //                    }
                //                }
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
            }
        }
    }

    DialogExternalLink {
        id: dialogExternalLink
    }
}
