import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3

ListItem {
    id: root

    property string itemName
    property string itemValue
    property string itemDescr
    property string itemDate
    property alias actions: actionList.actions
    property bool actionActive: false

    divider {
        visible: false
        anchors {
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }
    }


//    action: Action {
//        onTriggered: {
////            root.actionActive = true
////            PopupUtils.open(actionsPopoverComponent, root)
//        }
//    }

    onPressAndHold: {
        PopupUtils.open(actionsPopoverComponent, root)
    }


    highlightColor: theme.palette.highlighted.background //overlay

    ListItemLayout {
        title.text: root.itemName
        subtitle.text: root.itemDescr

        Column {
            SlotsLayout.position: SlotsLayout.Trailing
            spacing: units.gu(0.5)

            //WORKAROUND: Dynamic setting of width depending on which is longer to retain right alignment
            Component.onCompleted: {
                dateLabel.text = root.itemDate
                valueLabel.text = root.itemValue
                if (dateLabel.width > valueLabel.width) {
                    width = dateLabel.width
                    valueLabel.width = dateLabel.width
                } else {
                    width = valueLabel.width
                    dateLabel.width = valueLabel.width
                }
            }

            Label {
                id: dateLabel
                //text: root.itemDate
                textSize: Label.Small
                fontSizeMode: Text.HorizontalFit
                horizontalAlignment: Text.AlignRight
                color: theme.palette.normal.foregroundText
                minimumPixelSize: units.gu(2)
                elide: Text.ElideRight
            }
            Label {
                id: valueLabel
                //text: root.itemValue
                textSize: Label.Medium
                font.weight: Font.Normal
                fontSizeMode: Text.HorizontalFit
                horizontalAlignment: Text.AlignRight
                minimumPixelSize: units.gu(2)
                elide: Text.ElideRight
            }
        }
    }

    ActionList {
        id: actionList
    }

    Component {
        id: actionsPopoverComponent

        ActionSelectionPopover {
            id: actionsPopover

            actions: root.actions

//            delegate:
//                ActionDelegate {
//                text: action.text
//                iconName: action.iconName
//            }

            onVisibleChanged: {
                root.actionActive = visible ? true : false
            }

            target: root
        }
    }
}
