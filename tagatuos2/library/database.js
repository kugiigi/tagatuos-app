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

/*************Extra functions*************/
function processTextForGLOB (text) {
    if (text.indexOf("*") > -1 || text.indexOf("?") > -1) {
        return " "
    }

    return ["*", text, "*"].join("")
}

function processTextForLIKE (text) {
    if (text.indexOf("_") > -1 || text.indexOf("%") > -1) {
        return " "
    }

    return ["%", text, "%"].join("")
}


/*************Meta data functions*************/

//Create initial data
function createInitialData() {
    createMetaTables()
    createInitialProfielData()
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

function createInitialProfielData(intProfileId) {
    var db = openDB()
    db.transaction(function (tx) {
        let _categories = null
        let _txtSqlStatement = ""
        if (intProfileId) {
            _categories = tx.executeSql('SELECT * FROM categories WHERE profile_id = ?', [intProfileId])
            _txtSqlStatement = "INSERT INTO categories VALUES(?, ?, ?, ?, ?)"
        } else {
            // For older version with no profile id
            _categories = tx.executeSql('SELECT * FROM categories')
            _txtSqlStatement = "INSERT INTO categories VALUES(?, ?, ?, ?)"
        }

        if (_categories.rows.length === 0) {
            let _categoriesData = [
                [i18n.tr("Food"),i18n.tr("Breakfast, Lunch, Dinner, etc."), "default", "cornflowerblue"]
                , [i18n.tr("Transportation"),i18n.tr("Taxi, Bus, Train, Gas, etc."), "default", "orangered"]
                , [i18n.tr("Clothing"),i18n.tr("Shirts, Pants, underwear, etc."), "default", "chocolate"]
                , [i18n.tr("Household"),i18n.tr("Electricity, Groceries, Rent etc."), "default", "springgreen"]
                , [i18n.tr("Leisure"),i18n.tr("Movies, Books, Sports etc."), "default", "palegreen"]
                , [i18n.tr("Savings"),i18n.tr("Investments, Reserve Funds etc."), "default", "purple"]
                , [i18n.tr("Healthcare"),i18n.tr("Dental, Hospital, Medicines etc."), "default", "snow"]
                , [i18n.tr("Miscellaneous"),i18n.tr("Other expenses"), "default", "darkslategrey"]
            ]
            let _length = _categoriesData.length
            for (let i = 0; i < _length; i++) {
                let _bindValues = []
                if (intProfileId) {
                    _bindValues = [intProfileId, ..._categoriesData[i]]
                } else {
                    _bindValues = _categoriesData[i]
                }

                tx.executeSql(_txtSqlStatement, _bindValues)
            }
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
    if (currentVersion > 3) {
        enableForeignKeys()
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
    updateExpenseDateToUTC() // Update all dates to UTC
    dropMetaViews() // To cater the changes in the meta tables
    createProfilesRecord()
    alterMetaTablesForVersion4() // Add profile id
    alterMetaViewsForVersion4() // Add profile id and if null in currency fields
    console.log("Database Upgraded to 4")
    upgradeUserVersion()
}

// Apparently doesn't work since it uses WebSQL :(
function enableForeignKeys() {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql("PRAGMA foreign_keys = ON")
    })
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
                    "CREATE TABLE IF NOT EXISTS `profiles` (`profile_id`	INTEGER PRIMARY KEY AUTOINCREMENT \
                    ,`active` INTEGER NOT NULL CHECK (`active` IN (0, 1)), `display_name` TEXT \
                    , `enable_overlay` INTEGER NOT NULL CHECK (`enable_overlay` IN (0, 1)), `overlay_color` TEXT \
                    , `overlay_opacity` REAL)")
        tx.executeSql(
                        'INSERT INTO profiles ("active", "display_name", "enable_overlay", "overlay_color", "overlay_opacity") VALUES(1, ?, ?, ?, ?)'
                                    ,[ i18n.tr("Default"), 0, "blue", 0.2])
    })
}

// Update all old data to UTC since the new logic stores everything in UTC and display them in localtime
function updateExpenseDateToUTC() {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "UPDATE expenses SET date = strftime('%Y-%m-%d %H:%M:%f', date, 'utc')")
    })
}

