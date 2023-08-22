.import QtQuick.LocalStorage 2.12 as Sql


// Open database for transactions
function openDB() {
    var db = null
    if (db !== null)
        return

    db = Sql.LocalStorage.openDatabaseSync("tagatuos.kugiigi", "1.0",
                                           "applciation's backend data", 100000)

    return db
}

//update database
function update(txtStatement) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(txtStatement)
    })
}

//select data from database
function select(txtStatement, bindValues) {
    var db = openDB()
    var rs = null
    var arrResult = []
    
    if (bindValues) {
        try {
            db.transaction(function (tx) {
                if (bindValues) {
                    rs = tx.executeSql(txtStatement,bindValues)
                }else{
                    rs = tx.executeSql(txtStatement)
                }


                arrResult.length = rs.rows.length

                for (var i = 0; i < rs.rows.length; i++) {
                    //add new row in the array
                    arrResult[i] = []

                    //assign values to the array
                    arrResult[i] = rs.rows.item(i)
                }
            })
        } catch (err) {
            console.log("Select: " + txtStatement)
            console.log("Bind: " + bindValues)
            console.log("Error message: " + err)
        }
    }

    return arrResult
}

//insert data to database
function insert(txtStatement) {
    var db = openDB()

    db.transaction(function (tx) {
        if (txtStatement.constructor === Array) {
            for (var i = 0; i < txtStatement.length; i++) {
                tx.executeSql(txtStatement[i])
            }
        } else {
            tx.executeSql(txtStatement)
        }
    })
}

/*************Meta data functions*************/

//Create initial data
function createInitialData() {
    createMetaTables()
    initiateData()
}

//Create meta tables
function createMetaTables() {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `categories` (`category_name`	TEXT,`descr` TEXT,`icon` TEXT DEFAULT 'default',`color`	TEXT)")
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `expenses` (`expense_id` INTEGER PRIMARY KEY AUTOINCREMENT,`category_name` TEXT,`name`	TEXT,`descr` TEXT,`date` TEXT,`value` REAL)")
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `debts` (`debt_id` INTEGER PRIMARY KEY AUTOINCREMENT,`name` TEXT,`descr` TEXT,`date` TEXT,`value` REAL,`debtor_flag` INTEGER, `paid_flag` INTEGER)")
    })
}

function createMetaViews() {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql("DROP VIEW IF EXISTS expenses_today")
        tx.executeSql("DROP VIEW IF EXISTS expenses_yesterday")
        tx.executeSql("DROP VIEW IF EXISTS expenses_thisweek")
        tx.executeSql("DROP VIEW IF EXISTS expenses_thismonth")
        tx.executeSql("DROP VIEW IF EXISTS expenses_recent")
        tx.executeSql("DROP VIEW IF EXISTS expenses_lastweek")
        tx.executeSql("DROP VIEW IF EXISTS expenses_lastmonth")
        tx.executeSql("DROP VIEW IF EXISTS expenses_vw")


        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_today AS SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) WHERE date(a.date) = date('now','localtime')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_yesterday AS SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) WHERE date(a.date) = date('now','localtime','-1 day')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_thisweek AS SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) WHERE date(a.date) BETWEEN date('now','localtime','weekday 6','-6 days') AND date('now','localtime','weekday 6')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_thismonth AS SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) WHERE date(a.date) BETWEEN date('now', 'localtime', 'start of month')  AND date('now','localtime','start of month','+1 month','-1 day')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_recent AS SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) WHERE date(a.date) BETWEEN date('now','localtime','-7 day') AND date('now','localtime')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_lastweek AS SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) WHERE date(a.date) BETWEEN date('now','localtime','weekday 6', '-13 days') AND date('now','localtime','weekday 6', '-7 days')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_lastmonth AS SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) WHERE date(a.date) BETWEEN date('now','localtime','start of month','-1 month') AND date('now','localtime','start of month','-1 day')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_vw AS SELECT a.expense_id, a.category_name, a.name, a.descr, a.date, a.value, b.home_currency, b.travel_currency, IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id)")
    })
}

//Initialize data for first time use
function initiateData() {
    var db = openDB()
    db.transaction(function (tx) {
        var categories = tx.executeSql('SELECT * FROM categories')
        if (categories.rows.length === 0) {
            tx.executeSql(
                        'INSERT INTO categories VALUES(?, ?,"default","cornflowerblue")',[i18n.tr("Food"),i18n.tr("Breakfast, Lunch, Dinner, etc.")])
            tx.executeSql(
                        'INSERT INTO categories VALUES(?, ?,"default","orangered")',[i18n.tr("Transportation"),i18n.tr("Taxi, Bus, Train, Gas, etc.")])
            tx.executeSql(
                        'INSERT INTO categories VALUES(?, ?,"default","chocolate")',[i18n.tr("Clothing"),i18n.tr("Shirts, Pants, underwear, etc.")])
            tx.executeSql(
                        'INSERT INTO categories VALUES(?, ?,"default","springgreen")',[i18n.tr("Household"),i18n.tr("Electricity, Groceries, Rent etc.")])
            tx.executeSql(
                        'INSERT INTO categories VALUES(?, ?,"default","palegreen")',[i18n.tr("Leisure"),i18n.tr("Movies, Books, Sports etc.")])
            tx.executeSql(
                        'INSERT INTO categories VALUES(?, ?,"default","purple")',[i18n.tr("Savings"),i18n.tr("Investments, Reserve Funds etc.")])
            tx.executeSql(
                        'INSERT INTO categories VALUES(?, ?,"default","snow")',[i18n.tr("Healthcare"),i18n.tr("Dental, Hospital, Medicines etc.")])
            tx.executeSql(
                        'INSERT INTO categories VALUES(?, ?,"default","darkslategrey")',[i18n.tr("Miscellaneous"),i18n.tr("Other expenses")])
        }
    })
}

//Checks current database user version
function checkUserVersion() {
    var db = openDB()
    var rs = null
    var currentDataBaseVersion

    db.transaction(function (tx) {
        rs = tx.executeSql('PRAGMA user_version')
        currentDataBaseVersion = rs.rows.item(0).user_version
    })

    return currentDataBaseVersion
}

//increments database user version
function upgradeUserVersion() {
    var db = openDB()
    var rs = null
    var currentDataBaseVersion
    var newDataBaseVersion

    db.transaction(function (tx) {
        rs = tx.executeSql('PRAGMA user_version')
        currentDataBaseVersion = rs.rows.item(0).user_version
        newDataBaseVersion = currentDataBaseVersion + 1
        tx.executeSql("PRAGMA user_version = " + newDataBaseVersion)
    })
}

//Execute Needed Database upgrades
function databaseUpgrade(currentVersion) {
    if (currentVersion < 1) {
        executeUserVersion1()
    }
    if (currentVersion < 2) {
        executeUserVersion2()
    }
    if (currentVersion < 3) {
        executeUserVersion3()
    }
    if (currentVersion < 4) {
        executeUserVersion4()
    }
}

//Database Changes for User Version 1
function executeUserVersion1() {
    createMetaViews()
    createReportsRecord()
    createQuickRecord()
    console.log("Database Upgraded to 1")
    upgradeUserVersion()
}

