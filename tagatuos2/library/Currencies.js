.import "../library/DBUtilities.js" as DB
.import QtQuick.LocalStorage 2.0 as Sql


function currencies() {
//    var db = DB.open()
//    var arrResults = []
//    var rs = null
//    var txtSelectStatement = ""

//    txtSelectStatement = "SELECT * FROM currencies"

//    db.transaction(function (tx) {
//        rs = tx.executeSql(txtSelectStatement)

//        arrResults.length = rs.rows.length

//        for (var i = 0; i < rs.rows.length; i++) {
//            arrResults[i] = rs.rows.item(i)
//        }
//    })
//    return arrResults
    return DB.select("SELECT currency_code, description FROM currencies")
}

var currency = function (code) {
    var symbol = '₱'
    var descr = 'Philippines Piso'
    var decimal = '.'
    var thousand = ','
    var precision = 2
    var format = '%s%v'

    var arrResults = DB.select("SELECT * FROM currencies WHERE currency_code = ?",code)

    for (var i = 0; i < arrResults.length; i++) {
        symbol = arrResults[i].symbol
        descr = arrResults[i].description

        decimal = arrResults[i].decimal
        decimal = decimal ? decimal : "."

        thousand = arrResults[i].thousand
        thousand = thousand ? thousand : ","

        precision = arrResults[i].precision
        precision = precision !== "" ? Number(precision) : 2

        format = arrResults[i].format
        format = format ? format : "%s%v"
    }

    return {symbol: symbol, descr: descr, decimal: decimal, thousand: thousand, precision:precision, format: format}
//    return {symbol: symbol, descr: descr}
}
