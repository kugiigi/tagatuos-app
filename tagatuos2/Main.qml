import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Layouts 1.0
import Qt.labs.settings 1.0
import UserMetrics 0.1
import "components"
import "components/ListModels"
import "components/Common"
import "ui"
import "library/DataProcess.js" as DataProcess
import "library/Currencies.js" as Currencies


/*!
    \brief MainView with a Label and Button elements.
    */
MainView {
    id: mainView
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "tagatuos2.kugiigi"

    property string displayMode: "Phone" //"Desktop" //"Phone" //"Tablet"

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

    anchorToKeyboard: true
    theme.name: tempSettings.currentTheme

    property string current_version: "0.82"
    property alias mainPage: mainPageLoader.item
    property alias addBottomEdge: addBottomEdge
    property alias listModels: listModelsLoader.item //listModels
    property alias tempSettings: settingsLoader.item

    // For Debugging only
    property bool showBottomEdgeHint: false
    
    Metric {
        id: userMetric
        
        property string circleMetric

        name: "expenseCounter"
        format: circleMetric
        emptyFormat: i18n.tr("No expense yet for today")
        domain: "tagatuos2.kugiigi"
    }

    Component.onCompleted: {
        /*Meta data processing*/
        var currentDataBaseVersion = DataProcess.checkUserVersion()

        if (currentDataBaseVersion === 0) {
            DataProcess.createInitialData()
        }

        DataProcess.databaseUpgrade(currentDataBaseVersion)
        settingsLoader.active = true
    }

    Loader {
        id: settingsLoader

        active: false
        asynchronous: true
        sourceComponent: tempSettingsComponent

        onLoaded: {
            listModelsLoader.active = true
        }
    }

    Component {
        id: tempSettingsComponent
        Item {
            id: tempSettings
            property string currentTheme: "Ubuntu.Components.Themes.Ambiance"
            property string currentCurrency: "PHP"
            property string dashboardItems: "Today;Recent;This Week"
            property string dashboardItemsOrder: "Today;Yesterday;Recent;This Week;This Month;Last Week;Last Month"
            property bool startDashboard: true
            property int startingPageIndex: 1
            property bool hideBottomHint: false

            //TODO: Temporary only
            property bool travelMode: false
            property string travelCurrency: "USD"
            property real exchangeRate: 1.0
            property bool fetchExchangeRate: false
            property string exchangeRateJSON: ""
            property string exchangeRateDate: ""

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


            //        onDashboardItemsChanged: mainView.listModels.dashboardModel.initialise()
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
            }

            Settings {
                property alias currentTheme: tempSettings.currentTheme
                property alias currentCurrency: tempSettings.currentCurrency
                property alias dashboardItems: tempSettings.dashboardItems
                property alias dashboardItemsOrder: tempSettings.dashboardItemsOrder
                property alias startDashboard: tempSettings.startDashboard
                property alias startingPageIndex: tempSettings.startingPageIndex
                property alias hideBottomHint: tempSettings.hideBottomHint

                property alias travelMode: tempSettings.travelMode
                property alias travelCurrency: tempSettings.travelCurrency
                property alias exchangeRate: tempSettings.exchangeRate
                property alias fetchExchangeRate: tempSettings.fetchExchangeRate
                property alias exchangeRateJSON: tempSettings.exchangeRateJSON
                property alias exchangeRateDate: tempSettings.exchangeRateDate
            }
        }
    }

    Loader {
        id: listModelsLoader

        active: false
        asynchronous: true
        sourceComponent: listModelsComponent

        onLoaded: {
            listModels.modelCategories.getItems()
            mainPageLoader.active = true
        }
    }

    Component {
        id: listModelsComponent
        ListModels {
            id: listModels

            //        Component.onCompleted: {
            //            modelCategories.getItems()
            //        }
            Connections {
                target: tempSettings
                onDashboardItemsChanged: {
                    dashboardModel.initialise()
                }
            }
        }
    }

    PageStack {
        id: mainPageStack

        Loader {
            id: mainPageLoader
            active: false
            asynchronous: true
            source: "ui/MainPage.qml" //"ui/Dashboard.qml"

            visible: status == Loader.Ready

            onLoaded: {
                mainPageStack.push(mainPageLoader.item)
                mainPage.detailView.applyLayoutChanges()
            }
        }

        Loader {
            id: addFullPageLoader

            property string mode: "add"
            property string itemID
            active: false
            asynchronous: true
            sourceComponent: addFullPageComponent

            visible: status == Loader.Ready

            onLoaded: {
                addBottomEdge.collapse()
                switch (mode) {
                case "add":
                    addBottomEdge.collapse()
                    addFullPageLoader.item.mode = "add"
                    addFullPageLoader.item.type = "expense"
                    mainPageStack.push(addFullPageLoader.item)
                    break
                case "edit":
                    addBottomEdge.collapse()
                    addFullPageLoader.item.mode = "edit"
                    addFullPageLoader.item.type = "expense"
                    addFullPageLoader.item.itemID = itemID
                    mainPageStack.push(addFullPageLoader.item)
                    break
                }
            }
        }

        Component {
            id: addFullPageComponent
            AddFullPage {
                id: addFullPage
                onCancel: {
                    mainPageStack.pop()
                }

                onSaved: {
                    mainPageStack.pop()
                }
            }
        }

        function addExpense() {
            addFullPageLoader.mode = "add"
            addFullPageLoader.active = true
            if (addFullPageLoader.item) {
                addFullPageLoader.item.mode = "add"
                addFullPageLoader.item.type = "expense"
                mainPageStack.push(addFullPageLoader.item)
            }
        }

        function editExpense(expense_id) {
            addFullPageLoader.mode = "edit"
            addFullPageLoader.itemID = expense_id
            addFullPageLoader.active = true
            if (addFullPageLoader.item) {
                addFullPageLoader.item.mode = "edit"
                addFullPageLoader.item.type = "expense"
                addFullPageLoader.item.itemID = expense_id
                mainPageStack.push(addFullPageLoader.item)
            }
        }
    }

    AddBottomEdge {
        id: addBottomEdge

        onCommitCompleted: {
            visible = showBottomEdgeHint //false
            enabled = showBottomEdgeHint //false
            hint.visible = showBottomEdgeHint //false
        }

        //Component.onCompleted: QuickUtils.mouseAttached = true
    }

    Connections {
        id: keyboard
        target: Qt.inputMethod
    }
}