function createReportsRecord(){
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `reports` (`report_id` INTEGER PRIMARY KEY AUTOINCREMENT,`creator` TEXT DEFAULT 'user',`report_name` TEXT,`type` TEXT DEFAULT 'LINE',`date_range` TEXT DEFAULT 'This Month',`date_mode` TEXT DEFAULT 'Day',`filter` TEXT,`exceptions` TEXT,`date1` TEXT,`date2` TEXT)")
    })


}

function createQuickRecord(){
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `quick_expenses` (`quick_id` INTEGER PRIMARY KEY AUTOINCREMENT, `category_name`	TEXT, `name` TEXT, `descr` TEXT, `value` REAL);")
    })

}

//Database Changes for User Version 2
// Version 0.70
function executeUserVersion2() {
    createCurrenciesRecord()
    createInitialCurrencies()
    console.log("Database Upgraded to 2")
    upgradeUserVersion()
}

function createCurrenciesRecord(){
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                     "CREATE TABLE IF NOT EXISTS `currencies` (`currency_code`	TEXT,`description`	TEXT,`symbol`	TEXT,`decimal`	TEXT,`thousand`	TEXT,`precision`	INTEGER,`format`	TEXT,PRIMARY KEY(currency_code));")
    })

}

// Insert initial Currency data
function createInitialCurrencies() {
    var db = openDB()
    db.transaction(function (tx) {
        var currencies = tx.executeSql('SELECT * FROM currencies')
        if (currencies.rows.length === 0) {
            tx.executeSql("INSERT INTO currencies VALUES('ALL','Albania Lek',?,',','.','2','%s%v')",[String.fromCharCode(76, 101, 107)])
            tx.executeSql("INSERT INTO currencies VALUES('AFN','Afghanistan Afghani',?,'.',',','2','%v %s')",[String.fromCharCode(1547)])
            tx.executeSql("INSERT INTO currencies VALUES('ARS','Argentina Peso',?,',','.','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('AWG','Aruba Guilder',?,'.',',','2','%s%v')",[String.fromCharCode(402)])
            tx.executeSql("INSERT INTO currencies VALUES('AUD','Australia Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('AZN','Azerbaijan Manat',?,',',' ','2','%s%v')",[String.fromCharCode(8380)])
            tx.executeSql("INSERT INTO currencies VALUES('BSD','Bahamas Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('BBD','Barbados Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('BYN','Belarus Ruble',?,'','','2','%v %s')",[String.fromCharCode(66, 114)])
            tx.executeSql("INSERT INTO currencies VALUES('BZD','Belize Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(66, 90, 36)])
            tx.executeSql("INSERT INTO currencies VALUES('BMD','Bermuda Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('BOB','Bolivia Bolíviano',?,',','.','2','%s%v')",[String.fromCharCode(36, 98)])
            tx.executeSql("INSERT INTO currencies VALUES('BAM','Bosnia and Herzegovina Convertible Marka',?,',','.','2','%s%v')",[String.fromCharCode(75, 77)])
            tx.executeSql("INSERT INTO currencies VALUES('BWP','Botswana Pula',?,'.',',','2','%s%v')",[String.fromCharCode(80)])
            tx.executeSql("INSERT INTO currencies VALUES('BGN','Bulgaria Lev',?,',',' ','2','%s%v')",[String.fromCharCode(1083, 1074)])
            tx.executeSql("INSERT INTO currencies VALUES('BRL','Brazil Real',?,',','.','2','%s%v')",[String.fromCharCode(82, 36)])
            tx.executeSql("INSERT INTO currencies VALUES('BND','Brunei Darussalam Dollar',?,',','.','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('KHR','Cambodia Riel',?,'.',',','2','%s%v')",[String.fromCharCode(6107)])
            tx.executeSql("INSERT INTO currencies VALUES('CAD','Canada Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('KYD','Cayman Islands Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('CLP','Chile Peso',?,',','.','0','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('CNY','China Yuan Renminbi',?,'.',',','2','%v %s')",[String.fromCharCode(165)])
            tx.executeSql("INSERT INTO currencies VALUES('COP','Colombia Peso',?,',','.','0','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('CRC','Costa Rica Colon',?,',','.','2','%s%v')",[String.fromCharCode(8353)])
            tx.executeSql("INSERT INTO currencies VALUES('HRK','Croatia Kuna',?,',','.','2','%s%v')",[String.fromCharCode(107, 110)])
            tx.executeSql("INSERT INTO currencies VALUES('CUP','Cuba Peso',?,'.',',','2','%s%v')",[String.fromCharCode(8369)])
            tx.executeSql("INSERT INTO currencies VALUES('CZK','Czech Republic Koruna',?,',',' ','2','%v %s')",[String.fromCharCode(75, 269)])
            tx.executeSql("INSERT INTO currencies VALUES('DKK','Denmark Krone',?,',','','2','%v %s')",[String.fromCharCode(107, 114)])
            tx.executeSql("INSERT INTO currencies VALUES('DOP','Dominican Republic Peso',?,'.',',','2','%s%v')",[String.fromCharCode(82, 68, 36)])
            tx.executeSql("INSERT INTO currencies VALUES('XCD','East Caribbean Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('EGP','Egypt Pound',?,'.',',','2','%s%v')",[String.fromCharCode(163)])
            tx.executeSql("INSERT INTO currencies VALUES('SVC','El Salvador Colon',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('EUR','Euro Member Countries',?,',',' ','2','%s%v')",[String.fromCharCode(8364)])
            tx.executeSql("INSERT INTO currencies VALUES('FKP','Falkland Islands (Malvinas) Pound',?,'.',',','2','%s%v')",[String.fromCharCode(163)])
            tx.executeSql("INSERT INTO currencies VALUES('FJD','Fiji Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('GHS','Ghana Cedi',?,'.',',','2','')",[String.fromCharCode(162)])
            tx.executeSql("INSERT INTO currencies VALUES('GIP','Gibraltar Pound',?,'.',',','2','%s%v')",[String.fromCharCode(163)])
            tx.executeSql("INSERT INTO currencies VALUES('GTQ','Guatemala Quetzal',?,'.',',','2','%s%v')",[String.fromCharCode(81)])
            tx.executeSql("INSERT INTO currencies VALUES('GGP','Guernsey Pound',?,'','','2','%s%v')",[String.fromCharCode(163)])
            tx.executeSql("INSERT INTO currencies VALUES('GYD','Guyana Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('HNL','Honduras Lempira',?,'.',',','2','%s%v')",[String.fromCharCode(76)])
            tx.executeSql("INSERT INTO currencies VALUES('HKD','Hong Kong Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('HUF','Hungary Forint',?,',',' ','0','%s%v')",[String.fromCharCode(70, 116)])
            tx.executeSql("INSERT INTO currencies VALUES('ISK','Iceland Krona',?,',','.','2','%s%v')",[String.fromCharCode(107, 114)])
            tx.executeSql("INSERT INTO currencies VALUES('INR','India Rupee',?,'.',',','2','%s%v')",[String.fromCharCode(8360)])
            tx.executeSql("INSERT INTO currencies VALUES('IDR','Indonesia Rupiah',?,',','.','2','%s%v')",[String.fromCharCode(82, 112)])
            tx.executeSql("INSERT INTO currencies VALUES('IRR','Iran Rial',?,'/',',','2','%v %s')",[String.fromCharCode(65020)])
            tx.executeSql("INSERT INTO currencies VALUES('IMP','Isle of Man Pound',?,'','','2','%s%v')",[String.fromCharCode(163)])
            tx.executeSql("INSERT INTO currencies VALUES('ILS','Israel Shekel',?,'.',',','2','%s%v')",[String.fromCharCode(8362)])
            tx.executeSql("INSERT INTO currencies VALUES('JMD','Jamaica Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(74, 36)])
            tx.executeSql("INSERT INTO currencies VALUES('JPY','Japan Yen',?,'.',',','0','%s%v')",[String.fromCharCode(165)])
            tx.executeSql("INSERT INTO currencies VALUES('JEP','Jersey Pound',?,'','','2','%s%v')",[String.fromCharCode(163)])
            tx.executeSql("INSERT INTO currencies VALUES('KZT','Kazakhstan Tenge',?,'-',' ','2','%s%v')",[String.fromCharCode(1083, 1074)])
            tx.executeSql("INSERT INTO currencies VALUES('KPW','Korea (North) Won',?,'.',',','0','%s%v')",[String.fromCharCode(8361)])
            tx.executeSql("INSERT INTO currencies VALUES('KRW','Korea (South) Won',?,'.',',','0','%s%v')",[String.fromCharCode(8361)])
            tx.executeSql("INSERT INTO currencies VALUES('KGS','Kyrgyzstan Som',?,'-',' ','2','%s%v')",[String.fromCharCode(1083, 1074)])
            tx.executeSql("INSERT INTO currencies VALUES('LAK','Laos Kip',?,'.',',','2','%s%v')",[String.fromCharCode(8365)])
            tx.executeSql("INSERT INTO currencies VALUES('LBP','Lebanon Pound',?,'.',',','2','%s%v')",[String.fromCharCode(163)])
            tx.executeSql("INSERT INTO currencies VALUES('LRD','Liberia Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('MKD','Macedonia Denar',?,',','.','2','%s%v')",[String.fromCharCode(1076, 1077, 1085)])
            tx.executeSql("INSERT INTO currencies VALUES('MYR','Malaysia Ringgit',?,'.',',','2','%s%v')",[String.fromCharCode(82, 77)])
            tx.executeSql("INSERT INTO currencies VALUES('MUR','Mauritius Rupee',?,'.',',','2','%s%v')",[String.fromCharCode(8360)])
            tx.executeSql("INSERT INTO currencies VALUES('MXN','Mexico Peso',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('MNT','Mongolia Tughrik',?,',',' ','2','%s%v')",[String.fromCharCode(8366)])
            tx.executeSql("INSERT INTO currencies VALUES('MZN','Mozambique Metical',?,'.',',','2','%s%v')",[String.fromCharCode(77, 84)])
            tx.executeSql("INSERT INTO currencies VALUES('NAD','Namibia Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('NPR','Nepal Rupee',?,'.',',','2','%s%v')",[String.fromCharCode(8360)])
            tx.executeSql("INSERT INTO currencies VALUES('ANG','Netherlands Antilles Guilder',?,'.',',','2','%s%v')",[String.fromCharCode(402)])
            tx.executeSql("INSERT INTO currencies VALUES('NZD','New Zealand Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('NIO','Nicaragua Cordoba',?,'.',',','2','%s%v')",[String.fromCharCode(67, 36)])
            tx.executeSql("INSERT INTO currencies VALUES('NGN','Nigeria Naira',?,'.',',','2','%s%v')",[String.fromCharCode(8358)])
            tx.executeSql("INSERT INTO currencies VALUES('NOK','Norway Krone',?,',',' ','2','%v %s')",[String.fromCharCode(107, 114)])
            tx.executeSql("INSERT INTO currencies VALUES('OMR','Oman Rial',?,'.',',','3','%v %s')",[String.fromCharCode(65020)])
            tx.executeSql("INSERT INTO currencies VALUES('PKR','Pakistan Rupee',?,'.',',','2','%s%v')",[String.fromCharCode(8360)])
            tx.executeSql("INSERT INTO currencies VALUES('PAB','Panama Balboa',?,'.',',','2','%s%v')",[String.fromCharCode(66, 47, 46)])
            tx.executeSql("INSERT INTO currencies VALUES('PYG','Paraguay Guarani',?,',','.','0','%v%s')",[String.fromCharCode(71, 115)])
            tx.executeSql("INSERT INTO currencies VALUES('PEN','Peru Sol',?,'.',',','2','%s%v')",[String.fromCharCode(83, 47, 46)])
            tx.executeSql("INSERT INTO currencies VALUES('PHP','Philippines Piso',?,'.',',','2','%s%v')",[String.fromCharCode(8369)])
            tx.executeSql("INSERT INTO currencies VALUES('PLN','Poland Zloty',?,',',' ','2','%v %s')",[String.fromCharCode(122, 322)])
            tx.executeSql("INSERT INTO currencies VALUES('QAR','Qatar Riyal',?,'.',',','2','%v %s')",[String.fromCharCode(65020)])
            tx.executeSql("INSERT INTO currencies VALUES('RON','Romania Leu',?,',','.','2','%s%v')",[String.fromCharCode(108, 101, 105)])
            tx.executeSql("INSERT INTO currencies VALUES('RUB','Russia Ruble',?,',',' ','2','%v %s')",[String.fromCharCode(8381)])
            tx.executeSql("INSERT INTO currencies VALUES('SHP','Saint Helena Pound',?,'.',',','2','%s%v')",[String.fromCharCode(163)])
            tx.executeSql("INSERT INTO currencies VALUES('SAR','Saudi Arabia Riyal',?,'.',',','2','%v %s')",[String.fromCharCode(65020)])
            tx.executeSql("INSERT INTO currencies VALUES('RSD','Serbia Dinar',?,',','.','2','%s%v')",[String.fromCharCode(1044, 1080, 1085, 46)])
            tx.executeSql("INSERT INTO currencies VALUES('SCR','Seychelles Rupee',?,'.',',','2','%s%v')",[String.fromCharCode(8360)])
            tx.executeSql("INSERT INTO currencies VALUES('SGD','Singapore Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('SBD','Solomon Islands Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('SOS','Somalia Shilling',?,'.',',','2','%s%v')",[String.fromCharCode(83)])
            tx.executeSql("INSERT INTO currencies VALUES('ZAR','South Africa Rand',?,',',' ','2','%s%v')",[String.fromCharCode(82)])
            tx.executeSql("INSERT INTO currencies VALUES('LKR','Sri Lanka Rupee',?,'.',',','2','%s%v')",[String.fromCharCode(8360)])
            tx.executeSql("INSERT INTO currencies VALUES('SEK','Sweden Krona',?,',','.','2','%v %s')",[String.fromCharCode(107, 114)])
            tx.executeSql("INSERT INTO currencies VALUES('CHF','Switzerland Franc',?,'.','''','2','')",[String.fromCharCode(67, 72, 70)])
            tx.executeSql("INSERT INTO currencies VALUES('SRD','Suriname Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('SYP','Syria Pound',?,'.',',','2','%s%v')",[String.fromCharCode(163)])
            tx.executeSql("INSERT INTO currencies VALUES('TWD','Taiwan New Dollar',?,'.',',','0','%s%v')",[String.fromCharCode(78, 84, 36)])
            tx.executeSql("INSERT INTO currencies VALUES('THB','Thailand Baht',?,'.',',','2','%s%v')",[String.fromCharCode(3647)])
            tx.executeSql("INSERT INTO currencies VALUES('TTD','Trinidad and Tobago Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(84, 84, 36)])
            tx.executeSql("INSERT INTO currencies VALUES('TRY','Turkey Lira',?,',','.','2','%s%v')",[String.fromCharCode(8378)])
            tx.executeSql("INSERT INTO currencies VALUES('TVD','Tuvalu Dollar',?,'.',',','','')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('UAH','Ukraine Hryvnia',?,',',' ','2','%s%v')",[String.fromCharCode(8372)])
            tx.executeSql("INSERT INTO currencies VALUES('GBP','United Kingdom Pound',?,'.',',','2','%s%v')",[String.fromCharCode(163)])
            tx.executeSql("INSERT INTO currencies VALUES('USD','United States Dollar',?,'.',',','2','%s%v')",[String.fromCharCode(36)])
            tx.executeSql("INSERT INTO currencies VALUES('UYU','Uruguay Peso',?,',','.','0','%s%v')",[String.fromCharCode(36)]) //36, 85 doesn't work with accounting.js
            tx.executeSql("INSERT INTO currencies VALUES('UZS','Uzbekistan Som',?,',',' ','2','%s%v')",[String.fromCharCode(1083, 1074)])
            tx.executeSql("INSERT INTO currencies VALUES('VEF','Venezuela Bolívar',?,',','.','2','%s%v')",[String.fromCharCode(66, 115)])
            tx.executeSql("INSERT INTO currencies VALUES('VND','Viet Nam Dong',?,',','.','0','%v %s')",[String.fromCharCode(8363)])
            tx.executeSql("INSERT INTO currencies VALUES('YER','Yemen Rial',?,'.',',','2','%v %s')",[String.fromCharCode(65020)])
            tx.executeSql("INSERT INTO currencies VALUES('ZWD','Zimbabwe Dollar',?,'','','2','%s%v')",[String.fromCharCode(90, 36)])

        }
    })
}

//Database Changes for User Version 3
// Version 0.80
function executeUserVersion3() {
    createTravelRecord()
    createMetaViews()
    console.log("Database Upgraded to 3")
    upgradeUserVersion()
}


function createTravelRecord(){
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                     "CREATE TABLE `travel_expenses` (`expense_id`	INTEGER,`home_currency`	TEXT,`travel_currency`	TEXT,`rate`	REAL, `value` REAL,PRIMARY KEY(expense_id));")
    })
}

