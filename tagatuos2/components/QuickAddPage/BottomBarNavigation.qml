import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems

ListView{
    id: bottomBarNavigation

    boundsBehavior: Flickable.StopAtBounds
    orientation: ListView.Horizontal
    interactive: true
    currentIndex: 1


    delegate: BottomBarItem{
        iconName: modelData.icon
        label: modelData.title
        isHighlighted: bottomBarNavigation.currentIndex === index  //ListView.isCurrentItem
        width: (bottomBarNavigation.width / bottomBarNavigation.model.length) >= units.gu(10) ? (bottomBarNavigation.width / bottomBarNavigation.model.length) : units.gu(10)
        height: units.gu(8)

        onClicked: bottomBarNavigation.currentIndex = index
    }

    ListItems.ThinDivider {
        anchors {
            top: bottomBarNavigation.top
            left: parent.left
            right: parent.right
//            leftMargin: units.gu(1)
//            rightMargin: units.gu(1)
        }
    }

    Rectangle{
        id: background
        z: -1
        color: theme.palette.normal.foreground
        anchors.fill: parent
    }

}
