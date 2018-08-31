//.import "../library/ProcessFunc.js" as Process
.import QtQuick.LocalStorage 2.0 as Sql


/*open database for transactions*/
function openDB() {
    var db = null
    if (db !== null)
        return

    // db = LocalStorage.openDatabaseSync(identifier, version, description, estimated_size, callback(db))
    db = Sql.LocalStorage.openDatabaseSync("tagatuos.kugiigi", "1.0",
                                           "applciation's backend data", 100000)

    return db
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
            //            db.transaction(function (tx) {
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




/*************Main Data functions*************/
function getExpenses(mode, sort, dateFilter1, dateFilter2) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""
    var txtWhereStatement = ""
    var txtOrderStatement = ""
    var txtSelectView = "expenses_vw"

    switch (mode) {
    case "Today":
        txtSelectView = "expenses_today"
        break
    case "Yesterday":
        txtSelectView = "expenses_yesterday"
        break
    case "This Week":
        txtSelectView = "expenses_thisweek"
        break
    case "This Month":
        txtSelectView = "expenses_thismonth"
        break
    case "Recent":
        txtSelectView = "expenses_recent"
        break
    case "Last Week":
        txtSelectView = "expenses_lastweek"
        break
    case "Last Month":
        txtSelectView = "expenses_lastmonth"
        break
    case "Calendar (By Day)":
        txtWhereStatement = " WHERE date(date) = date(?,'localtime')"
        break
    case "Calendar (By Week)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?,'localtime') AND date(?, 'localtime')"
        break
    case "Calendar (By Month)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?, 'localtime') AND date(?,'localtime')"
        break
    case "Calendar (Custom)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?, 'localtime') AND date(?,'localtime')"
        break
    default:
        txtWhereStatement = ""
        break
    }

    switch (sort) {
    case "Category":
        txtOrderStatement = " ORDER BY category_name, date desc, name"
        break
    default:
        txtOrderStatement = " ORDER BY date desc, category_name, name"
        break
    }

    txtSelectStatement = 'SELECT expense_id, category_name, name, descr, date, value, home_currency, travel_currency, rate, travel_value FROM '
    txtSelectStatement = txtSelectStatement + txtSelectView + txtWhereStatement + txtOrderStatement

//    console.log(txtSelectStatement)
    db.transaction(function (tx) {
        if (mode.search("Calendar") === -1) {
            rs = tx.executeSql(txtSelectStatement)
        } else {
            //            console.log(mode + txtSelectStatement + dateFilter1 + dateFilter2)
            if (mode.search("Day") === -1) {
                rs = tx.executeSql(txtSelectStatement,
                                   [dateFilter1, dateFilter2])
            } else {
                rs = tx.executeSql(txtSelectStatement, dateFilter1)
            }
        }

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function getExpenseData(id) {
    var db = openDB()
    var arrResults = []
    var rs = null

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM expenses WHERE expense_id = ?", [id])
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            //add new row in the array
            arrResults[i] = []

            //assign values to the array
            arrResults[i] = rs.rows.item(i)
        }
    })

    //Get Travel Data
    var arrTravelData = getTravelData(id)
    if(arrTravelData){
        arrResults[0].travel = arrTravelData
    }

    return arrResults[0]
}

function getExpenseAutoComplete(txtString) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""
    var txtWhereStatement = ""
    var txtOrderStatement = ""
    var txtGroupStatement = ""
    var txtContainString = ""

    txtContainString = "%" + txtString + "%"

    txtSelectStatement = 'SELECT name, value, count(*) as total FROM expenses '
    txtWhereStatement = " where name LIKE ?"
    txtOrderStatement = " ORDER BY total desc limit 4"
    txtGroupStatement = " GROUP BY name,value"

    txtSelectStatement = txtSelectStatement + txtWhereStatement
            + txtGroupStatement + txtOrderStatement

    //console.log(txtSelectStatement)
    db.transaction(function (tx) {
        rs = tx.executeSql(txtSelectStatement, [txtContainString])

        arrResults.length = rs.rows.length

        //console.log("statement: " + txtSelectStatement + " - " +  txtContainString + ": results: " + arrResults.length)
        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })
    return arrResults
}


