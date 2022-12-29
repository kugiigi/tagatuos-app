import QtQuick 2.9
import Lomiri.Components 1.3

Item {
    id: root

    property alias title: activityTitle.text
    property alias subTitle: activitySubTitle.text
    readonly property real widthLimit: units.gu(30)
    readonly property real heightLimit: units.gu(40)
    property bool withBackground: false


    //anchors.fill: parent
    height: withBackground && backgroundLoader.item ? childrenRect.height - backgroundLoader.item.height : childrenRect.height
    anchors.left: parent.left
    anchors.right: parent.right

    onVisibleChanged: {
        if (visible) {
            timer.start()
        } else {
            timer.stop()
            columnTexts.visible = false
        }
    }

    ActivityIndicator {
        id: loadingIndicator
        anchors.horizontalCenter: parent.horizontalCenter
        running: root.visible
    }


    Timer {
        id: timer
        interval: 300
        running: false
        onTriggered: {
            columnTexts.visible = true
        }
    }

    Column {
        id: columnTexts

        visible: false

        opacity: !parent.parent.parent ? 1 : parent.parent.parent.height <= heightLimit ? 0 : 1

        anchors {
            top: loadingIndicator.bottom
            topMargin: units.gu(5)
            left: parent.left
            right: parent.right
        }

        Label {
            id: activityTitle
            anchors {
                left: parent.left
                right: parent.right
            }

            fontSize: parent.width <= widthLimit ? "medium" : "large"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            id: activitySubTitle

            fontSize: parent.width <= widthLimit ? "small" : "medium"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter

            anchors {
                right: parent.right
                left: parent.left
            }
        }
    }

    Component {
        id: backgroundComponent

        Rectangle{
            color: theme.palette.normal.overlay
            opacity: 0.7
        }
    }

    Loader {
        id: backgroundLoader

        active: withBackground
        asynchronous: true
        visible: status == Loader.Ready
        sourceComponent: backgroundComponent
        anchors.centerIn: parent
        z: -1
        onLoaded: {
            item.height = root.parent.height
            item.width = root.parent.width
        }
    }

}
