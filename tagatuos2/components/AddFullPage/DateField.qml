import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.Pickers 1.3

Column {
    id: dateField

    property alias date: dateLabel.date
//    spacing: units.gu(1)

    anchors {
        left: parent.left
        right: parent.right
    }

    Label {
        id: dateTextLabel
        text: i18n.tr("Date")
        font.weight: Text.Normal
        color: theme.palette.normal.foregroundText
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
        }
    }

    ListItem {
        id: expenseDateListItem

        visible: true
        divider.visible: false

        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: parent.right
            rightMargin: units.gu(2)
        }

        onClicked: {
            dateAction.trigger()
        }

        onActiveFocusChanged: {
            if(activeFocus){
                root.resetFocus()
            }
        }

        Action {
            id: dateAction
            onTriggered: {
                expenseDateListItem.color = expenseDateListItem.highlightColor
                var datePicker = PickerPanel.openDatePicker(
                            dateLabel, "date", "Years|Months|Days")
                var datePickerClosed = function () {
                    expenseDateListItem.color = "transparent"
                }

                datePicker.closed.connect(datePickerClosed)
            }
        }
        Label {
            id: dateLabel
            property date date: new Date()
            property bool highlighted: false
            property alias mouseArea: mouseArea

            height: units.gu(3)
            text: Qt.formatDateTime(
                      date, "dddd, MMMM d, yyyy") //"dddd, MMMM d yyyy")
            color: theme.palette.normal.foregroundText
            fontSizeMode: Text.HorizontalFit
            fontSize: "medium"
            minimumPixelSize: units.gu(2)
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            anchors {
                left: parent.left
                leftMargin: units.gu(2)
                right: parent.right
                rightMargin: units.gu(1)
                top: parent.top
                bottom: parent.bottom
            }
            Rectangle {
                z: -1
                anchors.fill: parent
                color: dateLabel.highlighted ? theme.palette.selected.background : "Transparent"
            }
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                z: 1
                onClicked: {
                    dateAction.trigger()
                }
            }
        }
    }

}