function alterMetaTablesForVersion4() {
    var db = openDB()

    db.transaction(function (tx) {
        
        /* Recreate tables with foreign key profile_id */
        // Also make category name as primary key
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `categories_new` (profile_id INTEGER DEFAULT 1 \
                    , `category_name` TEXT NOT NULL,`descr` TEXT,`icon` TEXT DEFAULT 'default',`color`	TEXT \
                    , PRIMARY KEY (profile_id, category_name) \
                    , FOREIGN KEY (profile_id) REFERENCES profiles (profile_id) ON DELETE CASCADE)")
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `expenses_new` (profile_id INTEGER REFERENCES profiles(profile_id) DEFAULT 1 \
                    , `expense_id` INTEGER PRIMARY KEY AUTOINCREMENT,`category_name` TEXT NOT NULL  DEFAULT " + i18n.tr("Uncategorized") +
                    ",`name`	TEXT,`descr` TEXT,`date` TEXT,`value` REAL \
                    , FOREIGN KEY (profile_id, category_name) REFERENCES categories (profile_id, category_name) ON UPDATE CASCADE ON DELETE RESTRICT)")
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `debts_new` (profile_id INTEGER REFERENCES profiles(profile_id) DEFAULT 1 \
                    , `debt_id` INTEGER PRIMARY KEY AUTOINCREMENT,`name` TEXT,`descr` TEXT,`date` TEXT,`value` REAL,`debtor_flag` INTEGER, `paid_flag` INTEGER)")
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `quick_expenses_new` (profile_id INTEGER REFERENCES profiles(profile_id) DEFAULT 1 \
                    , `quick_id` INTEGER PRIMARY KEY AUTOINCREMENT, `category_name`	TEXT NOT NULL DEFAULT " + i18n.tr("Uncategorized") +
                    ", `name` TEXT, `descr` TEXT, `value` REAL \
                    , FOREIGN KEY (profile_id, category_name) REFERENCES categories (profile_id, category_name) ON UPDATE CASCADE ON DELETE CASCADE)")
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

        // New views for trend charts
        tx.executeSql("DROP VIEW IF EXISTS datelist_weeksOfThisYear")
        tx.executeSql("DROP VIEW IF EXISTS datelist_weeksOfLastYear")
        tx.executeSql("DROP VIEW IF EXISTS datelist_monthsOfYear")
        tx.executeSql("DROP VIEW IF EXISTS datelist_daysOfWeek")
        tx.executeSql("DROP VIEW IF EXISTS datelist_daysOfRecent")
        tx.executeSql("DROP VIEW IF EXISTS datelist_daysOfPreviousRecent")
        tx.executeSql("DROP VIEW IF EXISTS datelist_weeksOfThisMonth")
        tx.executeSql("DROP VIEW IF EXISTS datelist_weeksOfLastMonth")
        tx.executeSql("DROP VIEW IF EXISTS datelist_daysOfThisMonth")
        tx.executeSql("DROP VIEW IF EXISTS datelist_daysOfLastMonth")


        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_vw AS SELECT a.profile_id, a.expense_id, a.category_name, a.name, a.descr, a.date, a.value \
                    , IFNULL(b.home_currency, '') as home_currency, IFNULL(b.travel_currency, '') as travel_currency \
                    , IFNULL(b.rate, 0) as 'rate', IFNULL(b.value, 0) as 'travel_value' \
                    FROM expenses a LEFT OUTER JOIN travel_expenses b USING(expense_id)")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_today AS SELECT profile_id, expense_id, category_name, name, descr, date, value \
                    , home_currency, travel_currency, rate, travel_value \
                    FROM expenses_vw \
                    WHERE date(date,'localtime') = date('now','localtime')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_yesterday AS SELECT profile_id, expense_id, category_name, name, descr, date, value \
                    , home_currency, travel_currency, rate, travel_value \
                    FROM expenses_vw \
                    WHERE date(date,'localtime') = date('now','localtime','-1 day')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_thisweek AS SELECT profile_id, expense_id, category_name, name, descr, date, value \
                    , home_currency, travel_currency, rate, travel_value \
                    FROM expenses_vw \
                    WHERE date(date,'localtime') BETWEEN date('now','localtime','weekday 6','-6 days') AND date('now','localtime','weekday 6')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_thismonth AS SELECT profile_id, expense_id, category_name, name, descr, date, value \
                    , home_currency, travel_currency, rate, travel_value \
                    FROM expenses_vw \
                    WHERE date(date,'localtime') BETWEEN date('now', 'localtime', 'start of month')  AND date('now','localtime','start of month','+1 month','-1 day')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_recent AS SELECT profile_id, expense_id, category_name, name, descr, date, value \
                    , home_currency, travel_currency, rate, travel_value \
                    FROM expenses_vw \
                    WHERE date(date,'localtime') BETWEEN date('now','localtime','-6 day') AND date('now','localtime')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_previousrecent AS SELECT profile_id, expense_id, category_name, name, descr, date, value \
                    , home_currency, travel_currency, rate, travel_value \
                    FROM expenses_vw \
                    WHERE date(date,'localtime') BETWEEN date('now','localtime','-13 day') AND date('now','localtime','-7 day')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_lastweek AS SELECT profile_id, expense_id, category_name, name, descr, date, value \
                    , home_currency, travel_currency, rate, travel_value \
                    FROM expenses_vw \
                    WHERE date(date,'localtime') BETWEEN date('now','localtime','weekday 6', '-13 days') AND date('now','localtime','weekday 6', '-7 days')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_lastmonth AS SELECT profile_id, expense_id, category_name, name, descr, date, value \
                    , home_currency, travel_currency, rate, travel_value \
                    FROM expenses_vw \
                    WHERE date(date,'localtime') BETWEEN date('now','localtime','start of month','-1 month') AND date('now','localtime','start of month','-1 day')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_thisyear AS SELECT profile_id, expense_id, category_name, name, descr, date, value \
                    , home_currency, travel_currency, rate, travel_value \
                    FROM expenses_vw \
                    WHERE date(date,'localtime') BETWEEN date('now', 'localtime', 'start of year')  AND date('now','localtime','start of year','+1 year','-1 day')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_lastyear AS SELECT profile_id, expense_id, category_name, name, descr, date, value \
                    , home_currency, travel_currency, rate, travel_value \
                    FROM expenses_vw \
                    WHERE date(date,'localtime') BETWEEN date('now','localtime','start of year','-1 year') AND date('now','localtime','start of year','-1 day')")

        // Date List Views for Charts
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS datelist_weeksOfThisYear AS WITH RECURSIVE rec AS ( \
                                SELECT date('now', 'localtime', 'start of year') AS dt, date('now','start of year','+1 year','-1 day') AS last_dt \
                                UNION ALL SELECT date(dt, 'localtime', '+7 day'), last_dt FROM rec WHERE dt < date(last_dt, '-6 day') \
                            ) \
                            SELECT strftime('%W', dt) AS week_num, dt AS date FROM rec")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS datelist_weeksOfLastYear AS WITH RECURSIVE rec AS ( \
                                SELECT date('now','localtime','start of year','-1 year') as dt, date('now','localtime','start of year','-1 day') AS last_dt \
                                UNION ALL SELECT date(dt, 'localtime', '+7 day'), last_dt FROM rec WHERE dt < date(last_dt, '-6 day') \
                            ) \
                            SELECT strftime('%W', dt) AS week_num, dt AS date FROM rec")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS datelist_monthsOfYear AS WITH RECURSIVE rec AS ( \
                                SELECT 1 AS month_num \
                                UNION ALL SELECT month_num + 1 FROM rec WHERE month_num < 12 \
                            ) \
                            SELECT PRINTF('%02d', month_num) AS month_num FROM rec")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS datelist_daysOfWeek AS WITH RECURSIVE rec AS ( \
                                SELECT 0 AS day_num \
                                UNION ALL SELECT day_num + 1 FROM rec WHERE day_num < 6 \
                            ) \
                            SELECT cast(day_num as text) AS day_num FROM rec")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS datelist_daysOfRecent AS WITH RECURSIVE rec AS ( \
                                SELECT date('now','localtime','-6 day') AS dt, date('now','localtime') AS last_dt \
                                UNION ALL SELECT date(dt, 'localtime', '+1 day'), last_dt FROM rec WHERE dt < last_dt \
                            ) \
                            SELECT strftime('%w', dt) as day_num, dt as date FROM rec")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS datelist_daysOfPreviousRecent AS WITH RECURSIVE rec AS ( \
                                SELECT date('now','localtime','-13 day') AS dt, date('now','localtime','-7 day') AS last_dt \
                                UNION ALL SELECT date(dt, 'localtime', '+1 day'), last_dt FROM rec WHERE dt < last_dt \
                            ) \
                            SELECT strftime('%w', dt) as day_num, dt as date FROM rec")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS datelist_weeksOfThisMonth AS WITH RECURSIVE rec AS ( \
                                SELECT date('now', 'localtime', 'start of month') AS dt, date('now','localtime','start of month','+1 month','-1 day') AS last_dt \
                                UNION ALL SELECT date(dt, 'localtime', '+7 day'), last_dt FROM rec WHERE dt < date(last_dt, '-6 day') \
                            ) \
                            SELECT strftime('%W', dt) AS week_num, dt AS date FROM rec")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS datelist_weeksOfLastMonth AS WITH RECURSIVE rec AS ( \
                                SELECT date('now','localtime','start of month','-1 month') AS dt, date('now','localtime','start of month','-1 day') AS last_dt \
                                UNION ALL SELECT date(dt, 'localtime', '+7 day'), last_dt FROM rec WHERE dt < date(last_dt, '-6 day') \
                            ) \
                            SELECT strftime('%W', dt) AS week_num, dt AS date FROM rec")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS datelist_daysOfThisMonth AS WITH RECURSIVE rec AS ( \
                                SELECT date('now', 'localtime', 'start of month') AS dt, date('now','localtime','start of month','+1 month','-1 day') AS last_dt \
                                UNION ALL SELECT date(dt, 'localtime', '+1 day'), last_dt FROM rec WHERE dt < last_dt \
                            ) \
                            SELECT strftime('%d', dt) AS day_num, dt AS date FROM rec")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS datelist_daysOfLastMonth AS WITH RECURSIVE rec AS ( \
                                SELECT date('now','localtime','start of month','-1 month') AS dt, date('now','localtime','start of month','-1 day') AS last_dt \
                                UNION ALL SELECT date(dt, 'localtime', '+1 day'), last_dt FROM rec WHERE dt < last_dt \
                            ) \
                            SELECT strftime('%d', dt) AS day_num, dt AS date FROM rec")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS datelist_daysOfThisWeek AS WITH RECURSIVE rec AS ( \
                                SELECT date('now','localtime','weekday 6','-6 days') AS dt, date('now','localtime','weekday 6') AS last_dt \
                                UNION ALL SELECT date(dt, 'localtime', '+1 day'), last_dt FROM rec WHERE dt < last_dt \
                            ) \
                            SELECT strftime('%w', dt) AS day_num, dt AS date FROM rec")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS datelist_daysOfLastWeek AS WITH RECURSIVE rec AS ( \
                                SELECT date('now','localtime','weekday 6', '-13 days') AS dt, date('now','localtime','weekday 6', '-7 days') AS last_dt \
                                UNION ALL SELECT date(dt, 'localtime', '+1 day'), last_dt FROM rec WHERE dt < last_dt \
                            ) \
                            SELECT strftime('%w', dt) AS day_num, dt AS date FROM rec")
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

