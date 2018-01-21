import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems
import "../../library/ApplicationFunctions.js" as AppFunctions

Item {
    id: root

    /* Required by ColumnFlow */
    property int index
    property var model
    property var cloneModel: root.model
    readonly property real itemHeight: units.gu(3)
    readonly property real itemHeaderHeight: units.gu(4)
    readonly property int itemCountLimit: 10
    property real overLimitHeight: itemHeaderHeight + (itemHeight * itemCountLimit)
                                   + expandItem.height
    property bool overLimit: listView.model.count > itemCountLimit //listView.height > heightLimit

    height: mainShape.height + units.gu(2)

    //    UbuntuShape {
    Rectangle {
        id: mainShape

        //        backgroundColor: theme.palette.normal.foreground //base
        color: "transparent"
        anchors.centerIn: root
//        border.color: theme.palette.normal.foreground
//        border.width: units.gu(0.25)

        height: root.overLimit ? root.overLimitHeight : listView.height + units.gu(
                                     1)
        width: root.width - units.gu(2)
        //        radius: "small"
        radius: units.gu(1)
        //        relativeRadius: 0.1
        //        aspect: UbuntuShape.Flat

        //        Behavior on backgroundColor {
        Behavior on color {
            ColorAnimation {
                easing: UbuntuAnimation.StandardEasing
                duration: UbuntuAnimation.BriskDuration
            }
        }

        UbuntuListView {
            id: listView
            interactive: false
            model: root.cloneModel !== null ? root.cloneModel.childModel : null
            height: model !== null ? root.overLimit ? (units.gu(
                                                           3) * root.itemCountLimit) + headerItem.height : (units.gu(3) * model.count) + headerItem.height : 0 //(units.gu(3) * model.count) + headerItem.height : 0 //contentHeight
            header: FlowItemHeader {
                title: model !== null ? model.category_name : ""
                total: model !== null ? AppFunctions.formatMoney(model.total,
                                                                 false) : ""
                height: root.itemHeaderHeight //units.gu(4)
                width: listView.width
            }
            clip: true
            currentIndex: -1
            anchors {
                top: mainShape.top
                left: mainShape.left
                right: mainShape.right
            }

            delegate: FlowItemListItem {
                height: root.itemHeight //units.gu(3)
                itemName: name
                itemValue: AppFunctions.formatMoney(value, true)
            }
        }

        ListItems.ThinDivider {
            visible: expandItem.visible
            anchors {
                top: listView.bottom
                left: parent.left
                right: parent.right
                leftMargin: units.gu(1)
                rightMargin: units.gu(1)
            }
        }

        FlowItemExpandItem {
            id: expandItem
            height: units.gu(3.5)
            visible: root.overLimit ? true : false
            anchors {
                top: listView.bottom
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                itemSelected(index)
            }
            onPressedChanged: {
                if (pressed) {
                    //                    mainShape.aspect = UbuntuShape.Inset
                    mainShape.color = theme.palette.highlighted.foreground //base
                } else {
                    //                    mainShape.aspect = UbuntuShape.Flat
                    //                    mainShape.backgroundColor = theme.palette.normal.foreground //base
                    mainShape.color = "transparent"
                }
            }
        }
    }
}
