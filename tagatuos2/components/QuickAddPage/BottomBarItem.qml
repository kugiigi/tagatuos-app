import QtQuick 2.9
import Lomiri.Components 1.3

AbstractButton {
    id: bottomBarItem

    property alias iconName: icon.name
    property alias label: label.text
    property bool isHighlighted: false

    Rectangle {
        id: pressed
        anchors.fill: parent
        color: theme.palette.normal.base
        visible: bottomBarItem.pressed
        opacity: visible ? 1 : 0

        Behavior on opacity {
            LomiriNumberAnimation {
                easing: LomiriAnimation.StandardEasing
                duration: LomiriAnimation.BriskDuration
            }
        }
    }

    Rectangle{
        id: background
        z: -1
        visible: bottomBarItem.isHighlighted
        color: theme.palette.normal.selection
        anchors.fill: parent
    }

    Column {
        id: column

        spacing: units.gu(1)
        anchors {
            fill: parent
            margins: units.gu(1)
        }

        Icon {
            id: icon
            height: units.gu(3)
            width: height
            color: theme.palette.normal.foregroundText
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Label {
            id: label
            textSize: Label.Small
            font.weight: Text.Normal
            fontSizeMode: Text.HorizontalFit
            color: theme.palette.normal.foregroundText
            minimumPixelSize: units.gu(2)
            elide: Text.ElideRight
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