//Database Changes for User Version 4
// Version 1.0 (Rewrite)
function executeUserVersion4() {
    dropMetaViews() // To cater the changes in the meta tables
    createProfilesRecord()
    alterMetaTablesForVersion4() // Add profile id
    alterMetaViewsForVersion4() // Add profile id and if null in currency fields
    console.log("Database Upgraded to 4")
    upgradeUserVersion()
}

function dropMetaViews() {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql("DROP VIEW IF EXISTS expenses_today")
        tx.executeSql("DROP VIEW IF EXISTS expenses_yesterday")
        tx.executeSql("DROP VIEW IF EXISTS expenses_thisweek")
        tx.executeSql("DROP VIEW IF EXISTS expenses_thismonth")
        tx.executeSql("DROP VIEW IF EXISTS expenses_recent")
        tx.executeSql("DROP VIEW IF EXISTS expenses_lastweek")
        tx.executeSql("DROP VIEW IF EXISTS expenses_lastmonth")
        tx.executeSql("DROP VIEW IF EXISTS expenses_vw")
    })
}

function createProfilesRecord() {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `profiles` (`profile_id`	INTEGER PRIMARY KEY AUTOINCREMENT,`active` INTEGER NOT NULL CHECK (`active` IN (0, 1)), `display_name` TEXT)")
        tx.executeSql(
                        'INSERT INTO profiles ("active", "display_name") VALUES(1, ?)',[i18n.tr("Default")])
    })
}

