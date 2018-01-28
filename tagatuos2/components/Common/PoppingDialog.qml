import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: root

    property bool fullscreen: false

    property real explicitWidth
    property real explicitHeight

    property real maxWidth: units.gu(50)
    property real maxHeight: units.gu(89)

    property var returnValue
    property Component delegate

    property real targetWidth: switch (true) {
           case fullscreen:
               parent.width
               break
           case explicitWidth  && explicitWidth < root.parent.width:
               explicitWidth
               break
           case !fullscreen:
               maxWidth
               break
           default:
               parent.width
               break
           }

    property real targetHeight: switch (true) {
            case fullscreen:
                parent.height
                break
            case explicitHeight && explicitHeight < root.parent.height:
                explicitHeight
                break
            case !fullscreen:
                maxHeight
                break
            default:
                parent.height
                break
            }

    property real targetX: fullscreen ? 0 : (root.parent.width - targetWidth) / 2
    property real targetY: fullscreen ? 0 : (root.parent.height - targetHeight) / 2


    signal opened()
    signal closed(var returnValue)
    signal closing()

    z: Number.MAX_VALUE

    Component.onCompleted: {
        if(delegate){
            delegateLoader.active = true
        }

        parallelAnimationAppear.start()
    }

    function close(){
        closing()
        parallelAnimationHide.start()
    }


    Rectangle {
        id: backgroundRectangle

        //Private properties
        property real initialX
        property real initialY
        property real initialWidth
        property real initialHeight

        anchors.fill: parent
        color: theme.palette.normal.overlay
    }

    Loader {
        id: delegateLoader

        active: false
        asynchronous: true
        visible: status == Loader.Ready
        sourceComponent: root.delegate

        onLoaded: item.parent = root
    }

    LoadingComponent {
        id: loadingComponent

        visible: delegateLoader.status !== Loader.Ready && delegateLoader.active && !parallelAnimationAppear.running
        anchors.centerIn: parent
        //title: searchMode ? i18n.tr("Loading results") : root.loadingTitle
        //subTitle: i18n.tr("Please wait")
    }

    // Close Button for test purposes only
    // Closing UI should be implemented by the using component
    Button{
        id: close

        iconName: "close"
        height: units.gu(5)
        width: height
        anchors{
           left: parent.left
           top: parent.top
        }

        onClicked:{
            visible = false
            root.close()
        }
    }

    ParallelAnimation {
        id: parallelAnimationAppear

        onStarted: {
            backgroundRectangle.initialX = root.x;
            backgroundRectangle.initialY = root.y;
            backgroundRectangle.initialHeight = root.height
            backgroundRectangle.initialWidth = root.width
        }

        UbuntuNumberAnimation {
            target: root
            property: "x"
            to: targetX
            duration: UbuntuAnimation.BriskDuration
        }
        UbuntuNumberAnimation {
            target: root
            property: "y"
            to: targetY
            duration: UbuntuAnimation.BriskDuration
        }
        UbuntuNumberAnimation {
            target: root
            property: "width"
            to: root.targetWidth
            duration: UbuntuAnimation.BriskDuration
        }
        UbuntuNumberAnimation {
            target: root
            property: "height"
            to: root.targetHeight
            duration: UbuntuAnimation.BriskDuration
        }
        UbuntuNumberAnimation {
            target: backgroundRectangle
            property: "opacity"
            to: 1
            duration: UbuntuAnimation.BriskDuration
        }
    }

    ParallelAnimation {
        id: parallelAnimationHide

        UbuntuNumberAnimation {
            target: root
            property: "x"
            to: backgroundRectangle.initialX
        }
        UbuntuNumberAnimation {
            target: root
            property: "y"
            to: backgroundRectangle.initialY
        }
        UbuntuNumberAnimation {
            target: root
            property: "width"
            to: backgroundRectangle.initialWidth
        }
        UbuntuNumberAnimation {
            target: root
            property: "height"
            to: backgroundRectangle.initialHeight
        }
        UbuntuNumberAnimation {
            target: backgroundRectangle
            property: "opacity"
            to: 0
        }

        onStopped: {
            root.destroy()
        }
    }
}
