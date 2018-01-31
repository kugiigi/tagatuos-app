import QtQuick 2.4
import Ubuntu.Components 1.3

Rectangle {
    id: root
    property alias text: label.text

    visible: opacity === 0 ? false : true

    Behavior on opacity {
        UbuntuNumberAnimation {
            easing: UbuntuAnimation.StandardEasing
            duration: UbuntuAnimation.FastDuration
        }
    }


    Label {
        id: label
        visible: root.height >= units.gu(5) ? true : false
        fontSizeMode: Text.HorizontalFit
        font.bold: true
        color: UbuntuColors.porcelain//theme.palette.normal.foregroundText
        textSize: Label.Large
        minimumPixelSize: units.gu(2)
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Text.AlignHCenter
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
    }
}