function newProfile(txtDisplayName, boolEnableOverlay, txtOverlayColor = "blue", txtOverlayOpacity = 0.2) {
    let _txtSaveStatement
    let _db = openDB()
    let _rs = null
    let _result
    let _success = false
    let _errorMsg = ""

    let _existsResult = checkProfileIfExist(txtDisplayName)

    // Do not save when opacity is too big
    let _saveOverlayOpacity = txtOverlayOpacity > 0.6 ? 0.6 : txtOverlayOpacity

    _txtSaveStatement = 'INSERT INTO profiles(active, display_name, enable_overlay, overlay_color, overlay_opacity) VALUES(1, ?, ?, ?, ?)'

    if (!_existsResult) {
        try {
            _db.transaction(function (tx) {
                tx.executeSql(_txtSaveStatement, [txtDisplayName, boolEnableOverlay, txtOverlayColor, _saveOverlayOpacity])

                // Intialize profile data such as Categories
                _rs = tx.executeSql("SELECT MAX(profile_id) as id FROM profiles")
                let _newID = _rs.rows.item(0).id
                createInitialProfielData(_newID)
            })

            _success = true
        } catch (err) {
            console.log("Database error: " + err)
            _errorMsg = err
            _success = false
        }
    } else {
        _success = false
    }

    _result = {"success": _success, "error": _errorMsg, "exists": _existsResult}

    return _result
}

function editProfile(intProfileId, txtDisplayName, txtNewDisplayName, boolEnableOverlay, txtOverlayColor = "blue", txtOverlayOpacity = 0.2) {
    let _db = openDB()
    let _txtSaveStatement = ""
    let _result
    let _success = false
    let _errorMsg = ""
    let _exists = false

    if (txtNewDisplayName !== txtDisplayName) {
        let _existsResult = checkProfileIfExist(txtDisplayName)
        _exists = _existsResult.success && _existsResult.exists
    }

    // Do not save when opacity is too big
    let _saveOverlayOpacity = txtOverlayOpacity > 0.6 ? 0.6 : txtOverlayOpacity

    _txtSaveStatement = "UPDATE profiles SET display_name = ?, enable_overlay = ?, overlay_color = ?, overlay_opacity = ? WHERE profile_id = ?"

    if (!_exists) {
        try {
            _db.transaction(function (tx) {
                tx.executeSql(_txtSaveStatement, [ txtNewDisplayName, boolEnableOverlay, txtOverlayColor, _saveOverlayOpacity, intProfileId ])
            })

            _success = true
        } catch (err) {
            console.log("Database error: " + err)
            _errorMsg = err
            _success = false
        }
    } else {
        _success = false
    }

    _result = {"success": _success, "error": _errorMsg, "exists": _exists}

    return _result
}

