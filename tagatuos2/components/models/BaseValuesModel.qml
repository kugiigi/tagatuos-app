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

//~     property string totalValue: getTotalValue()
//~     property string totalTravelValue: getTotalTravelValue()

//~     function getDashItems(itemId) {
//~         var current
//~         var currentItemId
//~         var dashItems = []
//~         for (var i = 0; i < dashItemsModel.count; i++) {
//~             current = dashItemsModel.get(i)
//~             currentItemId = current.itemId
//~             if (currentItemId == itemId) {
//~                 dashItems.push(current.valueType)
//~             }
//~         }
//~         return dashItems
//~     }

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

//~     function getTotalValue(){
//~         var result = 0;
//~         for(var i = 0; i < rootModel.count; i++){
//~           result += rootModel.get(i).total;
//~         }
//~         return AppFunctions.formatMoney(result, false);
//~     }

//~     function getTotalTravelValue(){
//~         var result = 0;
//~         for(var i = 0; i < rootModel.count; i++){
//~           result += rootModel.get(i).total;
//~         }
//~         result = result * tempSettings.exchangeRate

//~         return AppFunctions.formatMoneyTravel(result, false);
//~     }

}
