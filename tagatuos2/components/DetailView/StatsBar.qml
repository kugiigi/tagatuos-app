import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems

Rectangle {
    id: root

    property bool hide: false
    property string text: listView.model !== null
                              || listView.model !== undefined ? (tempSettings.travelMode ? listView.model.totalTravelValue : listView.model.totalValue) : ""
    property string secondaryText: listView.model !== null
                                   || listView.model !== undefined ? (tempSettings.travelMode ? listView.model.totalValue : "") : ""
    property color bgColor: "transparent" //theme.palette.normal.base

    height: units.gu(8)
    width: height
    radius: height
    color: bgColor
    opacity: 0.7
    state: "floating"

    ListItems.ThinDivider {
        visible: root.state === "bar"
        height: units.gu(0.3)
        anchors {
            top: root.top
            left: root.left
            right: root.right
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }
    }

    states: [
        State {
            name: "floating"
            PropertyChanges {
                target: root
                height: units.gu(8)
                radius: height
                width: height
                opacity: 0.7
                anchors.rightMargin: units.gu(3)
                anchors.bottomMargin: units.gu(5)
                bgColor: "transparent" //theme.palette.normal.base
            }
            AnchorChanges {
                target: root
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                }
            }
        },
        State {
            name: "bar"
            PropertyChanges {
                target: root
                height: units.gu(10)
                radius: 0
                width: 0
                opacity: 1
                anchors.rightMargin: 0
                anchors.bottomMargin: 0
                bgColor: "transparent" //theme.palette.normal.overlay
            }
            AnchorChanges {
                target: root
                anchors {
                    right: parent.right
                    left: parent.left
                    bottom: parent.bottom
                }
            }
        },
        State {
            name: "extended"
        }
    ]

    anchors {
        right: parent.right
        rightMargin: units.gu(3)
        bottom: parent.bottom
        bottomMargin: units.gu(5)
    }


    //    Connections {
    //        id: parentFlickable
    //        target: root.parent

    //        onVerticalVelocityChanged: {
    //            if(target.verticalVelocity === 0){
    //                timer.start()
    //            }else{
    //                timer.stop()
    //                root.hide = false
    //                if (target.verticalVelocity < 0) {
    //                    root.mode = "Up"
    //                } else{
    //                    root.mode = "Down"
    //                }
    //            }
    //        }
    //    }
    Behavior on radius {
        UbuntuNumberAnimation {
            easing.type: Easing.OutCubic
            duration: UbuntuAnimation.BriskDuration
        }
    }

    Behavior on width {
        UbuntuNumberAnimation {
            easing.type: Easing.OutCubic
            duration: UbuntuAnimation.BriskDuration
        }
    }

    Behavior on height {
        UbuntuNumberAnimation {
            easing.type: Easing.OutCubic
            duration: UbuntuAnimation.BriskDuration
        }
    }

//    Behavior on color {
//        ColorAnimation {
//            easing: UbuntuAnimation.StandardEasing
//            duration: UbuntuAnimation.BriskDuration
//        }
//    }


    Column{
        id: valuesColumn

        anchors{
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        Label {
            id: totalLabel
            visible: root.state === "bar" ? true : false
            text: root.text
            textSize: Label.XLarge
            fontSizeMode: Text.HorizontalFit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: tempSettings.travelMode ? theme.palette.normal.positive : theme.palette.normal.overlayText
            minimumPixelSize: units.gu(2)
            elide: Text.ElideRight
            anchors{
                left: parent.left
                right: parent.right
            }

        }
        Label {
            id: totalSecondaryLabel
            visible: root.state === "bar" && text !== "" ? true : false
            text: root.secondaryText
            textSize: Label.Medium
            fontSizeMode: Text.HorizontalFit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: theme.palette.normal.backgroundTertiaryText
            minimumPixelSize: units.gu(2)
            elide: Text.ElideRight
            anchors{
                left: parent.left
                right: parent.right
            }
        }
    }



    Icon {
        id: icon
        visible: root.state === "floating" ? true : false
        anchors.centerIn: root
        height: root.height / 1.5
        width: height
        name: "info"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: root
//        enabled: root.state === "floating" ? true : false
        onClicked: {
            root.state = root.state === "bar" ? "floating" : "bar"
        }

        onPressedChanged: {
            if (pressed) {
                root.color = "#3A000000"
            } else {
                root.color = bgColor
            }
        }
    }
}
