.import "external/moment.mjs" as Moment
.import "external/accounting.js" as Accounting
.import "Currencies.js" as Currencies

const moment = Moment.mom();

String.prototype.replaceAt = function (index, character) {
    return this.substr(0, index) + character + this.substr(index + 1)
}

String.prototype.bindValues = function (charBind, arrValues) {
    var intCurSearchIndex = 0
    var intCurIndex
    var txtNewString = this

    for (var i = 0; i < arrValues.length; i++) {
        intCurIndex = txtNewString.indexOf(charBind, 0)
        txtNewString = txtNewString.replaceAt(intCurIndex, arrValues[i])
    }
    return txtNewString
}


function elideText(inputText, charLimit) {
    let elideString = "..."
    charLimit = charLimit ? charLimit : 20
    let returnValue = inputText

    if (returnValue.length > charLimit) {
        returnValue = returnValue.substring(0, charLimit) + elideString
    }

    return returnValue
}

function elideMidText(inputText, charLimit) {
    let elideString = "..."
    charLimit = charLimit ? charLimit : 20
    let returnValue = inputText

    if (returnValue.length > charLimit) {
        let sideCharLimit = Math.floor((charLimit - elideString.length) / 2)
        let extraFirstChar = (charLimit - elideString.length) % 2
        let firstChars = returnValue.substring(0, sideCharLimit + extraFirstChar)
        let lastChars = returnValue.substring(returnValue.length - sideCharLimit)
        returnValue = firstChars + elideString + lastChars
    }

    return returnValue
}

function bulletText(inputText, customBullet) {
    let bulletChar = customBullet ? customBullet : "•"

    return "%1 %2".arg(bulletChar).arg(inputText)
}

function bulletTextArray(inputTextArray, customBullet) {
    let bulletChar = customBullet ? customBullet : "•"

    return bulletText(inputTextArray.join("%1%2 ".arg("\n").arg(bulletChar)), customBullet)
}

function scrollToView(item, flickable, topMargin=0,  bottomMargin=0) {
    let _mappedY
    let _itemHeightY
    let _currentViewport
    let _intendedContentY
    let _maxContentY

    _mappedY = item.mapToItem(flickable.contentItem, 0, 0).y
    _itemHeightY = _mappedY + item.height
    _currentViewport = flickable.contentY - flickable.originY + flickable.height - flickable.bottomMargin + flickable.topMargin

    //~ console.log("_mappedY: " + _mappedY)
    //~ console.log("_itemHeightY: " + _itemHeightY)
    //~ console.log("_currentViewport: " + _currentViewport)
    if (_itemHeightY > _currentViewport) {
        _maxContentY = flickable.contentHeight - flickable.height + flickable.bottomMargin
        _intendedContentY = _itemHeightY - flickable.height + item.height + flickable.bottomMargin + bottomMargin

        if (_intendedContentY > _maxContentY) {
            //~ console.log("maxContentY")
            flickable.contentY = _maxContentY
        } else {
            //~ console.log("intendedContentY")
            flickable.contentY = _intendedContentY
        }
    } else if (_mappedY < flickable.contentY) {
        //~ console.log("compute")
        flickable.contentY = _mappedY - topMargin - flickable.topMargin
    }

    //~ console.log("Final:" + flickable.contentY)
}

function round_number(num, dec) {
    return Math.round(num * Math.pow(10, dec)) / Math.pow(10, dec);
}

function formatDateForDB(petsa) {
    return formatDate(petsa, "YYYY-MM-DD HH:mm:ss.SSS")
}

function formatDate(petsa, format) {
    return moment(petsa).format(format)
}

function getUTCToday() {
    //get current date
    var today = moment.utc(new Date()).format("YYYY-MM-DD HH:mm:ss.SSS")

    return today.toString()
}

function getToday() {
    //get current date
    var today = moment(new Date()).format("YYYY-MM-DD HH:mm:ss.SSS")

    return today.toString()
}

