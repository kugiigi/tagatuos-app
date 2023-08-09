import { mom } from "../../library/moment.mjs"

var moment = mom();

WorkerScript.onMessage = function (msg) {
    var txtProfileId, txtDisplayName
    var txtItemId, txtDescr, txtDisplayFormat
    var txtUnit, txtSymbol, txtFieldName
    var txtValueType, txtScope
    var txtFieldId, intPrecision
    var arrFields = []
    var arrItems = []
    var currentSortField, previousSortField
    var txtEntryDate, txtComments, txtFormattedEntryDate
    var realValue
    var intFieldSeq, currentIndex
    var currentEntryDate, currentItemId, prevEntryDate, prevItemId
    var txtDisplayFormatWithValue, txtFormattedValue
    var modelFields
    var dashItems
    var total = 0
    var valueCount = 0
    var average = 0
    var highest
    var last
    var result

    if (msg.model) {
        msg.model.clear()
    }

    switch (msg.modelId) {
        case "Profiles":
            for (var i = 0; i < msg.result.length; i++) {
                txtProfileId = msg.result[i].profile_id
                txtDisplayName = msg.result[i].display_name
                msg.model.append({
                                     profileId: txtProfileId
                                     , displayName: txtDisplayName
                                 })
            }
            break;
        case "MonitorItems":
            for (var i = 0; i < msg.result.length; i++) {
                txtItemId = msg.result[i].item_id
                txtDisplayName = msg.result[i].display_name
                txtDescr = msg.result[i].descr
                txtDisplayFormat = msg.result[i].display_format
                txtUnit = msg.result[i].unit
                txtSymbol = msg.result[i].display_symbol
                msg.model.append({
                                     itemId: txtItemId
                                     , displayName: txtDisplayName
                                     , descr: txtDescr
                                     , displayFormat: txtDisplayFormat
                                     , unit: txtUnit
                                     , displaySymbol: txtSymbol
                                 })
            }
            break;
        case "DashItems":
            for (var i = 0; i < msg.result.length; i++) {
                txtItemId = msg.result[i].item_id
                txtValueType = msg.result[i].value_type
                txtScope = msg.result[i].scope
                msg.model.append({
                                     itemId: txtItemId
                                     , valueType: txtValueType
                                     , scope: txtScope
                                 })
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
        case "Values_1":
        case "Values_2":
        case "Values_3":
            dashItems = msg.properties.dashItems

            for (var i = 0; i < msg.result.length; i++) {
                txtEntryDate = msg.result[i].entry_date
                txtDisplayName = msg.result[i].display_name
                txtItemId = msg.result[i].item_id
                txtFieldId = msg.result[i].field_id
                intPrecision = msg.result[i].precision
                intFieldSeq = msg.result[i].field_seq
                txtSymbol = msg.result[i].display_symbol
                txtDisplayFormat = msg.result[i].display_format

                realValue = round(msg.result[i].value, intPrecision)
                txtComments = msg.result[i].comments
                txtComments = txtComments ? txtComments : ""

                currentEntryDate = txtEntryDate
                currentItemId = txtItemId
                
                txtFormattedEntryDate = moment(txtEntryDate).format("hh:mm A")
                realValue = round(realValue, intPrecision)
                
                if (currentEntryDate !== prevEntryDate || currentItemId !== prevItemId) {
                    total = total + realValue
                    valueCount += 1
                    txtFormattedValue = formatValue(txtDisplayFormat, intFieldSeq, realValue)
                    last = { entryDate: txtFormattedEntryDate, value: txtFormattedValue }
                    
                    if (highest) {
                        if (realValue > highest.value) {
                            highest = { entryDate: txtFormattedEntryDate, value: txtFormattedValue }
                        } else if(realValue == highest.value) {
                            highest = { entryDate: highest.entryDate + ", " + txtFormattedEntryDate, value: txtFormattedValue }
                        }
                    } else {
                        highest = { entryDate: txtFormattedEntryDate, value: txtFormattedValue }
                    }

                    msg.model.append({
                                         entryDate: txtFormattedEntryDate
                                         , entryDateId: txtEntryDate
                                         , itemName: txtDisplayName
                                         , itemId: txtItemId
                                         , fields:  [ { fieldId: txtFieldId, value: realValue } ]
                                         , values: txtFormattedValue
                                         , unit: txtSymbol
                                         , comments: txtComments
                                     })
                } else {
                    if (currentItemId == prevItemId) {
                        currentIndex = msg.model.count - 1
                        txtDisplayFormatWithValue = msg.model.get(currentIndex).values
                        txtFormattedValue  = formatValue(txtDisplayFormatWithValue, intFieldSeq, realValue)

                        last = { entryDate: txtFormattedEntryDate, value: txtFormattedValue }

                        modelFields = msg.model.get(currentIndex).fields
                        modelFields.append( { fieldId: txtFieldId, value: realValue })
                        msg.model.setProperty(currentIndex, "values", txtFormattedValue)
                    }
                }

                prevEntryDate = currentEntryDate
                prevItemId = currentItemId
                arrFields = []
            }
            result = []
            total = round(total, intPrecision)
            average = round(total / valueCount, intPrecision)

            if (dashItems.indexOf("total") > -1) {
                result.push( { value_type: "total", value: total, unit: txtSymbol } )
            }

            if (dashItems.indexOf("average") > -1) {
                result.push( { value_type: "average", value: average, unit: txtSymbol } )
            }
            
            if (dashItems.indexOf("last") > -1) {
                result.push( { value_type: "last", value: last, unit: txtSymbol } )
            }
            
            if (dashItems.indexOf("highest") > -1) {
                result.push( { value_type: "highest", value: highest, unit: txtSymbol } )
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
