import QtQuick 2.9
import Ubuntu.Components 1.3
import "BaseComponents"

BaseHeader {
    id:root

    visible: opacity === 0 ? false : true

//        flickable: listView.currentItem.item.listView


    function show(){
        opacity = 1
    }

    function hide(){
        opacity = 0
    }

    Behavior on opacity {
        UbuntuNumberAnimation {
            easing: UbuntuAnimation.StandardEasing
            duration: UbuntuAnimation.BriskDuration
        }
    }

    contents: Row{
        anchors.centerIn: parent
        spacing: units.gu(1)
        Icon{
            visible: tempSettings.travelMode
            color: theme.palette.normal.positive
            name: "airplane-mode"
            height: parent.height//units.gu(2.5)
            width: height
        }

        Label {
            text: root.title
            textSize: Label.Large
            font.weight: Font.Normal
            //        anchors.centerIn: parent
            fontSizeMode: Text.HorizontalFit
            color: tempSettings.travelMode ? theme.palette.normal.positive : theme.palette.normal.foregroundText
            minimumPixelSize: units.gu(3)
            elide: Text.ElideRight
        }
    }
}
