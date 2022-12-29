import QtQuick 2.9
import Lomiri.Components 1.3

AbstractButton {
    id: button

    action: modelData
    width: buttonsRow.width + units.gu(2)

    style: Rectangle {
        color: action.color ? action.color : theme.palette.normal.foreground

        Connections{
            target: button
            onPressedChanged:{
                if(target.pressed){
                    color = theme.palette.highlighted.foreground
                }else{
                    color = action.color ? action.color : theme.palette.normal.foreground
                }
            }
        }

        Behavior on color {
            ColorAnimation{
                easing: LomiriAnimation.StandardEasing
                duration: LomiriAnimation.BriskDuration
            }
        }
    }

    Row {
        id: buttonsRow

        spacing: units.gu(0.5)
        anchors {
            centerIn: parent
        }

        Icon {
            id: icon

            name: action.iconName
            width: label.text ? units.gu(2) : units.gu(3)
            height: width
            visible: action.iconName
        }

        Label {
            id: label

            text: action.text
            renderType: Text.QtRendering
            font.weight: Font.Normal
        }
    }
}
