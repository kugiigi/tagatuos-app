import QtQuick 2.9
import Lomiri.Components 1.3

Flickable {
    id: root

    property double initContentX
    property double initElementNumber
    property double singleItemWidth
    property int currentIndex

    Component.onCompleted: {
        contentX = singleItemWidth * currentIndex
    }

    opacity: visible ? 1 : 0
    interactive: true

    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.HorizontalFlick
    maximumFlickVelocity: units.gu(500)
    flickDeceleration: units.gu(1200)

    onSingleItemWidthChanged: {
        smoothedAnimation.duration = 0 //do not animate when resizing
        cancelFlick()
        contentX = singleItemWidth * currentIndex
        smoothedAnimation.duration = LomiriAnimation.BriskDuration
//        returnToBounds()
    }

    onMovementStarted: {
        //save contentX to a custom property on your flickable
        initContentX = contentX
        //also save current element number
        initElementNumber = contentX / singleItemWidth
    }

    onMovementEnded: {
        var numberOfItem = Math.round(
                    (contentX - initContentX) / singleItemWidth)
        contentX = (singleItemWidth * numberOfItem) + (initElementNumber * singleItemWidth)
        currentIndex = Math.round(contentX / singleItemWidth)
    }

    onCurrentIndexChanged: {
        contentX = singleItemWidth * currentIndex
    }

    Behavior on anchors.topMargin {
        LomiriNumberAnimation {
            easing: LomiriAnimation.StandardEasing
            duration: LomiriAnimation.BriskDuration
        }
    }

    Behavior on opacity {
        LomiriNumberAnimation {
            easing: LomiriAnimation.StandardEasing
            duration: LomiriAnimation.BriskDuration
        }
    }

    Behavior on contentX {
        //SmoothedAnimation {
        LomiriNumberAnimation{
            id: smoothedAnimation
            duration: LomiriAnimation.BriskDuration
//            reversingMode: SmoothedAnimation.Immediate
            easing.type: Easing.InOutQuad
            onRunningChanged: {
                if (!running) {
                    root.visible = true
                }
            }
        }
    }
}