function getExpenseTrend(range, mode, category, exception, dateFilter1, dateFilter2) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtLabelDateFormat
    var txtSelectStatement = ""
    var txtSelectLabel = ""
    var txtWhereStatement = ""
    var txtGroupByStatement = ""
    var txtOrderStatement = ""

    txtSelectLabel = "strftime(?, date)"

    switch (range) {
    case "This Week":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now','localtime','weekday 6','-6 days') AND date('now','localtime','weekday 6')"
        break
    case "This Month":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now', 'localtime', 'start of month')  AND date('now','start of month','+1 month','-1 day')"
        break
    case "This Year":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now', 'localtime', 'start of year') AND date('now','start of year','+1 year','-1 day')"
        break
    case "Recent":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now','-6 day','localtime') AND date('now','localtime')"
        break
    case "Last Week":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now','localtime','weekday 6', '-13 days') AND date('now','localtime','weekday 6', '-7 days')"
        break
    case "Last Month":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now', '-1 month','localtime','start of month') AND date('now','localtime','start of month','-1 day')"
        break
    case "Last Year":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now', '-1 year','localtime','start of year') AND date('now','localtime','start of year','-1 day')"
        break
    case "Calendar (By Week)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?,'localtime') AND date(?, 'localtime')"
        break
    case "Calendar (By Month)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?, 'localtime') AND date(?,'localtime')"
        break
    case "Calendar (By Year)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?, 'localtime') AND date(?,'localtime')"
        break
    case "Calendar (Custom)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?, 'localtime') AND date(?,'localtime')"
        break
    default:
        txtWhereStatement = ""
        break
    }

    switch (mode) {
    case "Day":
//        txtLabelDateFormat = "%d"
        txtSelectLabel = 'date'
        break
    case "Week":
        txtLabelDateFormat = "%W"
        break
    case "Month":
        txtLabelDateFormat = "%m"
        break
    default:
        txtLabelDateFormat = "%d"
        break
    }

    txtSelectStatement = 'SELECT ' + txtSelectLabel + ' as label, TOTAL(value) as  total from expenses'
    txtGroupByStatement = " GROUP BY label"
    txtOrderStatement = " ORDER BY label ASC"

    txtSelectStatement = txtSelectStatement + txtWhereStatement + txtGroupByStatement + txtOrderStatement