function convertDBToDate(petsa) {
    return moment(petsa, "YYYY-MM-DD HH:mm:ss.SSS").toDate();
}

function isToday(petsa) {
    //check if current date
    var dtPetsa = moment(petsa)
    var today = moment(new Date())

    return dtPetsa.isSame(today,'day')
}

function addDays(petsa, days, toDBString = false) {
    let _momentDate = moment(petsa)
    _momentDate.add(days, 'day')
    if (toDBString) {
        return _momentDate.format("YYYY-MM-DD HH:mm:ss.SSS")
    } else {
        return _momentDate.toDate()
    }
}

function addMonths(petsa, months, toDBString = false) {
    let _momentDate = moment(petsa)
    _momentDate.add(months, 'month')
    if (toDBString) {
        return _momentDate.format("YYYY-MM-DD HH:mm:ss.SSS")
    } else {
        return _momentDate.toDate()
    }
}

function checkIfWithinDateRange(inputDate, fromDate, toDate) {
    let _inputDateMom = moment(inputDate)
    let _fromDateMom = moment(fromDate)
    let _toDateMom = moment(toDate)

    return _inputDateMom.isBetween(_fromDateMom, _toDateMom,'day',[])
}

function getStartEndDate(date,mode){
    var momentDate = moment(date)
    var firstDay
    var lastDay

    switch(mode){
    case 'day':
        firstDay = momentDate.startOf('day').format("YYYY-MM-DD HH:mm:ss")
        lastDay = momentDate.endOf('day').format("YYYY-MM-DD HH:mm:ss")
        break;
    case 'week':
        firstDay = momentDate.startOf('week').startOf('day').format("YYYY-MM-DD HH:mm:ss")
        lastDay = momentDate.endOf('week').endOf('day').format("YYYY-MM-DD HH:mm:ss")
        break;
    case 'month':
        firstDay = momentDate.startOf('month').startOf('day').format("YYYY-MM-DD HH:mm:ss")
        lastDay = momentDate.endOf('month').endOf('day').format("YYYY-MM-DD HH:mm:ss")
        break;
    case 'recent':
        lastDay = momentDate.endOf('day').format("YYYY-MM-DD HH:mm:ss")
        firstDay = momentDate.subtract(6, 'day').startOf('day').format("YYYY-MM-DD HH:mm:ss")
        break;
    case 'recent exclude':
        lastDay = momentDate.subtract(1, 'day').endOf('day').format("YYYY-MM-DD HH:mm:ss")
        firstDay = momentDate.subtract(6, 'day').startOf('day').format("YYYY-MM-DD HH:mm:ss")
        break;
    case 'year':
        firstDay = momentDate.startOf('year').startOf('day').format("YYYY-MM-DD HH:mm:ss")
        lastDay = momentDate.endOf('year').endOf('day').format("YYYY-MM-DD HH:mm:ss")
        break;
    case 'all':
        lastDay = momentDate.endOf('day').format("YYYY-MM-DD HH:mm:ss")
        firstDay = momentDate.subtract(50, 'year').startOf('day').format("YYYY-MM-DD HH:mm:ss")
        break;
    default:
        firstDay = momentDate.startOf('day').format("YYYY-MM-DD HH:mm:ss")
        firstDay = momentDate.startOf('day').format("YYYY-MM-DD HH:mm:ss")
        lastDay = momentDate.endOf('day').format("YYYY-MM-DD HH:mm:ss")
        break;
    }



    return {
        start: firstDay.toString(),
        end: lastDay.toString()
    }
}

function formatMoney(value, currency, options) {
    var formattedMoney

    var finalOptions

    if (options) {
        finalOptions = options
    }else{
        finalOptions = Currencies.currency(currency)
    }

    formattedMoney = Accounting.accounting.formatMoney(value, finalOptions);

    return formattedMoney;
}

