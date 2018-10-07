import QtQuick 2.9
import Ubuntu.Components 1.3
import "../../library/Currencies.js" as Currency
import "../BaseComponents"

//ListModel {
//    id: root

//    property string loadingStatus: "Null"


//    function load() {
//        var txtName
//        var txtDescr
//        var txtColor
//        var arrResult

//        loadingStatus = "Loading"

//        root.clear()

//        arrResult = Currency.currencies()

//        var msg = {
//            result: arrResult,
//            model: root,
//            mode: 'Currencies'
//        }
//        workerLoader.sendMessage(msg)
//    }

//    /*WorkerScript for asynch loading of models*/
//    WorkerScript {
//        id: workerLoader
//        source: "../../library/WorkerScripts/SimpleListModelLoader.js"

//        onMessage: {
//            root.modelData = messageObject.result
//            root.loadingStatus = "Ready"
//        }
//    }
//}

BaseListModel {
    id: rootModel

    mode: "Currencies"

    function load(){
        var arrResult = Currency.currencies()

        loadItems(arrResult)
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

