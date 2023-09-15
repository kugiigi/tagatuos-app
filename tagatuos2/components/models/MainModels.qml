import QtQuick 2.12
import Lomiri.Components 1.3 as UT
import "../../library/dataUtils.js" as DataUtils
import "../../library/functions.js" as Functions
import "../../library/ApplicationFunctions.js" as AppFunctions
import "../../common/" as Common

Item {
    id: mainModels

    readonly property string profilesID: "Profiles"
    readonly property string currenciesID: "Currencies"
    readonly property string categoriesID: "Categories"
    readonly property string firstDetailedListID: "Detailed_1"
    readonly property string secondDetailedListID: "Detailed_2"
    readonly property string thirdDetailedListID: "Detailed_3"
    readonly property string quickExpensesID: "QuickExpenses"
    readonly property string historyEntryExpensesID: "HistoryEntry"
    readonly property string searchExpenseID: "SearchExpense"

    readonly property string todayBreakdownChartID: "TodayBreakdownChart"
    readonly property string thisWeekBreakdownChartID: "ThisWeekBreakdownChart"
    readonly property string thisMonthBreakdownChartID: "ThisMonthBreakdownChart"
    readonly property string thisYearBreakdownChartID: "ThisYearBreakdownChart"
    readonly property string recentBreakdownChartID: "RecentBreakdownChart"

    readonly property string thisWeekTrendChartID: "ThisWeekTrendChart"
    readonly property string recentTrendChartID: "RecentTrendChart"
    readonly property string thisMonthTrendChartID: "ThisMonthTrendChart"
    readonly property string thisYearTrendChartID: "ThisYearTrendChart"
    
    property alias profilesModel: profilesModel
    property var detailedListModels: [ firstDetailedListModel, secondDetailedListModel, thirdDetailedListModel ]
    property alias firstDetailedListModel: firstDetailedListModel
    property alias secondDetailedListModel: secondDetailedListModel
    property alias thirdDetailedListModel: thirdDetailedListModel
    property alias exchangeRatesModel: exchangeRatesModel
    property alias currenciesModel: currenciesModel
    property alias categoriesModel: categoriesModel
    property alias quickExpensesModel: quickExpensesModel
    property alias historyEntryExpensesModel: historyEntryExpensesModel

    property alias searchExpenseModel: searchExpenseModel

    // Breakdown Chart Models
    property alias todayBreakdownChartModel: todayBreakdownChartModel
    property alias thisWeekBreakdownChartModel: thisWeekBreakdownChartModel
    property alias thisMonthBreakdownChartModel: thisMonthBreakdownChartModel
    property alias thisYearBreakdownChartModel: thisYearBreakdownChartModel
    property alias recentBreakdownChartModel: recentBreakdownChartModel
    
    // Trend Chart Models
    property alias thisWeekTrendChartModel: thisWeekTrendChartModel
    property alias recentTrendChartModel: recentTrendChartModel
    property alias thisMonthTrendChartModel: thisMonthTrendChartModel
    property alias thisYearTrendChartModel: thisYearTrendChartModel

    // Refresh models that are affected by new, edited or deleted expense values
    function refreshValues(entryDate, expenseID) {
        if (entryDate) {
            // Refresh quick history model
            if (Functions.isToday(entryDate)) {
                historyEntryExpensesModel.refresh()
            }

            // Refresh detailed list models
            if (Functions.checkIfWithinDateRange(entryDate, firstDetailedListModel.fromDate, firstDetailedListModel.toDate)) {
                firstDetailedListModel.refresh()
            }

            if (Functions.checkIfWithinDateRange(entryDate, secondDetailedListModel.fromDate, secondDetailedListModel.toDate)) {
                secondDetailedListModel.refresh()
            }

            if (Functions.checkIfWithinDateRange(entryDate, thirdDetailedListModel.fromDate, thirdDetailedListModel.toDate)) {
                thirdDetailedListModel.refresh()
            }

            // Refresh breakdown chart models
            if (Functions.checkIfWithinDateRange(entryDate, todayBreakdownChartModel.getFromDate(), todayBreakdownChartModel.getToDate())) {
                todayBreakdownChartModel.refresh()
            }

            if (Functions.checkIfWithinDateRange(entryDate, thisWeekBreakdownChartModel.getFromDate(), thisWeekBreakdownChartModel.getToDate())) {
                thisWeekBreakdownChartModel.refresh()
            }

            if (Functions.checkIfWithinDateRange(entryDate, thisMonthBreakdownChartModel.getFromDate(), thisMonthBreakdownChartModel.getToDate())) {
                thisMonthBreakdownChartModel.refresh()
            }

            if (Functions.checkIfWithinDateRange(entryDate, thisYearBreakdownChartModel.getFromDate(), thisYearBreakdownChartModel.getToDate())) {
                thisYearBreakdownChartModel.refresh()
            }

            if (Functions.checkIfWithinDateRange(entryDate, recentBreakdownChartModel.getFromDate(), recentBreakdownChartModel.getToDate())) {
                recentBreakdownChartModel.refresh()
            }

            // Refresh trend chart models
            if (Functions.checkIfWithinDateRange(entryDate, thisWeekTrendChartModel.getFromDate(), thisWeekTrendChartModel.getToDate())) {
                thisWeekTrendChartModel.refresh()
            }

            if (Functions.checkIfWithinDateRange(entryDate, thisMonthTrendChartModel.getFromDate(), thisMonthTrendChartModel.getToDate())) {
                thisMonthTrendChartModel.refresh()
            }

            if (Functions.checkIfWithinDateRange(entryDate, thisYearTrendChartModel.getFromDate(), thisYearTrendChartModel.getToDate())) {
                thisYearTrendChartModel.refresh()
            }

            if (Functions.checkIfWithinDateRange(entryDate, recentTrendChartModel.getFromDate(), recentTrendChartModel.getToDate())) {
                recentTrendChartModel.refresh()
            }
        }

        if (expenseID) {
            if (searchExpenseModel.find(expenseID, "expense_id") > -1) {
                searchExpenseModel.refresh()
            }
        }
    }

    // Refreshes all data relevant to the active profile
    function refreshAllProfileData() {
        firstDetailedListModel.refresh()
        secondDetailedListModel.refresh()
        thirdDetailedListModel.refresh()

        categoriesModel.refresh()
        quickExpensesModel.refresh()
        historyEntryExpensesModel.refresh()
        searchExpenseModel.refresh()

        // Breakdown Chart Models
        todayBreakdownChartModel.refresh()
        thisWeekBreakdownChartModel.refresh()
        thisMonthBreakdownChartModel.refresh()
        thisYearBreakdownChartModel.refresh()
        recentBreakdownChartModel.refresh()

        // Trend Chart Models
        thisWeekTrendChartModel.refresh()
        recentTrendChartModel.refresh()
        thisMonthTrendChartModel.refresh()
        thisYearTrendChartModel.refresh()
    }

    function refreshQuickExpense() {
        quickExpensesModel.refresh()
    }

    function refreshProfiles() {
        profilesModel.refresh()
    }

    function refreshCategories(operation = "ADD") {
        switch(operation) {
            case "EDIT":
                // Refresh all data with category to take effect
                refreshAllProfileData() // Same list for now
                break
            case "DELETE":
                categoriesModel.refresh()
                quickExpensesModel.refresh() // Since they are deleted too
                break
            case "ADD":
            default:
                categoriesModel.refresh()
                break
        }
    }

    /*WorkerScript for asynch loading of models*/
    WorkerScript {
        id: workerLoader
        source: "ModelWorkerScript.mjs"

        onMessage: {
            switch (messageObject.modelId) {
            case mainModels.profilesID:
                profilesModel.loadingStatus = "Ready"
                break;
            case mainModels.currenciesID:
                currenciesModel.loadingStatus = "Ready"
                break
            case mainModels.categoriesID:
                categoriesModel.loadingStatus = "Ready"
                break
            case mainModels.quickExpensesID:
                quickExpensesModel.loadingStatus = "Ready"
                break
            case mainModels.historyEntryExpensesID:
                historyEntryExpensesModel.loadingStatus = "Ready"
                break

            case mainModels.searchExpenseID:
                searchExpenseModel.loadingStatus = "Ready"
                break

            // Detailed List Models
            case mainModels.firstDetailedListID:
                firstDetailedListModel.summaryValues = messageObject.result
                firstDetailedListModel.loadingStatus = "Ready"
                break;
            case mainModels.secondDetailedListID:
                secondDetailedListModel.summaryValues = messageObject.result
                secondDetailedListModel.loadingStatus = "Ready"
                break;
            case mainModels.thirdDetailedListID:
                thirdDetailedListModel.summaryValues = messageObject.result
                thirdDetailedListModel.loadingStatus = "Ready"
                break;

            // Breakdown Chart Models
            case mainModels.todayBreakdownChartID:
                todayBreakdownChartModel.loadingStatus = "Ready"
                break;
            case mainModels.thisWeekBreakdownChartID:
                thisWeekBreakdownChartModel.loadingStatus = "Ready"
                break;
            case mainModels.thisMonthBreakdownChartID:
                thisMonthBreakdownChartModel.loadingStatus = "Ready"
                break;
            case mainModels.thisYearBreakdownChartID:
                thisYearBreakdownChartModel.loadingStatus = "Ready"
                break;
            case mainModels.recentBreakdownChartID:
                recentBreakdownChartModel.loadingStatus = "Ready"
                break;
            case mainModels.recentBreakdownChartID:
                recentBreakdownChartModel.loadingStatus = "Ready"
                break;

            // Trend Chart Models
            case mainModels.thisWeekTrendChartID:
                thisWeekTrendChartModel.loadingStatus = "Ready"
                thisWeekTrendChartModel.modelData = messageObject.result
                break;
            case mainModels.recentTrendChartID:
                recentTrendChartModel.loadingStatus = "Ready"
                recentTrendChartModel.modelData = messageObject.result
                break;
            case mainModels.thisMonthTrendChartID:
                thisMonthTrendChartModel.loadingStatus = "Ready"
                thisMonthTrendChartModel.modelData = messageObject.result
                break;
            case mainModels.thisYearTrendChartID:
                thisYearTrendChartModel.loadingStatus = "Ready"
                thisYearTrendChartModel.modelData = messageObject.result
                break;
            }
        }
    }

    Common.BaseListModel {
        id: profilesModel
  
        worker: workerLoader
        modelId: mainModels.profilesID
        Component.onCompleted: refresh()
        
        function refresh() {
            fillData(mainView.profiles.list())
        }
    }
    
    Common.BaseListModel {
        id: currenciesModel

        modelId: mainModels.currenciesID
        worker: workerLoader
        Component.onCompleted: refresh()

        function refresh() {
            fillData(mainView.currencies.list())
        }
    }
    
    QtObject {
        id: exchangeRatesModel

        property var data: JSON.parse(mainView.settings.exchangeRateJSON)
        property string appID: "624288a2010b46efa678686799b33599" //openexchangerates app ID
        property string requestURL: encodeURI("https://openexchangerates.org/api/latest.json?app_id=" + appID)

        property string tempJSON: '{
                                "disclaimer": "Usage subject to terms: https://openexchangerates.org/terms",
                               "license": "https://openexchangerates.org/license",
                               "timestamp": 1534424400,
                               "base": "USD",
                               "rates": {
                                 "AED": 3.673158,
                                 "AFN": 72.750697,
                                 "ALL": 110.22,
                                 "AMD": 482.840272,
                                 "EUR": 0.879867,
                                 "PHP": 53.478,
                                 "USD": 1
                                 }
                                }'
        function fetchLatestJSON(callback) {
            let _xhr = new XMLHttpRequest();

            _xhr.onreadystatechange = function() {
                if (_xhr.readyState == 4) {
                    if (_xhr.status == 200) {
                        console.log("exchange rate fetch success")
                        mainView.settings.exchangeRateJSON = _xhr.responseText
                        mainView.settings.exchangeRateDate = Functions.getToday()
                        callback(true)
                    } else {
                        console.log('Failed to fetch exchange rate list');
                        callback(false)
                    }
                }
            };

            _xhr.open('GET', requestURL, true);
            _xhr.send();

        }
    }

    Common.BaseListModel {
        id: categoriesModel

        modelId: mainModels.categoriesID
        worker: workerLoader
        Component.onCompleted: refresh()

        function refresh() {
            fillData(mainView.categories.list())
        }

        function getColor(category) {
            for (let i = 0; i < count; i++) {
                if (get(i).category_name === category) {
                    return get(i).colorValue
                }
            }
        }
    }

    Common.BaseListModel {
        id: quickExpensesModel
  
        worker: workerLoader
        modelId: mainModels.quickExpensesID
        Component.onCompleted: refresh()

        function refresh() {
            fillData(mainView.quickExpenses.list())
        }
    }

    Common.BaseListModel {
        id: historyEntryExpensesModel

        property string searchText: ""
        property int resultLimit: 10

        worker: workerLoader
        modelId: mainModels.historyEntryExpensesID
        Component.onCompleted: refresh()

        onSearchTextChanged: refresh()

        function refresh() {
            fillData(mainView.expenses.historyDataForEntry(searchText, resultLimit))
        }
    }
    
    // Search Expense model
    Common.BaseListModel {
        id: searchExpenseModel

        property string searchText: ""
        property string order: "desc"
        property int resultLimit: 50

        modelId: mainModels.searchExpenseID
        worker: workerLoader

        function refresh() {
            fillData(mainView.expenses.search(searchText, resultLimit, order))
        }

        Component.onCompleted: refresh()

        onSearchTextChanged: refresh()
        onOrderChanged: refresh()
    }

    // Detailed List Models
    BaseValuesModel {
        id: firstDetailedListModel

        modelId: mainModels.firstDetailedListID
        worker: workerLoader
    }

    BaseValuesModel {
        id: secondDetailedListModel

        modelId: mainModels.secondDetailedListID
        worker: workerLoader
    }

    BaseValuesModel {
        id: thirdDetailedListModel

        modelId: mainModels.thirdDetailedListID
        worker: workerLoader
    }

    // Breakdown Charts
    BreakdownChartModel {
        id: todayBreakdownChartModel

        dataID: "today"
        modelFunction: mainView.dashboard.breakdown
        worker: workerLoader
        modelId: mainModels.todayBreakdownChartID
        onReadyChanged: {
            if (ready) {
                let _currentProfileName = mainView.profiles.currentName()
                let _currentData = get(0).data
                let _newMetricMsg = ""
                let _total = 0

                if (_currentProfileName) {
                    _newMetricMsg = "<b>" + i18n.tr("Today's expenses [%1]:<br>").arg(_currentProfileName) + "</b>"
                } else {
                    _newMetricMsg = "<b>" + i18n.tr("Today's expenses:<br>") + "</b>"
                }

                for (let i = 0; i < _currentData.count; i++) {
                    let _currentItem = _currentData.get(i)
                    let _label = _currentItem.label
                    let _value = _currentItem.value

                    _total += _value
                    _newMetricMsg = _newMetricMsg + "<br>%1 - %2".arg(_label).arg(AppFunctions.formatMoney(_value))
                    
                }

                if (_total > 0) {
                    _newMetricMsg = _newMetricMsg + "<br><br><i>" + i18n.tr("Total: <b>%1</b>").arg(AppFunctions.formatMoney(_total)) + "</i>"
                    mainView.userMetric.circleMetric = _newMetricMsg
                    mainView.userMetric.increment(1)
                } else {
                    mainView.userMetric.circleMetric = mainView.userMetric.emptyFormat
                }
            }
        }
    }

    BreakdownChartModel {
        id: thisWeekBreakdownChartModel

        dataID: "thisweek"
        modelFunction: mainView.dashboard.breakdown
        worker: workerLoader
        modelId: mainModels.thisWeekBreakdownChartID
    }

    BreakdownChartModel {
        id: thisMonthBreakdownChartModel

        dataID: "thismonth"
        modelFunction: mainView.dashboard.breakdown
        worker: workerLoader
        modelId: mainModels.thisMonthBreakdownChartID
    }

    BreakdownChartModel {
        id: thisYearBreakdownChartModel

        dataID: "thisyear"
        modelFunction: mainView.dashboard.breakdown
        worker: workerLoader
        modelId: mainModels.thisYearBreakdownChartID
    }

    BreakdownChartModel {
        id: recentBreakdownChartModel

        dataID: "recent"
        modelFunction: mainView.dashboard.breakdown
        worker: workerLoader
        modelId: mainModels.recentBreakdownChartID
    }

    // Trend Chart Models
    TrendChartModel {
        id: thisWeekTrendChartModel

        chartRange: "thisweek"
        chartMode: "day"
        modelFunction: mainView.dashboard.trend
        worker: workerLoader
        modelId: mainModels.thisWeekTrendChartID
    }

    TrendChartModel {
        id: recentTrendChartModel

        chartRange: "recent"
        chartMode: "day"
        modelFunction: mainView.dashboard.trend
        worker: workerLoader
        modelId: mainModels.recentTrendChartID
    }

    TrendChartModel {
        id: thisMonthTrendChartModel

        chartRange: "thismonth"
        chartMode: "week"
        modelFunction: mainView.dashboard.trend
        worker: workerLoader
        modelId: mainModels.thisMonthTrendChartID
    }

    TrendChartModel {
        id: thisYearTrendChartModel

        chartRange: "thisyear"
        chartMode: "month"
        modelFunction: mainView.dashboard.trend
        worker: workerLoader
        modelId: mainModels.thisYearTrendChartID
    }

    Connections {
        target: mainView

        // Refresh 
        onCurrentDateChanged: {
            mainModels.refreshValues(currentDate)
        }
    }

    Connections {
        target: mainView.settings
        onActiveProfileChanged: {
            refreshAllProfileData()
        }
    }
}
