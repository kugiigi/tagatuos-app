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
        , categories: function (profile) {

            return {
                list: function() {
                    return Database.getCategories(profile);
                }
            }
        }
        , quickExpenses: function (profile) {

            return {
                list: function() {
                    return Database.getQuickExpenses(profile, "");
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
                    let _travelData = null

                    // Travel Data
                    if (mainView.settings.travelMode) {
                        let _realRate = mainView.settings.exchangeRate
                        let _txtHomeCur = mainView.settings.currentCurrency
                        let _txtTravelCur = mainView.settings.travelCurrency
                        //~ let _realTravelValue = 0
                        let _realTravelValue = _realValue
                        _realValue = _realTravelValue * _realRate

                        //~ if (itemHomeCur === mainView.settings.currentCurrency && itemTravelCur === mainView.settings.travelCurrency) {
                            //~ _realTravelValue = _realValue
                            //~ _realValue = realTravelValue * _realRate
                        //~ } else {
                            //~ _realTravelValue = _realValue / _realRate
                        //~ }

                        _travelData = {
                            "rate": _realRate
                            , "homeCur": _txtHomeCur
                            , "travelCur": _txtTravelCur
                            , "value": _realTravelValue
                        }
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
                , edit: function(entryDate, fieldId, itemId, value, comments) {
                    return Database.updateItemValue(entryDate, fieldId, profile, itemId, value)
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
                , detailedData: function(category, scope, dateFrom, dateTo) {
                    return Database.getExpenseDetailedData(profile, category, scope, dateFrom, dateTo)
                }
                , historyDataForEntry: function(searchText, limit) {
                    return Database.getHistoryExpenses(profile, searchText, limit)
                }
                , lastDateWithData: function(category, dateBase) {
                    return Database.getDateWithData(false, profile, category, dateBase)
                }
                , nextDateWithData: function(category, dateBase) {
                    return Database.getDateWithData(true, profile, category, dateBase)
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
