import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems

ListItem {
    id: root

    property alias title: todayListItemLayout.title
    property alias subtitle: todayListItemLayout.subtitle
    property string total

    divider.visible: false

    ListItems.ThinDivider {
        height: units.gu(0.3)
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
    }

    ListItemLayout {
        id: todayListItemLayout

        title.textSize: Label.Large
        title.font.weight: Font.Bold
        subtitle.textSize: Label.Medium
        Label {
            text: root.total
            textSize: Label.Large
            font.weight: Font.Normal
            SlotsLayout.position: SlotsLayout.Trailing
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignRight
        }
        ProgressionSlot{}
//        Icon {
//            name: "next"
//            SlotsLayout.position: SlotsLayout.Trailing
//            width: units.gu(3)
//        }
    }
}
