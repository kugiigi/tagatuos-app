import QtQuick 2.12
import Lomiri.Components 1.3 as UT
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import UserMetrics 0.1
import Lomiri.Components.Themes.Ambiance 1.3 as Ambiance
import Lomiri.Components.Themes.SuruDark 1.3 as SuruDark
import "library/database.js" as Database
import "library/dataUtils.js" as DataUtils
import "library/functions.js" as Functions
import "common/pages" as PageComponents
import "common/menus" as Menus
import "components/pages" as Pages
import "components/models" as Models
import "common" as Common
import "components"

ApplicationWindow {
    id: mainView
    objectName: "mainView"

    readonly property string current_version: "1.0"
    readonly property var suruTheme: switch(settings.currentTheme) {
            case "Ambiance":
            case "Ubuntu.Components.Themes.Ambiance":
            case "Lomiri.Components.Themes.Ambiance":
                return Suru.Light
                break
            case "SuruDark":
            case "Ubuntu.Components.Themes.SuruDark":
            case "Lomiri.Components.Themes.SuruDark":
                return Suru.Dark
                break
            case "System":
            default:
                if (Theme.name == "Lomiri.Components.Themes.SuruDark") {
                    return Suru.Dark
                } else {
                    return Suru.Light
                }
                break
        }
    readonly property QtObject uitkColors: Suru.theme === Suru.Dark ? suruDarkTheme : ambianceTheme
    
    readonly property string displayMode: "Phone" //"Desktop" //"Phone" //"Tablet"
    readonly property bool isWideLayout: width >= Suru.units.gu(110)
    readonly property var dataUtils: DataUtils.dataUtils
    readonly property var profiles: dataUtils.profiles
    readonly property var currencies: dataUtils.currencies()
    readonly property var categories: dataUtils.categories(settings.activeProfile)
    readonly property var expenses: dataUtils.expenses(settings.activeProfile)   
    readonly property var quickExpenses: dataUtils.quickExpenses(settings.activeProfile)   
    readonly property var dashboard: dataUtils.dashboard(settings.activeProfile)   
    property string currentDate: Functions.getToday()

    readonly property alias userMetric: userMetric
    readonly property alias settings: settingsLoader.item
    readonly property alias tooltip: globalTooltip
    readonly property alias mainModels: listModelsLoader.item
    readonly property alias keyboard: keyboardRec.keyboard
    readonly property alias keyboardRectangle: keyboardRec
    readonly property var mainPage: mainPageLoader.item.mainPage
    readonly property var sidePage: mainPageLoader.item.sidePage
    readonly property var detailedListPage: mainPageLoader.item.detailedListPage
    readonly property var mainSurface: mainPageLoader.item
    readonly property alias drawer: drawerLoader.item
    readonly property alias popupPage: popupPageLoader.item
    readonly property alias newExpenseView: newExpenseViewLoader.item

    readonly property bool sidePageIsOpen: sidePage && sidePage.visible

    property bool temporaryDisableColorOverlay: false

    title: i18n.tr("Tagatuos - Your expense diary")
    visible: false
    minimumWidth: Suru.units.gu(30)

    Suru.theme: suruTheme //Suru.Light //Suru.Dark

    width: switch (displayMode) {
           case "Phone":
               units.gu(50)
               break
           case "Tablet":
               units.gu(100)
               break
           case "Desktop":
               units.gu(120)
               break
           default:
               units.gu(120)
               break
           }
    height: switch (displayMode) {
            case "Phone":
                units.gu(89)
                break
            case "Tablet":
                units.gu(56)
                break
            case "Desktop":
                units.gu(68)
                break
            default:
                units.gu(68)
                break
            }

    Component.onCompleted: {
        /*Meta data processing*/
        let _currentDataBaseVersion = Database.checkUserVersion()

        if (_currentDataBaseVersion === 0) {
            Database.createInitialData()
        }

        Database.databaseUpgrade(_currentDataBaseVersion)
        settingsLoader.active = true
    }

    function initDataUtils() {
        dataUtils = Qt.binding( function() { return DataUtils.dataUtils } )
        profiles = Qt.binding( function() { return dataUtils.profiles } )
        categories = Qt.binding( function() { return dataUtils.categories(settings.activeProfile) } )
        expenses = Qt.binding( function() { return dataUtils.expenses(settings.activeProfile) } )
        listModelsLoader.active = true
    }

    function checkIfDayChanged() {
        if (!Functions.isToday(currentDate)) {
            currentDate = Functions.getToday()
        }
    }

    Ambiance.Palette { id: ambianceTheme }
    SuruDark.Palette { id: suruDarkTheme }

    Metric {
        id: userMetric

        property string circleMetric

        name: "expenseCounter"
        format: circleMetric
        emptyFormat: i18n.tr("No expense yet for today")
        domain: "tagatuos2.kugiigi"
    }

    UT.MainView {
        //Only for making translation work
        id: dummyMainView
        applicationName: "tagatuos2.kugiigi"
        visible: false
    }

    Connections {
        target: Qt.application

        onStateChanged: {
            if (state == Qt.ApplicationActive) {
                checkIfDayChanged()
            }
        }
    }

    UT.LiveTimer {
        frequency: UT.LiveTimer.Hour
        onTrigger: {
            checkIfDayChanged()
        }
    }

    Common.GlobalTooltip {
        id: globalTooltip
        parent: mainView.mainFocusScope
        marginTop: Suru.units.gu(10)
    }

    Loader {
        id: settingsLoader

        active: false
        asynchronous: true
        sourceComponent: SettingsComponent {}

        onLoaded: listModelsLoader.active = true
    }

    Loader {
        id: listModelsLoader

        active: false
        asynchronous: true
        sourceComponent: Models.MainModels {
            id: listModels
        }

        onLoaded: {
            mainPageLoader.active = true
            newExpenseViewLoader.active = true
            popupPageLoader.active = true
            drawerLoader.active = true
        }
    }

    FocusScope {
        id: mainFocusScope

        anchors.fill: parent

        Rectangle {
            id: colorOverlay

            z: 100
            visible: mainView.profiles.enableOverlay() && !mainView.temporaryDisableColorOverlay
            anchors.fill: parent
            opacity: mainView.profiles.overlayOpacity()
            parent: mainView.overlay
            color: mainView.profiles.overlayColor()
        }

        Loader {
            id: drawerLoader

            active: false
            asynchronous: true
            sourceComponent: MenuDrawer {
                id: drawer

                listViewTopMargin: mainView.mainPage && mainView.mainPage.pageHeader.expanded ? mainView.mainPage.pageHeader.height : 0
                model:  [ profilesAction, categoriesAction, quickExpensesAction, travelModeAction, settingsAction, aboutAction ]

                Common.BaseAction {
                    id: profilesAction

                    text: i18n.tr("Profiles")
                    iconName: "account"

                    onTrigger: popupPage("qrc:///components/pages/ProfilesPage.qml", { activeProfile: mainView.settings.activeProfile })
                }

                Common.BaseAction {
                    id: categoriesAction

                    text: i18n.tr("Categories")
                    iconName: "stock_note"

                    onTrigger: popupPage("qrc:///components/pages/CategoriesPage.qml")
                }

                Common.BaseAction {
                    id: quickExpensesAction

                    text: i18n.tr("Quick Expenses")
                    iconName: "scope-manager"

                    onTrigger: {
                        let _properties = {
                            coloredCategory: mainView.detailedListPage.coloredCategory
                            , homeCurrency: mainView.settings.currentCurrency
                        }
                        popupPage("qrc:///components/pages/QuickExpensesPage.qml", _properties)
                    }
                }

                Common.BaseAction {
                    id: travelModeAction

                    text: i18n.tr("Travel Mode")
                    iconName: "airplane-mode"
                    // WORKAROUND: Suru colors do not change when changing theme
                    // Only happens in QtObject
                    icon.color: mainView.settings.travelMode ? mainView.uitkColors.normal.activity: mainView.uitkColors.normal.backgroundSecondaryText

                    onTrigger: popupPage("qrc:///components/pages/TravelModePage.qml")
                }

                Common.BaseAction {
                    id: settingsAction

                    text: i18n.tr("Settings")
                    iconName: "settings"

                    onTrigger: popupPage("qrc:///components/pages/SettingsPage.qml")
                }

                Common.BaseAction {
                    id: aboutAction

                    text: i18n.tr("About")
                    iconName: "info"

                    onTrigger: popupPage("qrc:///components/pages/AboutPage.qml")
                }

                function popupPage(source, properties) {
                    mainView.popupPage.openInPage(source, properties)
                }
            }

            visible: status == Loader.Ready
        }

        Loader {
            id: mainPageLoader

            active: false
            asynchronous: true
            visible: status == Loader.Ready
            anchors.fill: parent
            sourceComponent: Item {
                property alias sidePage: sidePage
                property alias mainPage: corePage
                property alias detailedListPage: detailedListPage

                PageComponents.BasePageStack {
                    id: corePage

                    anchors {
                        fill: parent
                        rightMargin: mainView.isWideLayout ? sidePage.width : 0
                    }

                    isWideLayout: width > Suru.units.gu(90)
                    enableBottomGestureHint: !mainView.settings.hideBottomHint
                    enableHeaderPullDown: mainView.settings.headerPullDown
                    enableBottomSideSwipe: mainView.settings.sideSwipe
                    enableDirectActions: mainView.settings.directActions
                    enableDirectActionsDelay: mainView.settings.quickActionEnableDelay
                    enableBottomQuickSwipe: mainView.settings.quickSideSwipe
                    enableHorizontalSwipe: mainView.settings.horizontalSwipe
                    bottomGestureAreaHeight: mainView.settings.bottomGesturesAreaHeight
                    directActionsHeight: mainView.settings.quickActionsHeight

                    customTitleItem {
                        sourceComponent: mainView.mainModels.profilesModel.count > 1 ? profilePickerComponent : null
                        hideOnExpand: false
                        fillWidth: false
                        alignment: Qt.AlignLeft
                    }

                    initialItem: Pages.DashboardPage {
                        isTravelMode: mainView.settings.travelMode
                        travelCurrency: mainView.settings.travelCurrency
                    }

                    Behavior on anchors.rightMargin {
                        NumberAnimation {
                            easing: Suru.animations.EasingIn
                            duration: Suru.animations.SnapDuration
                        }
                    }

                    Pages.BottomSwipeUpConnection {
                        target: corePage.middleBottomGesture
                        enabled: !sidePage.middleBottomGesture.dragging
                    }
                }

                Rectangle {
                    anchors {
                        horizontalCenter: corePage.right
                        top: parent.top
                        bottom: parent.bottom
                        margins: Suru.units.gu(2)
                    }
                    width: Suru.units.dp(1)
                    visible: sidePage.visible && !(!mainView.isWideLayout && sidePage.forceShowInNarrow)
                    color: Suru.neutralColor
                }

                PageComponents.BasePageStack {
                    id: sidePage

                    readonly property bool shownInNarrow: !mainView.isWideLayout
                    property bool forceShowInNarrow: false

                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        right: parent.right
                    }

                    width: shownInNarrow ? parent.width : Suru.units.gu(50)
                    isWideLayout: width > Suru.units.gu(60)
                    forceShowBackButton: shownInNarrow
                    enableShortcuts: true
                    enableBottomGestureHint: !mainView.settings.hideBottomHint
                    enableHeaderPullDown: mainView.settings.headerPullDown
                    enableBottomSideSwipe: mainView.settings.sideSwipe
                    enableDirectActions: mainView.settings.directActions
                    enableDirectActionsDelay: mainView.settings.quickActionEnableDelay
                    enableBottomQuickSwipe: mainView.settings.quickSideSwipe
                    enableHorizontalSwipe: mainView.settings.horizontalSwipe
                    bottomGestureAreaHeight: mainView.settings.bottomGesturesAreaHeight
                    directActionsHeight: mainView.settings.quickActionsHeight
                    initialItem: Pages.DetailedListPage {
                        id: detailedListPage

                        isTravelMode: mainView.settings.travelMode
                        travelCurrency: mainView.settings.travelCurrency
                        scope: mainView.settings.detailedListScope
                        sort: mainView.settings.detailedListSort
                        order: mainView.settings.detailedListOrder
                        coloredCategory: mainView.settings.detailedListColoredCategory

                        onScopeChanged: mainView.settings.detailedListScope = scope
                        onSortChanged: mainView.settings.detailedListSort = sort
                        onOrderChanged: mainView.settings.detailedListOrder = order
                        onColoredCategoryChanged: mainView.settings.detailedListColoredCategory = coloredCategory
                    }

                    visible: opacity > 0
                    opacity: mainView.isWideLayout || forceShowInNarrow ? 1 : 0

                    customTitleItem {
                        sourceComponent: shownInNarrow && mainView.mainModels.profilesModel.count > 1 ? profilePickerComponent : null
                        hideOnExpand: false
                        fillWidth: false
                        alignment: Qt.AlignLeft
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            easing: Suru.animations.EasingIn
                            duration: Suru.animations.SnapDuration
                        }
                    }

                    function show() {
                        forceShowInNarrow = true
                    }

                    function hide() {
                        forceShowInNarrow = false
                    }

                    onBack: hide()
                    onCurrentItemChanged: {
                        if (currentItem.hasOwnProperty("shownInNarrow")) {
                            currentItem.shownInNarrow = Qt.binding(function() { return sidePage.shownInNarrow } )
                        }
                    }

                    Pages.BottomSwipeUpConnection {
                        target: sidePage.middleBottomGesture
                        enabled: !corePage.middleBottomGesture.dragging
                    }
                }
                
                Component {
                    id: profilePickerComponent

                    Common.BaseButton {
                        id: profileSwitcherButton

                        text: mainView.profiles.currentName()
                        Suru.textLevel: Suru.HeadingTwo
                        alignment: Qt.AlignLeft
                        display: AbstractButton.TextBesideIcon
                        secondaryIcon {
                            name: "go-down"
                            width: Suru.units.gu(1)
                            height: secondaryIcon.width
                            color: Suru.foregroundColor
                        }

                        onClicked: {
                            if (mainView.mainModels.profilesModel.count > 1) {
                                profileSwitcherMenuComponent.createObject(mainView.overlay).show("", profileSwitcherButton, false)
                            }
                        }
                    }
                }

                Component {
                    id: profileSwitcherMenuComponent

                    Menus.AdvancedMenu {
                        id: profilesMenu

                        type: Menus.AdvancedMenu.Type.ItemAttached
                        doNotOverlapCaller: true
                        destroyOnClose: true
                        minimumWidth: Suru.units.gu(15)
                        maximumWidth: Suru.units.gu(20)

                        Repeater {
                            id: profilesMenuItemRepeater

                            model: mainView.mainModels.profilesModel

                            Menus.BaseMenuItem {
                                readonly property int profileId: model.profileId

                                text: model ? model.displayName : ""
                                visible: profileId != mainView.settings.activeProfile
                                onTriggered: mainView.settings.activeProfile = profileId
                            }
                        }
                    }
                }
            }

            onLoaded: mainView.visible = true
        }

        Loader {
            id: newExpenseViewLoader

            active: false
            asynchronous: true
            visible: status == Loader.Ready
            anchors.fill: parent
            sourceComponent: Pages.NewExpenseView {
                currentHomeCurrency: mainView.settings.currentCurrency
                currentTravelCurrency: mainView.settings.travelCurrency
                currentExchangeRate: mainView.settings.exchangeRate
                isColoredText: mainView.settings.coloredText
                isTravelMode: mainView.settings.travelMode
                isWideLayout: mainView.isWideLayout
                dragDistance: {
                    if (mainPage.middleBottomGesture.dragging) {
                        return mainPage.middleBottomGesture.distance
                    }

                    if (sidePage.middleBottomGesture.dragging) {
                        return sidePage.middleBottomGesture.distance
                    }

                    return 0
                }
            }
        }

        Loader {
            id: popupPageLoader

            active: false
            asynchronous: true
            sourceComponent: PopupPageStack {}
        }
    }

    Common.KeyboardRectangle {
        id: keyboardRec
    }

    // Customize the global attached tooltip in QQC2 components
    Control {
        ToolTip.toolTip {
            readonly property real centeredImplicitWidth: Math.max(ToolTip.toolTip.background ? ToolTip.toolTip.background.implicitWidth : 0,
                                ToolTip.toolTip.contentItem.implicitWidth + ToolTip.toolTip.leftPadding + ToolTip.toolTip.rightPadding)
            implicitWidth: Math.min(parent.width, centeredImplicitWidth)
            contentItem: Label {
                text: ToolTip.toolTip.text
                wrapMode: Text.WordWrap
                color: Suru.backgroundColor
            }
        }
    }
}