//    console.log(txtSelectStatement)
    db.transaction(function (tx) {
        if (range.search("Calendar") === -1) {
            if(mode === "Day"){
                rs = tx.executeSql(txtSelectStatement)
            }else{
                rs = tx.executeSql(txtSelectStatement,txtLabelDateFormat)
            }
        } else {
            if(mode === "Day"){
                rs = tx.executeSql(txtSelectStatement,
                                   [dateFilter1, dateFilter2])
            }else{
                rs = tx.executeSql(txtSelectStatement,
                                   [txtLabelDateFormat, dateFilter1, dateFilter2])
            }
        }

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}


function getExpenseBreakdown(range, category, exception, dateFilter1, dateFilter2) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtLabelDateFormat
    var txtSelectStatement = ""
    var txtWhereStatement = ""
    var txtWhereAndStatement = ""
    var txtGroupByStatement = ""
    var txtOrderStatement = ""


    switch (range) {
    case "Today":
        txtWhereStatement = " WHERE date(date) = date('now','localtime')"
        break
    case "Yesterday":
        txtWhereStatement = " WHERE date(date) = date('now','-1 day','localtime') "
        break
    case "This Week":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now','localtime','weekday 6','-6 days') AND date('now','localtime','weekday 6')"
        break
    case "This Month":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now', 'localtime', 'start of month')  AND date('now','start of month','+1 month','-1 day')"
        break
    case "This Year":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now', 'localtime', 'start of year') AND date('now','start of year','+1 year','-1 day')"
        break
    case "Recent":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now','-6 day','localtime') AND date('now','localtime')"
        break
    case "Last Week":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now','localtime','weekday 6', '-13 days') AND date('now','localtime','weekday 6', '-7 days')"
        break
    case "Last Month":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now', '-1 month','localtime','start of month') AND date('now','localtime','start of month','-1 day')"
        break
    case "Last Year":
        txtWhereStatement = " WHERE date(date) BETWEEN date('now', '-1 year','localtime','start of year') AND date('now','localtime','start of year','-1 day')"
        break
    case "Calendar (By Week)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?,'localtime') AND date(?, 'localtime')"
        break
    case "Calendar (By Month)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?, 'localtime') AND date(?,'localtime')"
        break
    case "Calendar (By Year)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?, 'localtime') AND date(?,'localtime')"
        break
    case "Calendar (Custom)":
        txtWhereStatement = " WHERE date(date) BETWEEN date(?, 'localtime') AND date(?,'localtime')"
        break
    default:
        txtWhereStatement = ""
        break
    }

    txtSelectStatement = 'SELECT exp.category_name as category, cat.color as color, TOTAL(exp.value) as value FROM expenses exp, categories cat'
    txtWhereAndStatement = " AND exp.category_name = cat.category_name"
    txtGroupByStatement = " GROUP BY cat.category_name"
    txtOrderStatement = " ORDER BY cat.category_name ASC"

    txtSelectStatement = txtSelectStatement + txtWhereStatement + txtWhereAndStatement + txtGroupByStatement + txtOrderStatement

//    console.log(txtSelectStatement)
    db.transaction(function (tx) {

        if (range.search("Calendar") === -1) {
           rs = tx.executeSql(txtSelectStatement)
        } else {
            if(mode.search("Day") === -1){
                rs = tx.executeSql(txtSelectStatement, [dateFilter1,dateFilter2])
            }else{
                rs = tx.executeSql(txtSelectStatement, dateFilter1)
            }
        }

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function saveExpense(txtCategory, txtName, txtDescr, txtDate, realValue, travelData) {
    var txtSaveStatement
    var db = openDB()
    var rs = null
    var newID
    var newChecklist

    txtSaveStatement = 'INSERT INTO expenses(category_name,name,descr,date,value) VALUES(?,?,?,?,?)'

    db.transaction(function (tx) {
        tx.executeSql(txtSaveStatement,
                      [txtCategory, txtName, txtDescr, txtDate, realValue])

        rs = tx.executeSql("SELECT MAX(expense_id) as id FROM expenses")
        newID = rs.rows.item(0).id
        //Save Travel Data
        if(travelData){
            saveTravelExpense(newID, travelData.homeCur, travelData.travelCur, travelData.rate, travelData.value)
        }
        newChecklist = {
            expense_id: newID,
            category_name: txtCategory,
            name: txtName,
            descr: txtDescr,
            date: txtDate,
            value: realValue,
            travel: travelData
        }
    })


    return newChecklist
}

function updateExpense(id, category, name, descr, date, value, travelData) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "UPDATE expenses SET category_name = ?, name = ?, descr = ?, date = ?, value = ? WHERE expense_id = ?",
                    [category, name, descr, date, value, id])
    })

    //Update Travel Data
    if(travelData){
        updateTravelExpense(id, travelData.homeCur, travelData.travelCur, travelData.rate, travelData.value)
    }
}

function deleteExpense(id) {
    var txtDeleteStatement
    var db = openDB()

    txtDeleteStatement = 'DELETE FROM expenses WHERE expense_id = ?'

    db.transaction(function (tx) {
        tx.executeSql(txtDeleteStatement, [id])
    })

    //Delete Travel Data
    deleteTravelExpense(id)
}


//Travel Data
function getTravelData(id) {
    var db = openDB()
    var arrResults = []
    var rs = null

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM travel_expenses WHERE expense_id = ?", [id])
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            //add new row in the array
            arrResults[i] = []

            //assign values to the array
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults[0]
}

function saveTravelExpense(id, homeCurrency, travelCurrency, rate, value ) {
    var txtSaveStatement
    var db = openDB()
    var rs = null
    var newID
    var newChecklist

    txtSaveStatement = 'INSERT INTO travel_expenses(expense_id,home_currency,travel_currency,rate,value) VALUES(?,?,?,?,?)'

    db.transaction(function (tx) {
        tx.executeSql(txtSaveStatement,
                      [id, homeCurrency, travelCurrency, rate, value])
    })
}

