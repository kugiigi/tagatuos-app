import QtQuick 2.9
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


    model: [{
            title: i18n.tr("Recent"),
            icon: "history",
            type: "recent"
        }, {
            title: i18n.tr("Quick List"),
            icon: "bookmark",
            type: "list"
        }, {
            title: i18n.tr("Most Used"),
            icon: "view-list-symbolic",
            type: "top"
        }]
    height: units.gu(8)
    anchors {
        bottom: contents.bottom
        left: parent.left
        right: parent.right
    }

    ListItems.ThinDivider {
        anchors {
            top: bottomBarNavigation.top
            left: parent.left
            right: parent.right
        }
    }

    Rectangle{
        id: background
        z: -1
        color: theme.palette.normal.foreground
        anchors.fill: parent
    }

}