function deleteProfile(intProfileId) {
    let _txtSqlStatement = ""
    let _db = openDB()
    let _success
    let _errorMsg
    let _result

    // FIXME: Deactivate a profile if it has expense data until proper archiving is implemented
    if (checkProfileData(intProfileId)) {
        _txtSqlStatement = 'UPDATE profiles set active = 0 WHERE profile_id = ?'
    } else {
        _txtSqlStatement = 'DELETE FROM profiles WHERE profile_id = ?'
        deleteProfileCategories(intProfileId)
        deleteProfileQuickExpenses(intProfileId)
    }

    try {
        _db.transaction(function (tx) {
            tx.executeSql(_txtSqlStatement, [intProfileId])
        })

        _success = true
    } catch (err) {
        console.log("Database error: " + err)
        _errorMsg = err
        _success = false
    }

    _result = {"success": _success, "error": _errorMsg}
    
    return _result
}

// Check if profile has expense data
function checkProfileData(intProfileId) {
    let _db = openDB()
    let _rs = null
    let _exists

    _db.transaction(function (tx) {
        _rs = tx.executeSql("SELECT 1 FROM expenses WHERE profile_id = ?", [intProfileId])

        _exists = _rs.rows.length === 0 ? false : true
    })

    return _exists
}

function deleteProfileCategories(intProfileId) {
    let _db = openDB()

    _db.transaction(function (tx) {
        tx.executeSql("DELETE FROM categories WHERE profile_id = ?", [intProfileId])
    })
}

function deleteProfileQuickExpenses(intProfileId) {
    let _db = openDB()

    _db.transaction(function (tx) {
        tx.executeSql("DELETE FROM quick_expenses WHERE profile_id = ?", [intProfileId])
    })
}

function getCurrencies() {
    let _db = openDB()
    let _arrResults = []
    let _rs = null
    let _txtSelectStatement = ""

    _txtSelectStatement = "SELECT * FROM currencies"

    _db.transaction(function (tx) {
        _rs = tx.executeSql(_txtSelectStatement)

        _arrResults.length = _rs.rows.length

        for (let i = 0; i < _rs.rows.length; i++) {
            _arrResults[i] = _rs.rows.item(i)
        }
    })

    return _arrResults
}

function getDateWithData(forward, intProfileId, txtCategory, txtDateBase, txtScope) {
    let _db = openDB()
    let _rs = null
    let _txtSelectStatement
    let _txtWhereStatement
    let _txtFullStatement
    let _arrArgs = []
    let _lastDate

    _db.transaction(function (tx) {
        _txtWhereStatement = "WHERE profile_id = ?"

        if (forward) {
            _txtSelectStatement = "SELECT min((strftime('%Y-%m-%d %H:%M:%f', date, 'localtime'))) as entry_date"
            switch (txtScope) {
                case "week":
                    _txtWhereStatement = _txtWhereStatement + " AND  date(date, 'localtime') > date(?,'weekday 6')"
                    break
                case "month":
                    _txtWhereStatement = _txtWhereStatement + " AND  date(date, 'localtime') > date(?,'start of month','+1 month','-1 day')"
                    break
                case "day":
                default:
                    _txtWhereStatement = _txtWhereStatement + " AND date(date, 'localtime') > date(?)"
            }
        } else {
            _txtSelectStatement = "SELECT max((strftime('%Y-%m-%d %H:%M:%f', date, 'localtime'))) as entry_date"

            switch (txtScope) {
                case "week":
                    _txtWhereStatement = _txtWhereStatement + " AND  date(date, 'localtime') <  date(?,'weekday 6','-6 days')"
                    break
                case "month":
                    _txtWhereStatement = _txtWhereStatement + " AND  date(date, 'localtime') < date(?,'start of month')"
                    break
                case "day":
                default:
                    _txtWhereStatement = _txtWhereStatement + " AND date(date, 'localtime') < date(?)"
            }
        }

        _txtSelectStatement = _txtSelectStatement + " FROM expenses_vw"

        if (txtCategory !== "all") {
            _txtWhereStatement = _txtWhereStatement + " AND category_name = ?"
            _arrArgs = [intProfileId, txtDateBase, txtCategory]
        } else {
            _arrArgs = [intProfileId, txtDateBase]
        }

        _txtFullStatement = [_txtSelectStatement, _txtWhereStatement].join(" ")
        _rs = tx.executeSql(_txtFullStatement, _arrArgs)
        _lastDate = _rs.rows.item(0).entry_date
    })

    return _lastDate
}

