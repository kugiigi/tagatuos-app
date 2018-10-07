.import "../library/moment.js"  as Moment
.import "../library/accounting.js"  as Accounting
.import "../library/Currencies.js" as Currencies

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

function round_number(num, dec) {
    return Math.round(num * Math.pow(10, dec)) / Math.pow(10, dec);
}

function getToday() {
    //get current date
    var today = Moment.moment(new Date()).format("YYYY-MM-DD HH:mm:ss")//.format("YYYY/MM/DD")

    return today.toString()
}

function isToday(petsa) {
    //check if current date
    var dtPetsa = Moment.moment(petsa)
    var today = Moment.moment(new Date())

    return dtPetsa.isSame(today,'day')
}

function getStartEndDate(date,mode){
    var momentDate = Moment.moment(date)
    var firstDay
    var lastDay

    switch(mode){
    case 'week':
        firstDay = momentDate.startOf('week').format("YYYY-MM-DD HH:mm:ss")
        lastDay = momentDate.endOf('week').format("YYYY-MM-DD HH:mm:ss")
        break
    case 'month':
        firstDay = momentDate.startOf('month').format("YYYY-MM-DD HH:mm:ss")
        lastDay = momentDate.endOf('month').format("YYYY-MM-DD HH:mm:ss")
        break
    default:
        firstDay = momentDate.startOf('week').format("YYYY-MM-DD HH:mm:ss")
        lastDay = momentDate.endOf('week').format("YYYY-MM-DD HH:mm:ss")
        break
    }



    return {
            start: firstDay.toString(),
            end: lastDay.toString()
    }

}

function formatMoney(value, currency, options){
    var formattedMoney

    var finalOptions

    if(options){
        finalOptions = options
    }else{
        finalOptions = Currencies.currency(currency)
    }

    formattedMoney = Accounting.accounting.formatMoney(value, finalOptions);

    return formattedMoney;
}


//convert to english format and make history specific labels such as Today and Yesterday
function historyDate(petsa){
if(petsa !== null){
    var today
    var yesterday
    var tomorrow
    var dtPetsa
    var engPetsa

    dtPetsa = new Date(dateFormat(1,petsa));

    today = new Date(getToday())

    yesterday = new Date(getToday());
    yesterday.setDate(yesterday.getDate()-1);

    tomorrow = new Date(getToday());
    tomorrow.setDate(tomorrow.getDate()+1);

//+ should be used as a prefix to correctly use === when comparing dates
    if(+dtPetsa === +today){
     engPetsa = "Today"

    }else if(+dtPetsa === +yesterday){
       engPetsa = "Yesterday"
    }else if(+dtPetsa === +tomorrow){
        engPetsa = "Tomorrow"
     }else{
        engPetsa = dateFormat(2,petsa);
    }

}
return engPetsa
}


