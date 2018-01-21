import QtQuick 2.4
import Ubuntu.Components 1.3
import "../../library/DataProcess.js" as DataProcess

Item {
    id: root

    property var modelData
    property string loadingStatus: "Null"

    function load(type, range, mode, category, exception, dateFilter1, dateFilter2) {
        var arrResult

        loadingStatus = "Loading"

        switch(type){
        case "LINE":
            arrResult = DataProcess.getExpenseTrend(range, mode, category,
                                                        exception, dateFilter1,
                                                        dateFilter2)
            break
        case "PIE":
            arrResult = DataProcess.getExpenseBreakdown(range, category,
                                                        exception, dateFilter1,
                                                        dateFilter2)
            break
        }

        var result = {
            type: type,
            data: arrResult,
            dateMode: mode,
            dateRange: range,
            dateFilter1: dateFilter1,
            dateFilter2: dateFilter2
        }

        var msg = {
            result: result,
            mode: "Report"
        }
        workerLoader.sendMessage(msg)
    }

    /*WorkerScript for asynch loading of models*/
    WorkerScript {
        id: workerLoader
        source: "../../library/WorkerScripts/ListModelLoader.js"

        onMessage: {
            root.modelData = messageObject.result
//            console.log("data: " + JSON.stringify(root.modelData))
            root.loadingStatus = "Ready"
        }
    }
}