function alterMetaTablesForVersion4() {
    var db = openDB()

    db.transaction(function (tx) {
        
        /* Recreate tables with foreign key profile_id */
        // Also make category name as primary key
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `categories_new` (profile_id INTEGER REFERENCES profiles(profile_id) DEFAULT 1 \
                    , `category_name`	TEXT PRIMARY KEY,`descr` TEXT,`icon` TEXT DEFAULT 'default',`color`	TEXT)")
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `expenses_new` (profile_id INTEGER REFERENCES profiles(profile_id) DEFAULT 1 \
                    , `expense_id` INTEGER PRIMARY KEY AUTOINCREMENT,`category_name` TEXT,`name`	TEXT,`descr` TEXT,`date` TEXT,`value` REAL)")
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `debts_new` (profile_id INTEGER REFERENCES profiles(profile_id) DEFAULT 1 \
                    , `debt_id` INTEGER PRIMARY KEY AUTOINCREMENT,`name` TEXT,`descr` TEXT,`date` TEXT,`value` REAL,`debtor_flag` INTEGER, `paid_flag` INTEGER)")
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `quick_expenses_new` (profile_id INTEGER REFERENCES profiles(profile_id) DEFAULT 1 \
                    , `quick_id` INTEGER PRIMARY KEY AUTOINCREMENT, `category_name`	TEXT, `name` TEXT, `descr` TEXT, `value` REAL);")
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `reports_new` (profile_id INTEGER REFERENCES profiles(profile_id) DEFAULT 1 \
                    , `report_id` INTEGER PRIMARY KEY AUTOINCREMENT,`creator` TEXT DEFAULT 'user',`report_name` TEXT,`type` TEXT DEFAULT 'LINE' \
                    ,`date_range` TEXT DEFAULT 'This Month',`date_mode` TEXT DEFAULT 'Day',`filter` TEXT,`exceptions` TEXT,`date1` TEXT,`date2` TEXT)")

        /* Insert old data to recreated tables */
        tx.executeSql("INSERT INTO categories_new SELECT 1, * FROM categories")
        tx.executeSql("INSERT INTO expenses_new SELECT 1, * FROM expenses")
        tx.executeSql("INSERT INTO debts_new SELECT 1, * FROM debts")
        tx.executeSql("INSERT INTO quick_expenses_new SELECT 1, * FROM quick_expenses")
        tx.executeSql("INSERT INTO reports_new SELECT 1, * FROM reports")

        /* Drop old tables */
        tx.executeSql("DROP TABLE categories")
        tx.executeSql("DROP TABLE expenses")
        tx.executeSql("DROP TABLE debts")
        tx.executeSql("DROP TABLE quick_expenses")
        tx.executeSql("DROP TABLE reports")

        /* Rename recreated tables to correct old names */
        tx.executeSql("ALTER TABLE categories_new RENAME TO categories")
        tx.executeSql("ALTER TABLE expenses_new RENAME TO expenses")
        tx.executeSql("ALTER TABLE debts_new RENAME TO debts")
        tx.executeSql("ALTER TABLE quick_expenses_new RENAME TO quick_expenses")
        tx.executeSql("ALTER TABLE reports_new RENAME TO reports")
    })
}