function updateTravelExpense(id, homeCurrency, travelCurrency, rate, value) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "UPDATE travel_expenses SET home_currency = ?, travel_currency = ?, rate = ?, value = ? WHERE expense_id = ?",
                    [homeCurrency, travelCurrency, rate, value, id])
    })
}

function deleteTravelExpense(id) {
    var txtDeleteStatement
    var db = openDB()

    txtDeleteStatement = 'DELETE FROM travel_expenses WHERE expense_id = ?'

    db.transaction(function (tx) {
        tx.executeSql(txtDeleteStatement, [id])
    })
}

function getCategories() {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""

    txtSelectStatement = "SELECT category_name, descr, icon, color FROM categories"

    db.transaction(function (tx) {
        rs = tx.executeSql(txtSelectStatement)

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })
    return arrResults
}

function saveCategory(txtName, txtDescr, txtIcon, txtColor) {
    var txtSaveStatement
    var db = openDB()
    txtSaveStatement = 'INSERT INTO categories(category_name,descr,icon,color) VALUES(?,?,?,?)'

    db.transaction(function (tx) {
        tx.executeSql(txtSaveStatement, [txtName, txtDescr, txtIcon, txtColor])
    })
}

function categoryExist(category) {
    var db = openDB()
    var rs = null
    var exists

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM categories WHERE category_name = ?", [category])

        exists = rs.rows.length === 0 ? false : true
    })

    return exists
}

function deleteCategory(txtCategory) {
    var txtDeleteStatement, txtUpdateExpensesStatement
    var txtNewCategory = "Uncategorized"
    var db = openDB()

    txtDeleteStatement = 'DELETE FROM categories WHERE category_name = ?'
    txtUpdateExpensesStatement = 'UPDATE expenses SET category_name = ? WHERE category_name = ?'

    db.transaction(function (tx) {
        tx.executeSql(txtUpdateExpensesStatement,
                      [txtNewCategory, txtCategory])
        tx.executeSql(txtDeleteStatement, [txtCategory])
    })
}

function updateCategory(txtName, txtNewName, txtDescr, txtIcon, txtColor) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql("UPDATE expenses SET category_name = ? WHERE category_name = ?",
                      [txtNewName, txtName])
        tx.executeSql(
                    "UPDATE categories SET category_name = ?, descr = ?, icon = ?, color= ? WHERE category_name = ?",
                    [txtNewName, txtDescr, txtIcon, txtColor, txtName])
    })
}


function getReports() {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""

    txtSelectStatement = "SELECT * FROM reports"

    db.transaction(function (tx) {
        rs = tx.executeSql(txtSelectStatement)

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })
    return arrResults
}

function saveReport(txtName, txtDescr, txtIcon, txtColor) {
    var txtSaveStatement
    var db = openDB()
    txtSaveStatement = 'INSERT INTO categories(category_name,descr,icon,color) VALUES(?,?,?,?)'

    db.transaction(function (tx) {
        tx.executeSql(txtSaveStatement, [txtName, txtDescr, txtIcon, txtColor])
    })
}

function reportExist(category) {
    var db = openDB()
    var rs = null
    var exists

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM categories WHERE category_name = ?", [category])

        exists = rs.rows.length === 0 ? false : true
    })

    return exists
}

function deleteReport(intReportID) {
    var txtDeleteStatement
    var db = openDB()

    txtDeleteStatement = 'DELETE FROM reports WHERE report_id = ?'

    db.transaction(function (tx) {
        tx.executeSql(txtDeleteStatement, [intReportID])
    })
}

function updateReport(txtName, txtNewName, txtDescr, txtIcon, txtColor) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql("UPDATE expenses SET category_name = ? WHERE category_name = ?",
                      [txtNewName, txtName])
        tx.executeSql(
                    "UPDATE categories SET category_name = ?, descr = ?, icon = ?, color= ? WHERE category_name = ?",
                    [txtNewName, txtDescr, txtIcon, txtColor, txtName])
    })
}

function getQuickExpenses(searchText) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""
    var txtWhereStatement = ""
    var txtOrderStatement = ""

    txtOrderStatement = " ORDER BY name asc"

    txtSelectStatement = 'SELECT quick_id, category_name, name, descr, value FROM quick_expenses'
    if(searchText){
        txtWhereStatement = " WHERE category_name LIKE ? OR name LIKE ? OR descr LIKE ?"
    }

    txtSelectStatement = txtSelectStatement + txtWhereStatement + txtOrderStatement