function relativeTime(petsa, format) {
    const defaultFormat = "MMM DD hh:mm A"
    var formatToUse = format ? format : defaultFormat
    
    if(petsa !== null){
    
        var dtPetsa
        var engPetsa
        var formattedDate
        var timeFormat = "hh:mm A"
    
        dtPetsa = moment(petsa)
    
        var comparisonValues = getDateComparisonValues(petsa)

        switch(true){
            case dtPetsa.isSame(comparisonValues.today,'day'):
                engPetsa = dtPetsa.format(timeFormat)
                break;
            case dtPetsa.isSame(comparisonValues.yesterday,'day'):
                engPetsa = i18n.tr("Yesterday") + ", " + dtPetsa.format(timeFormat)
                break;
            case dtPetsa.isBetween(comparisonValues.thisWeekFirstDay,comparisonValues.thisWeekLastDay,'day',[]):
                engPetsa = dtPetsa.format("dddd")
                break;
            case dtPetsa.isSameOrBefore(comparisonValues.endOfLastYear, 'day'):
                engPetsa = dtPetsa.format("MMM DD, YYYY hh:mm A")
                break;
            default:
                engPetsa = dtPetsa.format(formatToUse)
                break;
        }
    }
    return engPetsa
}


//Converts dates into user friendly format when necessary
function relativeDate(petsa, format, mode){
    var defaultFormat = "ddd, MMM DD"
    var formatToUse = format ? format : defaultFormat

    if(petsa !== null){
    
        var dtPetsa
        var engPetsa
        var formattedDate
    
        dtPetsa = moment(petsa)
    
        var comparisonValues = getDateComparisonValues(petsa)
        formattedDate = " - " + dtPetsa.format(formatToUse)

        switch(true){
            case dtPetsa.isSame(comparisonValues.today,'day'):
                engPetsa = i18n.tr("Today") + formattedDate
                break
            case dtPetsa.isSame(comparisonValues.yesterday,'day'):
                engPetsa = i18n.tr("Yesterday") + formattedDate
                break
            case dtPetsa.isSame(comparisonValues.tomorrow,'day'):
                engPetsa = i18n.tr("Tomorrow") + formattedDate
                break
            case dtPetsa.isBetween(comparisonValues.thisWeekFirstDay,comparisonValues.thisWeekLastDay,'day',[]) && mode === "Advanced":
                engPetsa = i18n.tr("On ") + dtPetsa.format("dddd")
                break
            case dtPetsa.isBetween(comparisonValues.lastWeekFirstDay,comparisonValues.astWeekLastDay,'day',[]) && mode === "Advanced":
                engPetsa = i18n.tr("Last Week")
                break
            case dtPetsa.isBetween(comparisonValues.nextWeekFirstDay,comparisonValues.nextWeekLastDay,'day',[]) && mode === "Advanced":
                engPetsa = i18n.tr("Next Week")
                break
            case dtPetsa.isBetween(comparisonValues.lastMonthFirstDay,comparisonValues.lastMonthLastDay,'day',[]) && mode === "Advanced":
                engPetsa = i18n.tr("Last Month")
                break
            case dtPetsa.isBetween(comparisonValues.nextMonthFirstDay,comparisonValues.nextMonthLastDay,'day',[]) && mode === "Advanced":
                engPetsa = i18n.tr("Next Month")
                break
            case dtPetsa.isBetween(comparisonValues.thisMonthFirstDay,comparisonValues.thisMonthLastDay,'day',[]) && mode === "Advanced":
                engPetsa = i18n.tr("This Month")
                break
            case dtPetsa.isSameOrBefore(comparisonValues.lastMonthFirstDay,'day') && mode === "Advanced":
                engPetsa = i18n.tr("Older")
                break
            case dtPetsa.isSameOrAfter(comparisonValues.nextMonthLastDay,'day') && mode === "Advanced":
                engPetsa = i18n.tr("In The Future")
                break
            case dtPetsa.isSameOrBefore(comparisonValues.endOfLastYear, 'day'):
                engPetsa = dtPetsa.format("ddd, MMM DD, YYYY")
                break;
            default:
                engPetsa = dtPetsa.format(formatToUse)
                break
        }
    }
    return engPetsa
}

