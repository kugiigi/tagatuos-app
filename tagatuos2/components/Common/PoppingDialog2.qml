import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: root

    property bool fullscreen: false

    property real explicitWidth
    property real explicitHeight

    property real maxWidth: units.gu(50)
    property real maxHeight: units.gu(89)

    property bool open: false
    property QtObject popupParent

    property Component delegate

    property real targetWidth: if (fullscreen) {
                                   parent.width
                               } else if (explicitWidth
                                          && explicitWidth <= root.parent.width) {
                                   explicitWidth
                               } else if (maxWidth <= root.parent.width) {
                                   maxWidth
                               } else {
                                   root.parent.width
                               }

    property real targetHeight: if (fullscreen) {
                                    root.parent.height
                                } else if (explicitHeight
                                           && explicitHeight <= root.parent.height) {
                                    explicitHeight
                                } else if (maxHeight <= root.parent.height) {
                                    maxHeight
                                } else {
                                    root.parent.height
                                }

    property real targetX: fullscreen ? 0 : (root.parent.width - targetWidth) / 2
    property real targetY: fullscreen ? 0 : (root.parent.height - targetHeight) / 2

    z: 1//Number.MAX_VALUE / 2

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

        modalBGRectangle.parent = root.parent
        modalBGRectangle.originalParent = parent
        root.parent = popupParent
        modalBGRectangle.z = root.z
        modalBGRectangle.visible = true

        opening()
        z = Number.MAX_VALUE / 2
        parallelAnimationShow.start()

        x = itemFrom.mapToItem(parent, 0, 0).x
        y = itemFrom.mapToItem(parent, 0, 0).y
        width = itemFrom.width
        height = itemFrom.height
    }

    function close() {
        modalBGRectangle.parent = root
        modalBGRectangle.visible = false

        closing()
        delegateLoader.active = false
        parallelAnimationClose.start()
        root.parent = modalBGRectangle.originalParent
    }

    Rectangle {
        id: modalBGRectangle

        property real maxOpacity: 0.3

        // Private Properties
        property QtObject originalParent

        color: theme.palette.normal.backgroundText
        opacity: 0
        anchors.fill: root.open ? parent : undefined
        visible: false

        // To capture mouse events and not propagate to the background elements
        MouseArea {
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


    Binding {
        id: xBinding

        when: root.open
        target: root
        property: "x"
        value: fullscreen ? 0 : (root.parent.width - targetWidth) / 2
    }

    Binding {
        id: yBinding

        when: root.open
        target: root
        property: "y"
        value: fullscreen ? 0 : (root.parent.height - targetHeight) / 2
    }

    Binding {
        id: heightBinding

        when: root.open //false
        target: root
        property: "height"
        value: if (fullscreen) {
                   root.parent.height
               } else if (explicitHeight
                          && explicitHeight <= root.parent.height) {
                   explicitHeight
               } else if (maxHeight <= root.parent.height) {
                   maxHeight
               } else {
                   root.parent.height
               }
    }

    Binding {
        id: widthBinding

        when: root.open
        target: root
        property: "width"
        value: if (fullscreen) {
                   root.parent.width
               } else if (explicitWidth && explicitWidth <= root.parent.width) {
                   explicitWidth
               } else if (maxWidth <= root.parent.width) {
                   maxWidth
               } else {
                   root.parent.width
               }
    }

    InverseMouseArea {
        id: inverseMouseArea

        anchors.fill: root.open ? parent : undefined

        onClicked: {
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

        anchors.fill: root.open ? parent : undefined
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
            item.parent = root
        }
    }

    LoadingComponent {
        id: loadingComponent

        visible: delegateLoader.status !== Loader.Ready && delegateLoader.active
                 && !parallelAnimationShow.running
        anchors.centerIn: root.open ? parent : undefined
    }

    ParallelAnimation {
        id: parallelAnimationShow

        onStarted: {
            backgroundRectangle.initialX = root.x
            backgroundRectangle.initialY = root.y
            backgroundRectangle.initialHeight = root.height
            backgroundRectangle.initialWidth = root.width
        }

        onStopped: {
            if (root.delegate) {
                delegateLoader.active = true
            }
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
            to: targetWidth
            duration: UbuntuAnimation.BriskDuration
        }
        UbuntuNumberAnimation {
            target: root
            property: "height"
            to: targetHeight
            duration: UbuntuAnimation.BriskDuration
        }
    }

    ParallelAnimation {
        id: parallelAnimationClose

        UbuntuNumberAnimation {
            target: root
            property: "x"
            to: backgroundRectangle.initialX
            duration: UbuntuAnimation.BriskDuration
        }
        UbuntuNumberAnimation {
            target: root
            property: "y"
            to: backgroundRectangle.initialY
            duration: UbuntuAnimation.BriskDuration
        }
        UbuntuNumberAnimation {
            target: root
            property: "width"
            to: backgroundRectangle.initialWidth
            duration: UbuntuAnimation.BriskDuration
        }
        UbuntuNumberAnimation {
            target: root
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
            root.closed()
        }
    }
}
