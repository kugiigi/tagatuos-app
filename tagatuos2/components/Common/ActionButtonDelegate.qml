import QtQuick 2.4
import Ubuntu.Components 1.3

AbstractButton {
    id: button

    action: modelData
    width: buttonsRow.width + units.gu(2)

    anchors {
        top: action.visible ? parent.top : undefined
        bottom: action.visible ?parent.bottom : undefined
    }


    //    Component.onCompleted: {
    //        if(action.color){
    //            icon.color = action.color
    //            label.color = action.color
    //        }
    //    }
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
                easing: UbuntuAnimation.StandardEasing
                duration: UbuntuAnimation.BriskDuration
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
            font.weight: Font.Normal
        }
    }
}
