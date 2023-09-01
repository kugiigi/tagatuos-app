import QtQuick 2.12
import "../../common" as Common

Common.BaseListModel {
    id: baseValuesModel

    property var summaryValues

    // Current values if data was loaded
    property string category
    property string fromDate
    property string toDate
    property string scope

    function refresh() {
        if (fromDate && toDate) {
            load(category, scope, fromDate, toDate)
        }
    }

    function load(categoryName, inputScope, dateFrom, dateTo) {
        properties = { scope: scope }
        category = categoryName
        fromDate = dateFrom
        toDate = dateTo
        scope = inputScope
        fillData(mainView.expenses.detailedData(categoryName, scope, dateFrom, dateTo))
    }
}