//Converts dates into user friendly format when necessary
function relativeDate(petsa, format, mode){
if(petsa !== null){

    var dtPetsa
    var engPetsa

    dtPetsa = Moment.moment(petsa)

    var comparisonValues = getDateComparisonValues(petsa)

    //console.log(dtPetsa + " - " + yesterday)
    switch(true){
    case dtPetsa.isSame(comparisonValues.today,'day'):
        engPetsa = i18n.tr("Today")
        break
    case dtPetsa.isSame(comparisonValues.yesterday,'day'):
        engPetsa = i18n.tr("Yesterday")
        break
    case dtPetsa.isSame(comparisonValues.tomorrow,'day'):
        engPetsa = i18n.tr("Tomorrow")
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
    default:
        engPetsa = Qt.formatDate(petsa,format)
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

    dtPetsa = Moment.moment(petsa)

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
    var result = []

    today = Moment.moment()
    yesterday = Moment.moment().subtract(1, 'day')
    tomorrow = Moment.moment().add(1, 'day')

        lastWeekFirstDay = Moment.moment().subtract(1, 'week').startOf('week')//.subtract(1,'day')
        lastWeekLastDay = Moment.moment().subtract(1, 'week').endOf('week')//.add(1,'day')
        lastMonthFirstDay = Moment.moment().subtract(1, 'month').startOf('month')//.subtract(1,'day')
        lastMonthLastDay = Moment.moment().subtract(1, 'month').endOf('month')//.add(1,'day')
        nextWeekFirstDay = Moment.moment().add(1, 'week').startOf('week')//.subtract(1,'day')
        nextWeekLastDay = Moment.moment().add(1, 'week').endOf('week')//.add(1,'day')
        nextMonthFirstDay = Moment.moment().add(1, 'month').startOf('month')//.subtract(1,'day')
        nextMonthLastDay = Moment.moment().add(1, 'month').endOf('month')//.add(1,'day')
        thisMonthFirstDay = Moment.moment().startOf('month')
        thisMonthLastDay = Moment.moment().endOf('month')
        thisWeekFirstDay = Moment.moment().startOf('week')
        thisWeekLastDay = Moment.moment().endOf('week')
        sevenDaysago = Moment.moment().subtract(7, 'day')

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

function formatDateCalendar(date){
    var format = "ddd, MMM D"
    var format2 = "ddd, MMM D, YYYY"
    var currentYear = Moment.moment().format("YYYY")
    var result

    if( Moment.moment(date).format("YYYY") === currentYear){
        result = Moment.moment(date).format(format)
    }else{
        result = Moment.moment(date).format(format2)
    }

    return result
}

function getDateComparisonValuesFormat(){

    var format = "ddd, MMM D"
    var format2 = "ddd, MMM D, YYYY"
    var currentYear = Moment.moment().format("YYYY")

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


    today = Moment.moment(comparisonValues.today).format(format)
    if( Moment.moment(comparisonValues.yesterday).format("YYYY") === currentYear){
        yesterday = Moment.moment(comparisonValues.yesterday).format(format)
    }else{
        yesterday = Moment.moment(comparisonValues.yesterday).format(format2)
    }

    tomorrow = Moment.moment(comparisonValues.tomorrow).format(format)

    if( Moment.moment(comparisonValues.lastWeekFirstDay).format("YYYY") === currentYear){
        lastWeekFirstDay = Moment.moment(comparisonValues.lastWeekFirstDay).format(format)
    }else{
        lastWeekFirstDay = Moment.moment(comparisonValues.lastWeekFirstDay).format(format2)
    }

    if( Moment.moment(comparisonValues.lastWeekLastDay).format("YYYY") === currentYear){
        lastWeekLastDay = Moment.moment(comparisonValues.lastWeekLastDay).format(format)
    }else{
        lastWeekLastDay = Moment.moment(comparisonValues.lastWeekLastDay).format(format2)
    }

    if( Moment.moment(comparisonValues.lastMonthFirstDay).format("YYYY") === currentYear){
        lastMonthFirstDay = Moment.moment(comparisonValues.lastMonthFirstDay).format(format)
    }else{
        lastMonthFirstDay = Moment.moment(comparisonValues.lastMonthFirstDay).format(format2)
    }

    if( Moment.moment(comparisonValues.lastMonthLastDay).format("YYYY") === currentYear){
        lastMonthLastDay = Moment.moment(comparisonValues.lastMonthLastDay).format(format)
    }else{
        lastMonthLastDay = Moment.moment(comparisonValues.lastMonthLastDay).format(format2)
    }

    nextWeekFirstDay = Moment.moment(comparisonValues.nextWeekFirstDay).format(format)
    nextWeekLastDay = Moment.moment(comparisonValues.nextWeekLastDay).format(format)
    nextMonthFirstDay = Moment.moment(comparisonValues.nextMonthFirstDay).format(format)
    nextMonthLastDay = Moment.moment(comparisonValues.nextMonthLastDay).format(format)

    thisMonthFirstDay = Moment.moment(comparisonValues.thisMonthFirstDay).format(format)
    thisMonthLastDay = Moment.moment(comparisonValues.thisMonthLastDay).format(format)

    if( Moment.moment(comparisonValues.thisWeekFirstDay).format("YYYY") === currentYear){
        thisWeekFirstDay = Moment.moment(comparisonValues.thisWeekFirstDay).format(format)
    }else{
        thisWeekFirstDay = Moment.moment(comparisonValues.thisWeekFirstDay).format(format2)
    }

    if( Moment.moment(comparisonValues.thisWeekLastDay).format("YYYY") === currentYear){
        thisWeekLastDay = Moment.moment(comparisonValues.thisWeekLastDay).format(format)
    }else{
        thisWeekLastDay = Moment.moment(comparisonValues.thisWeekLastDay).format(format2)
    }

    if( Moment.moment(comparisonValues.sevenDaysago).format("YYYY") === currentYear){
        sevenDaysago = Moment.moment(comparisonValues.sevenDaysago).format(format)
    }else{
        sevenDaysago = Moment.moment(comparisonValues.sevenDaysago).format(format2)
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

    var newDate = Moment.moment(date)

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

    console.log(calendarMode + newDate)

    return newDate.format("YYYY-MM-DD HH:mm:ss")
}

function getPreviousDate(calendarMode, date) {

    var newDate = Moment.moment(date)

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

    return newDate.format("YYYY-MM-DD HH:mm:ss")
}

/**********OLD FUNCTIONS*****************/
//format date for database insertion
function dateFormat(intMode, petsa) {

    var txtPetsa = ""
    var txtYear = ""
    var txtDay = ""
    var txtMonth = ""
    var txtHour = ""
    var txtMinute = ""
    var txtSecond = ""

    switch (intMode) {
    case 0:

        //Date to string for database
        txtDay = String(petsa.getDate())
        txtMonth = String(petsa.getMonth() + 1) //Months are zero based
        if (txtMonth.length === 1) {
            txtMonth = "0" + txtMonth
        }

        if (txtDay.length === 1) {
            txtDay = "0" + txtDay
        }

        txtYear = petsa.getFullYear()
        txtHour = "00" //petsa.getHours();
        txtMinute = "00" //petsa.getMinutes();
        txtSecond = "00" //petsa.getSeconds();
        txtPetsa = txtYear + "-" + txtMonth + "-" + txtDay + " " + txtHour + ":"
                + txtMinute + ":" + txtSecond + ".000"
        break
    case 1:
        //from database date to string for datepicker
        txtYear = petsa.substr(0, 4)
        txtMonth = petsa.substr(5, 2)
        txtDay = petsa.substr(8, 2)
        txtPetsa = txtYear + "/" + txtMonth + "/" + txtDay
        break
    case 2:
        //from database date to english format
        txtYear = petsa.substr(0, 4)
        txtMonth = petsa.substr(5, 2)
        txtDay = petsa.substr(8, 2)
        txtPetsa = getMonthName(
                    parseInt(txtMonth) - 1) + " " + txtDay + ", " + txtYear
        break
    }

    return txtPetsa.toString()
}

function getMonthName(intMonth) {
    var month = []
    month[0] = "January"
    month[1] = "February"
    month[2] = "March"
    month[3] = "April"
    month[4] = "May"
    month[5] = "June"
    month[6] = "July"
    month[7] = "August"
    month[8] = "September"
    month[9] = "October"
    month[10] = "November"
    month[11] = "December"

    return month[intMonth]
}

function getDayName(intDay) {
    var weekday = new Array(7)
    weekday[0] = "Sunday"
    weekday[1] = "Monday"
    weekday[2] = "Tuesday"
    weekday[3] = "Wednesday"
    weekday[4] = "Thursday"
    weekday[5] = "Friday"
    weekday[6] = "Saturday"

    return weekday[intDay]
}

function getCurrencySymbol(txtCurrency) {
    var txtSymbol = ""

    switch (txtCurrency) {
    case "US Dollar":
        txtSymbol = "$"
        break
    case "Philippines Peso":
        txtSymbol = "₱"
        break
    case "Euro":
        txtSymbol = "€"
        break
    case "Japan Yen":
        txtSymbol = "¥"
        break
    case "Korea Won":
        txtSymbol = "₩"
        break
    case "Indonesia Rupiah":
        txtSymbol = "Rp"
        break
    default:
        txtSymbol = "$"
        break
    }

    return txtSymbol
}

Date.prototype.addHours = function(h) {
   this.setTime(this.getTime() + (h*60*60*1000));
   return this;
}

Date.prototype.subtractHours = function(h) {
   this.setTime(this.getTime() - (h*60*60*1000));
   return this;
}

Date.prototype.addDays = function (days) //function to add days to a date
{
    var dat = new Date(this.valueOf())
    dat.setDate(dat.getDate() + days)
    return dat
}

Date.prototype.subtractDays = function (days) //function to add days to a date
{
    var dat = new Date(this.valueOf())
    dat.setDate(dat.getDate() - days)
    return dat
}

Date.prototype.addWeeks = function(h) {
   this.setDate(this.getDate() + (7 * h));
   return this;
}

Date.prototype.subtractWeeks = function(h) {
   this.setDate(this.getDate() - (7 * h));
   return this;
}

Date.prototype.addMonths = function (month) //function to add month to a date
{
    var dat = new Date(this.valueOf())
    dat.setMonth(dat.getMonth() + month)
    return dat
}

Date.prototype.subtractMonths = function (month) //function to subtract month to a date
{
    var dat = new Date(this.valueOf())
    dat.setMonth(dat.getMonth() - month)
    return dat
}

function moveDate(mode, dateCode, txtdate) {

    dateCode = dateCode.replace('?', '') //to disregard specific or defaults
    txtdate = dateFormat(1, txtdate) //convert from database date to proper date
    var newDate = new Date(txtdate)

    if (mode === "previous") {
        switch (dateCode) {
        case "week":
            newDate = newDate.subtractDays(7)
            break
        case "day":
            newDate = newDate.subtractDays(1)
            break
        case "month":
            newDate = newDate.subtractMonths(1)
            break
        }
    } else if (mode === "next") {
        switch (dateCode) {
        case "week":
            newDate = newDate.addDays(7)
            break
        case "day":
            newDate = newDate.addDays(1)
            break
        case "month":
            newDate = newDate.addMonths(1)
            break
        }
    }

    return dateFormat(0, newDate)
}

//delay execution
function sleep(milliseconds) {
    var start = new Date().getTime()
    for (var i = 0; i < 1e7; i++) {
        if ((new Date().getTime() - start) > milliseconds) {
            break
        }
    }
}

Number.prototype.formatMoney = function (c, d, t) {
    var n = this, c = isNaN(
                c = Math.abs(
                    c)) ? 2 : c, d = d == undefined ? "." : d, t = t == undefined ? "," : t, s = n < 0 ? "-" : "", i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "", j = (j = i.length) > 3 ? j % 3 : 0
    return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(
                /(\d{3})(?=\d)/g,
                "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "")
}

function getTranslation(txtWord, txtLanguage) {
    var txtTranslated

    if (txtLanguage === "English") {
        switch (txtWord) {
        case "Gastos":
            txtTranslated = "Expense"
            break
        case "Kita":
            txtTranslated = "Income"
            break
        case "Utang":
            txtTranslated = "Debt"
            break
        case "Expense":
            txtTranslated = "Gastos"
            break
        case "Income":
            txtTranslated = "Kita"
            break
        case "Debt":
            txtTranslated = "Utang"
            break
        }
    } else if (txtLanguage === "German") {
        switch (txtWord) {
        case "Gastos":
            txtTranslated = "Ausgabe"
            break
        case "Kita":
            txtTranslated = "Einkommen"
            break
        case "Utang":
            txtTranslated = "Schuld"
            break
        case "Ausgabe":
            txtTranslated = "Gastos"
            break
        case "Einkommen":
            txtTranslated = "Kita"
            break
        case "Schuld":
            txtTranslated = "Utang"
            break
        }
    } else {
        txtTranslated = txtWord
    }

    return txtTranslated
}

function checkRequired(arrValues) {
    var boolPass = true;

    for (var i = 0; i < arrValues.length; i++) {
        if (arrValues[i].trim() === "") {
            boolPass = false;
        }
    }
    return boolPass
}
