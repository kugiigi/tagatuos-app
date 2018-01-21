import QtQuick 2.4
import Ubuntu.Components 1.3

Rectangle {
    id: root

    property alias model: listView.model
    property bool show: false //Initial condition to show this popover

    signal itemSelected(string name, real value)

    z: 100
    color: theme.palette.normal.overlay
    height: model.count * units.gu(7)
    border.color: theme.palette.focused.overlay
    border.width: units.gu(0.07)

//    onItemSelected: {
//        root.model.clear()
//        root.show = false
//    }
    opacity: visible ? 1 : 0

    Behavior on opacity {
        UbuntuNumberAnimation {
            easing: UbuntuAnimation.StandardEasing
            duration: UbuntuAnimation.BriskDuration
        }
    }

    visible: show && model.count > 0 ? true : false

    InverseMouseArea{
        onClicked: root.show = false
    }

    ListView {
        id: listView
        //width: parent.width
        //height: contentHeight
        anchors.fill: parent
        clip: true

        delegate: ListItem {
            id: listResult

            onClicked: {
                itemSelected(model.name, model.value)
            }
            ListItemLayout {
                title.text: model.name
                subtitle.text: "₱" + model.value
            }
        }
    }
}
