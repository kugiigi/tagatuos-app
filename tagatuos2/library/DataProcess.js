.import "../library/ProcessFunc.js" as Process
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


        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_today AS SELECT expense_id, category_name, name, descr, date, value FROM expenses WHERE date(date) = date('now','localtime')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_yesterday AS SELECT expense_id, category_name, name, descr, date, value FROM expenses WHERE date(date) = date('now','localtime','-1 day')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_thisweek AS SELECT expense_id, category_name, name, descr, date, value FROM expenses WHERE date(date) BETWEEN date('now','localtime','weekday 6','-6 days') AND date('now','localtime','weekday 6')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_thismonth AS SELECT expense_id, category_name, name, descr, date, value FROM expenses WHERE date(date) BETWEEN date('now', 'localtime', 'start of month')  AND date('now','localtime','start of month','+1 month','-1 day')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_recent AS SELECT expense_id, category_name, name, descr, date, value FROM expenses WHERE date(date) BETWEEN date('now','localtime','-7 day') AND date('now','localtime')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_lastweek AS SELECT expense_id, category_name, name, descr, date, value FROM expenses WHERE date(date) BETWEEN date('now','localtime','weekday 6', '-13 days') AND date('now','localtime','weekday 6', '-7 days')")
        tx.executeSql(
                    "CREATE VIEW IF NOT EXISTS expenses_lastmonth AS SELECT expense_id, category_name, name, descr, date, value FROM expenses WHERE date(date) BETWEEN date('now','localtime','start of month','-1 month') AND date('now','localtime','start of month','-1 day')")
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
                        'INSERT INTO categories VALUES("Food", "Breakfast, Lunch, Dinner, etc.","default","cornflowerblue")')
            tx.executeSql(
                        'INSERT INTO categories VALUES("Transportation", "Taxi, Bus, Train, Gas, etc.","default","orangered")')
            tx.executeSql(
                        'INSERT INTO categories VALUES("Clothing", "Shirts, Pants, underwear, etc.","default","chocolate")')
            tx.executeSql(
                        'INSERT INTO categories VALUES("Household", "Electricity, Groceries, Rent etc.","default","springgreen")')
            tx.executeSql(
                        'INSERT INTO categories VALUES("Leisure", "Movies, Books, Sports etc.","default","palegreen")')
            tx.executeSql(
                        'INSERT INTO categories VALUES("Savings", "Investments, Reserve Funds etc.","default","purple")')
            tx.executeSql(
                        'INSERT INTO categories VALUES("Healthcare", "Dental, Hospital, Medicines etc.","default","snow")')
            tx.executeSql(
                        'INSERT INTO categories VALUES("Miscellaneous", "Other expenses","default","darkslategrey")')
            //            })
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
//        tx.executeSql(
//                    'INSERT INTO reports VALUES("system","Trend This Year By Day","LINE","This Year","Day","","","","")')
    })


}

function createQuickRecord(){
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "CREATE TABLE IF NOT EXISTS `quick_expenses` (`quick_id` INTEGER PRIMARY KEY AUTOINCREMENT, `category_name`	TEXT, `name` TEXT, `descr` TEXT, `value` REAL);")
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
    var txtSelectView = "expenses"

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

    txtSelectStatement = 'SELECT expense_id, category_name, name, descr, date, value FROM '
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

function saveExpense(txtCategory, txtName, txtDescr, txtDate, realValue) {
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
        newChecklist = {
            expense_id: newID,
            category_name: txtCategory,
            name: txtName,
            descr: txtDescr,
            date: txtDate,
            value: realValue
        }
    })

    return newChecklist
}

function updateExpense(id, category, name, descr, date, value) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "UPDATE expenses SET category_name = ?, name = ?, descr = ?, date = ?, value = ? WHERE expense_id = ?",
                    [category, name, descr, date, value, id])
    })
}

