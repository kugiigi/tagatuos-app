import { mom } from "../../library/external/moment.mjs"

var moment = mom();

WorkerScript.onMessage = function (msg) {
    //~ var txtProfileId, txtDisplayName
    //~ var txtItemId, txtDescr, txtDisplayFormat
    //~ var txtUnit, txtSymbol, txtFieldName
    //~ var txtValueType, txtScope
    //~ var txtFieldId, intPrecision
    //~ var arrFields = []
    //~ var arrItems = []
    //~ var currentSortField, previousSortField
    //~ var txtEntryDate, txtComments, txtFormattedEntryDate
    //~ var realValue
    //~ var intFieldSeq, currentIndex
    //~ var currentEntryDate, currentItemId, prevEntryDate, prevItemId
    //~ var txtDisplayFormatWithValue, txtFormattedValue
    //~ var modelFields
    //~ var dashItems
    //~ var total = 0
    //~ var valueCount = 0
    //~ var average = 0
    //~ var highest
    //~ var last
    let result

    if (msg.model) {
        msg.model.clear()
    }

    switch (msg.modelId) {
        case "Profiles":
            for (let i = 0; i < msg.result.length; i++) {
                let txtProfileId = msg.result[i].profile_id
                let txtDisplayName = msg.result[i].display_name
                msg.model.append({
                                     profileId: txtProfileId
                                     , displayName: txtDisplayName
                                 })
            }
            break;
        case "Categories":
            for (let i = 0; i < msg.result.length; i++) {
                let txtName = msg.result[i].category_name
                let txtDescr = msg.result[i].descr
                let txtIcon = msg.result[i].icon
                let txtColor = msg.result[i].color
                msg.model.append({
                                     category_name: txtName,
                                     value: txtName, // For category combo box
                                     descr: txtDescr,
                                     icon: txtIcon,
                                     colorValue: txtColor
                                 })
            }
            break
        case "QuickExpenses":
            for (let i = 0; i < msg.result.length; i++) {
                let txtID = msg.result[i].quick_id
                let txtCategoryName = msg.result[i].category_name
                let txtName = msg.result[i].name
                let txtDescr = msg.result[i].descr
                let txtValue = msg.result[i].value

                msg.model.append({
                                     quickID: txtID
                                     , categoryName: txtCategoryName
                                     , name: txtName
                                     , description: txtDescr
                                     , value: txtValue
                                 })
            }
            break;
        case "HistoryEntry":
            for (let i = 0; i < msg.result.length; i++) {
                let txtName = msg.result[i].name
                let txtCategoryName = msg.result[i].category_name
                let txtDescr = msg.result[i].descr
                let txtValue = msg.result[i].value
                let realTravelValue = msg.result[i].travel_value
                let realRate = msg.result[i].rate
                let txtHomeCur = msg.result[i].home_currency
                let txtTravelCur = msg.result[i].travel_currency

                msg.model.append({
                                     name: txtName
                                     , categoryName: txtCategoryName
                                     , description: txtDescr
                                     , value: txtValue
                                     , rate: realRate
                                     , home_currency: txtHomeCur
                                     , travel_currency: txtTravelCur
                                     , travel_value: realTravelValue
                                 })
            }
            break;
        case "TodayBreakdownChart":
        case "ThisWeekBreakdownChart":
        case "ThisMonthBreakdownChart":
        case "ThisYearBreakdownChart":
        case "RecentBreakdownChart":
            let _data = []

            for (let i = 0; i < msg.result.length; i++) {
                _data = [] // Reset first

                for (let h = 0; h < msg.result[i].length; h++) {
                    _data.push({ label: msg.result[i][h].category_name, value: msg.result[i][h].total, color: msg.result[i][h].color })
                }

                msg.model.append( { data: _data } )
            }
            break;
        case "MonitorItemsFields":
            for (var i = 0; i < msg.result.length; i++) {
                txtItemId = msg.result[i].item_id
                txtDisplayName = msg.result[i].display_name
                txtFieldId = msg.result[i].field_id
                txtFieldName = msg.result[i].field_name
                txtSymbol = msg.result[i].display_symbol
                intPrecision = msg.result[i].precision

                currentSortField = txtItemId

                if (previousSortField !== currentSortField) {
                    arrFields.push({
                                        fieldId: txtFieldId
                                        , title: txtFieldName
                                        , unit: txtSymbol
                                        , precision: intPrecision
                                    })
                    msg.model.append({
                                     itemId: txtItemId
                                     , displayName: txtDisplayName
                                     , fields: arrFields
                                 })
                    arrFields = []
                } else {
                    var currentIndex = msg.model.count - 1
    
                    msg.model.get(currentIndex).fields.append({
                                                                fieldId: txtFieldId
                                                                , title: txtFieldName
                                                                , unit: txtSymbol
                                                              })
                }

                previousSortField = currentSortField
            }
            break;
        case "Detailed_1":
        case "Detailed_2":
        case "Detailed_3":
            //~ dashItems = msg.properties.dashItems
            let scope = msg.properties.scope
            let total = 0
            //~ let travelTotal = 0
            const travelTotals = []
            const highest = []
            const lowest = []

            for (var i = 0; i < msg.result.length; i++) {
                let intID = msg.result[i].expense_id
                let txtCategory = msg.result[i].category_name
                let realTotal = msg.result[i].category_total
                let realTravelTotal = msg.result[i].category_travel_total
                let txtName = msg.result[i].name
                let txtDescr = msg.result[i].descr
                let txtDateValue = msg.result[i].entry_date
                let txtDate = relativeDate(txtDateValue, "ddd, MMM d, yyyy", "Basic")
                let realValue = msg.result[i].value
                let realTravelValue = msg.result[i].travel_value
                let realRate = msg.result[i].rate
                let txtHomeCur = msg.result[i].home_currency
                let txtTravelCur = msg.result[i].travel_currency

                //~ console.log(txtCategory + " - " + txtName + " - " + txtDateValue)

                let currentExpenseId = intID
                let prevExpenseId = 0
                let currentTravelCurrency = txtTravelCur
                let prevTravelCurrency = ""
                let currentItemData = {
                    expense_id: intID,
                    category_name: txtCategory,
                    category_total: realTotal,
                    category_travel_total: realTravelTotal,
                    category_id: [txtCategory, realTotal, realTravelTotal].join("|"),
                    name: txtName,
                    descr: txtDescr,
                    entry_date: txtDateValue,
                    entry_date_relative: txtDate,
                    value: realValue,
                    rate: realRate,
                    home_currency: txtHomeCur,
                    travel_currency: txtTravelCur,
                    travel_value: realTravelValue
                }

                if (currentExpenseId !== prevExpenseId) {
                    total += realValue

                    // Get add to total of the same travel currency
                    if (txtTravelCur) {
                        let _foundIndex = travelTotals.findIndex((element) => element.currency == txtTravelCur)
                        if (_foundIndex > -1) {
                            travelTotals[_foundIndex].total += realTravelValue
                        } else {
                            travelTotals.push( { "currency": txtTravelCur, "total": realTravelValue } )
                        }
                    }

                    if (highest.length > 0) {
                        if (realValue >= highest[0].value) {
                            if (realValue > highest[0].value) {
                                highest.length = 0
                            }

                            highest.push(currentItemData)
                        }
                    } else {
                        highest.push(currentItemData)
                    }

                    if (lowest.length > 0) {
                        if (realValue <= lowest[0].value) {
                            if (realValue < lowest[0].value) {
                                lowest.length = 0
                            }

                            lowest.push(currentItemData)
                        }
                    } else {
                        lowest.push(currentItemData)
                    }
                }

                prevExpenseId = currentExpenseId
                prevTravelCurrency = currentTravelCurrency

                msg.model.append(currentItemData)
            }

            result = []

            switch (scope) {
                case "day":
                default:
                    result.push( { value_type: "TOTAL", data: total } )

                    for (let i = 0; i < travelTotals.length; i++) {
                        result.push( { value_type: "TRAVEL_TOTAL", data: travelTotals[i].total, currency: travelTotals[i].currency } )
                    }

                    result.push( { value_type: "HIGHEST", data: highest } )
                    result.push( { value_type: "LOWEST", data: lowest } )
                    break
            }

            break;
        case "Dashboard":
            for (var i = 0; i < msg.result.length; i++) {
                txtItemId = msg.result[i].item_id
                txtDisplayName = msg.result[i].display_name
                txtDisplayFormat = msg.result[i].display_format
                txtUnit = msg.result[i].unit
                txtSymbol = msg.result[i].display_symbol
                txtValueType = msg.result[i].value_type
                txtScope = msg.result[i].scope
                arrItems = msg.result[i].items
                msg.model.append({
                                     itemId: txtItemId
                                     , displayName: txtDisplayName
                                     , displayFormat: txtDisplayFormat
                                     , unit: txtUnit
                                     , displaySymbol: txtSymbol
                                     , valueType: txtValueType
                                     , scope: txtScope
                                     , items: arrItems
                                 })
            }
            break;
    }

    if (msg.model) {
        msg.model.sync() // updates the changes to the list
        msg.model.clear() //clear model after sync to remove from memory (assumption only :))
    }

    WorkerScript.sendMessage({
                                 modelId: msg.modelId
                                ,result: result
                             })
}



