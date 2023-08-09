import QtQuick 2.12
import Qt.labs.settings 1.0
import "../library/Currencies.js" as Currencies
import "../common" as Common

Item {
    id: tempSettings

    property alias currentTheme: settingsItem.currentTheme
    property alias currentCurrency: settingsItem.currentCurrency
//~         property alias dashboardItems: settingsItem.dashboardItems
//~         property alias dashboardItemsOrder: settingsItem.dashboardItemsOrder
//~         property alias startDashboard: settingsItem.startDashboard
//~         property alias startingPageIndex: settingsItem.startingPageIndex
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
    //~     property string currentTheme: "Ubuntu.Components.Themes.Ambiance"
        property string currentCurrency: "PHP"
    //~     property string dashboardItems: "Today;Recent;This Week"
    //~     property string dashboardItemsOrder: "Today;Yesterday;Recent;This Week;This Month;Last Week;Last Month"
    //~     property bool startDashboard: true
    //~     property int startingPageIndex: 1
        property bool hideBottomHint: false
        property string currentTheme: "System"
        property bool coloredText: true

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

        property bool enableHaptics: true
    }
}
