import QtQuick 2.9
import Lomiri.Components 1.3
import "../BaseComponents"
import "../../library/DataProcess.js" as DataProcess

BaseListModel {
    id: rootModel

    mode: "QuickAdd"

    function load(type, searchText){
        var arrResult

        switch(type){
        case "recent":
            mode = "QuickRecent"
            arrResult = DataProcess.getRecentExpenses(searchText)
            break
        case "list":
            mode = "QuickAdd"
            arrResult = DataProcess.getQuickExpenses(searchText)
            break
        case "top":
            mode = "QuickTop"
            arrResult = DataProcess.getTopExpenses()
            break
        }
        loadItems(arrResult)
    }

}