function getExpenseDetailedData(intProfileId, txtCategory, txtScope, txtDateFrom, txtDateTo, txtSort="category", txtOrder="asc") {
    let _db = openDB()
    let _arrResults = []
    let _rs = null
    let _txtSelectStatement = ""
    let _txtFromStatement = ""
    let _txtWhereStatement = ""
    let _txtDateStatement =""
    let _txtOrderStatement = ""
    let _txtFullStatement = ""
    let _arrArgs = []

    //~ console.log (txtDateFrom + " - " + txtDateTo)
    _db.transaction(function (tx) {
        _txtSelectStatement = "SELECT expense_id, category_name, name, descr, strftime('%Y-%m-%d %H:%M:%f', date, 'localtime') as entry_date \
                                ,value, home_currency, travel_currency, rate, travel_value"
        if (txtSort == "category") {
            _txtSelectStatement = _txtSelectStatement + ", TOTAL(value) OVER (PARTITION BY category_name) AS group_total \
                                                         , TOTAL(travel_value) OVER (PARTITION BY category_name) AS group_travel_total"
        } else if (txtSort == "date" && txtScope !== "day") {
            _txtSelectStatement = _txtSelectStatement + ", TOTAL(value) OVER (PARTITION BY strftime('%Y-%m-%d', date, 'localtime')) AS group_total \
                                                         , TOTAL(travel_value) OVER (PARTITION BY strftime('%Y-%m-%d', date, 'localtime')) AS group_travel_total"
        }

        _txtFromStatement = "FROM expenses_vw"
        _txtWhereStatement = "WHERE profile_id = ?"

        switch (txtScope) {
            case "week":
                _txtDateStatement =  "AND date(date, 'localtime') BETWEEN date(?,'weekday 6','-6 days') AND date(?,'weekday 6')"
                break
            case "month":
                _txtDateStatement =  "AND date(date, 'localtime') BETWEEN date(?, 'start of month') AND date(?,'start of month','+1 month','-1 day')"
                break
            case "day":
            _txtDateStatement =  "AND date(date, 'localtime') BETWEEN date(?) AND date(?)"
        }

        if (txtCategory !== "all") {
            _txtWhereStatement = _txtWhereStatement + " AND category_name = ?"
            _arrArgs = [intProfileId, txtCategory, txtDateFrom, txtDateTo]
        } else {
            _arrArgs = [intProfileId, txtDateFrom, txtDateTo]
        }

        switch (txtSort) {
            case "date":
                _txtOrderStatement = "ORDER BY date " + txtOrder + ", category_name ASC"
                break
            case "category":
            default:
                _txtOrderStatement = "ORDER BY category_name ASC, date " + txtOrder
                break
        }

        _txtFullStatement = [_txtSelectStatement, _txtFromStatement, _txtWhereStatement, _txtDateStatement, _txtOrderStatement].join(" ")
        _rs = tx.executeSql(_txtFullStatement, _arrArgs)
        _arrResults.length = _rs.rows.length

        for (let i = 0; i < _rs.rows.length; i++) {
            _arrResults[i] = _rs.rows.item(i)
        }
    })

    return _arrResults
}

function getCategoryBreakdown(intProfileId, txtRange, txtFromDate, txtToDate) {
    let _db = openDB()
    let _arrResults = []
    let _rs = null
    let _txtStatement = ""
    let _txtSelectStatement = ""
    let _txtFromStatement = ""
    let _txtWhereStatement = ""
    let _txtGroupStatement = ""
    let _txtFromRecord = ""
    let _isCustom = false

    _txtSelectStatement = "SELECT expense.category_name, TOTAL(expense.value) as total, IFNULL(category.color, 'black') as color"
    _txtWhereStatement = "WHERE expense.profile_id = ?"
    _txtGroupStatement = "GROUP BY expense.category_name"

    switch (txtRange) {
        case "today":
            _txtFromRecord = "expenses_today"
            break
        case "yesterday":
            _txtFromRecord = "expenses_yesterday"
            break
        case "thisweek":
            _txtFromRecord = "expenses_thisweek"
            break
        case "lastweek":
            _txtFromRecord = "expenses_lastweek"
            break
        case "recent":
            _txtFromRecord = "expenses_recent"
            break
        case "previousrecent":
            _txtFromRecord = "expenses_previousrecent"
            break
        case "thismonth":
            _txtFromRecord = "expenses_thismonth"
            break
        case "lastmonth":
            _txtFromRecord = "expenses_lastmonth"
            break
        case "thisyear":
            _txtFromRecord = "expenses_thisyear"
            break
        case "lastyear":
            _txtFromRecord = "expenses_lastyear"
            break
        default:
            _txtFromRecord = "expenses_vw"
            _txtWhereStatement = [_txtWhereStatement, "AND date(date, 'localtime') BETWEEN date(?,'localtime') AND date(?,'localtime')"].join(" ")
            _isCustom = true
            break
    }

    _txtFromStatement = "FROM " + _txtFromRecord + " expense LEFT OUTER JOIN categories category USING(profile_id, category_name)"

    _txtStatement = [_txtSelectStatement, _txtFromStatement, _txtWhereStatement, _txtGroupStatement].join(" ")

    _db.transaction(function (tx) {
        if (_isCustom) {
            _rs = tx.executeSql(_txtStatement, [intProfileId, txtFromDate, txtToDate])
        } else {
            _rs = tx.executeSql(_txtStatement, [intProfileId])
        }

        _arrResults.length = _rs.rows.length

        for (let i = 0; i < _rs.rows.length; i++) {
            _arrResults[i] = _rs.rows.item(i)
        }
    })

    return _arrResults
}

