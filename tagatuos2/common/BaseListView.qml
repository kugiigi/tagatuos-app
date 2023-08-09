import QtQuick 2.12
import Lomiri.Components 1.3
import "pages" as PageComponents

ListView {
    id: baseListView

    property PageComponents.BasePageHeader pageHeader
    property bool enableScrollPositioner: true

    boundsBehavior: Flickable.DragOverBounds
    boundsMovement: Flickable.StopAtBounds

    PullDownFlickableConnections {
        pageHeader: baseListView.pageHeader
        target: baseListView
    }

    Loader {
        active: baseListView.enableScrollPositioner
        z: 1
        parent: baseListView.parent
        anchors {
            right: parent.right
            rightMargin: units.gu(2)
            bottom: parent.bottom
            bottomMargin: units.gu(3)
        }

        sourceComponent: ScrollPositioner {
            id: scrollPositioner

            target: baseListView
            mode: "Down"
        }
    }
}
