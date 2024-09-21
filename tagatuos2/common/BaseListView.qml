import QtQuick 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import Lomiri.Components 1.3
import "pages" as PageComponents

ListView {
    id: baseListView

    property PageComponents.BasePageHeader pageHeader
    property bool enableScrollPositioner: true
    property alias scrollPositionerPosition: scrollPositioner.position
    property alias scrollPositionerSize: scrollPositioner.buttonWidthGU

    boundsBehavior: Flickable.DragOverBounds
    boundsMovement: Flickable.StopAtBounds
    maximumFlickVelocity: Suru.units.gu(500)

    PullDownFlickableConnections {
        pageHeader: baseListView.pageHeader
        target: baseListView
    }

    ScrollPositionerItem {
        id: scrollPositioner

        active: baseListView.parent instanceof Layout ? false : baseListView.enableScrollPositioner
        target: baseListView
        z: 1
        parent: baseListView.parent
        bottomMargin: units.gu(5) //+ baseListView.bottomMargin
        position: mainView.settings.scrollPositionerPosition
        buttonWidthGU: mainView.settings.scrollPositionerSize
    }
}
