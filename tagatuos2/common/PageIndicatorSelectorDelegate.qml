import QtQuick 2.12
import Lomiri.Components 1.3 as UT
import QtQuick.Controls.Suru 2.2
import QtQuick.Controls 2.12
import "." as Common

Rectangle {
    id: indicatorRec

    property real highlightScale: 1.5
    property bool isCurrent: false
    property bool isSwipeSelected: false
    property bool isExtraHighlighted: false
    property bool swipeSelectMode: false

    property color backgroundColor: Suru.neutralColor
    property color currentItemBackgroundColor: Suru.tertiaryForegroundColor
    property color highlightColor: Suru.highlightColor
    property color currentItemColor: Suru.foregroundColor
    property color itemColor: Suru.secondaryForegroundColor

    readonly property color foregroundColor: {
        if (isSwipeSelected)
            return highlightColor

        if (color.hslLightness > 0.5) {
            return "black"
        } else {
            return "white"
        }
    }

    property int itemIndex: -1
    property string itemTitle
    property string itemIconName
    property string itemText
    

    signal selected

    color: {
        if (isCurrent)
            return currentItemBackgroundColor

        if (isExtraHighlighted) {
            if (backgroundColor.hslLightness > 0.5) {
                return Qt.darker(backgroundColor, 1.2)
            } else {
                return Qt.lighter(backgroundColor, 1.5)
            }
        }

        return backgroundColor
    }

    radius: isExtraHighlighted ? width * 0.2 : width / 2
    height: width
    z: swipeSelectMode ? isSwipeSelected ? 2 : 1
                                        : isCurrent ? 2 : 1
    scale: swipeSelectMode ? isSwipeSelected ? highlightScale : 1
                                : isCurrent ? highlightScale : 1
    Behavior on scale { NumberAnimation { easing: Suru.animations.EasingInOut; duration: Suru.animations.BriskDuration } }
    Behavior on color { ColorAnimation { duration: Suru.animations.BriskDuration } }

    onIsSwipeSelectedChanged: {
        if (isSwipeSelected) {
            delayHaptics.restart()
        } else {
            delayHaptics.stop()
        }
    }

    Timer {
        id: delayHaptics

        running: false
        interval: 100
        onTriggered: {
            if (indicatorRec.isSwipeSelected) {
                Common.Haptics.playSubtle()
            }
        }
    }

    UT.Icon {
        visible: indicatorRec.itemIconName && indicatorRec.itemIconName.trim() !== ""
        name: indicatorRec.itemIconName
        width: parent.width * 0.7
        height: width
        anchors.centerIn: parent
        color: indicatorRec.foregroundColor
    }

    Label {
        visible: indicatorRec.itemText && indicatorRec.itemText.trim() !== ""
        text: indicatorRec.itemText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: parent.width * 0.5
        anchors.centerIn: parent
        color: indicatorRec.foregroundColor
    }

    TapHandler {
        acceptedPointerTypes: PointerDevice.GenericPointer | PointerDevice.Cursor | PointerDevice.Pen
        onSingleTapped: {
            indicatorRec.selected()
        }
    }
}