function alterMetaViewsForVersion4() {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql("DROP VIEW IF EXISTS expenses_today")
        tx.executeSql("DROP VIEW IF EXISTS expenses_yesterday")
        tx.executeSql("DROP VIEW IF EXISTS expenses_thisweek")
        tx.executeSql("DROP VIEW IF EXISTS expenses_thismonth")
        tx.executeSql("DROP VIEW IF EXISTS expenses_recent")
        tx.executeSql("DROP VIEW IF EXISTS expenses_lastweek")
        tx.executeSql("DROP VIEW IF EXISTS expenses_lastmonth")
        tx.executeSql("DROP VIEW IF EXISTS expenses_vw")


        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_today AS SELECT a.profile_id, a.expense_id, a.category_name, a.name, a.descr, a.date, a.value \
                    , IFNULL(b.home_currency, '') as home_currency, IFNULL(b.travel_currency, '') as travel_currency \
                    , IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' \
                    FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) \
                    WHERE date(a.date) = date('now','localtime')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_yesterday AS SELECT a.profile_id, a.expense_id, a.category_name, a.name, a.descr, a.date, a.value \
                    , IFNULL(b.home_currency, '') as home_currency, IFNULL(b.travel_currency, '') as travel_currency \
                    , IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' \
                    FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) \
                    WHERE date(a.date) = date('now','localtime','-1 day')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_thisweek AS SELECT a.profile_id, a.expense_id, a.category_name, a.name, a.descr, a.date, a.value \
                    , IFNULL(b.home_currency, '') as home_currency, IFNULL(b.travel_currency, '') as travel_currency \
                    , IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' \
                    FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) \
                    WHERE date(a.date) BETWEEN date('now','localtime','weekday 6','-6 days') AND date('now','localtime','weekday 6')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_thismonth AS SELECT a.profile_id, a.expense_id, a.category_name, a.name, a.descr, a.date, a.value \
                    , IFNULL(b.home_currency, '') as home_currency, IFNULL(b.travel_currency, '') as travel_currency \
                    , IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' \
                    FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) \
                    WHERE date(a.date) BETWEEN date('now', 'localtime', 'start of month')  AND date('now','localtime','start of month','+1 month','-1 day')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_recent AS SELECT a.profile_id, a.expense_id, a.category_name, a.name, a.descr, a.date, a.value \
                    , IFNULL(b.home_currency, '') as home_currency, IFNULL(b.travel_currency, '') as travel_currency \
                    , IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' \
                    FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) \
                    WHERE date(a.date) BETWEEN date('now','localtime','-7 day') AND date('now','localtime')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_lastweek AS SELECT a.profile_id, a.expense_id, a.category_name, a.name, a.descr, a.date, a.value \
                    , IFNULL(b.home_currency, '') as home_currency, IFNULL(b.travel_currency, '') as travel_currency \
                    , IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' \
                    FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) \
                    WHERE date(a.date) BETWEEN date('now','localtime','weekday 6', '-13 days') AND date('now','localtime','weekday 6', '-7 days')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_lastmonth AS SELECT a.profile_id, a.expense_id, a.category_name, a.name, a.descr, a.date, a.value \
                    , IFNULL(b.home_currency, '') as home_currency, IFNULL(b.travel_currency, '') as travel_currency \
                    , IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' \
                    FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id) \
                    WHERE date(a.date) BETWEEN date('now','localtime','start of month','-1 month') AND date('now','localtime','start of month','-1 day')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_vw AS SELECT a.profile_id, a.expense_id, a.category_name, a.name, a.descr, a.date, a.value \
                    , IFNULL(b.home_currency, '') as home_currency, IFNULL(b.travel_currency, '') as travel_currency \
                    , IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' \
                    FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id)")
    })
}


/*************Main Data functions*************/
function getProfiles() {
    var db = openDB()
    var arrResults = []
    var rs = null

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM profiles where active = 1 order by display_name asc")
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function checkProfileIfExist(txtDisplayName) {
    var db = openDB()
    var rs = null
    var exists

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM profiles WHERE active = 1 and display_name = ?", [txtDisplayName])

        exists = rs.rows.length === 0 ? false : true
    })

    return exists
}

function newProfile(txtDisplayName) {
    var txtSaveStatement
    var db = openDB()
    var rs = null
    var newID

    txtSaveStatement = 'INSERT INTO profiles(active, display_name) VALUES(1, ?)'

    db.transaction(function (tx) {
        tx.executeSql(txtSaveStatement,
                      [txtDisplayName])

        rs = tx.executeSql("SELECT MAX(profile_id) as id FROM profiles")
        newID = rs.rows.item(0).id
    })


    return newID
}

function editProfile(intProfileId, txtNewDisplayName) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "UPDATE profiles SET display_name = ? WHERE profile_id = ?",
                    [txtNewDisplayName, intProfileId])
    })
}

function deleteProfile(intProfileId) {
    var txtSqlStatement
    var db = openDB()
    var success
    var errorMsg
    var result

    // FIXME: Deactivate a profile if it has data until proper archiving is implemented
    if (checkProfileData(intProfileId)) {
        txtSqlStatement = `UPDATE profiles set active = 0 WHERE profile_id = ?`
    } else {
        txtSqlStatement = 'DELETE FROM profiles WHERE profile_id = ?'
    }

    try {
        db.transaction(function (tx) {
            tx.executeSql(txtSqlStatement, [intProfileId])
        })

        success = true
    } catch (err) {
        console.log("Database error: " + err)
        errorMsg = err
        success = false
    }
    
    result = {"success": success, "error": errorMsg}
    
    return result
}

function getCategories(intProfileId) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""

    txtSelectStatement = "SELECT category_name, descr, icon, color FROM categories WHERE profile_id = ? ORDER BY category_name"

    db.transaction(function (tx) {
        rs = tx.executeSql(txtSelectStatement, [intProfileId])

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })
    return arrResults
}

