import QtQuick 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
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
//~         active: baseFlickable.enableScrollPositioner
        active: baseFlickable.parent instanceof Layout ? false : baseFlickable.enableScrollPositioner
        z: 1
        parent: baseFlickable.parent
//~         anchors {
//~             right: parent.right
//~             rightMargin: Suru.units.gu(2)
//~             bottom: parent.bottom
//~             bottomMargin: Suru.units.gu(3)
//~         }
        anchors {
            right: active ? parent.right : undefined
            rightMargin: Suru.units.gu(2)
            bottom: active ? parent.bottom : undefined
            bottomMargin: Suru.units.gu(3)
        }

        sourceComponent: ScrollPositioner {
            id: scrollPositioner

            target: baseFlickable
            mode: "Down"
        }
    }
}
