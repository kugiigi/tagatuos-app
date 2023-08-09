import QtQuick 2.12
import Lomiri.Components 1.3
import "pages" as PageComponents

Flickable {
    id: baseFlickable

    property PageComponents.BasePageHeader pageHeader
    property bool enableScrollPositioner: true

    boundsBehavior: Flickable.DragOverBounds
    boundsMovement: Flickable.StopAtBounds

    PullDownFlickableConnections {
        pageHeader: baseFlickable.pageHeader
        target: baseFlickable
    }

    Loader {
        active: baseFlickable.enableScrollPositioner
        z: 1
        parent: baseFlickable.parent
        anchors {
            right: parent.right
            rightMargin: units.gu(2)
            bottom: parent.bottom
            bottomMargin: units.gu(3)
        }

        sourceComponent: ScrollPositioner {
            id: scrollPositioner

            target: baseFlickable
            mode: "Down"
        }
    }
}