function deleteExpense(id) {
    var txtDeleteStatement
    var db = openDB()

    txtDeleteStatement = 'DELETE FROM expenses WHERE expense_id = ?'

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

function getRecentExpenses() {
    var db = openDB()
    var arrResults = []
    var rs = null
    var txtSelectStatement = ""
    var txtWhereStatement = ""
    var txtOrderStatement = ""
    var txtLimitStatement = ""
    var intTop = 10

    txtOrderStatement = " ORDER BY date desc, expense_id desc"

    txtSelectStatement = 'SELECT expense_id, category_name, name, descr, date, value FROM expenses'
    txtLimitStatement = " LIMIT " + intTop
    txtSelectStatement = txtSelectStatement + txtWhereStatement + txtOrderStatement + txtLimitStatement
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

/******Old Functions**********/
function saveChecklist(txtName, txtDescr, txtCategory, txtCreationDt, txtTargetDt, txtListType) {
    var txtSaveStatement
    var db = openDB()
    var rs = null
    var newID
    var newChecklist

    txtSaveStatement = 'INSERT INTO CHECKLIST(name,descr,category,creation_dt,target_dt, status) VALUES(?,?,?,?,?,?)'

    //txtSaveStatement = txtSaveStatement.bindValues("?",[txtName,txtDescr,txtCategory,txtCreationDt]);
    db.transaction(function (tx) {
        tx.executeSql(
                    txtSaveStatement,
                    [txtName, txtDescr, txtCategory, txtCreationDt, txtTargetDt, txtListType])
        rs = tx.executeSql("SELECT MAX(id) as id FROM CHECKLIST")
        newID = rs.rows.item(0).id
        newChecklist = {
            id: newID,
            checklist: txtName,
            descr: txtDescr,
            category: txtCategory,
            creation_dt: txtCreationDt,
            completion_dt: null,
            status: txtListType,
            target_dt: txtTargetDt,
            completed: 0,
            total: 0
        }
    })

    return newChecklist
}

function checklistExist(category, name) {
    var db = openDB()
    var rs = null
    var exists

    db.transaction(function (tx) {
        rs = tx.executeSql(
                    "SELECT * FROM checklist WHERE category = ? AND name = ? and status<>'complete'",
                    [category, name])

        exists = rs.rows.length === 0 ? false : true
    })

    return exists
}

function itemExist(checklistid, name) {
    var db = openDB()
    var rs = null
    var exists

    db.transaction(function (tx) {
        rs = tx.executeSql(
                    "SELECT * FROM items WHERE checklist_id = ? AND name = ?",
                    [checklistid, name])

        exists = rs.rows.length === 0 ? false : true
    })

    return exists
}

function saveItem(checklistid, txtChecklist, txtName, txtComment) {
    var txtSaveStatement
    var db = openDB()
    txtSaveStatement = 'INSERT INTO items(checklist_id,checklist,name,comments) VALUES(?,?,?,?)'

    db.transaction(function (tx) {
        tx.executeSql(txtSaveStatement,
                      [checklistid, txtChecklist, txtName, txtComment])
    })
}

function getDBChecklists(statement, binds) {
    var db = openDB()
    var arrResults = []
    var rs = null

    db.transaction(function (tx) {
        //console.log(statement)
        //console.log(binds)
        if (binds !== undefined) {
            rs = tx.executeSql(statement, binds)
        } else {
            rs = tx.executeSql(statement)
        }

        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            //add new row in the array
            arrResults[i] = []

            //assign values to the array
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function getDBChecklist(checklistid) {
    var db = openDB()
    var arrResults = []
    var rs = null

    db.transaction(function (tx) {
        rs = tx.executeSql("SELECT * FROM checklist WHERE id = ?",
                           [checklistid])
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            //add new row in the array
            arrResults[i] = []

            //assign values to the array
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function getDBCategories(statement) {
    var db = openDB()
    var arrResults = []
    var rs = null

    db.transaction(function (tx) {
        rs = tx.executeSql(statement)
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            //add new row in the array
            arrResults[i] = []

            //assign values to the array
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function getTargets() {
    var db = openDB()
    var rs = null
    var arrResults = []

    db.transaction(function (tx) {
        rs = tx.executeSql(
                    "SELECT id, name, target_dt, (CASE WHEN target_dt < date('now','localtime') THEN 1 ELSE 0 END) overdue FROM checklist WHERE target_dt <> '' AND status = 'incomplete' ORDER BY target_dt")
        arrResults.length = rs.rows.length

        for (var i = 0; i < rs.rows.length; i++) {
            //add new row in the array
            arrResults[i] = []

            //assign values to the array
            arrResults[i] = rs.rows.item(i)
        }
    })

    return arrResults
}

function deleteChecklist(checklistid) {
    var txtDeleteStatement, txtDeleteItemsStatement
    var db = openDB()

    txtDeleteStatement = 'DELETE FROM CHECKLIST WHERE id = ?'
    txtDeleteItemsStatement = 'DELETE FROM ITEMS WHERE checklist_id = ?'

    db.transaction(function (tx) {
        tx.executeSql(txtDeleteItemsStatement, [checklistid])
        tx.executeSql(txtDeleteStatement, [checklistid])
    })
}

function deleteItem(checklistid, txtName) {
    var txtDeleteStatement
    var db = openDB()

    txtDeleteStatement = 'DELETE FROM ITEMS WHERE checklist_id = ? AND name = ?'

    db.transaction(function (tx) {
        tx.executeSql(txtDeleteStatement, [checklistid, txtName])
    })
}

function updateItemStatus(checklistid, name, status) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "UPDATE ITEMS SET status = ? WHERE checklist_id = ? AND name = ?",
                    [status, checklistid, name])
    })
}

function updateItem(checklistid, name, newname, comments) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "UPDATE ITEMS SET name = ?, comments = ? WHERE checklist_id = ? AND name = ?",
                    [newname, comments, checklistid, name])
    })
}

function updateItemPriority(checklistid, name, newPriority) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    "UPDATE ITEMS SET priority = ? WHERE checklist_id = ? AND name = ?",
                    [newPriority, checklistid, name])
    })
}

