import QtQuick 2.12
import "../../common" as Common

Common.BaseListModel {
    id: baseValuesModel

    property var summaryValues
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

    function load(itemId, scope, dateFrom, dateTo) {
//~         var dashItems = getDashItems(itemId);
//~         properties = { dashItems: dashItems }
        properties = { scope: scope }
        fillData(mainView.expenses.detailedData(itemId, scope, dateFrom, dateTo))
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
