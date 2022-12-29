import QtQuick 2.9
import Lomiri.Components 1.3
import "../BaseComponents"
import "../../library/DataProcess.js" as DataProcess

BaseListModel {
    id: rootModel


    function load(searchText){
        var arrResult = DataProcess.getExpenseAutoComplete(searchText)
        loadItems(arrResult)
    }

}
