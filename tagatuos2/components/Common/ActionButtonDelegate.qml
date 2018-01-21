import QtQuick 2.4
import Ubuntu.Components 1.3

AbstractButton {
    id: button
    action: modelData
    width: label.width + units.gu(4)
    //height: parent.height
    anchors{
        top: parent.top
        bottom: parent.bottom
    }

    Rectangle {
        color: theme.palette.highlighted.foreground
        anchors.fill: parent
        opacity: button.pressed ? 1 : 0
        visible: opacity === 0 ? false: true

        Behavior on opacity {
            UbuntuNumberAnimation {
                easing: UbuntuAnimation.StandardEasing
                duration: UbuntuAnimation.BriskDuration
            }
        }
    }
    Label {
        anchors.centerIn: parent
        id: label
        text: action.text
        font.weight: Font.Normal
    }
}
