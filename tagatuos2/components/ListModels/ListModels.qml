import QtQuick 2.9
import Ubuntu.Components 1.3
import "../../library/DataProcess.js" as DataProcess
import "../../library/ProcessFunc.js" as Process
import "../../library/ApplicationFunctions.js" as AppFunctions

Item {
    id: lists

    property alias modelSortFilterExpense: modelSortFilterExpense
    property alias modelTodayExpenses: modelTodayExpenses
    property alias modelRecentExpenses: modelRecentExpenses
    property alias modelYesterdayExpenses: modelYesterdayExpenses
    property alias modelThisWeekExpenses: modelThisWeekExpenses
    property alias modelThisMonthExpenses: modelThisMonthExpenses
    property alias modelLastWeekExpenses: modelLastWeekExpenses
    property alias modelLastMonthExpenses: modelLastMonthExpenses
    property alias modelCalendarExpenses: modelCalendarExpenses
    property alias modelCategories: modelCategories
    property alias modelExpenseAutoComplete: modelExpenseAutoComplete
    property alias modelReports: modelReports
    property alias modelQuickAdd: modelQuickAdd
    property alias dashboardModel: dashboardModel
    property alias modelCurrencies: modelCurrencies
    property alias modelExchangeRates: modelExchangeRates

    /*WorkerScript for asynch loading of models*/
    WorkerScript {
        id: workerLoader
        source: "../../library/WorkerScripts/ListModelLoader.js"

        onMessage: {
            switch (messageObject.mode) {
            case "Expenses":
                console.log("modelExpenses: " + modelExpenses.count)
                modelExpenses.loadingStatus = "Ready"
                modelLoader.active = true
                //                sortFilterExpenseModel.model = modelExpenses
                break
            case "Today":
                console.log("modelTodayExpenses: " + modelTodayExpenses.count)
                modelTodayExpenses.loadingStatus = "Ready"
                break
            case "Recent":
                console.log("modelRecentExpenses: " + modelRecentExpenses.count)
                modelRecentExpenses.loadingStatus = "Ready"
                break
            case "Yesterday":
                console.log("modelYesterdayExpenses: " + modelYesterdayExpenses.count)
                modelYesterdayExpenses.loadingStatus = "Ready"
                break
            case "This Week":
                console.log("modelThisWeekExpenses: " + modelThisWeekExpenses.count)
                modelThisWeekExpenses.loadingStatus = "Ready"
                break
            case "This Month":
                console.log("modelThisMonthExpenses: " + modelThisMonthExpenses.count)
                modelThisMonthExpenses.loadingStatus = "Ready"
                break
            case "Last Week":
                console.log("modelLastWeekExpenses: " + modelLastWeekExpenses.count)
                modelLastWeekExpenses.loadingStatus = "Ready"
                break
            case "Last Month":
                console.log("modelLastMonthExpenses: " + modelLastMonthExpenses.count)
                modelLastMonthExpenses.loadingStatus = "Ready"
                break
            case "Calendar (By Day)":

            case "Calendar (By Week)":

            case "Calendar (By Month)":

            case "Calendar (Custom)":
                console.log("modelCalendarExpenses: " + modelCalendarExpenses.count)
                modelCalendarExpenses.loadingStatus = "Ready"
                break
            case "ExpenseAutoComplete":
                modelExpenseAutoComplete.loadingStatus = "Ready"
                break
            case "Categories":
                modelCategories.loadingStatus = "Ready"
                break
            case "Reports":
                modelReports.loadingStatus = "Ready"
                break
            case "QuickAdd":

            case "QuickRecent":

            case "QuickTop":
                modelQuickAdd.loadingStatus = "Ready"
                break
            case "Currencies":
                modelCurrencies.loadingStatus = "Ready"
                break
            }
        }
    }

    /******functions********/
    function addItem(newItem) {
        var dateGroup = Process.groupDate(newItem.date)

        if (dateGroup.search("Today") >= 0) {
            addNewItem(modelTodayExpenses, newItem)
        }

        if (dateGroup.search("Yesterday") >= 0) {
            addNewItem(modelYesterdayExpenses, newItem)
        }

        if (dateGroup.search("This Week") >= 0) {
            addNewItem(modelThisWeekExpenses, newItem)
        }

        if (dateGroup.search("This Month") >= 0) {
            addNewItem(modelThisMonthExpenses, newItem)
        }

        if (dateGroup.search("Recent") >= 0) {
            addNewItem(modelRecentExpenses, newItem)
        }

        if (dateGroup.search("Last Week") >= 0) {
            addNewItem(modelLastWeekExpenses, newItem)
        }

        if (dateGroup.search("Last Month") >= 0) {
            addNewItem(modelLastMonthExpenses, newItem)
        }
    }

    function updateItem(updatedItem) {
        var dateGroup = Process.groupDate(updatedItem.date)

        if (dateGroup.search("Today") >= 0) {
            updateItemInModel(modelTodayExpenses, updatedItem)
        }

        if (dateGroup.search("Yesterday") >= 0) {
            updateItemInModel(modelYesterdayExpenses, updatedItem)
        }

        if (dateGroup.search("This Week") >= 0) {
            updateItemInModel(modelThisWeekExpenses, updatedItem)
        }

        if (dateGroup.search("This Month") >= 0) {
            updateItemInModel(modelThisMonthExpenses, updatedItem)
        }

        if (dateGroup.search("Recent") >= 0) {
            updateItemInModel(modelRecentExpenses, updatedItem)
        }

        if (dateGroup.search("Last Week") >= 0) {
            updateItemInModel(modelLastWeekExpenses, updatedItem)
        }

        if (dateGroup.search("Last Month") >= 0) {
            updateItemInModel(modelLastMonthExpenses, updatedItem)
        }
    }

    function deleteItem(id) {
        var expenseData = getExpenseDetails(id)
        var dateGroup = Process.groupDate(expenseData.date)
        DataProcess.deleteExpense(id)

        if (dateGroup.search("Today") >= 0) {
            deleteItemInModel(modelTodayExpenses, id)
        }

        if (dateGroup.search("Yesterday") >= 0) {
            deleteItemInModel(modelYesterdayExpenses, id)
        }

        if (dateGroup.search("This Week") >= 0) {
            deleteItemInModel(modelThisWeekExpenses, id)
        }

        if (dateGroup.search("This Month") >= 0) {
            deleteItemInModel(modelThisMonthExpenses, id)
        }

        if (dateGroup.search("Recent") >= 0) {
            deleteItemInModel(modelRecentExpenses, id)
        }

        if (dateGroup.search("Last Week") >= 0) {
            deleteItemInModel(modelLastWeekExpenses, id)
        }

        if (dateGroup.search("Last Month") >= 0) {
            deleteItemInModel(modelLastMonthExpenses, id)
        }
    }

    function getExpenseDetails(id) {
        var expenseData = DataProcess.getExpenseData(id)

        return expenseData
    }

    //add the new item to the appropriate model
    function addNewItem(model, newItem) {
        var sortGroupFound = false

        for (var i = 0; i < model.count; i++) {
            var sortValue = model.get(i).category_name

            if (sortValue === newItem.category_name) {
                sortGroupFound = true
                break
            }
        }

        if (sortGroupFound) {
            var totalValue = model.get(i).total
            var currentCount = model.get(i).count

            model.get(i).childModel.insert(0, {
                                               expense_id: newItem.expense_id,
                                               category_name: newItem.category_name,
                                               name: newItem.name,
                                               descr: newItem.descr,
                                               date: Process.relativeDate(
                                                         newItem.date,
                                                         "ddd, MMM d, yyyy",
                                                         "Basic"),
                                               dateValue: newItem.date,
                                               value: newItem.value,
                                               homeCur: typeof newItem.travel !== "undefined" ? newItem.travel.homeCur : "",
                                               travelCur: typeof newItem.travel !== "undefined" ? newItem.travel.travelCur : "",
                                               rate: typeof newItem.travel !== "undefined" ? newItem.travel.rate : 0,
                                               travel_value: typeof newItem.travel !== "undefined" ? newItem.travel.value : 0
                                           })

//            model.setProperty(i, "total", Math.round(
//                                  (totalValue + newItem.value) * 100) / 100)
            model.setProperty(i, "total", (totalValue + newItem.value))
            model.setProperty(i, "count", currentCount + 1)
        } else {
            var childArray = []

            childArray.push({
                                expense_id: newItem.expense_id,
                                category_name: newItem.category_name,
                                name: newItem.name,
                                descr: newItem.descr,
                                date: Process.relativeDate(newItem.date,
                                                           "ddd, MMM d, yyyy",
                                                           "Basic"),
                                dateValue: newItem.date,
                                value: newItem.value,
                                homeCur: typeof newItem.travel !== "undefined" ? newItem.travel.homeCur : "",
                                travelCur: typeof newItem.travel !== "undefined" ? newItem.travel.travelCur : "",
                                rate: typeof newItem.travel !== "undefined" ? newItem.travel.rate : 0,
                                travel_value: typeof newItem.travel !== "undefined" ? newItem.travel.value : 0
                            })
            model.append({
                             category_name: newItem.category_name,
                             childModel: childArray,
                             total: newItem.value,
                             count: 1
                         })
        }
    }

    function updateItemInModel(model, updatedItem) {
        var childModel
        var expenseID
        var childModelCount

        for (var i = 0; i < model.count; i++) {
            childModel = model.get(i).childModel

            for (var j = 0; j < childModel.count; j++) {
                expenseID = childModel.get(j).expense_id

                if (expenseID == updatedItem.expense_id) {
//                    model.setProperty(
//                                i, "total", Math.round(
//                                    ((model.get(i).total - childModel.get(
//                                          j).value) + updatedItem.value) * 100) / 100)
                    model.setProperty(i, "total", ((model.get(i).total - childModel.get(j).value) + updatedItem.value))

                    model.get(i).childModel.setProperty(
                                j, "category_name", updatedItem.category_name)
                    model.get(i).childModel.setProperty(j, "name",
                                                        updatedItem.name)
                    model.get(i).childModel.setProperty(j, "descr",
                                                        updatedItem.descr)
                    model.get(i).childModel.setProperty(j, "date",
                                                        Process.relativeDate(
                                                            updatedItem.date,
                                                            "ddd, MMM d, yyyy",
                                                            "Basic"))
                    model.get(i).childModel.setProperty(j, "dateValue",
                                                        updatedItem.date)
                    model.get(i).childModel.setProperty(j, "value",
                                                        updatedItem.value)
                    //                    model.setProperty(i, "childModel",childModel)

                    //Travel Data
                    if(typeof updatedItem.travel !== "undefined"){
                        model.get(i).childModel.setProperty(j, "homeCur",
                                                            updatedItem.travel.homeCur)
                        model.get(i).childModel.setProperty(j, "travelCur",
                                                            updatedItem.travel.travelCur)
                        model.get(i).childModel.setProperty(j, "rate",
                                                            updatedItem.travel.rate)
                        model.get(i).childModel.setProperty(j, "travel_value",
                                                            updatedItem.travel.value)
                    }
                    break
                }
            }

            if (childModelCount === 0) {
                model.remove(i)
                break
            }
        }
    }

    function deleteItemInModel(model, id) {
        var childModel
        var expenseID
        var childModelCount

        for (var i = 0; i < model.count; i++) {
            childModel = model.get(i).childModel

            for (var j = 0; j < childModel.count; j++) {
                expenseID = childModel.get(j).expense_id

                if (expenseID === id) {
                    childModelCount = model.get(i).count - 1

//                    model.setProperty(i, "total", Math.round(
//                                          (model.get(i).total - childModel.get(
//                                               j).value) * 100) / 100)
                    model.setProperty(i, "total", (model.get(i).total - childModel.get(j).value))
                    model.setProperty(i, "count", childModelCount)
                    childModel.remove(j)
                    model.setProperty(i, "childModel", childModel)
                    break
                }
            }

            if (childModelCount === 0) {
                model.remove(i)
                break
            }
        }
    }

    function addQuickItem(newItem) {
        modelQuickAdd.insert(0, {
                                 quick_id: newItem.quick_id,
                                 category_name: newItem.category_name,
                                 quickname: newItem.quickname,
                                 quickdate: "",
                                 descr: newItem.descr,
                                 quickvalue: newItem.quickvalue,
                                 travel_value: 0,
                                 rate: 0,
                                 homeCur: "",
                                 travelCur: ""
                             })
    }

    function updateQuickItem(updatedItem) {
        var quickID
        for (var j = 0; j < modelQuickAdd.count; j++) {
            quickID = modelQuickAdd.get(j).quick_id

            if (quickID == updatedItem.quick_id) {

                modelQuickAdd.setProperty(j, "category_name",
                                                 updatedItem.category_name)
                modelQuickAdd.setProperty(j, "quickname", updatedItem.quickname)
                modelQuickAdd.setProperty(j, "quickdate", "")
                modelQuickAdd.setProperty(j, "descr", updatedItem.descr)
                modelQuickAdd.setProperty(j, "quickvalue", updatedItem.quickvalue)
                modelQuickAdd.setProperty(j, "travel_value", 0)
                modelQuickAdd.setProperty(j, "rate", 0)
                modelQuickAdd.setProperty(j, "homeCur", "")
                modelQuickAdd.setProperty(j, "travelCur", "")
                break
            }
        }
    }

    function deleteQuickItem(id) {
        var quickID
        for (var j = 0; j < modelQuickAdd.count; j++) {
            quickID = modelQuickAdd.get(j).quick_id

            if (quickID === id) {
                modelQuickAdd.remove(j)
                break
            }
        }
    }

    /*General Functions*/
    function arrayUnique(array) {
        var a = array.concat()
        for (var i = 0; i < a.length; ++i) {
            for (var j = i + 1; j < a.length; ++j) {
                if (a[i] === a[j])
                    a.splice(j--, 1)
            }
        }

        return a
    }

    /*Sorted/Filtered ListModel*/
    SortFilterModel {
        id: modelSortFilterExpense
        property string totalValue: getTotalValue()
        property string totalTravelValue: getTotalTravelValue()
        property string loadingStatus: model.loadingStatus

        filter.property: "category_name"

        onModelChanged: {
            loadingStatus = model.loadingStatus
        }

        function getTotalValue() {
            var result = 0
            for (var i = 0; i < modelSortFilterExpense.count; i++) {
                result += modelSortFilterExpense.get(i).total
            }
            return AppFunctions.formatMoney(result, false)
        }
        function getTotalTravelValue() {
            var result = 0
            for (var i = 0; i < modelSortFilterExpense.count; i++) {
                result += modelSortFilterExpense.get(i).total
            }
            result = result / tempSettings.exchangeRate

            return AppFunctions.formatMoneyTravel(result, false)
        }
    }

    Connections {
        id: modelConnection
        target: modelSortFilterExpense.model

        onLoadingStatusChanged: {
            console.log("Nagiba: " + target.loadingStatus)
            modelSortFilterExpense.loadingStatus = target.loadingStatus
            //            modelSortFilterExpense.getTotalValue()
        }
    }

    /*Today Expenses*/
    ExpenseListModel {
        id: modelTodayExpenses
        mode: "Today"
    }

    /*Recent Expenses*/
    ExpenseListModel {
        id: modelRecentExpenses
        mode: "Recent"
    }

    /*Yesterday Expenses*/
    ExpenseListModel {
        id: modelYesterdayExpenses
        mode: "Yesterday"
    }

    /*This Week Expenses*/
    ExpenseListModel {
        id: modelThisWeekExpenses
        mode: "This Week"
    }

    /*This Month Expenses*/
    ExpenseListModel {
        id: modelThisMonthExpenses
        mode: "This Month"
    }

    /*Last Week Expenses*/
    ExpenseListModel {
        id: modelLastWeekExpenses
        mode: "Last Week"
    }

    /*Last Month Expenses*/
    ExpenseListModel {
        id: modelLastMonthExpenses
        mode: "Last Month"
    }

    /*Calendar Expenses*/
    ExpenseListModel {
        id: modelCalendarExpenses
        mode: "Calendar (Custom)"
    }

    /*Expense Autocomplete Model*/
    ExpenseAutoCompleteListModel {
        id: modelExpenseAutoComplete
        mode: "ExpenseAutoComplete"
    }

    ListModel {
        id: dashboardModel
        signal //        Component.onCompleted: initialise()
        ready

        function initialise() {

            dashboardModel.clear()

            var dashboardItems = tempSettings.dashboardItems.split(";")
            var itemsCount = dashboardItems.length

            //            dashboardItems = dashboardItems.split(";")
            for (var i = 0; i < itemsCount; i++) {
                switch (dashboardItems[i]) {
                case "Today":
                    if (modelTodayExpenses.count === 0) {
                        modelTodayExpenses.load("Category")
                    }
                    dashboardModel.append({
                                              viewMode: "today",
                                              textHeader: i18n.tr("Today"),
                                              textEmpty: i18n.tr(
                                                             "No expense for Today"),
                                              textLoading: i18n.tr(
                                                               "Loading Today's Expenses"),
                                              itemModel: modelTodayExpenses
                                          })
                    break
                case "Yesterday":
                    if (modelYesterdayExpenses.count === 0) {
                        modelYesterdayExpenses.load("Category")
                    }
                    dashboardModel.append({
                                              viewMode: "yesterday",
                                              textHeader: i18n.tr("Yesterday"),
                                              textEmpty: i18n.tr(
                                                             "No expense for Yesterday"),
                                              textLoading: i18n.tr(
                                                               "Loading Yesterday's Expenses"),
                                              itemModel: modelYesterdayExpenses
                                          })
                    break
                case "This Week":
                    if (modelThisWeekExpenses.count === 0) {
                        modelThisWeekExpenses.load("Category")
                    }
                    dashboardModel.append({
                                              viewMode: "thisweek",
                                              textHeader: i18n.tr("This Week"),
                                              textEmpty: i18n.tr(
                                                             "No expense for This Week"),
                                              textLoading: i18n.tr(
                                                               "Loading This Week's Expenses"),
                                              itemModel: modelThisWeekExpenses
                                          })
                    break
                case "This Month":
                    if (modelThisMonthExpenses.count === 0) {
                        modelThisMonthExpenses.load("Category")
                    }
                    dashboardModel.append({
                                              viewMode: "thismonth",
                                              textHeader: i18n.tr("This Month"),
                                              textEmpty: i18n.tr(
                                                             "No expense for This Month"),
                                              textLoading: i18n.tr(
                                                               "Loading This Month's Expenses"),
                                              itemModel: modelThisMonthExpenses
                                          })
                    break
                case "Recent":
                    if (modelRecentExpenses.count === 0) {
                        modelRecentExpenses.load("Category")
                    }
                    dashboardModel.append({
                                              viewMode: "recent",
                                              textHeader: i18n.tr("Recent"),
                                              textEmpty: i18n.tr(
                                                             "No Recent Expenses"),
                                              textLoading: i18n.tr(
                                                               "Loading Recent Expenses"),
                                              itemModel: modelRecentExpenses
                                          })
                    break
                case "Last Week":
                    if (modelLastWeekExpenses.count === 0) {
                        modelLastWeekExpenses.load("Category")
                    }
                    dashboardModel.append({
                                              viewMode: "lastweek",
                                              textHeader: i18n.tr("Last Week"),
                                              textEmpty: i18n.tr(
                                                             "No expense for Last Week"),
                                              textLoading: i18n.tr(
                                                               "Loading Last Week's Expenses"),
                                              itemModel: modelLastWeekExpenses
                                          })
                    break
                case "Last Month":
                    if (modelLastMonthExpenses.count === 0) {
                        modelLastMonthExpenses.load("Category")
                    }
                    dashboardModel.append({
                                              viewMode: "lastmonth",
                                              textHeader: i18n.tr("Last Month"),
                                              textEmpty: i18n.tr(
                                                             "No expense for Last Month"),
                                              textLoading: i18n.tr(
                                                               "Loading Last Month's Expenses"),
                                              itemModel: modelLastMonthExpenses
                                          })
                    break
                }
            }

            ready()
        }
    }

    ListModel {
        id: modelCategories
        property bool isListOnly: false
        property string loadingStatus: "Null"

        onIsListOnlyChanged: {
            if (isListOnly) {
                appendAddNew()
            } else {
                removeAddNew()
            }
        }

        function appendAddNew() {
            modelCategories.insert(0, {
                                       category_name: "Add new category",
                                       descr: "add new",
                                       icon: "default",
                                       colorValue: "white"
                                   })
        }

        function removeAddNew() {
            modelCategories.remove(0)
        }

        function getColor(category) {
            var i
            for (var i = 0; i < modelCategories.count; i++) {
                if (modelCategories.get(i).category_name === category) {
//                    i = modelCategories.count
//                    if (modelCategories.get(i) === undefined) {
//                        return "white"
//                    } else {
                        return modelCategories.get(i).colorValue
//                    }
                }
            }
        }

        function getItems() {
            var txtName
            var txtDescr
            var txtColor
            var arrResult

            loadingStatus = "Loading"

            modelCategories.clear()

            arrResult = DataProcess.getCategories()

            var msg = {
                result: arrResult,
                model: modelCategories,
                mode: 'Categories'
            }
            workerLoader.sendMessage(msg)
        }
    }

    ListModel {
        id: modelReports

        property string loadingStatus: "Null"

        function getItems() {
            var txtName
            var txtDescr
            var txtColor
            var arrResult

            loadingStatus = "Loading"

            modelReports.clear()

            arrResult = DataProcess.getReports()

            var msg = {
                result: arrResult,
                model: modelReports,
                mode: 'Reports'
            }
            workerLoader.sendMessage(msg)
        }
    }

    QuickAddModel {
        id: modelQuickAdd
    }

    ListModel {
        id: modelCurrencies

        property string loadingStatus: "Null"

        function getItems() {
            var txtName
            var txtDescr
            var txtColor
            var arrResult

            loadingStatus = "Loading"

            modelCurrencies.clear()

            arrResult = DataProcess.getCurrencies()

            var msg = {
                result: arrResult,
                model: modelCurrencies,
                mode: 'Currencies'
            }
            workerLoader.sendMessage(msg)
        }
    }

    QtObject{
        id: modelExchangeRates

        property var data: JSON.parse(tempSettings.exchangeRateJSON)
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


        function fetchLatestJSON(callback){
            var xhr = new XMLHttpRequest();

            xhr.onreadystatechange = function() {
                //                data = JSON.parse(tempJSON)
                //                callback(true)
                if (xhr.readyState == 4) {
                    if (xhr.status == 200) {
                        console.log("exchange rate fetch success")
//                        data = JSON.parse(xhr.responseText)
                        tempSettings.exchangeRateJSON = xhr.responseText
                        tempSettings.exchangeRateDate = Process.getToday()
                        callback(true)
                    }
                    else {
                        console.log('Failed to fetch exchange rate list');
                        callback(false)
                    }
                }
            };

            xhr.open('GET', requestURL, true);
            xhr.send();

        }
    }

}
