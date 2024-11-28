import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2

Rectangle {
    id: backgroundRec

    property var control
    property bool showDivider
    property bool transparentBackground: false
    property bool enableHoveredHighlight: true
    property color backgroundColor: Suru.backgroundColor
    property color borderColor: Suru.backgroundColor
    property color highlightColor: Suru.highlightColor
    property color highlightedBorderColor: Suru.highlightColor

    radius: Suru.units.gu(1.5)
    color: backgroundRec.transparentBackground ? "transparent" : backgroundRec.backgroundColor
    border.width: control.highlighted ? Suru.units.gu(0.2) : Suru.units.gu(0.1)
    border.color: backgroundRec.transparentBackground ? "transparent"
                                    : control.highlighted ? backgroundRec.highlightedBorderColor : backgroundRec.borderColor

    Behavior on border.width {
        NumberAnimation {
            easing: Suru.animations.EasingIn
            duration: Suru.animations.FastDuration
        }
    }

    Rectangle {
        id: highlightRect

        anchors.fill: parent
        visible: opacity > 0
        opacity: {
            if (control.highlighted)
                return 0.1

            if (control.down || (control.hovered && backgroundRec.enableHoveredHighlight))
                return 1

            return 0
        }
        border.width: backgroundRec.border.width
        border.color: "transparent"
        radius: backgroundRec.radius
        color: {
            if (control.highlighted)
                return backgroundRec.highlightColor

            let _factor = 1.0

            if (backgroundRec.backgroundColor.hslLightness > 0.5) {
                if (control.interactive && control.down) {
                    _factor = 1.2
                } else {
                    _factor = 1.1
                }

                return Qt.darker(backgroundRec.backgroundColor, _factor)
            } else {
                if (control.interactive && control.down) {
                    _factor = 2.0
                } else {
                    _factor = 1.8
                }

                return Qt.lighter(backgroundRec.backgroundColor, _factor)
            }

            return backgroundRec.backgroundColor
        }

        Behavior on color {
            enabled: !control.highlighted
            ColorAnimation {
                duration: Suru.animations.FastDuration
                easing: Suru.animations.EasingIn
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Suru.animations.FastDuration
                easing: Suru.animations.EasingIn
            }
        }
    }

    ThinDivider {
        visible: backgroundRec.showDivider
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Suru.units.gu(2)
            rightMargin: anchors.leftMargin
        }
    }
}
