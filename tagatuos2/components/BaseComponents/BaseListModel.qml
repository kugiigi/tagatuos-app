import QtQuick 2.4
import Ubuntu.Components 1.3


ListModel {
    id: rootModel
    property string loadingStatus: "Null"
    property string mode


    function loadItems(result) {

        loadingStatus = "Loading"

        rootModel.clear()

        var msg = {'result': result, 'model': rootModel,'mode': mode};
                        workerLoader.sendMessage(msg);
    }
}