/*Functions*/
const round = (number, decimalPlaces) => {
    const factorOfTen = Math.pow(10, decimalPlaces)
    return Math.round(number * factorOfTen) / factorOfTen
}

function formatValue(format, sequence, value) {
    return format.replace("%" + sequence, value)
}

//Converts dates into user friendly format when necessary
function relativeDate(petsa, format, mode){
    if(petsa !== null){
        var dtPetsa
        var engPetsa
    
        dtPetsa = moment(petsa)
    
        var comparisonValues = getDateComparisonValues(petsa)
    
    
        switch(true){
        case dtPetsa.isSame(comparisonValues.today,'day'):
            engPetsa = "Today"
            break
        case dtPetsa.isSame(comparisonValues.yesterday,'day'):
            engPetsa = "Yesterday"
            break
        case dtPetsa.isSame(comparisonValues.tomorrow,'day'):
            engPetsa = "Tomorrow"
            break
        case dtPetsa.isBetween(comparisonValues.thisWeekFirstDay,comparisonValues.thisWeekLastDay,'day',[]) && mode === "Advanced":
            engPetsa = "On " + dtPetsa.format("dddd")
            break
        case dtPetsa.isBetween(comparisonValues.lastWeekFirstDay,comparisonValues.lastWeekLastDay,'day',[]) && mode === "Advanced":
            engPetsa = "Last Week"
            break
        case dtPetsa.isBetween(comparisonValues.nextWeekFirstDay,comparisonValues.nextWeekLastDay,'day',[]) && mode === "Advanced":
            engPetsa = "Next Week"
            break
        case dtPetsa.isBetween(comparisonValues.lastMonthFirstDay,comparisonValues.lastMonthLastDay,'day',[]) && mode === "Advanced":
            engPetsa = "Last Month"
            break
        case dtPetsa.isBetween(comparisonValues.nextMonthFirstDay,comparisonValues.nextMonthLastDay,'day',[]) && mode === "Advanced":
            engPetsa = "Next Month"
            break
        case dtPetsa.isBetween(comparisonValues.thisMonthFirstDay,comparisonValues.thisMonthLastDay,'day',[]) && mode === "Advanced":
            engPetsa = "This Month"
            break
        case dtPetsa.isSameOrBefore(comparisonValues.lastMonthFirstDay,'day') && mode === "Advanced":
            engPetsa = "Older"
            break
        case dtPetsa.isSameOrAfter(comparisonValues.nextMonthLastDay,'day') && mode === "Advanced":
            engPetsa = "In The Future"
            break
        default:
            engPetsa = Qt.formatDate(petsa,format)
            break
        }
    }
    return engPetsa
}