function getQuickExpenses(intProfileId, txtSearchText) {
    let db = openDB()
    let arrResults = []
    let rs = null
    let txtSelectStatement = ""
    let txtWhereStatement = "WHERE profile_id = ?"
    let txtWhereStatement2 = ""
    let txtOrderStatement = ""

    txtOrderStatement = "ORDER BY name asc"

    txtSelectStatement = 'SELECT quick_id, category_name, name, descr, value FROM quick_expenses'
    if(txtSearchText){
        txtWhereStatement2 = "AND (category_name LIKE ? OR name LIKE ? OR descr LIKE ?)"
    }

    txtSelectStatement = [txtSelectStatement, txtWhereStatement, txtWhereStatement2, txtOrderStatement].join(" ")
    //~ console.log(txtSelectStatement)
    db.transaction(function (tx) {
        if (txtSearchText) {
            let wildcard = "%" + txtSearchText + "%"
            rs = tx.executeSql(txtSelectStatement, [intProfileId, wildcard, wildcard, wildcard])
        } else {
            rs = tx.executeSql(txtSelectStatement, [intProfileId])
        }

        arrResults.length = rs.rows.length

        for (let i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function getTopExpenses(intProfileId, txtSearchText, intLimit=10) {
    let db = openDB()
    let arrResults = []
    let rs = null
    let txtFullStatement = ""
    let txtSelectStatement = ""
    let txtFromStatement = ""
    let txtWhereStatement = ""
    let txtOrderStatement = ""
    let txtGroupStatement = ""
    let txtLimitStatement = ""

    txtSelectStatement = "SELECT name, category_name, value, COUNT(*) as count"
    txtFromStatement = "FROM expenses_vw"
    txtWhereStatement = "WHERE profile_id = ? AND name LIKE ?"
    txtGroupStatement = "GROUP BY name, category_name, value"
    txtOrderStatement = "ORDER BY count desc"
    txtLimitStatement = "LIMIT ?"
    txtFullStatement = [txtSelectStatement, txtFromStatement, txtWhereStatement, txtGroupStatement, txtOrderStatement, txtLimitStatement].join(" ")
    //console.log(txtSelectStatement)
    db.transaction(function (tx) {
        if (txtSearchText) {
            let wildcard = "%" + txtSearchText + "%"
            rs = tx.executeSql(txtFullStatement, [intProfileId, wildcard, intLimit])
        } else {
            rs = tx.executeSql(txtFullStatement, [intProfileId, intLimit])
        }

        arrResults.length = rs.rows.length

        for (let i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function getHistoryExpenses(intProfileId, txtSearchText, intLimit=10) {
    let db = openDB()
    let arrResults = []
    let rs = null
    let txtFullStatement = ""
    let txtSelectStatement = ""
    let txtFromStatement = ""
    let txtLimitStatement = ""

    // List items that match the name before descr
    txtSelectStatement = "SELECT DISTINCT name, category_name, descr, value, home_currency, travel_currency, rate, travel_value"
    txtFromStatement = "FROM ( \
                        SELECT name, category_name, descr, value, date, home_currency, travel_currency, rate, travel_value, 1 as score \
                        FROM expenses_vw \
                        WHERE profile_id = ? \
                        AND UPPER(name) LIKE UPPER(?) \
                        GROUP BY name, category_name, descr, value \
                        UNION \
                        SELECT name, category_name, descr, value, date, home_currency, travel_currency, rate, travel_value, 0 as score \
                        FROM expenses_vw \
                        WHERE profile_id = ? \
                        AND UPPER(descr) LIKE UPPER(?) \
                        GROUP BY name, category_name, descr, value \
                        ORDER BY score desc, date DESC \
                        )"
    txtLimitStatement = "LIMIT ?"
    txtFullStatement = [txtSelectStatement, txtFromStatement, txtLimitStatement].join(" ")
    //console.log(txtSelectStatement)
    db.transaction(function (tx) {
        let wildcard = "%" + txtSearchText + "%"
        rs = tx.executeSql(txtFullStatement, [intProfileId, wildcard, intProfileId, wildcard, intLimit])

        arrResults.length = rs.rows.length

        for (let i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

//~ function getItemsFields() {
    //~ var db = openDB()
    //~ var arrResults = []
    //~ var rs = null

    //~ db.transaction(function (tx) {
        //~ rs = tx.executeSql("SELECT items.item_id, items.display_name, fields.field_id \
              //~ , fields.display_name as field_name, fields.precision, units.display_symbol \
              //~ FROM monitor_items items, monitor_items_fields fields \
              //~ LEFT OUTER JOIN units units ON fields.unit = units.name \
              //~ WHERE items.item_id = fields.item_id \
              //~ ORDER BY items.display_name asc, fields.field_seq asc")
        //~ arrResults.length = rs.rows.length

        //~ for (var i = 0; i < rs.rows.length; i++) {
            //~ arrResults[i] = rs.rows.item(i)
        //~ }
    //~ })

    //~ return arrResults
//~ }

function addNewExpense(intProfileId, expenseData, travelData) {
    let txtSaveStatement
    let db = openDB()
    let rs = null
    let success
    let errorMsg
    let result
    
    let _txtEntryDate = expenseData.entryDate
    let _txtName = expenseData.name
    let _txtCategory = expenseData.category
    let _txtDescr = expenseData.description
    let _realValue = expenseData.value

    txtSaveStatement = 'INSERT INTO expenses (profile_id, category_name, name, descr, date, value) VALUES(?, ?, ?, ?, strftime("%Y-%m-%d %H:%M:%f", ?, "utc"), ?)'

    try {
        db.transaction(function (tx) {
            tx.executeSql(txtSaveStatement,
                          [intProfileId, _txtCategory, _txtName, _txtDescr, _txtEntryDate, _realValue])

            // Add Travel Data
            if (travelData) {
                rs = tx.executeSql("SELECT MAX(expense_id) as id FROM expenses")
                let _newID = rs.rows.item(0).id

                addTravelData(_newID, travelData)
            }
    
        })

        success = true
    } catch (err) {
        console.log("Database error: " + err)
        errorMsg = err
        success = false
    }

    result = {"success": success, "error": errorMsg}
    
    return result
}

function addTravelData(id, travelData) {
    let txtSaveStatement
    let db = openDB()
    let rs = null

    let _txtHomeCurrency = travelData.homeCur
    let _txtTravelCurrency = travelData.travelCur
    let _realRate = travelData.rate
    let _realValue = travelData.value

    txtSaveStatement = 'INSERT INTO travel_expenses (expense_id, home_currency, travel_currency, rate, value) VALUES(?, ?, ?, ?, ?)'

    db.transaction(function (tx) {
        tx.executeSql(txtSaveStatement,
                      [id, _txtHomeCurrency, _txtTravelCurrency, _realRate, _realValue])
    })
}

function updateExpense(expenseData, travelData) {
    let _txtUpdateStatement
    let _db = openDB()
    let _rs = null
    let _success
    let _errorMsg
    let _result
    let _oldEntryDate
    
    let _txtID = expenseData.expenseID
    let _txtEntryDate = expenseData.entryDate
    let _txtName = expenseData.name
    let _txtCategory = expenseData.category
    let _txtDescr = expenseData.description
    let _realValue = expenseData.value
    let _travelData = travelData

    _txtUpdateStatement = 'UPDATE expenses SET category_name = ?, name = ?, descr = ?, date = strftime("%Y-%m-%d %H:%M:%f", ?, "utc"), value = ? WHERE expense_id = ?'

    try {
        _db.transaction(function (tx) {
            // Check old entry date
            _rs = tx.executeSql("SELECT strftime('%Y-%m-%d %H:%M:%f', date, 'localtime') as entry_date FROM expenses WHERE expense_id = ?", _txtID)
            _oldEntryDate = _rs.rows.item(0).entry_date

            tx.executeSql(_txtUpdateStatement, [_txtCategory, _txtName, _txtDescr, _txtEntryDate, _realValue, _txtID])
        })

        // Update Travel Data
        if (_travelData.rate > 0 && _travelData.homeCur != ""
                && _travelData.travelCur != "" && _travelData.value > 0) {
            updateTravelExpense(_txtID, _travelData)
        }

        _success = true
    } catch (err) {
        console.log("Database error: " + err)
        _errorMsg = err
        _success = false
    }

    _result = {"success": _success, "error": _errorMsg, "oldEntryDate": _oldEntryDate}
    
    return _result
}

function updateTravelExpense(id, travelData) {
    let _db = openDB()

    let _homeCur = travelData.homeCur
    let _travelCur = travelData.travelCur
    let _rate = travelData.rate
    let _value = travelData.value

    _db.transaction(function (tx) {
        tx.executeSql(
                    "UPDATE travel_expenses SET home_currency = ?, travel_currency = ?, rate = ?, value = ? WHERE expense_id = ?",
                    [_homeCur, _travelCur, _rate, _value, id])
    })
}

function updateItemEntryDate(txtEntryDate, txtNewEntryDate, intProfileId) {
    var txtSaveStatement, txtSaveCommentStatement
    var db = openDB()
    var rs = null
    var newID
    var success
    var errorMsg
    var result

    txtSaveStatement = 'UPDATE monitor_items_values SET entry_date = strftime("%Y-%m-%d %H:%M:%f", ?, "utc") \
                        WHERE strftime("%Y-%m-%d %H:%M:%f", entry_date, "localtime") = strftime("%Y-%m-%d %H:%M:%f", ?) \
                        AND profile_id = ?'
    txtSaveCommentStatement = "UPDATE monitor_items_comments SET entry_date = strftime('%Y-%m-%d %H:%M:%f', ?, 'utc') \
                        WHERE strftime('%Y-%m-%d %H:%M:%f', entry_date, 'localtime') = strftime('%Y-%m-%d %H:%M:%f', ?) \
                        AND profile_id = ?"

    try {
        db.transaction(function (tx) {
            tx.executeSql(txtSaveStatement,
                          [txtNewEntryDate, txtEntryDate, intProfileId])
            tx.executeSql(txtSaveCommentStatement,
                          [txtNewEntryDate, txtEntryDate, intProfileId])
    
        })

        success = true
    } catch (err) {
        console.log("Database error: " + err)
        errorMsg = err
        success = false
    }

    result = {"success": success, "error": errorMsg}
    
    return result
}

function addNewComment(txtEntryDate, intProfileId, txtComments) {
    var txtSaveStatement
    var db = openDB()
    var rs = null
    var newID
    var success
    var errorMsg
    var result

    txtSaveStatement = 'INSERT INTO monitor_items_comments ("entry_date", "profile_id", "comments") \
                        VALUES(strftime("%Y-%m-%d %H:%M:%f", ?, "utc"),?,?)'

    try {
        db.transaction(function (tx) {
            tx.executeSql(txtSaveStatement,
                          [txtEntryDate, intProfileId, txtComments])
    
        })

        success = true
    } catch (err) {
        console.log("Database error: " + err)
        errorMsg = err
        success = false
    }

    result = {"success": success, "error": errorMsg}
    
    return result
}

function editComment(txtEntryDate, intProfileId, txtNewComments) {
    var db = openDB()
    var success
    var errorMsg
    var result
    var txtInsertStatement, txtUpdateStatement
    
    txtInsertStatement = 'INSERT INTO monitor_items_comments ("entry_date", "profile_id", "comments") \
                        VALUES(strftime("%Y-%m-%d %H:%M:%f", ?, "utc"),?,?)'
    txtUpdateStatement = "UPDATE monitor_items_comments SET comments = ? WHERE profile_id = ? \
                        AND strftime('%Y-%m-%d %H:%M:%f', entry_date, 'localtime') = strftime('%Y-%m-%d %H:%M:%f', ?)"

    try {
        db.transaction(function (tx) {
            if (checkCommentIfExist(txtEntryDate)) {
                tx.executeSql(
                            txtUpdateStatement,
                            [txtNewComments, intProfileId, txtEntryDate])
            } else {
                tx.executeSql(
                    txtInsertStatement,
                    [txtEntryDate, intProfileId, txtNewComments])
            }
        })
        success = true
    } catch (err) {
        console.log("Database error: " + err)
        errorMsg = err
        success = false
    }
    
    result = {"success": success, "error": errorMsg}
    
    return result
}

function checkCommentIfExist(txtEntryDate) {
    var db = openDB()
    var rs = null
    var exists

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM monitor_items_comments WHERE strftime('%Y-%m-%d %H:%M:%f', entry_date, 'localtime') = strftime('%Y-%m-%d %H:%M:%f', ?)", [txtEntryDate])

        exists = rs.rows.length === 0 ? false : true
    })

    return exists
}

// Check if profile has values data
function checkProfileData(intProfileId) {
    var db = openDB()
    var rs = null
    var exists

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM monitor_items_values WHERE profile_id = ?", [intProfileId])

        exists = rs.rows.length === 0 ? false : true
    })

    return exists
}

function getDateWithData(forward, intProfileId, txtCategory, txtDateBase) {
    var db = openDB()
    var rs = null
    var txtSelectStatement
    var txtWhereStatement
    var txtFullStatement
    var arrArgs = []
    var lastDate

    db.transaction(function (tx) {
        txtWhereStatement = "WHERE profile_id = ?"
        //~ txtWhereStatement = "WHERE"

        if (forward) {
            txtSelectStatement = "SELECT min((strftime('%Y-%m-%d %H:%M:%f', date, 'localtime'))) as entry_date"
            txtWhereStatement = txtWhereStatement + " AND date(expenses_vw.date, 'localtime') > date(?)"
            //~ txtWhereStatement = txtWhereStatement + " date(expenses_vw.date, 'localtime') > date(?)"
        } else {
            txtSelectStatement = "SELECT max((strftime('%Y-%m-%d %H:%M:%f', date, 'localtime'))) as entry_date"
            txtWhereStatement = txtWhereStatement + " AND date(expenses_vw.date, 'localtime') < date(?)"
            //~ txtWhereStatement = txtWhereStatement + " date(expenses_vw.date, 'localtime') < date(?)"
        }

        txtSelectStatement = txtSelectStatement + " FROM expenses_vw"

        if (txtCategory !== "all") {
            txtWhereStatement = txtWhereStatement + " AND category_name = ?"
            arrArgs = [intProfileId, txtDateBase, txtCategory]
            //~ arrArgs = [txtDateBase, txtCategory]
        } else {
            arrArgs = [intProfileId, txtDateBase]
            //~ arrArgs = [txtDateBase]
        }

        txtFullStatement = txtSelectStatement + " " + txtWhereStatement
        rs = tx.executeSql(txtFullStatement, arrArgs)
        lastDate = rs.rows.item(0).entry_date
    })

    return lastDate
}

function getExpenseDetailedData(intProfileId, txtCategory, txtScope, txtxDateFrom, txtDateTo) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement
    var txtWhereStatement
    var txtOrderStatement
    var txtFullStatement
    var arrArgs = []
    //~ console.log (txtxDateFrom + " - " + txtDateTo)
    db.transaction(function (tx) {
        txtSelectStatement = "SELECT expense_id, category_name, name, descr, strftime('%Y-%m-%d %H:%M:%f', date, 'localtime') as entry_date \
                                , TOTAL(value) OVER (PARTITION BY category_name) AS category_total \
                                , TOTAL(travel_value) OVER (PARTITION BY category_name) AS category_travel_total \
                                ,value, home_currency, travel_currency, rate, travel_value \
                                FROM expenses_vw"
        txtWhereStatement = "WHERE profile_id = ? AND date(date, 'localtime') BETWEEN date(?) AND date(?)"

        if (txtCategory !== "all") {
            txtWhereStatement = txtWhereStatement + " AND category_name = ?"
            //~ arrArgs = [txtxDateFrom, txtDateTo, txtCategory]
            arrArgs = [intProfileId, txtxDateFrom, txtDateTo, txtCategory]
        } else {
            //~ arrArgs = [txtxDateFrom, txtDateTo]
            arrArgs = [intProfileId, txtxDateFrom, txtDateTo]
        }
        txtOrderStatement = "ORDER BY category_name, date desc"

        txtFullStatement = txtSelectStatement + " " + txtWhereStatement + " " + txtOrderStatement
        rs = tx.executeSql(txtFullStatement, arrArgs)
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function deleteExpense(intProfileId, txtExpenseID) {
    var txtSqlStatement
    var db = openDB()
    var success
    var errorMsg
    var result

    try {
        db.transaction(function (tx) {
            txtSqlStatement = 'DELETE FROM expenses WHERE profile_id = ? AND expense_id = ?'
            tx.executeSql(txtSqlStatement, [intProfileId, txtExpenseID])
        })

        success = true

        deleteTravelExpense(txtExpenseID)
    } catch (err) {
        console.log("Database error: " + "Profiled ID-" + intProfileId + "Expense ID-" + txtExpenseID)
        console.log("Error message: " + err)
        success = false
    }
    
    result = {"success": success, "error": errorMsg}
    
    return result
}

function deleteTravelExpense(txtExpenseID) {
    var txtDeleteStatement
    var db = openDB()

    txtDeleteStatement = 'DELETE FROM travel_expenses WHERE expense_id = ?'

    db.transaction(function (tx) {
        tx.executeSql(txtDeleteStatement, [txtExpenseID])
    })
}

// Check if there are other values with exactly the same entry date
function checkEntryDateMultiple(intProfileId, txtEntryDate, txtItemId) {
    var db = openDB()
    var rs = null
    var exists

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM monitor_items_values \
                            WHERE profile_id = ? AND strftime('%Y-%m-%d %H:%M:%f', entry_date, 'localtime') = strftime('%Y-%m-%d %H:%M:%f', ?) AND item_id <> ?", [intProfileId, txtEntryDate, txtItemId])

        exists = rs.rows.length === 0 ? false : true
    })

    return exists
}

function getDashItems() {
    var db = openDB()
    var arrResults = []
    var rs = null

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT dash.item_id, items.display_name, items.display_format \
              , items.unit, units.display_symbol, dash.value_type, dash.scope \
              FROM monitor_items_dash dash, monitor_items items \
              LEFT OUTER JOIN units units ON items.unit = units.name \
              WHERE dash.item_id = items.item_id")
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function getTotalFromValues(intProfileId, txtItemId, txtxDateFrom, txtDateTo, txtGrouping) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement

    db.transaction(function (tx) {
        txtSelectStatement = "SELECT strftime('%Y-%m-%d %H:%M:%f', val.entry_date, 'localtime') as entry_date, ROUND(TOTAL(val.value), fields.precision) as value \
                              FROM monitor_items_values as val \
                              LEFT OUTER JOIN monitor_items_fields fields \
                              ON val.field_id = fields.field_id \
                              AND val.item_id = fields.item_id \
                              WHERE val.profile_id = ? \
                              AND val.item_id = ? \
                              AND datetime(val.entry_date, 'localtime') BETWEEN datetime(?) AND datetime(?) \
                              GROUP BY fields.field_id \
                              ORDER BY val.entry_date asc, fields.field_seq asc;"
        rs = tx.executeSql(txtSelectStatement,
                                   [intProfileId, txtItemId, txtxDateFrom, txtDateTo])
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function getAverageFromValues(intProfileId, txtItemId, txtxDateFrom, txtDateTo, txtGrouping) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement, txtGroupBy, txtOrderBy, txtGroupSelect, txtMainSelect,txtFromWhere

    txtMainSelect = "SELECT strftime('%Y-%m-%d %H:%M:%f', val.entry_date, 'localtime') as entry_date, ROUND(AVG(val.value), fields.precision) as value, fields.precision"
    txtFromWhere = "FROM monitor_items_values as val \
                    LEFT OUTER JOIN monitor_items_fields fields \
                    ON val.field_id = fields.field_id \
                    AND val.item_id = fields.item_id \
                    WHERE val.profile_id = ? \
                    AND val.item_id = ? \
                    AND datetime(val.entry_date, 'localtime') BETWEEN datetime(?) AND datetime(?)"
    txtGroupBy = "GROUP BY fields.field_id"
    txtOrderBy = "ORDER BY val.entry_date asc, fields.field_seq asc"

    switch (txtGrouping) {
        case "day":
            txtGroupSelect = "SELECT entry_date, ROUND(AVG(value), precision) as value FROM ("
            txtMainSelect = "SELECT strftime('%Y-%m-%d %H:%M:%f', val.entry_date, 'localtime') as entry_date, ROUND(TOTAL(val.value), fields.precision) as value, fields.precision"
            txtGroupBy = txtGroupBy + ", date(val.entry_date, 'localtime')"
            break;
    }

    txtSelectStatement = (txtGroupSelect ? txtGroupSelect + " " : "") + txtMainSelect + " " + txtFromWhere + " " + txtGroupBy + " " + txtOrderBy + (txtGroupSelect ? ")" : "")

    db.transaction(function (tx) {
        
        rs = tx.executeSql(txtSelectStatement,
                                   [intProfileId, txtItemId, txtxDateFrom, txtDateTo])
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function getLastValue(intProfileId, txtItemId, txtxDateFrom, txtDateTo, txtGrouping) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement

    db.transaction(function (tx) {
        txtSelectStatement = "SELECT strftime('%Y-%m-%d %H:%M:%f', valu.entry_date, 'localtime') as entry_date, valu.value \
                            FROM monitor_items_values valu \
                            , (SELECT val.profile_id, val.item_id, MAX(val.entry_date) as entry_date, val.value \
                            FROM monitor_items_values as val \
                            LEFT OUTER JOIN monitor_items_fields fields \
                            ON val.field_id = fields.field_id \
                            AND val.item_id = fields.item_id \
                            WHERE val.profile_id = ? \
                            AND val.item_id = ? \
                            AND fields.field_seq = 1 \
                            AND datetime(val.entry_date, 'localtime') BETWEEN datetime(?) AND datetime(?) \
                            GROUP BY fields.field_id) max \
							LEFT OUTER JOIN monitor_items_fields fd \
                            ON valu.field_id = fd.field_id \
                            AND valu.item_id = fd.item_id \
                            WHERE max.profile_id = valu.profile_id \
                            AND max.entry_date = valu.entry_date \
                            AND max.item_id = valu.item_id \
                            ORDER BY fd.field_seq asc;"
        rs = tx.executeSql(txtSelectStatement,
                                   [intProfileId, txtItemId, txtxDateFrom, txtDateTo])
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function getHighestValue(intProfileId, txtItemId, txtxDateFrom, txtDateTo, txtGrouping) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement

    db.transaction(function (tx) {
        txtSelectStatement = "SELECT strftime('%Y-%m-%d %H:%M:%f', valu.entry_date, 'localtime') as entry_date, valu.value \
                            FROM monitor_items_values valu \
                            , (SELECT val.profile_id, val.item_id, val.entry_date, MAX(val.value) as maxValue \
                            FROM monitor_items_values as val \
                            LEFT OUTER JOIN monitor_items_fields fields \
                            ON val.field_id = fields.field_id \
                            AND val.item_id = fields.item_id \
                            WHERE val.profile_id = ? \
                            AND val.item_id = ? \
                            AND fields.field_seq = 1 \
                            AND datetime(val.entry_date, 'localtime') BETWEEN datetime(?) AND datetime(?) \
                            GROUP BY fields.field_id) max \
							LEFT OUTER JOIN monitor_items_fields fd \
                            ON valu.field_id = fd.field_id \
                            AND valu.item_id = fd.item_id \
                            WHERE max.profile_id = valu.profile_id \
                            AND max.entry_date = valu.entry_date \
                            AND max.item_id = valu.item_id \
                            ORDER BY fd.field_seq asc;"
        rs = tx.executeSql(txtSelectStatement,
                                   [intProfileId, txtItemId, txtxDateFrom, txtDateTo])
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}
