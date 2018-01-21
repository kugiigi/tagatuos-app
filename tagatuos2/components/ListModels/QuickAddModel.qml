import QtQuick 2.4
import Ubuntu.Components 1.3
import "../BaseComponents"
import "../../library/DataProcess.js" as DataProcess
import "../../library/ApplicationFunctions.js" as AppFunctions

BaseListModel {
    id: rootModel

    mode: "QuickAdd"

    function load(type, searchText){
        var arrResult

        switch(type){
        case "recent":
            mode = "QuickRecent"
            arrResult = DataProcess.getRecentExpenses()
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
