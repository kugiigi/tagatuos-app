import QtQuick 2.12
import Qt.labs.settings 1.0
import "../library/Currencies.js" as Currencies
import "../common" as Common
import "../components/pages/newexpenseview" as NewExpenseView

Item {
    id: tempSettings

    property alias currentTheme: settingsItem.currentTheme
    property alias currentCurrency: settingsItem.currentCurrency
    property alias hideBottomHint: settingsItem.hideBottomHint
    property alias enableHaptics: settingsItem.enableHaptics

    property alias travelMode: settingsItem.travelMode
    property alias travelCurrency: settingsItem.travelCurrency
    property alias exchangeRate: settingsItem.exchangeRate
    property alias fetchExchangeRate: settingsItem.fetchExchangeRate
    property alias exchangeRateJSON: settingsItem.exchangeRateJSON
    property alias exchangeRateDate: settingsItem.exchangeRateDate
    property alias coloredText: settingsItem.coloredText
    property alias activeProfile: settingsItem.activeProfile

    property alias tagOfTheDayDate: settingsItem.tagOfTheDayDate
    property alias tagOfTheDay: settingsItem.tagOfTheDay

    // Interface
    property alias scrollPositionerPosition: settingsItem.scrollPositionerPosition
    property alias scrollPositionerSize: settingsItem.scrollPositionerSize
    property alias enableFastDateScroll: settingsItem.enableFastDateScroll
    property alias quickExpenseDisplayType: settingsItem.quickExpenseDisplayType

    //Detailed List Page
    property alias detailedListScope: settingsItem.detailedListScope
    property alias detailedListSort: settingsItem.detailedListSort
    property alias detailedListOrder: settingsItem.detailedListOrder
    property alias detailedListColoredCategory: settingsItem.detailedListColoredCategory

    // Gestures
    property alias horizontalSwipe: settingsItem.horizontalSwipe
    property alias horizontalDirectActions: settingsItem.horizontalDirectActions
    property alias horizontalDirectActionsSensitivity: settingsItem.horizontalDirectActionsSensitivity
    property alias sideSwipe: settingsItem.sideSwipe
    property alias directActions: settingsItem.directActions
    property alias quickActionsHeight: settingsItem.quickActionsHeight
    property alias quickSideSwipe: settingsItem.quickSideSwipe
    property alias quickActionEnableDelay: settingsItem.quickActionEnableDelay
    property alias headerPullDown: settingsItem.headerPullDown
    property alias bottomGesturesAreaHeight: settingsItem.bottomGesturesAreaHeight
    property alias enableHeaderSwipeGesture: settingsItem.enableHeaderSwipeGesture

    // Session Settings (not stored)
    property string currentCurrencySymbol: "8369"
    property string currentCurrencyDecimal: "."
    property string currentCurrencyThousand: ","
    property int currentCurrencyPrecision: 2
    property string currentCurrencyFormat: "%s%v"

    property string travelCurrencySymbol: "$"
    property string travelCurrencyDecimal: "."
    property string travelCurrencyThousand: ","
    property int travelCurrencyPrecision: 2
    property string travelCurrencyFormat: "%s%v"

    function loadCurrencyData() {
        var currency = Currencies.currency(currentCurrency)

        currentCurrencySymbol = currency.symbol
        currentCurrencyDecimal = currency.decimal
        currentCurrencyThousand = currency.thousand
        currentCurrencyPrecision = currency.precision
        currentCurrencyFormat = currency.format
    }

    function loadTravelCurrencyData() {
        var currency = Currencies.currency(travelCurrency)

        travelCurrencySymbol = currency.symbol
        travelCurrencyDecimal = currency.decimal
        travelCurrencyThousand = currency.thousand
        travelCurrencyPrecision = currency.precision
        travelCurrencyFormat = currency.format
    }


    onCurrentCurrencyChanged: {
        loadCurrencyData()
    }

    onTravelCurrencyChanged: {
        loadTravelCurrencyData()
    }

    // Initiate temporary values
    Component.onCompleted: {
        loadCurrencyData()
        loadTravelCurrencyData()
        Common.Haptics.enabled = Qt.binding( function() { return enableHaptics } )
    }

    Settings {
        id: settingsItem

        // Settings
        property string currentCurrency: "PHP"
        property bool hideBottomHint: false
        property string currentTheme: "System"

        //Saved data
        property int activeProfile: 1
        property bool firstRun: true

        //TODO: Temporary only
        property bool travelMode: false
        property string travelCurrency: "USD"
        property real exchangeRate: 1.0
        property bool fetchExchangeRate: false
        property string exchangeRateJSON: ""
        property string exchangeRateDate: ""

        property bool coloredText: true
        property bool enableHaptics: true

        property string detailedListScope: "day"
        property string detailedListSort: "category"
        property string detailedListOrder: "asc"
        property bool detailedListColoredCategory: false

        property bool horizontalSwipe: true
        property bool sideSwipe: false
        property bool directActions: false
        property real quickActionsHeight: 3
        property bool quickSideSwipe: false
        property bool quickActionEnableDelay: false
        property bool headerPullDown: true
        property real bottomGesturesAreaHeight: 2
        property bool horizontalDirectActions: false
        property real horizontalDirectActionsSensitivity: 0.5

        property int scrollPositionerPosition: Common.ScrollPositionerItem.Position.Right
        /*
         * ScrollPositionerItem.Position.Right
         * ScrollPositionerItem.Position.Left
         * ScrollPositionerItem.Position.Middle
        */
        property int scrollPositionerSize: 8 // In Grid Units

        property bool enableFastDateScroll: true
        property bool enableHeaderSwipeGesture: true
        property string tagOfTheDayDate: ""
        property string tagOfTheDay: ""
        property int quickExpenseDisplayType: NewExpenseView.QuickListGridView.GridType.Rectangle
    }
}