//    console.log(txtSelectStatement)
    db.transaction(function (tx) {
        if(searchText){
            var wildcard = "%" + searchText + "%"
            rs = tx.executeSql(txtSelectStatement,[wildcard,wildcard,wildcard])
        }else{
            rs = tx.executeSql(txtSelectStatement)
        }

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function saveQuickExpense(txtCategory, txtName, txtDescr, realValue) {
    var txtSaveStatement
    var db = openDB()
    var rs = null
    var newID
    var newQuickExpense

    txtSaveStatement = 'INSERT INTO quick_expenses(category_name,name,descr,value) VALUES(?,?,?,?)'

    db.transaction(function (tx) {
        tx.executeSql(txtSaveStatement,
                      [txtCategory, txtName, txtDescr, realValue])
        rs = tx.executeSql("SELECT MAX(quick_id) as id FROM quick_expenses")
        newID = rs.rows.item(0).id
        newQuickExpense = {
            quick_id: newID,
            category_name: txtCategory,
            quickname: txtName,
            descr: txtDescr,
            quickvalue: realValue
        }
    })

    return newQuickExpense
}

function updateQuickExpense(id, category, name, descr, value) {
    var db = openDB()
    var updatedQuickExpense

    db.transaction(function (tx) {
        tx.executeSql(
                    "UPDATE quick_expenses SET category_name = ?, name = ?, descr = ?, value = ? WHERE quick_id = ?",
                    [category, name, descr, value, id])
    })

    updatedQuickExpense = {
        quick_id: id,
        category_name: category,
        quickname: name,
        descr: descr,
        quickvalue: value
    }

    return updatedQuickExpense
}

function deleteQuickExpense(id) {
    var txtDeleteStatement
    var db = openDB()

    txtDeleteStatement = 'DELETE FROM quick_expenses WHERE quick_id = ?'

    db.transaction(function (tx) {
        tx.executeSql(txtDeleteStatement, [id])
    })
}

function getRecentExpenses(searchText) {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""
    var txtWhereStatement = ""
    var txtOrderStatement = ""
    var txtLimitStatement = ""
    var intTop

    txtOrderStatement = " ORDER BY date desc, expense_id desc"

    txtSelectStatement = 'SELECT expense_id, category_name, name, descr, date, value FROM expenses'
    txtLimitStatement = " LIMIT ?"

    if(searchText){
        intTop = 20
        txtWhereStatement = " WHERE category_name LIKE ? OR name LIKE ? OR descr LIKE ?"
        txtSelectStatement = txtSelectStatement + txtWhereStatement + txtOrderStatement + txtLimitStatement
    }else{
        intTop = 10
        txtSelectStatement = txtSelectStatement + txtOrderStatement + txtLimitStatement
    }

    //console.log(txtSelectStatement)
    db.transaction(function (tx) {

        if(searchText){
            var wildcard = "%" + searchText + "%"
            rs = tx.executeSql(txtSelectStatement,[wildcard,wildcard,wildcard,intTop])
        }else{
            rs = tx.executeSql(txtSelectStatement,[intTop])
        }

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })


    return arrResults
}

function getTopExpenses() {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""
    var txtWhereStatement = ""
    var txtOrderStatement = ""
    var txtGroupStatement = ""
    var txtLimitStatement = ""
    var intTop = 10

    txtOrderStatement = " ORDER BY count desc"
    txtGroupStatement = " GROUP BY name, category_name, value"
    txtSelectStatement = 'SELECT name,category_name, value, COUNT(*) as count FROM expenses'
    txtLimitStatement = " LIMIT " + intTop
    txtSelectStatement = txtSelectStatement + txtWhereStatement + txtGroupStatement + txtOrderStatement + txtLimitStatement
    //console.log(txtSelectStatement)
    db.transaction(function (tx) {
        rs = tx.executeSql(txtSelectStatement)

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}


function getCurrencies() {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""

    txtSelectStatement = "SELECT * FROM currencies"

    db.transaction(function (tx) {
        rs = tx.executeSql(txtSelectStatement)

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })
    return arrResults
}