function updateFavorite(checklistid, newFavoriteStatus) {
    var db = openDB()

    var favorite = newFavoriteStatus ? 1 : 0

    db.transaction(function (tx) {
        tx.executeSql("UPDATE CHECKLIST SET favorite = ? WHERE id = ?",
                      [favorite, checklistid])
    })
}

function updateChecklist(intID, txtListType, txtName, txtDescr, txtCategory, txtTargetDt) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql("UPDATE items SET checklist = ? WHERE checklist_id = ?",
                      [txtName, intID])
        tx.executeSql(
                    "UPDATE checklist SET status = ?, name = ?, descr = ?, category = ?, target_dt = ? WHERE id = ?",
                    [txtListType, txtName, txtDescr, txtCategory, txtTargetDt, intID])
    })
}



function updateChecklistComplete(intID) {
    var db = openDB()
    var today = new Date(Process.getToday())
    var txtCompletionDt = Process.dateFormat(0, today)

    db.transaction(function (tx) {
        tx.executeSql(
                    "UPDATE checklist SET status = 'complete', completion_dt = ? WHERE id = ?",
                    [txtCompletionDt, intID])
        tx.executeSql(
                    'UPDATE items SET status = 1 WHERE checklist_id = ? AND status = 0',
                    intID)
    })
}

function updateChecklistIncomplete(intID) {
    var db = openDB()
    var txtCompletionDt = null

    db.transaction(function (tx) {
        tx.executeSql(
                    "UPDATE checklist SET status = 'incomplete', completion_dt = ? WHERE id = ?",
                    [txtCompletionDt, intID])
    })
}

//Uncheck all items
function uncheckAllItems(intID) {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    'UPDATE items SET status = 0 WHERE checklist_id = ? AND status <> 0',
                    intID)
    })
}

//Clear Hstory
function clearHistory(dateMode) {
    var db = openDB()
    var days

    switch (dateMode) {
    case "year":
        days = "-365 day"
        break
    case "month":
        days = "-30 day"
        break
    case "week":
        days = "-7 day"
        break
    default:
        days = "-365 day"
        break
    }

    db.transaction(function (tx) {
        if (dateMode !== "all") {
            tx.executeSql(
                        'DELETE FROM items WHERE EXISTS (SELECT 1 FROM checklist chk WHERE chk.id = checklist_id AND chk.status = "complete" and chk.completion_dt <= date("now",?,"localtime"))',
                        [days])
            tx.executeSql(
                        'DELETE FROM checklist WHERE status = "complete" and completion_dt <= date("now",?,"localtime")',
                        [days])
        } else {
            tx.executeSql(
                        'DELETE FROM items WHERE EXISTS (SELECT 1 FROM checklist chk WHERE chk.id = checklist_id AND chk.status = "complete")')
            tx.executeSql('DELETE FROM checklist WHERE status = "complete"')
        }
    })
}

//Clean Saved data
function cleanSaved() {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    'UPDATE checklist set target_dt = "" WHERE status = "saved" and target_dt <> ""')
        tx.executeSql(
                    'UPDATE checklist set completion_dt = "" WHERE status = "saved" and completion_dt <> ""')
    })
}

//Clean Normal Lists
function cleanNormalLists() {
    var db = openDB()

    db.transaction(function (tx) {
        tx.executeSql(
                    'UPDATE checklist set target_dt = "" WHERE status = "normal" and target_dt <> ""')
    })
}