function getExpenseTrend(intProfileId, txtRange, txtMode, arrCategories, txtFromDate, txtToDate) {
    let _db = openDB()
    let _arrResults = []
    let _rs = null
    let _txtFullStatement = ""
    let _txtSelectStatement = ""
    let _txtSelectLabel = ""
    let _txtFromStatement = ""
    let _txtMainRecord = ""
    let _txtDateListRecord = ""
    let _txtWhereStatement = ""
    let _txtExtraWhereStatement = ""
    let _txtCategoryWhereStatement = ""
    let _txtGroupStatement = ""
    let _txtOrderStatement = ""
    let _isCustom = false

    _txtWhereStatement = "ON profile_id = ?"
    _txtGroupStatement = "GROUP BY label"
    _txtOrderStatement = "ORDER BY label ASC"

    switch (txtMode) {
        case "day":
            _txtSelectLabel = "datelist.date"
            if (txtRange == "thismonth" || txtRange == "lastmonth") {
                _txtExtraWhereStatement = "AND strftime('%d', date(expense.date, 'localtime')) = datelist.day_num"
            } else {
                _txtExtraWhereStatement = "AND strftime('%w', date(expense.date, 'localtime')) = datelist.day_num"
            }
            break
        case "week":
            if (txtRange == "thismonth" || txtRange == "lastmonth") {
                _txtSelectLabel = "ROW_NUMBER() OVER(ORDER BY datelist.date)"
                _txtGroupStatement = "GROUP BY strftime('%W', datelist.date)"
            } else {
                _txtSelectLabel = "strftime('%W', datelist.date)"
            }
            _txtExtraWhereStatement = "AND strftime('%W', date(expense.date, 'localtime')) = datelist.week_num"
            break
        case "month":
            _txtSelectLabel = "datelist.month_num"
            _txtExtraWhereStatement = "AND strftime('%m', date(expense.date, 'localtime')) = datelist.month_num"
            break
        default:
            _txtSelectLabel = "strftime(?, date)"
            break
    }

    switch (txtRange) {
        case "today":
            _txtMainRecord = "expenses_today"
            break
        case "yesterday":
            _txtMainRecord = "expenses_yesterday"
            break
        case "thisweek":
            _txtMainRecord = "expenses_thisweek"
            _txtDateListRecord = "datelist_daysOfThisWeek"
            break
        case "lastweek":
            _txtMainRecord = "expenses_lastweek"
            _txtDateListRecord = "datelist_daysOfLastWeek"
            break
        case "recent":
            _txtMainRecord = "expenses_recent"
            _txtDateListRecord = "datelist_daysOfRecent"
            break
        case "previousrecent":
            _txtMainRecord = "expenses_previousrecent"
            _txtDateListRecord = "datelist_daysOfPreviousRecent"
            break
        case "thismonth":
            _txtMainRecord = "expenses_thismonth"
            if (txtMode =="day") {
                _txtDateListRecord = "datelist_daysOfThisMonth"
            } else if (txtMode =="week") {
                _txtDateListRecord = "datelist_weeksOfThisMonth"
            }
            break
        case "lastmonth":
            _txtMainRecord = "expenses_lastmonth"
            if (txtMode =="day") {
                _txtDateListRecord = "datelist_daysOfLastMonth"
            } else if (txtMode =="week") {
                _txtDateListRecord = "datelist_weeksOfLastMonth"
            }
            break
        case "thisyear":
            _txtMainRecord = "expenses_thisyear"
            if (txtMode =="week") {
                _txtDateListRecord = "datelist_weeksOfThisYear"
            } else if (txtMode =="month") {
                _txtDateListRecord = "datelist_monthsOfYear"
            }
            break
        case "lastyear":
            _txtMainRecord = "expenses_lastyear"
            if (txtMode =="week") {
                _txtDateListRecord = "datelist_weeksOfLastYear"
            } else if (txtMode =="month") {
                _txtDateListRecord = "datelist_monthsOfYear"
            }
            break
        default:
            _txtMainRecord = "expenses_vw"
            // TODO: Properly implement custom date range
            _txtWhereStatement = [_txtWhereStatement, "AND date(date, 'localtime') BETWEEN date(?,'localtime') AND date(?,'localtime')"].join(" ")
            _isCustom = true
            break
    }

    _txtSelectStatement = 'SELECT ' + _txtSelectLabel + ' as label, TOTAL(value) as total'
    _txtFromStatement = ["FROM", _txtDateListRecord, "datelist LEFT OUTER JOIN", _txtMainRecord, "expense"].join(" ")

    if (arrCategories && arrCategories.length > 0) {
        _txtCategoryWhereStatement = "AND ("
        for (let i= 0; i < arrCategories.length; i++) {
            if (i == 0) {
                _txtCategoryWhereStatement = _txtCategoryWhereStatement + "expense.category_name = " + "'" + arrCategories[i] + "'"
            } else {
                _txtCategoryWhereStatement = _txtCategoryWhereStatement + " OR expense.category_name = " + "'" + arrCategories[i] + "'"
            }
        }
        _txtCategoryWhereStatement = _txtCategoryWhereStatement + ")"
    }

    _txtFullStatement = [_txtSelectStatement, _txtFromStatement
                                , _txtWhereStatement, _txtExtraWhereStatement, _txtCategoryWhereStatement
                                , _txtGroupStatement, _txtOrderStatement].join(" ")

    //~ console.log(_txtFullStatement)
    _db.transaction(function (tx) {
        if (_isCustom) {
            _rs = tx.executeSql(_txtFullStatement, [intProfileId, fromDate, toDate])
        } else {
            _rs = tx.executeSql(_txtFullStatement, intProfileId)
        }

        _arrResults.length = _rs.rows.length

        for (let i = 0; i < _rs.rows.length; i++) {
            _arrResults[i] = _rs.rows.item(i)
        }
    })

    return _arrResults
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

function addCategory(intProfileId, txtName, txtDescr, txtIcon, txtColor) {
    let _txtSaveStatement
    let _db = openDB()
    let _result
    let _success = false
    let _errorMsg = ""
    
    let _existsResult = checkCategoryIfExists(intProfileId, txtName)
    let _colorExistsResult = checkCategoryColorIfExists(intProfileId, txtName, txtColor)

    _txtSaveStatement = 'INSERT INTO categories(profile_id,category_name,descr,icon,color) VALUES(?,?,?,?,?)'

    if (_existsResult.success && !_existsResult.exists && _colorExistsResult.success && !_colorExistsResult.exists) {
        try {
            _db.transaction(function (tx) {
                tx.executeSql(_txtSaveStatement, [intProfileId, txtName, txtDescr, txtIcon, txtColor])
            })

            _success = true
        } catch (err) {
            console.log("Database error: " + err)
            _errorMsg = err
            _success = false
        }
    } else {
        _success = false
    }

    _result = { "success": _success, "error": _errorMsg, "nameExists": _existsResult.exists, "colorExists": _colorExistsResult.exists }

    return _result
}

function updateCategory(intProfileId, txtName, txtNewName, txtDescr, txtIcon, txtColor) {
    let _db = openDB()
    let _result
    let _success = false
    let _errorMsg = ""
    let _nameExists = false
    let _colorExists = false

    if (txtNewName !== txtName) {
        let _existsResult = checkCategoryIfExists(intProfileId, txtNewName)
        _nameExists = _existsResult.success && _existsResult.exists
    }

    let _colorExistsResult = checkCategoryColorIfExists(intProfileId, txtName, txtColor)
    _colorExists = _colorExistsResult.success && _colorExistsResult.exists

    if (!_nameExists && !_colorExists) {
        try {
            _db.transaction(function (tx) {
                tx.executeSql(
                            "UPDATE categories SET category_name = ?, descr = ?, icon = ?, color= ? WHERE profile_id = ? AND category_name = ?",
                      [txtNewName, txtDescr, txtIcon, txtColor, intProfileId, txtName])
                tx.executeSql("UPDATE expenses SET category_name = ? WHERE profile_id = ? AND category_name = ?",
                      [txtNewName, intProfileId, txtName])
                tx.executeSql("UPDATE quick_expenses SET category_name = ? WHERE profile_id = ? AND category_name = ?",
                      [txtNewName, intProfileId, txtName])
            })

            _success = true
        } catch (err) {
            console.log("Database error: " + err)
            _errorMsg = err
            _success = false
        }
    } else {
        _success = false
    }

    _result = { "success": _success, "error": _errorMsg, "nameExists": _nameExists, "colorExists": _colorExists }

    return _result
}

function checkCategoryIfExists(intProfileId, txtCategory) {
    let _db = openDB()
    let _rs = null
    let _result
    let _success = false
    let _errorMsg = ""
    let _exists = false

    try {
        _db.transaction(function (tx) {
            _rs = tx.executeSql("SELECT * FROM categories WHERE profile_id = ? AND category_name = ?", [intProfileId, txtCategory])
            _exists = _rs.rows.length > 0
        })

        _success = true
    } catch (err) {
        console.log("Database error: " + err)
        _errorMsg = err
        _success = false
    }

    _result = {"success": _success, "error": _errorMsg, "exists": _exists}

    return _result
}

function checkCategoryColorIfExists(intProfileId, txtCategory, txtColor) {
    let _db = openDB()
    let _rs = null
    let _result
    let _success = false
    let _errorMsg = ""
    let _exists = false

    try {
        _db.transaction(function (tx) {
            _rs = tx.executeSql("SELECT * FROM categories WHERE profile_id = ? AND category_name != ? AND color = ?", [intProfileId, txtCategory, txtColor])
            _exists = _rs.rows.length > 0
        })

        _success = true
    } catch (err) {
        console.log("Database error: " + err)
        _errorMsg = err
        _success = false
    }

    _result = {"success": _success, "error": _errorMsg, "exists": _exists}

    return _result
}

function deleteCategory(intProfileId, txtCategory) {
    let _txtDeleteStatement, _txtUpdateExpensesStatement
    let _txtNewCategory = "Uncategorized"
    let _db = openDB()
    let _result
    let _success = false
    let _errorMsg = ""
    let _hasData = false

    _hasData = checkCategoryData(intProfileId, txtCategory)

    if (!_hasData) {
        _txtDeleteStatement = 'DELETE FROM categories WHERE profile_id = ? AND category_name = ?'

        try {
            _db.transaction(function (tx) {
                tx.executeSql(_txtDeleteStatement, [intProfileId, txtCategory])
                deleteCategoryQuickExpenses(intProfileId, txtCategory)
            })

            _success = true
        } catch (err) {
            console.log("Database error: " + err)
            _errorMsg = err
            _success = false
        }
    }

    _result = { "success": _success, "error": _errorMsg, "hasData": _hasData }

    return _result
}

// Check if category has expense data
function checkCategoryData(intProfileId, txtCategory) {
    let _db = openDB()
    let _rs = null
    let _exists

    _db.transaction(function (tx) {
        _rs = tx.executeSql("SELECT 1 FROM expenses WHERE profile_id = ? AND category_name = ?", [intProfileId, txtCategory])

        _exists = _rs.rows.length === 0 ? false : true
    })

    return _exists
}

function deleteCategoryQuickExpenses(intProfileId, txtCategory) {
    let _db = openDB()

    _db.transaction(function (tx) {
        tx.executeSql("DELETE FROM quick_expenses WHERE profile_id = ? AND category_name = ?", [intProfileId, txtCategory])
    })
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
                        AND (UPPER(name) LIKE UPPER(?) \
                        OR name GLOB ?) \
                        GROUP BY name, category_name, descr, value \
                        UNION \
                        SELECT name, category_name, descr, value, date, home_currency, travel_currency, rate, travel_value, 0 as score \
                        FROM expenses_vw \
                        WHERE profile_id = ? \
                        AND (UPPER(descr) LIKE UPPER(?) \
                        OR descr GLOB ?) \
                        GROUP BY name, category_name, descr, value \
                        ORDER BY score desc, date DESC \
                        )"
    txtLimitStatement = "LIMIT ?"
    txtFullStatement = [txtSelectStatement, txtFromStatement, txtLimitStatement].join(" ")
    //console.log(txtSelectStatement)
    db.transaction(function (tx) {
        let _likeText = processTextForLIKE(txtSearchText)
        let _globText = processTextForGLOB(txtSearchText)
        rs = tx.executeSql(txtFullStatement, [intProfileId, _likeText, _globText, intProfileId, _likeText, _globText, intLimit])

        arrResults.length = rs.rows.length

        for (let i = 0; i < rs.rows.length; i++) {
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function searchExpenses(intProfileId, txtSearchText, intLimit=10, txtSort ="desc") {
    let arrResults = []

    if (txtSearchText.trim() !== "") {
        let db = openDB()
        let rs = null
        let txtFullStatement = ""
        let txtSelectStatement = ""
        let txtFromStatement = ""
        let txtWhereStatement = ""
        let txtOrderStatement = ""
        let txtLimitStatement = ""
        let txtFullSearchTextGLOB = processTextForGLOB(txtSearchText)
        let txtFullSearchTextLIKE = processTextForLIKE(txtSearchText)
        let arrBindValues = [txtFullSearchTextGLOB, txtFullSearchTextGLOB, txtFullSearchTextLIKE, txtFullSearchTextLIKE]
        let txtSortBy = txtSort == "asc" ? "ASC" : "DESC"

        txtSelectStatement = "SELECT expense_id, category_name, name, descr, strftime('%Y-%m-%d %H:%M:%f', date, 'localtime') as entry_date \
                                , value, home_currency, travel_currency, rate, travel_value \
                                , CASE WHEN name GLOB ? THEN 1 \
                                     WHEN descr GLOB ? THEN 2 \
                                     WHEN name LIKE ? THEN 3 \
                                     WHEN descr LIKE ? THEN 4"

        let _arrSearchTerms = txtSearchText.split(" ")

        for (let i = 0; i < _arrSearchTerms.length; i++) {
            let _term = _arrSearchTerms[i]
            // Continue counting the score from 4 then continue from 8
            let _score = (4 * (i + 1)) + 1
            txtSelectStatement = txtSelectStatement + " WHEN name GLOB ? THEN " + _score
            txtSelectStatement = txtSelectStatement + " WHEN descr GLOB ? THEN " + (_score + 1)
            txtSelectStatement = txtSelectStatement + " WHEN name LIKE ? THEN " + (_score + 2)
            txtSelectStatement = txtSelectStatement + " WHEN descr LIKE ? THEN " + (_score + 3)
            
            let _txtTermGLOB = processTextForGLOB(_term)
            let _txtTermLIKE = processTextForLIKE(_term)
            arrBindValues.push(_txtTermGLOB, _txtTermGLOB, _txtTermLIKE, _txtTermLIKE)
        }

        txtSelectStatement = txtSelectStatement + " END as score"

        arrBindValues.push(intProfileId)

        txtFromStatement = "FROM expenses_vw"
        txtWhereStatement = "WHERE profile_id = ? AND ("

        for (let i = 0; i < _arrSearchTerms.length; i++) {
            let _term = _arrSearchTerms[i]

            if (i == 0) {
                txtWhereStatement = txtWhereStatement + "name GLOB ?"
            } else {
                txtWhereStatement = txtWhereStatement + " OR name GLOB ?"
            }
            txtWhereStatement = txtWhereStatement + " OR descr GLOB ?"
            txtWhereStatement = txtWhereStatement + " OR name LIKE ?"
            txtWhereStatement = txtWhereStatement + " OR descr LIKE ?"

            let _txtTermGLOB = processTextForGLOB(_term)
            let _txtTermLIKE = processTextForLIKE(_term)
            arrBindValues.push(_txtTermGLOB, _txtTermGLOB, _txtTermLIKE, _txtTermLIKE)
        }
        txtWhereStatement = txtWhereStatement + ")"
        txtOrderStatement = "ORDER BY score ASC, entry_date " + txtSortBy
        txtLimitStatement = "LIMIT ?"
        arrBindValues.push(intLimit)
        txtFullStatement = [txtSelectStatement, txtFromStatement, txtWhereStatement, txtOrderStatement, txtLimitStatement].join(" ")
        //~ console.log(txtFullStatement)
        //~ console.log(JSON.stringify(arrBindValues))
        db.transaction(function (tx) {
            rs = tx.executeSql(txtFullStatement, arrBindValues)

            arrResults.length = rs.rows.length

            for (let i = 0; i < rs.rows.length; i++) {
                arrResults[i] = rs.rows.item(i)
            }
        })
    }

    return arrResults
}

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

function addQuickExpense(intProfileId, expenseData) {
    let _db = openDB()
    let _rs = null
    let _success
    let _errorMsg
    let _result

    let _txtSaveStatement = 'INSERT INTO quick_expenses(profile_id, category_name, name, descr, value) VALUES(?,?,?,?,?)'

    let _txtName = expenseData.name
    let _txtCategory = expenseData.category
    let _txtDescr = expenseData.description
    let _realValue = expenseData.value

    let _existsResult = checkIfQuickExpenseExists(intProfileId, expenseData)

    if (_existsResult.success && !_existsResult.exists) {
        try {
            _db.transaction(function (tx) {
                tx.executeSql(_txtSaveStatement, [intProfileId, _txtCategory, _txtName, _txtDescr, _realValue])
            })

            _success = true
        } catch (err) {
            console.log("Database error: " + err)
            _errorMsg = err
            _success = false
        }
    } else {
        _success = false
    }

    _result = {"success": _success, "error": _errorMsg, "exists": _existsResult.exists}
    
    return _result
}

function editQuickExpense(intProfileId, quickData) {
    let _db = openDB()
    let _rs = null
    let _success
    let _errorMsg
    let _result

    let _txtSaveStatement = 'UPDATE quick_expenses SET category_name = ?, name = ? , descr = ?, value = ? WHERE profile_id = ? AND quick_id = ?'

    let _txtID = quickData.id
    let _txtName = quickData.name
    let _txtCategory = quickData.category
    let _txtDescr = quickData.description
    let _realValue = quickData.value

    let _existsResult = checkIfQuickExpenseExists(intProfileId, quickData)

    if (_existsResult.success && !_existsResult.exists) {
        try {
            _db.transaction(function (tx) {
                tx.executeSql(_txtSaveStatement, [_txtCategory, _txtName, _txtDescr, _realValue, intProfileId, _txtID])
            })

            _success = true
        } catch (err) {
            console.log("Database error: " + err)
            _errorMsg = err
            _success = false
        }
    } else {
        _success = false
    }

    _result = {"success": _success, "error": _errorMsg, "exists": _existsResult.exists}
    
    return _result
}

function deleteQuickExpense(intProfileId, txtID) {
    let _db = openDB()
    let _rs = null
    let _success
    let _errorMsg
    let _result
    let _txtDeleteStatement = 'DELETE FROM quick_expenses WHERE profile_id = ? AND quick_id = ?'

    try {
        _db.transaction(function (tx) {
            tx.executeSql(_txtDeleteStatement, [intProfileId, txtID])
        })

        _success = true
    } catch (err) {
        console.log("Database error: " + err)
        _errorMsg = err
        _success = false
    }

    _result = { "success": _success, "error": _errorMsg }
    
    return _result
}

function checkIfQuickExpenseExists(intProfileId, expenseData) {
    let _db = openDB()
    let _rs = null
    let _success
    let _errorMsg
    let _result
    let _exists = false

    let _txtSelectStatement = 'SELECT 1 FROM quick_expenses WHERE profile_id = ? AND category_name = ? AND name = ? AND descr = ? AND value = ?'

    let _txtName = expenseData.name
    let _txtCategory = expenseData.category
    let _txtDescr = expenseData.description
    let _realValue = expenseData.value

    try {
        _db.transaction(function (tx) {
            _rs = tx.executeSql(_txtSelectStatement, [intProfileId, _txtCategory, _txtName, _txtDescr, _realValue])
            _exists = _rs.rows.length > 0
        })

        _success = true
    } catch (err) {
        console.log("Database error: " + err)
        _errorMsg = err
        _success = false
    }

    _result = {"success": _success, "error": _errorMsg, "exists": _exists}
    
    return _result
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
