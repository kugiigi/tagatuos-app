import QtQuick 2.12
import Lomiri.Components 1.3 as UT
import "../../library/dataUtils.js" as DataUtils
import "../../library/functions.js" as Functions
import "../../common/" as Common

Item {
    id: mainModels

    readonly property string profilesID: "Profiles"
    readonly property string categoriesID: "Categories"
    readonly property string firstDetailedListID: "Detailed_1"
    readonly property string secondDetailedListID: "Detailed_2"
    readonly property string thirdDetailedListID: "Detailed_3"
    readonly property string quickExpensesID: "QuickExpenses"
    readonly property string historyEntryExpensesID: "HistoryEntry"
    
    property alias profilesModel: profilesModel
//~     property alias dashboardModel: dashboardModel
//~     property alias dashItemsModel: dashItemsModel
    property var detailedListModels: [ firstDetailedListModel, secondDetailedListModel, thirdDetailedListModel ]
    property alias firstDetailedListModel: firstDetailedListModel
    property alias secondDetailedListModel: secondDetailedListModel
    property alias thirdDetailedListModel: thirdDetailedListModel
    property alias categoriesModel: categoriesModel
    property alias quickExpensesModel: quickExpensesModel
    property alias historyEntryExpensesModel: historyEntryExpensesModel

    signal refreshValues(string entryDate)

    // Refresh models that are affected by new, edited or deleted expense values
    onRefreshValues: {
        if (Functions.checkIfWithinDateRange(entryDate, firstDetailedListModel.fromDate, firstDetailedListModel.toDate)) {
            firstDetailedListModel.refresh()
        } 
        if (Functions.checkIfWithinDateRange(entryDate, secondDetailedListModel.fromDate, secondDetailedListModel.toDate)) {
            secondDetailedListModel.refresh()
        } 
        if (Functions.checkIfWithinDateRange(entryDate, thirdDetailedListModel.fromDate, thirdDetailedListModel.toDate)) {
            thirdDetailedListModel.refresh()
        }
    }
    
    /*WorkerScript for asynch loading of models*/
    WorkerScript {
        id: workerLoader
        source: "ModelWorkerScript.mjs"

        onMessage: {
            switch (messageObject.modelId) {
            case "Profiles":
                profilesModel.loadingStatus = "Ready"
                break;
//~             case "MonitorItemsFields":
//~                 monitorItemsFieldsModel.loadingStatus = "Ready"
//~                 break;
//~             case "MonitorItems":
//~                 monitorItemsModel.loadingStatus = "Ready"
//~                 break;
//~             case "DashItems":
//~                 dashItemsModel.loadingStatus = "Ready"
//~                 break;
            case mainModels.categoriesID:
                categoriesModel.loadingStatus = "Ready"
                break
            case mainModels.quickExpensesID:
                quickExpensesModel.loadingStatus = "Ready"
                break
            case mainModels.historyEntryExpensesID:
                historyEntryExpensesModel.loadingStatus = "Ready"
                break
            case mainModels.firstDetailedListID:
                firstDetailedListModel.summaryValues = messageObject.result
                firstDetailedListModel.loadingStatus = "Ready"
                break;
            case mainModels.secondDetailedListID:
                secondDetailedListModel.summaryValues = messageObject.result
                secondDetailedListModel.loadingStatus = "Ready"
                break;
            case mainModels.thirdDetailedListID:
                thirdDetailedListModel.summaryValues = messageObject.result
                thirdDetailedListModel.loadingStatus = "Ready"
                break;
//~             case "Dashboard":
//~                 dashboardModel.loadingStatus = "Ready"
//~                 dashboardModel.updateUserMetric()
//~                 break;
            }
        }
    }

    Common.BaseListModel {
        id: profilesModel
  
        worker: workerLoader
        modelId: mainModels.profilesID
        Component.onCompleted: refresh()
        
        function refresh() {
            fillData(mainView.profiles.list())
        }
    }

//~     BaseListModel {
//~         id: dashItemsModel
  
//~         worker: workerLoader
//~         modelId: "DashItems"
//~         Component.onCompleted: refresh()
        
//~         function refresh() {
//~             fillData(mainView.monitoritems.dashList())
//~         }
//~     }

//~     BaseValuesModel {
    Common.BaseListModel {
        id: categoriesModel

        property bool isListOnly: false

        modelId: mainModels.categoriesID
        worker: workerLoader
        Component.onCompleted: refresh()

        function refresh() {
            fillData(mainView.categories.list())
        }

        onIsListOnlyChanged: {
            if (isListOnly) {
                appendAddNew()
            } else {
                removeAddNew()
            }
        }

//~         function appendAddNew() {
//~             modelCategories.insert(0, {
//~                                        category_name: "Add new category",
//~                                        descr: "add new",
//~                                        icon: "default",
//~                                        colorValue: "white"
//~                                    })
//~         }

//~         function removeAddNew() {
//~             modelCategories.remove(0)
//~         }

        function getColor(category) {
            for (let i = 0; i < count; i++) {
                if (get(i).category_name === category) {
                    return get(i).colorValue
                }
            }
        }
    }

    Common.BaseListModel {
        id: quickExpensesModel
  
        worker: workerLoader
        modelId: mainModels.quickExpensesID
        Component.onCompleted: refresh()

        function refresh() {
            fillData(mainView.quickExpenses.list())
        }
    }

    Common.BaseListModel {
        id: historyEntryExpensesModel

        property string searchText: ""
        property int resultLimit: 10

        worker: workerLoader
        modelId: mainModels.historyEntryExpensesID
        Component.onCompleted: refresh()

        onSearchTextChanged: refresh()

        function refresh() {
            fillData(mainView.expenses.historyDataForEntry(searchText, resultLimit))
        }
    }

    BaseValuesModel {
        id: firstDetailedListModel

        modelId: mainModels.firstDetailedListID
        worker: workerLoader
    }

    BaseValuesModel {
        id: secondDetailedListModel

        modelId: mainModels.secondDetailedListID
        worker: workerLoader
    }

    BaseValuesModel {
        id: thirdDetailedListModel

        modelId: mainModels.thirdDetailedListID
        worker: workerLoader
    }

//~     BaseListModel {
//~         id: dashboardModel
      
//~         worker: workerLoader
//~         modelId: "Dashboard"
//~         Component.onCompleted: refresh()
        
//~         function refresh() {
//~             fillData(mainView.values.dashList())
//~         }

//~         function updateUserMetric() {
//~             var curItem, curValue
//~             var valItems = []
//~             var msgItem
//~             var circleMessage
//~             var firstChar
//~             var valueText

//~             for (var i = 0; i < count; i++) {
//~                 curItem = get(i)

//~                 for (var h = 0; h < curItem.items.count; h++) {
//~                     curValue = curItem.items.get(h)
//~                     firstChar = curValue.title.charAt(0)

//~                     // Only add values from today
//~                     if (curItem.itemId !== "all" && curValue.type == "last" && firstChar >= "0" && firstChar <= "9") {
//~                         valItems.push({ "name": curItem.displayName, "title": curValue.title, "value": curValue.value + " " + curItem.displaySymbol })
//~                     }
//~                 }
//~             }
            
//~             for (var k = 0; k < valItems.length; k++) {
//~                 msgItem = valItems[k]
//~                 if (settings.coloredText) {
//~                     valueText = ("<font color=\"#FF19b6ee\">%1</font><br>%3 <font color=\"#FF3eb34f\">%2</font>").arg(msgItem.name).arg(msgItem.value).arg(msgItem.title)
//~                 } else {
//~                     valueText = ("%1:\n%3 %2 ").arg(msgItem.name).arg(msgItem.value).arg(msgItem.title)                    
//~                 }

                

//~                 if (circleMessage) {
//~                     if (settings.coloredText) {
//~                         circleMessage = circleMessage + "<br>" + valueText
//~                     } else {
//~                         circleMessage = circleMessage + "\n" + valueText
//~                     }

                    
//~                 } else {
//~                     circleMessage = valueText
//~                 }
//~             }

//~             if (circleMessage) {
//~                 userMetric.circleMetric = circleMessage
//~                 userMetric.increment(1)
//~             }
//~         }
//~     }

//~     Connections {
//~         target: mainView

//~         onCurrentDateChanged: {
//~             console.log("dashboard refreshed")
//~             dashboardModel.refresh()
//~         }
//~     }
}
