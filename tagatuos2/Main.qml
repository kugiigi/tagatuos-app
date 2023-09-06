import QtQuick 2.12
import Lomiri.Components 1.3 as UT
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import UserMetrics 0.1
import "library/database.js" as Database
import "library/dataUtils.js" as DataUtils
import "library/functions.js" as Functions
import "common/pages" as PageComponents
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
    
    property string displayMode: "Phone" //"Desktop" //"Phone" //"Tablet"
    property bool isWideLayout: width >= Suru.units.gu(110)
    property var dataUtils: DataUtils.dataUtils
    property var profiles: dataUtils.profiles
    property var categories: dataUtils.categories(settings.activeProfile)
    property var expenses: dataUtils.expenses(settings.activeProfile)   
    property var quickExpenses: dataUtils.quickExpenses(settings.activeProfile)   
    property var dashboard: dataUtils.dashboard(settings.activeProfile)   
    property string currentDate: Functions.getToday()

    property alias userMetric: userMetric
    property alias settings: settingsLoader.item
    property alias tooltip: globalTooltip
    property alias mainModels: listModelsLoader.item
    property alias keyboard: keyboardRec.keyboard
    property alias keyboardRectangle: keyboardRec
    property var mainPage: mainPageLoader.item.mainPage
    property var sidePage: mainPageLoader.item.sidePage
    property var detailedListPage: mainPageLoader.item.detailedListPage
    property var mainSurface: mainPageLoader.item
    property alias newExpenseView: newExpenseViewLoader.item

    readonly property bool sidePageIsOpen: sidePage && sidePage.visible

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
        var currentDataBaseVersion = Database.checkUserVersion()

        if (currentDataBaseVersion === 0) {
            Database.createInitialData()
        }

        Database.databaseUpgrade(currentDataBaseVersion)
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
        parent: mainView.mainPage
        marginTop: mainPage.mainPage ? mainPage.mainPage.pageHeader.height + Suru.units.gu(5) : 0
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
        }
    }

    FocusScope {
        id: mainFocusScope

        anchors.fill: parent

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
                    enableBottomGestureHint: true
                    enableHorizontalSwipe: true
                    enableDirectActions: true
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
                    enableBottomGestureHint: true
                    enableHorizontalSwipe: true
                    enableDirectActions: true
                    initialItem: Pages.DetailedListPage {
                        id: detailedListPage

                        isTravelMode: mainView.settings.travelMode
                        travelCurrency: mainView.settings.travelCurrency
                    }

                    visible: opacity > 0
                    opacity: mainView.isWideLayout || forceShowInNarrow ? 1 : 0

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
