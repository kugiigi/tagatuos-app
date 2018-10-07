import QtQuick 2.9
import Ubuntu.Components 1.3
import "../Common"

Item {
    id: root

    property alias model: flow.model
    property alias columns: flow.columns
    property alias flickable: flow.flickable
    property alias delegate: flow.delegate
    property bool noDate: false
    property var getter
    property alias count: flow.count
    signal itemSelected(int itemIndex)

    signal selected

    height: flow.contentHeight
    anchors {
        left: parent.left
        right: parent.right
    }

    onGetterChanged: flow.getter = getter  // cannot use alias to set a function (must be var)



    ColumnFlow {
        id: flow

        clip: true


        anchors.fill: root
        columns: {
            switch(true){
            case root.width > units.gu(40):
                Math.round(root.width / units.gu(30))
                break
            default:
                Math.round(root.width / units.gu(20))
                break
            }


        }
    }
}
