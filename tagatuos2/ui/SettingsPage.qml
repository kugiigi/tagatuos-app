import QtQuick 2.4
import Ubuntu.Components 1.3
//import Ubuntu.Components.ListItems 1.3 as ListItem
import "../components"
import "../components/Common"
import "../components/BaseComponents"

Page {

    id: settingsPage

    header: BaseHeader {
        title: i18n.tr("Settings")
    }

//    PageBackGround {
//    }

    onActiveChanged: {
        if (!active) {
            navigationListView.currentIndex = -1
        }
    }

    ScrollView {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom   //navigationListView.top
            topMargin: settingsPage.header.height
        }

        Flickable {
            id: settingsListView

            interactive: true
            clip: true
            contentHeight: _settingsColumn.height
            anchors.fill: parent

            UbuntuNumberAnimation on opacity {
                running: settingsListView.visible
                from: 0
                to: 1
                easing: UbuntuAnimation.StandardEasing
                duration: UbuntuAnimation.FastDuration
            }

            function positionViewAtBeginning() {
                //FIXME: find a way to position at the beginning a flickable
                //dummy function
                contentY = 0
            }

            Column {
                id: _settingsColumn

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                //Interface Settings
                ListItemSectionHeader {
                    title: i18n.tr("Interface")
                }

                CheckBoxItem {
                    titleText.text: i18n.tr("Always start with Dashboard")
                    subText.text: i18n.tr(
                                      "Disabling will load the page from previous session")
                    bindValue: tempSettings.startDashboard
                    divider.visible: false
                    onCheckboxValueChanged: {
                        tempSettings.startDashboard = checkboxValue
                    }
                }

                ExpandableListItemAdvanced {
                    id: themeExpandedListItem
                    listViewHeight: units.gu(21)
                    titleText.text: i18n.tr("Theme")
                    titleText.textSize: Label.Medium
                    subText.textSize: Label.Small
                    savedValue: tempSettings.currentTheme
                    highlightColor: theme.palette.highlighted.foreground
                    divider.visible: false
                    headerDivider.visible: false
                    expansionBottomDivider: false

                    onToggle: {
                        tempSettings.currentTheme = newValue
                    }
                }


                ListModel {
                    id: themesModel
                    Component.onCompleted: initialise()

                    function initialise() {
                        themesModel.append({
                                               value: "",
                                               text: i18n.tr("Systems")
                                           })
                        themesModel.append({
                                               value: "Ubuntu.Components.Themes.Ambiance",
                                               text: i18n.tr("Ambiance")
                                           })
                        themesModel.append({
                                               value: "Ubuntu.Components.Themes.SuruDark",
                                               text: i18n.tr("Suru Dark")
                                           })
                        themeExpandedListItem.model = themesModel
                    }
                }

                //General Settings
                ListItemSectionHeader {
                    title: i18n.tr("General")
                }

                PopupItemSelector{
                    id: currencyPopupItemSelector

                    titleText: i18n.tr("Currency")
                    selectedValue: tempSettings.currentCurrency
                    popupParent: settingsPage
                    model: mainView.listModels.modelCurrencies
                    valueRolename: "currency_code"
                    textRolename: "descr"
                    divider.visible: false

                    onConfirmSelection: {
                        tempSettings.currentCurrency = selections
                    }

                    Component.onCompleted: {
                        mainView.listModels.modelCurrencies.getItems()
                    }

                }

                ListModel {
                    id: currencyModel
                    Component.onCompleted: initialise()

                    function initialise() {
                        currencyModel.append({
                                               value: "ARS",
                                               text: i18n.tr("Argentina Peso")
                                           })
                        currencyModel.append({
                                               value: "PHP",
                                               text: i18n.tr("Philippines Peso")
                                           })
                        currencyModel.append({
                                               value: "USD",
                                               text: i18n.tr("US Dollars")
                                           })
                        currencyModel.append({
                                               value: "GBP",
                                               text: i18n.tr("United Kingdom Pound")
                                           })
//                        currencyPopupItemSelector.model = currencyModel
                    }
                }

                PopupItemSelector{
                    id: dashboardPopupItemSelector

                    titleText: i18n.tr("Dashboard")
                    selectedValue: tempSettings.dashboardItems
                    popupParent: settingsPage
                    multipleSelection: true
                    withOrdering: true
                    divider.visible: false

                    onConfirmSelection: {
                        tempSettings.dashboardItems = selections //.replace(/, /g,";")
                        tempSettings.dashboardItemsOrder = selectionsOrder //.replace(/, /g,";")
                        //"Today;Yesterday;Recent;This Week;This Month;Last Week;Last Month"
                    }

                }


                ListModel {
                    id: dashboardItemsModel
                    Component.onCompleted: initialise()

                    function initialise() {
                        dashboardItemsModel.clear()

                        var itemsOrder = tempSettings.dashboardItemsOrder.split(
                                    ";")
                        for (var i = 0; i <= itemsOrder.length; i++) {
                            switch (itemsOrder[i]) {
                            case "Today":
                                dashboardItemsModel.append({
                                                               value: "Today",
                                                               text: i18n.tr(
                                                                         "Today")
                                                           })
                                break
                            case "Yesterday":
                                dashboardItemsModel.append({
                                                               value: "Yesterday",
                                                               text: i18n.tr(
                                                                         "Yesterday")
                                                           })
                                break
                            case "Recent":
                                dashboardItemsModel.append({
                                                               value: "Recent",
                                                               text: i18n.tr(
                                                                         "Recent")
                                                           })
                                break
                            case "This Week":
                                dashboardItemsModel.append({
                                                               value: "This Week",
                                                               text: i18n.tr(
                                                                         "This Week")
                                                           })
                                break
                            case "This Month":
                                dashboardItemsModel.append({
                                                               value: "This Month",
                                                               text: i18n.tr(
                                                                         "This Month")
                                                           })
                                break
                            case "Last Week":
                                dashboardItemsModel.append({
                                                               value: "Last Week",
                                                               text: i18n.tr(
                                                                         "Last Week")
                                                           })
                                break
                            case "Last Month":
                                dashboardItemsModel.append({
                                                               value: "Last Month",
                                                               text: i18n.tr(
                                                                         "Last Month")
                                                           })
                                break
                            }
                        }
                        dashboardPopupItemSelector.model = dashboardItemsModel
                    }
                }

                ListItemSectionHeader {
                    title: i18n.tr("Administration")
                }

                UbuntuListView {
                    id: navigationListView

                    interactive: false
                    currentIndex: -1
                    clip: true
                    highlightFollowsCurrentItem: true
                    highlight: ListViewHighlight {
                    }
                    highlightMoveDuration: UbuntuAnimation.SnapDuration
                    highlightResizeDuration: UbuntuAnimation.SnapDuration
                    height: units.gu(7) * navigationsModel.count //contentHeight

                    anchors {
                        //bottom: parent.bottom
                        //bottomMargin: units.gu(1)
                        left: parent.left
                        right: parent.right
                    }
                    model: navigationsModel

                    UbuntuNumberAnimation on opacity {
                        running: navigationListView.visible
                        from: 0
                        to: 1
                        easing: UbuntuAnimation.StandardEasing
                        duration: UbuntuAnimation.FastDuration
                    }

                    delegate: NavigationItem {
                        id: categoriesNavigation
                        titleText.text: title
                        subText.text: subtitle


                        anchors {
                            left: parent.left
                            right: parent.right
                        }

                        action: Action {
                            onTriggered: {
                                mainPageStack.push(Qt.resolvedUrl(page))
                            }
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: navigationsModel
        Component.onCompleted: initialise()

        function initialise() {

            // TODO: Needs to implement reports first before unhiding
//            navigationsModel.append({
//                                        title: i18n.tr("Manage Reports"),
//                                        subtitle: i18n.tr(
//                                                      "Create custom reports"),
//                                        page: "ManageReports.qml"
//                                    })
            navigationsModel.append({
                                        title: i18n.tr("Manage Categories"),
                                        subtitle: i18n.tr(
                                                      "Add, edit, and delete categories"),
                                        page: "ManageCategory.qml"
                                    })
            navigationsModel.append({
                                        title: i18n.tr("About Tagatuos"),
                                        subtitle: i18n.tr(
                                                      "Credits, report bugs, view source code, contact developer, donate"),
                                        page: "AboutPage.qml"
                                    })
        }
    }
}
