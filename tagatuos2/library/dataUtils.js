.import "database.js" as Database
.import "functions.js" as Functions

var dataUtils = dataUtils || (function (undefined) {

    return {
        profiles: (function (currentProfile) {

            return {
                currentName: function() {
                    if (mainView.settings && mainView.mainModels && mainView.mainModels.profilesModel && mainView.mainModels.profilesModel.ready) { 
                        return mainView.mainModels.profilesModel.getItem(settings.activeProfile, "profileId").displayName
                    } else {
                        return ""
                    }
                }
                , list: function() {
                    return Database.getProfiles();
                }
                , refresh: function() {
                    mainView.mainModels.profilesModel.refresh();
                }
                , exists: function(displayName) {
                    return Database.checkProfileIfExist(displayName);
                }
                , new: function(displayName) {
                    var newProfileId = Database.newProfile(displayName);
                    this.refresh();
                    return newProfileId;
                }
                , edit: function(profileId, displayName) {
                    Database.editProfile(profileId, displayName);
                    this.refresh();
                }
                , delete: function(profileId) {
                    var result = Database.deleteProfile(profileId);
                    if (result.success) {
                        this.refresh();
                    }
                    return result;
                }
            }
        })()
        , currencies: function () {

            return {
                list: function() {
                    return Database.getCurrencies();
                }
            }
        }
        , categories: function (profile) {

            return {
                list: function() {
                    return Database.getCategories(profile);
                }
            }
        }
        , dashboard: function (profile) {

            return {
                breakdown: function(range) {
                    let _current = []
                    let _previous = []

                    switch (range) {
                        case "today":
                            _current = Database.getCategoryBreakdown(profile, "today");
                            _previous = Database.getCategoryBreakdown(profile, "yesterday");
                            break
                        case "thisweek":
                            _current = Database.getCategoryBreakdown(profile, "thisweek");
                            _previous = Database.getCategoryBreakdown(profile, "lastweek");
                            break
                        case "thismonth":
                            _current = Database.getCategoryBreakdown(profile, "thismonth");
                            _previous = Database.getCategoryBreakdown(profile, "lastmonth");
                            break
                        case "thisyear":
                            _current = Database.getCategoryBreakdown(profile, "thisyear");
                            _previous = Database.getCategoryBreakdown(profile, "lastyear");
                            break
                        case "recent":
                            _current = Database.getCategoryBreakdown(profile, "recent");
                            _previous = Database.getCategoryBreakdown(profile, "previousrecent");
                            break
                    }

                    return [ _current, _previous ]
                },
                trend: function(range, mode, categories, fromDate, toDate) {
                    let _current = []
                    let _previous = []

                    switch (range) {
                        case "thisweek":
                            _current = Database.getExpenseTrend(profile, "thisweek", mode, categories, fromDate, toDate);
                            _previous = Database.getExpenseTrend(profile, "lastweek", mode, categories, fromDate, toDate);
                            break
                        case "thismonth":
                            _current = Database.getExpenseTrend(profile, "thismonth", mode, categories, fromDate, toDate);
                            _previous = Database.getExpenseTrend(profile, "lastmonth", mode, categories, fromDate, toDate);
                            break
                        case "thisyear":
                            _current = Database.getExpenseTrend(profile, "thisyear", mode, categories, fromDate, toDate);
                            _previous = Database.getExpenseTrend(profile, "lastyear", mode, categories, fromDate, toDate);
                            break
                        case "recent":
                            _current = Database.getExpenseTrend(profile, "recent", mode, categories, fromDate, toDate);
                            _previous = Database.getExpenseTrend(profile, "previousrecent", mode, categories, fromDate, toDate);
                            break
                    }

                    return [ _current, _previous ]
                },
            }
        }
        , quickExpenses: function (profile) {

            return {
                list: function() {
                    return Database.getQuickExpenses(profile, "");
                }
                , add: function(expenseData) {
                    let _txtName = expenseData.name
                    let _realValue = expenseData.value
                    let _txtDescr = expenseData.description
                    let _txtCategory = expenseData.category

                    const _data = {
                        "name": _txtName
                        , "description": _txtDescr
                        , "category": _txtCategory
                        , "value": _realValue
                    }

                    let _result = Database.addQuickExpense(profile, _data)
                    if (_result.success) {
                        mainView.mainModels.refreshQuickExpense()
                    }

                    return { "success": _result.success, "exists": _result.exists}
                }
            }
        }
        , expenses: function (profile) {

            return {
                add: function(expenseData) {
                    let _txtDate = expenseData.entryDate
                    let _txtName = expenseData.name
                    let _realValue = expenseData.value
                    let _txtDescr = expenseData.description
                    let _txtCategory = expenseData.category
                    let _travelData

                    // Travel Data
                    if (mainView.settings.travelMode) {
                        _travelData = expenseData.travelData
                    }

                    const _data = {
                        "entryDate": _txtDate
                        , "name": _txtName
                        , "description": _txtDescr
                        , "category": _txtCategory
                        , "value": _realValue
                    }

                    let _result = Database.addNewExpense(profile, _data, _travelData)
                    if (_result.success) {
                        mainView.mainModels.refreshValues(_data.entryDate)
                    }

                    return _result.success
                }
                , edit: function(expenseData) {
                    let _txtID = expenseData.expenseID
                    let _txtDate = expenseData.entryDate
                    let _txtName = expenseData.name
                    let _realValue = expenseData.value
                    let _txtDescr = expenseData.description
                    let _txtCategory = expenseData.category
                    let _travelData = expenseData.travelData

                    const _data = {
                        "expenseID": _txtID
                        , "entryDate": _txtDate
                        , "name": _txtName
                        , "description": _txtDescr
                        , "category": _txtCategory
                        , "value": _realValue
                    }

                    let _result = Database.updateExpense(_data, _travelData)
                    if (_result.success) {
                        mainView.mainModels.refreshValues(_data.entryDate, _txtID)
                        if (_result.oldEntryDate != _data.entryDate) {
                            mainView.mainModels.refreshValues(_result.oldEntryDate)
                        }
                    }

                    return _result.success
                }
                , editEntryDate: function(entryDate, newEntryDate) {
                    return Database.updateItemEntryDate(entryDate, newEntryDate, profile)
                }
                , delete: function(expenseID, entryDate) {
                    let _result = Database.deleteExpense(profile, expenseID)
                    if (_result.success) {
                        mainView.mainModels.refreshValues(entryDate)
                    }

                    return _result.success
                }
                , addComment: function(entryDate, comments) {
                    return Database.addNewComment(entryDate, profile, comments);
                }
                , editComment: function(entryDate, comments) {
                    return Database.editComment(entryDate, profile, comments);
                }
                , deleteComment: function(entryDate) {
                    return Database.deleteComment(profile, entryDate);
                }
                , detailedData: function(category, scope, dateFrom, dateTo, sort, order) {
                    return Database.getExpenseDetailedData(profile, category, scope, dateFrom, dateTo, sort, order)
                }
                , historyDataForEntry: function(searchText, limit) {
                    return Database.getHistoryExpenses(profile, searchText, limit)
                }
                , search: function(searchText, limit, sort) {
                    return Database.searchExpenses(profile, searchText, limit, sort)
                }
                , lastDateWithData: function(category, dateBase, scope) {
                    return Database.getDateWithData(false, profile, category, dateBase, scope)
                }
                , nextDateWithData: function(category, dateBase, scope) {
                    return Database.getDateWithData(true, profile, category, dateBase, scope)
                }
                , entryDateMultiple: function(entryDate, itemId) {
                    return Database.checkEntryDateMultiple(profile, entryDate, itemId)
                }
                , dashList: function() {
                    var current, datesObj, currentItems, currentItem;
                    var currentItemId, prevItemId;
                    var currentIndex;
                    var valueType, scope, dateScope, grouping;
                    var value, title, entryDate;
                    var dateFrom, dateTo, today;
                    var dashItems = monitoritems.dashList();
                    var arrResults = [];
                    var arrValues = [];
                    var arrFieldValues = [];
                    
                    today = Functions.getToday();
                    entryDate = today;

                    for (var i = 0; i < dashItems.length; i++) {
                        current = dashItems[i];
                        currentItemId = current.item_id
                        scope = current.scope
                        valueType = current.value_type
                        
                        switch(true) {
                            case scope.indexOf('daily') > -1:
                                grouping = "day";
                                break;
                            case scope.indexOf('weekly') > -1:
                                grouping = "week";
                                break;
                            case scope.indexOf('monthly') > -1:
                                grouping = "month";
                                break;
                            default:
                                grouping = "none";
                                break;
                        }

                        switch(true) {
                            case scope.indexOf('today') > -1:
                                dateScope = "today";
                                datesObj = Functions.getStartEndDate(today, 'day');
                                dateFrom = datesObj.start;
                                dateTo = datesObj.end;
                                break;
                            case scope.indexOf('week') > -1:
                                dateScope = "thisweek";
                                datesObj = Functions.getStartEndDate(today, 'week');
                                dateFrom = datesObj.start;
                                dateTo = datesObj.end;
                                break;
                            case scope.indexOf('recent') > -1:
                                dateScope = "recent";
                                if (grouping !== "none" && valueType == "average") {
                                    datesObj = Functions.getStartEndDate(today, 'recent exclude');
                                } else {
                                    datesObj = Functions.getStartEndDate(today, 'recent');
                                }

                                dateFrom = datesObj.start;
                                dateTo = datesObj.end;
                                break;
                            case scope.indexOf('month') > -1:
                                dateScope = "thismonth";
                                datesObj = Functions.getStartEndDate(today, 'month');
                                dateFrom = datesObj.start;
                                dateTo = datesObj.end;
                                break;
                            case scope.indexOf('all') > -1:
                                dateScope = "all";
                                datesObj = Functions.getStartEndDate(today, 'all');
                                dateFrom = datesObj.start;
                                dateTo = datesObj.end;
                                break;
                            default:
                                dateScope = "today";
                                dateFrom = today;
                                dateTo = dateFrom;
                                break;
                        }
                        
                        switch(valueType) {
                            case 'total':
                                arrValues = this.getTotal(currentItemId, dateFrom, dateTo, grouping);
                                break;
                            case 'average':
                                arrValues = this.getAverage(currentItemId, dateFrom, dateTo, grouping);
                                break;
                            case 'last':
                                arrValues = this.getLast(currentItemId, dateFrom, dateTo, grouping);
                                break;
                            case 'highest':
                                arrValues = this.getHighest(currentItemId, dateFrom, dateTo, grouping);
                                break;
                            default: 
                                arrValues = [];
                                break;
                        }

                        arrFieldValues = [];
                        for (var h = 0; h < arrValues.length; h++) {
                            entryDate = arrValues[h].entry_date;
                            arrFieldValues.push(arrValues[h].value);
                        }

                        if (entryDate && arrFieldValues.length > 0) {
                            value = arrFieldValues.join("/");
                        } else {
                            value = "";
                        }

                        title = this.getValueLabel(valueType, dateScope, grouping, entryDate);
                        currentItem = { type: valueType, title: title, value: value, unit: current.display_symbol };
                        
                        if (currentItemId !== prevItemId) {
                            if (currentItemId !== "all") {
                                current.items = [currentItem];
                            }
                            if (valueType == "last") {
                                currentItems = arrResults[0].items;
                                if (currentItems) {
                                    currentItems.push(currentItem);
                                    arrResults[0].items = currentItems;
                                } else {
                                    arrResults[0].items = [currentItem];
                                }
                            }
                            arrResults.push(current);
                        } else {
                            currentIndex = arrResults.length - 1;
                            currentItems = arrResults[currentIndex].items;
                            currentItems.push(currentItem);
                            arrResults[currentIndex].items = currentItems;

                            if (valueType == "last") {
                                arrResults[0].items = currentItems;
                            }
                        }
                        
                        prevItemId = currentItemId;
                    }

                    return arrResults;
                }
                , getTotal: function(itemId, dateFrom, dateTo, grouping) {
                    return Database.getTotalFromValues(profile, itemId, dateFrom, dateTo, grouping)
                }
                , getAverage: function(itemId, dateFrom, dateTo, grouping) {
                    return Database.getAverageFromValues(profile, itemId, dateFrom, dateTo, grouping)
                }
                , getLast: function(itemId, dateFrom, dateTo, grouping) {
                    return Database.getLastValue(profile, itemId, dateFrom, dateTo, grouping)
                }
                , getHighest: function(itemId, dateFrom, dateTo, grouping) {
                    return Database.getHighestValue(profile, itemId, dateFrom, dateTo, grouping)
                }
                , getValueLabel: function(valueType, dateScope, grouping, entryDate) {
                    var label = "";

                    switch(valueType) {
                        case "total":
                            if (dateScope == "today") {
                                label = i18n.tr("Today's Total")
                            } else if (dateScope == "thisweek") {
                                label = i18n.tr("This week's Total")
                            } else if (dateScope == "recent") {
                                label = i18n.tr("Recent Total")
                            }
                            break;
                        case "average":
                            if (dateScope == "today") {
                                label = i18n.tr("Today's Average")
                            } else if (dateScope == "thisweek") {
                                label = i18n.tr("This Week's Average")
                            } else if (dateScope == "thismonth") {
                                label = i18n.tr("This Month's Average")
                            } else if (dateScope == "all") {
                                label = i18n.tr("Average")
                            } else if (dateScope == "recent") {
                                if (grouping == "day") {
                                    label = i18n.tr("Recent Daily Average")
                                } else {
                                    label = i18n.tr("Recent Average")
                                }
                            }
                            break;
                        case "last":
                            label = Functions.relativeTime(entryDate)
                            break;
                        case "highest":
                            if (dateScope == "today") {
                                label = i18n.tr("Highest Today")
                            } else if (dateScope == "thisweek") {
                                label = i18n.tr("Highest This Week")
                            } else if (dateScope == "recent") {
                                label = i18n.tr("Highest Recently")
                            }
                            break;
                    }

                    return label;
                }
            }
        }
    }
})();
