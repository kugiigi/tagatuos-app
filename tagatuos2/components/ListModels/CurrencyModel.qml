import QtQuick 2.4
import Ubuntu.Components 1.3
import "../../library/Currencies.js" as Currency

ListModel {
    id: root

    property string loadingStatus: "Null"

    function load() {
        var txtName
        var txtDescr
        var txtColor
        var arrResult

        loadingStatus = "Loading"

        root.clear()

        arrResult = Currency.currencies()

        var msg = {
            result: arrResult,
            model: root,
            mode: 'Currencies'
        }
        workerLoader.sendMessage(msg)
    }

    /*WorkerScript for asynch loading of models*/
    WorkerScript {
        id: workerLoader
        source: "../../library/WorkerScripts/SimpleListModelLoader.js"

        onMessage: {
            root.modelData = messageObject.result
            root.loadingStatus = "Ready"
        }
    }
}