//Gets date values for use in evaluating dates
function getDateComparisonValues(){
    var today
    var yesterday
    var tomorrow
    var lastWeekFirstDay
    var lastWeekLastDay
    var lastMonthFirstDay
    var lastMonthLastDay
    var nextWeekFirstDay
    var nextWeekLastDay
    var nextMonthFirstDay
    var nextMonthLastDay
    var thisMonthFirstDay
    var thisMonthLastDay
    var thisWeekFirstDay
    var thisWeekLastDay
    var sevenDaysago
    var result = []

    today = moment()
    yesterday = moment().subtract(1, 'day')
    tomorrow = moment().add(1, 'day')

        lastWeekFirstDay = moment().subtract(1, 'week').startOf('week')//.subtract(1,'day')
        lastWeekLastDay = moment().subtract(1, 'week').endOf('week')//.add(1,'day')
        lastMonthFirstDay = moment().subtract(1, 'month').startOf('month')//.subtract(1,'day')
        lastMonthLastDay = moment().subtract(1, 'month').endOf('month')//.add(1,'day')
        nextWeekFirstDay = moment().add(1, 'week').startOf('week')//.subtract(1,'day')
        nextWeekLastDay = moment().add(1, 'week').endOf('week')//.add(1,'day')
        nextMonthFirstDay = moment().add(1, 'month').startOf('month')//.subtract(1,'day')
        nextMonthLastDay = moment().add(1, 'month').endOf('month')//.add(1,'day')
        thisMonthFirstDay = moment().startOf('month')
        thisMonthLastDay = moment().endOf('month')
        thisWeekFirstDay = moment().startOf('week')
        thisWeekLastDay = moment().endOf('week')
        sevenDaysago = moment().subtract(6, 'day')

    result ={
                    today: today,
                    yesterday: yesterday,
                    tomorrow: tomorrow,
                    lastWeekFirstDay: lastWeekFirstDay,
                    lastWeekLastDay: lastWeekLastDay,
                    lastMonthFirstDay: lastMonthFirstDay,
                    lastMonthLastDay: lastMonthLastDay,
                    nextWeekFirstDay: nextWeekFirstDay,
                    nextWeekLastDay: nextWeekLastDay,
                    nextMonthFirstDay: nextMonthFirstDay,
                    nextMonthLastDay: nextMonthLastDay,
                    thisMonthFirstDay: thisMonthFirstDay,
                    thisMonthLastDay: thisMonthLastDay,
                    thisWeekFirstDay: thisWeekFirstDay,
                    thisWeekLastDay: thisWeekLastDay,
                    sevenDaysago: sevenDaysago
                }

    return result;

}