//Group expenses by date
function groupDate(petsa){
    if(petsa !== null){
        var dtPetsa
        var engPetsa = []
        var result
    
        dtPetsa = moment(petsa)
    
        var comparisonValues = getDateComparisonValues(petsa)
    
    
        if(dtPetsa.isSame(comparisonValues.today,'day')){
            engPetsa.push("Today")
        }
        if(dtPetsa.isSame(comparisonValues.yesterday,'day')){
            engPetsa.push("Yesterday")
        }
        if(dtPetsa.isBetween(comparisonValues.thisWeekFirstDay,comparisonValues.thisWeekLastDay,'day',[])){
            engPetsa.push("This Week")
        }
        if(dtPetsa.isBetween(comparisonValues.lastWeekFirstDay,comparisonValues.lastWeekLastDay,'day',[])){
            engPetsa.push("Last Week")
        }
        if(dtPetsa.isBetween(comparisonValues.nextWeekFirstDay,comparisonValues.nextWeekLastDay,'day',[])){
            engPetsa.push("Next Week")
        }
        if(dtPetsa.isBetween(comparisonValues.lastMonthFirstDay,comparisonValues.lastMonthLastDay,'day',[])){
            engPetsa.push("Last Month")
        }
        if(dtPetsa.isBetween(comparisonValues.thisMonthFirstDay,comparisonValues.thisMonthLastDay,'day',[])){
            engPetsa.push("This Month")
        }
        if(dtPetsa.isBetween(comparisonValues.sevenDaysago,comparisonValues.today,'day',[])){
            engPetsa.push("Recent")
        }
    
        result = engPetsa.join(";")
    }
    return result
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
    var endOfLastYear
    var result = []

    today = moment()
    yesterday = moment().subtract(1, 'day')
    tomorrow = moment().add(1, 'day')

        lastWeekFirstDay = moment().subtract(1, 'week').startOf('week')
        lastWeekLastDay = moment().subtract(1, 'week').endOf('week')
        lastMonthFirstDay = moment().subtract(1, 'month').startOf('month')
        lastMonthLastDay = moment().subtract(1, 'month').endOf('month')
        nextWeekFirstDay = moment().add(1, 'week').startOf('week')
        nextWeekLastDay = moment().add(1, 'week').endOf('week')
        nextMonthFirstDay = moment().add(1, 'month').startOf('month')
        nextMonthLastDay = moment().add(1, 'month').endOf('month')
        thisMonthFirstDay = moment().startOf('month')
        thisMonthLastDay = moment().endOf('month')
        thisWeekFirstDay = moment().startOf('week')
        thisWeekLastDay = moment().endOf('week')
        sevenDaysago = moment().subtract(7, 'day')
        endOfLastYear = moment().subtract(1, 'year').endOf('year')

    result = {
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
        sevenDaysago: sevenDaysago,
        endOfLastYear: endOfLastYear
    }

    return result;

}

function formatDateCalendar(date) {
    var format = "ddd, MMM D"
    var format2 = "ddd, MMM D, YYYY"
    var currentYear = moment().format("YYYY")
    var result

    if( moment(date).format("YYYY") === currentYear){
        result = moment(date).format(format)
    }else{
        result = moment(date).format(format2)
    }

    return result
}

