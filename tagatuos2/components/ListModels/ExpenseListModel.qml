import QtQuick 2.4
import Ubuntu.Components 1.3
import "../BaseComponents"
import "../../library/DataProcess.js" as DataProcess
import "../../library/ApplicationFunctions.js" as AppFunctions

BaseListModel {
    id: rootModel

    property string totalValue: getTotalValue()

    function getTotalValue(){
        var result = 0;
        for(var i = 0; i < rootModel.count; i++){
          result += rootModel.get(i).total;
        }
        return AppFunctions.formatMoney(result, false);
    }

    function load(sort, dateFilter1, dateFilter2){
        var arrResult = DataProcess.getExpenses(mode,sort,dateFilter1,dateFilter2)
        loadItems(arrResult)
    }

}
