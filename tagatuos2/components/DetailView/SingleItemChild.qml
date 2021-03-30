import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../../library/ApplicationFunctions.js" as AppFunctions

ListItem {
    id: singleItemChild

    property string itemName
    property string itemValue
    property string itemDescr
    property string itemDate
    property real itemTravelRate
    property string itemHomeCurrency
    property string itemTravelCurrency
    property string itemTravelValue
    property alias actions: actionList.actions

    property bool actionActive: false
    property bool showTravelValue: tempSettings.travelMode
    
    function openContextMenu() {
        PopupUtils.open(actionsPopoverComponent, singleItemChild)
    }

    divider {
        visible: false
        anchors {
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }
    }

    onClicked: {
        if(tempSettings.travelMode){
            showTravelValue = !showTravelValue
        }
    }


    onPressAndHold: {
        openContextMenu()
    }

    onShowTravelValueChanged: fieldsColumn.refresh()


    highlightColor: theme.palette.highlighted.background
    
    MouseArea {
        acceptedButtons: Qt.RightButton
        anchors.fill: parent
        onClicked: openContextMenu()
    }

    ListItemLayout {
        title.text: singleItemChild.itemName
        subtitle.text: singleItemChild.itemDescr

        Column {
            id: fieldsColumn

            SlotsLayout.position: SlotsLayout.Trailing
            spacing: units.gu(0.5)

            //WORKAROUND: Dynamic setting of width depending on which is longer to retain right alignment
            Component.onCompleted: {
                refresh()
            }

            function refresh(){

                if (dateLabel.width > valueLabel.width) {
                    width = dateLabel.width
                } else {
                    width = valueLabel.width
                }
            }

            Label {
                id: dateLabel
                text: singleItemChild.itemDate
                textSize: Label.Small
                fontSizeMode: Text.HorizontalFit
                horizontalAlignment: Text.AlignRight
                color: theme.palette.normal.foregroundText
                minimumPixelSize: units.gu(2)
                elide: Text.ElideRight
                anchors.right: parent.right
                onTextChanged: fieldsColumn.refresh()
            }
            Label {
                id: valueLabel
                text: singleItemChild.itemValue
                textSize: Label.Medium
                font.weight: Font.Normal
                fontSizeMode: Text.HorizontalFit
                horizontalAlignment: Text.AlignRight
                minimumPixelSize: units.gu(2)
                elide: Text.ElideRight
                color: singleItemChild.showTravelValue && tempSettings.travelMode ? theme.palette.normal.positive : theme.palette.normal.backgroundText
                anchors.right: parent.right
                onTextChanged: fieldsColumn.refresh()
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

            actions: singleItemChild.actions

            onVisibleChanged: {
                singleItemChild.actionActive = visible ? true : false
            }

            target: singleItemChild
        }
    }
}