function getDateComparisonValuesFormat() {

    var format = "ddd, MMM D"
    var format2 = "ddd, MMM D, YYYY"
    var currentYear = moment().format("YYYY")

    var comparisonValues = getDateComparisonValues()
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


    today = moment(comparisonValues.today).format(format)
    if( moment(comparisonValues.yesterday).format("YYYY") === currentYear){
        yesterday = moment(comparisonValues.yesterday).format(format)
    }else{
        yesterday = moment(comparisonValues.yesterday).format(format2)
    }

    tomorrow = moment(comparisonValues.tomorrow).format(format)

    if( moment(comparisonValues.lastWeekFirstDay).format("YYYY") === currentYear){
        lastWeekFirstDay = moment(comparisonValues.lastWeekFirstDay).format(format)
    }else{
        lastWeekFirstDay = moment(comparisonValues.lastWeekFirstDay).format(format2)
    }

    if( moment(comparisonValues.lastWeekLastDay).format("YYYY") === currentYear){
        lastWeekLastDay = moment(comparisonValues.lastWeekLastDay).format(format)
    }else{
        lastWeekLastDay = moment(comparisonValues.lastWeekLastDay).format(format2)
    }

    if( moment(comparisonValues.lastMonthFirstDay).format("YYYY") === currentYear){
        lastMonthFirstDay = moment(comparisonValues.lastMonthFirstDay).format(format)
    }else{
        lastMonthFirstDay = moment(comparisonValues.lastMonthFirstDay).format(format2)
    }

    if( moment(comparisonValues.lastMonthLastDay).format("YYYY") === currentYear){
        lastMonthLastDay = moment(comparisonValues.lastMonthLastDay).format(format)
    }else{
        lastMonthLastDay = moment(comparisonValues.lastMonthLastDay).format(format2)
    }

    nextWeekFirstDay = moment(comparisonValues.nextWeekFirstDay).format(format)
    nextWeekLastDay = moment(comparisonValues.nextWeekLastDay).format(format)
    nextMonthFirstDay = moment(comparisonValues.nextMonthFirstDay).format(format)
    nextMonthLastDay = moment(comparisonValues.nextMonthLastDay).format(format)

    thisMonthFirstDay = moment(comparisonValues.thisMonthFirstDay).format(format)
    thisMonthLastDay = moment(comparisonValues.thisMonthLastDay).format(format)

    if( moment(comparisonValues.thisWeekFirstDay).format("YYYY") === currentYear){
        thisWeekFirstDay = moment(comparisonValues.thisWeekFirstDay).format(format)
    }else{
        thisWeekFirstDay = moment(comparisonValues.thisWeekFirstDay).format(format2)
    }

    if( moment(comparisonValues.thisWeekLastDay).format("YYYY") === currentYear){
        thisWeekLastDay = moment(comparisonValues.thisWeekLastDay).format(format)
    }else{
        thisWeekLastDay = moment(comparisonValues.thisWeekLastDay).format(format2)
    }

    if( moment(comparisonValues.sevenDaysago).format("YYYY") === currentYear){
        sevenDaysago = moment(comparisonValues.sevenDaysago).format(format)
    }else{
        sevenDaysago = moment(comparisonValues.sevenDaysago).format(format2)
    }


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

function getNextDate(calendarMode, date) {

    var newDate = moment(date)

    switch(calendarMode){
    case "day":
        newDate.add(1, 'day')
        break
    case "week":
        newDate.add(1, 'week')
        break
    case "month":
        newDate.add(1, 'month')
        break
    case "custom":
        newDate.add(1, 'day')
        break
    }

    return newDate.format("YYYY-MM-DD HH:mm:ss.SSS")
}

function getPreviousDate(calendarMode, date) {

    var newDate = moment(date)

    switch(calendarMode){
    case "day":
        newDate.subtract(1, 'day')
        break
    case "week":
        newDate.subtract(1, 'week')
        break
    case "month":
        newDate.subtract(1, 'month')
        break
    case "custom":
        newDate.subtract(1, 'day')
        break
    }

    return newDate.format("YYYY-MM-DD HH:mm:ss.SSS")
}
