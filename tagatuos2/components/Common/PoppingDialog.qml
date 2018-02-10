import QtQuick 2.4
import Ubuntu.Components 1.3

Loader {
    id: root

    property bool fullscreen: false

    property real explicitWidth
    property real explicitHeight

    property real maxWidth: units.gu(50)
    property real maxHeight: units.gu(89)

    property bool open: false

    property Component delegate

    active: false
    asynchronous: true
    visible: status == Loader.Ready
    sourceComponent: poppingDialogComponent

    onLoaded: {
        item.parent = root.parent
        modalBGRectangle.parent = root.parent
        modalBGRectangle.z = parent.z
        modalBGRectangle.visible = true
    }

    Rectangle {
        id: modalBGRectangle

        property real maxOpacity: 0.3


        color: theme.palette.normal.backgroundText
        opacity: 0
        anchors.fill: parent
        visible: false

        // To capture mouse events and not propagate to the background elements
        MouseArea{
            id: modalMouseArea

            anchors.fill: parent

        }

        Behavior on opacity {
            UbuntuNumberAnimation {
                easing: UbuntuAnimation.StandardEasing
                duration: UbuntuAnimation.BriskDuration
            }
        }

    }

    signal opened
    signal opening
    signal closed
    signal closing


    onOpened: {
        open = true
        modalBGRectangle.opacity = modalBGRectangle.maxOpacity
    }
    onClosed: {
        open = false
        modalBGRectangle.opacity = 0
    }

    function show(itemFrom) {

        x = itemFrom.mapToItem(parent, 0, 0).x
        y = itemFrom.mapToItem(parent, 0, 0).y
        width = itemFrom.width
        height = itemFrom.height

        root.active = true
    }

    function close() {
//        closed()
        modalBGRectangle.parent = root
        modalBGRectangle.visible = false
        item.close()
    }


    Component {
        id: poppingDialogComponent

        Item {
            id: poppingDialog

            x: root.x
            y: root.y

            property real targetWidth: if(fullscreen){
                                           root.parent.width
                                       }else if(explicitWidth && explicitWidth <= root.parent.width){
                                           explicitWidth
                                       }else if(maxWidth <= root.parent.width){
                                           maxWidth
                                       }else{
                                           root.parent.width
                                       }


            property real targetHeight: if(fullscreen){
                                            root.parent.height
                                        }else if(explicitHeight && explicitHeight <= root.parent.height){
                                            explicitHeight
                                        }else if(maxHeight <= root.parent.height){
                                            maxHeight
                                        }else{
                                            root.parent.height
                                        }


            property real targetX: fullscreen ? 0 : (root.parent.width - targetWidth) / 2
            property real targetY: fullscreen ? 0 : (root.parent.height - targetHeight) / 2


            z: Number.MAX_VALUE

            Component.onCompleted: {
//                if (root.delegate) {
//                    delegateLoader.active = true
//                }

                opening()
                parallelAnimationShow.start()
            }

            function close() {
                closing()
                delegateLoader.active = false
                parallelAnimationClose.start()
            }

            Binding{
                id: xBinding

                when: root.open
                target: poppingDialog
                property: "x"
                value: fullscreen ? 0 : (root.parent.width - targetWidth) / 2
            }

            Binding{
                id: yBinding

                when: root.open
                target: poppingDialog
                property: "y"
                value: fullscreen ? 0 : (root.parent.height - targetHeight) / 2
            }

            Binding{
                id: heightBinding

                when: root.open //false
                target: poppingDialog
                property: "height"
                value: if(fullscreen){
                           root.parent.height
                       }else if(explicitHeight && explicitHeight <= root.parent.height){
                           explicitHeight
                       }else if(maxHeight <= root.parent.height){
                           maxHeight
                       }else{
                           root.parent.height
                       }
            }

            //WORKAROUND: Binding cannot catch up when OSK unhides
//            Connections{
//                target: root.parent
//                onHeightChanged:{
//                    delayTimer.restart()
//                }
//            }

//            Timer{
//                id: delayTimer

//                running: false
//                interval: 100
//                onTriggered: heightBinding.when = root.open

//            }

            Binding{
                id: widthBinding

                when: root.open
                target: poppingDialog
                property: "width"
                value: if(fullscreen){
                           root.parent.width
                       }else if(explicitWidth && explicitWidth <= root.parent.width){
                           explicitWidth
                       }else if(maxWidth <= root.parent.width){
                           maxWidth
                       }else{
                           root.parent.width
                       }
            }

            InverseMouseArea{
                id: inverseMouseArea

                anchors.fill: parent

                onClicked:{
                    root.close()
                }
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

                onLoaded: {
                    root.opened()
                    item.parent = poppingDialog
                }
            }

            LoadingComponent {
                id: loadingComponent

                visible: delegateLoader.status !== Loader.Ready
                         && delegateLoader.active
                         && !parallelAnimationShow.running
                anchors.centerIn: parent
                //title: searchMode ? i18n.tr("Loading results") : poppingDialog.loadingTitle
                //subTitle: i18n.tr("Please wait")
            }


            // Close Button for test purposes only
            // Closing UI should be implemented by the using component
            //        Button {
            //            id: close

            //            iconName: "close"
            //            height: units.gu(5)
            //            width: height
            //            anchors {
            //                left: parent.left
            //                top: parent.top
            //            }

            //            onClicked: {
            //                visible = false
            //                poppingDialog.close()
            //            }
            //        }
            ParallelAnimation {
                id: parallelAnimationShow

                onStarted: {
                    backgroundRectangle.initialX = poppingDialog.x
                    backgroundRectangle.initialY = poppingDialog.y
                    backgroundRectangle.initialHeight = poppingDialog.height
                    backgroundRectangle.initialWidth = poppingDialog.width
                }

                onStopped: {
                    if (root.delegate) {
                        delegateLoader.active = true
                    }
                }

                UbuntuNumberAnimation {
                    target: poppingDialog
                    property: "x"
                    to: targetX
                    duration: UbuntuAnimation.BriskDuration
                }
                UbuntuNumberAnimation {
                    target: poppingDialog
                    property: "y"
                    to: targetY
                    duration: UbuntuAnimation.BriskDuration
                }
                UbuntuNumberAnimation {
                    target: poppingDialog
                    property: "width"
                    to: targetWidth
                    duration: UbuntuAnimation.BriskDuration
                }
                UbuntuNumberAnimation {
                    target: poppingDialog
                    property: "height"
                    to: targetHeight
                    duration: UbuntuAnimation.BriskDuration
                }
//                UbuntuNumberAnimation {
//                    target: backgroundRectangle
//                    property: "opacity"
//                    to: 1
//                    duration: UbuntuAnimation.BriskDuration
//                }
            }

            ParallelAnimation {
                id: parallelAnimationClose

                UbuntuNumberAnimation {
                    target: poppingDialog
                    property: "x"
                    to: backgroundRectangle.initialX
                    duration: UbuntuAnimation.BriskDuration
                }
                UbuntuNumberAnimation {
                    target: poppingDialog
                    property: "y"
                    to: backgroundRectangle.initialY
                    duration: UbuntuAnimation.BriskDuration
                }
                UbuntuNumberAnimation {
                    target: poppingDialog
                    property: "width"
                    to: backgroundRectangle.initialWidth
                    duration: UbuntuAnimation.BriskDuration
                }
                UbuntuNumberAnimation {
                    target: poppingDialog
                    property: "height"
                    to: backgroundRectangle.initialHeight
                    duration: UbuntuAnimation.BriskDuration
                }
                UbuntuNumberAnimation {
                    target: backgroundRectangle
                    property: "opacity"
                    to: 0.3
                    duration: UbuntuAnimation.BriskDuration
                }

                onStopped: {
                    root.active = false
                    root.closed()
                }
            }
        }
    }
}
