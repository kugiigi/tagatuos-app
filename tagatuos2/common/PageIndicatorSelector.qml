import QtQuick 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import "." as Common

Item {
    id: pageIndicatorSelector

    readonly property bool swipeSelectMode: internal.swipeSelectMode
    readonly property real storedHeightBeforeSwipeSelectMode: internal.storedHeightBeforeSwipeSelectMode
    // WORKAROUND: !swipeHandler.pressed is a workaround for touch since it's still triggering hover when long pressing
    readonly property bool isHovered: bgHoverHandler.hovered && !swipeHandler.pressed

    readonly property real oneRowHeight: mainRowLayout.dotNormalWidth + mainRowLayout.padding * 2

    property alias swipeEnabled: swipeHandler.enabled
    property bool mouseHoverEnabled: true
    property alias indicatorWidth: mainRowLayout.dotNormalWidth
    property alias indicatorSelectedWidth: mainRowLayout.dotIsCurrentWidth

    property real highlightScale: 1.5
    property color backgroundColor: Suru.secondaryBackgroundColor
    property real backgroundOpacity: 0.8
    property real swipeHandlerOutsideMargin: Suru.units.gu(2)
    property real hoverHandlerOutsideMargin: Suru.units.gu(2)
    property int count
    property int currentIndex: -1
    property int extraHighlightedIndex: -1
    property alias model: itemRepeater.model

    signal newIndexSelected(int newIndex)

    height: mainRowLayout.height

    onIsHoveredChanged: internal.swipeSelectMode = isHovered

    QtObject {
        id: internal

        readonly property real initialSwipeThreshold: Suru.units.gu(1)
        property bool allowSelection: false
        property point startPoint: Qt.point(0, 0)
        // Allow immediately when hovering with mouse
        property real initialSwipeDistance: pageIndicatorSelector.isHovered ? initialSwipeThreshold : startPoint.x > 0 ? Math.abs(swipeHandler.mouseX - startPoint.x) : 0
        property bool swipeSelectMode: false
        property real storedHeightBeforeSwipeSelectMode: mainRowLayout.height
        readonly property real highlightMargin: mainRowLayout.dotWidth + Suru.units.gu(2)
        property var highlightedItem: {
            if (swipeSelectMode && (allowSelection || mainRowLayout.rowCount > 1)) {
                let _targetItem = bgHoverHandler.hovered ? bgHoverHandler : swipeHandler
                let _isMouse = _targetItem === bgHoverHandler
                let _highlightMargin = _isMouse ? 0 : highlightMargin
                let _mappedPos = mainRowLayout.mapFromItem(bg, _targetItem.mouseX, _targetItem.mouseY - _highlightMargin)

                let _found = null
                if (mainRowLayout.rowCount == 1) {
                    let _mappedX = _mappedPos.x
                    if (_mappedX < mainRowLayout.leftPadding) {
                        _mappedX = mainRowLayout.leftPadding
                    } else if (_mappedX > mainRowLayout.width - mainRowLayout.leftPadding) {
                        _mappedX = mainRowLayout.width - mainRowLayout.leftPadding
                    }
                    _found = mainRowLayout.childAt(_mappedX, mainRowLayout.height / 2)
                } else {
                    _found = mainRowLayout.childAt(_mappedPos.x, _mappedPos.y)
                }
                return _found
            }

            return null
        }

        onInitialSwipeDistanceChanged: {
            if (!allowSelection && initialSwipeDistance >= initialSwipeThreshold) {
                allowSelection = true
            }
        }

        onSwipeSelectModeChanged: {
            if (swipeSelectMode) {
                storedHeightBeforeSwipeSelectMode = mainRowLayout.height
                startPoint = Qt.point(swipeHandler.point.scenePressPosition.x, swipeHandler.point.scenePressPosition.y)
            } else {
                startPoint = Qt.point(0, 0)
                allowSelection = false
                titleRec.hide()
            }
        }

        onHighlightedItemChanged: {
            if (highlightedItem) {
                titleRec.show()
            }
        }
    }

    Rectangle {
        id: bg

        color: pageIndicatorSelector.backgroundColor
        opacity: pageIndicatorSelector.backgroundOpacity
        radius: Suru.units.gu(3)
        anchors.horizontalCenter: parent.horizontalCenter

        width: mainRowLayout.width
        height: mainRowLayout.height
        Behavior on opacity { NumberAnimation { easing: Suru.animations.EasingInOut; duration: Suru.animations.FastDuration } }
    }

    Rectangle {
        id: titleRec

        readonly property var targetItem: internal.highlightedItem
        property bool shown: false
        readonly property point mappedHighlightedItemPos: targetItem ? targetItem.mapToItem(pageIndicatorSelector, 0, 0) : Qt.point(0, 0)
        readonly property real intendedX: targetItem ? mappedHighlightedItemPos.x - (width / 2) + ((targetItem.width * pageIndicatorSelector.highlightScale) / 2) : 0
        readonly property Timer delayTimer: Timer {
            running: false
            interval: 400
            onTriggered: titleRec.shown = true
        }

        z: mainRowLayout.z + 1
        x: {
            if (intendedX + pageIndicatorSelector.anchors.leftMargin < 0) {
                return -pageIndicatorSelector.anchors.leftMargin
            }

            if (intendedX + width + pageIndicatorSelector.anchors.rightMargin > pageIndicatorSelector.width) {
                return pageIndicatorSelector.width - width - pageIndicatorSelector.anchors.rightMargin -  + Suru.units.gu(2)
            }

            return intendedX
        }

        y: targetItem ? mappedHighlightedItemPos.y - (height + Suru.units.gu(2)) : 0
        implicitWidth: rowLayout.width
        implicitHeight: rowLayout.height
        radius: height / 4
        color: Suru.neutralColor
        opacity: shown ? 1 : 0
        visible: opacity > 0 && x !== 0 && y !== 0

        function show(_delayed = true) {
            if (_delayed) {
                delayTimer.restart()
            } else {
                shown = true
            }
        }

        function hide() {
            delayTimer.stop()
            shown = false
        }

        RowLayout {
            id: rowLayout

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.bottomMargin: Suru.units.gu(0.5)
                Layout.topMargin: Suru.units.gu(0.5)
                Layout.leftMargin: Suru.units.gu(1)
                Layout.rightMargin: Suru.units.gu(1)
                Suru.textLevel: Suru.HeadingTwo
                color: Suru.foregroundColor
                text: titleRec.targetItem ? titleRec.targetItem.itemTitle : ""
            }
        }

        Behavior on opacity { NumberAnimation { easing: Suru.animations.EasingInOut; duration: Suru.animations.BriskDuration } }
    }

    Grid {
        id: mainRowLayout

        property real dotNormalWidth: Suru.units.gu(2)
        property real dotIsCurrentWidth: Suru.units.gu(5)
        property real dotWidth: pageIndicatorSelector.swipeSelectMode ? dotIsCurrentWidth : dotNormalWidth
        readonly property int normalColumns: Math.ceil((Math.min(pageIndicatorSelector.width * 0.8, Suru.units.gu(50))) / (dotWidth + spacing))
        readonly property int rowCount: Math.ceil(itemRepeater.count / columns)

        anchors.horizontalCenter: parent.horizontalCenter

        columns: normalColumns
        padding: Suru.units.gu(1)
        leftPadding: Suru.units.gu(2) // No rightPadding so it's properly centered
        spacing: Suru.units.gu(1)
        verticalItemAlignment: Grid.AlignVCenter
        horizontalItemAlignment: Grid.AlignHCenter

        Behavior on dotWidth { NumberAnimation { easing: Suru.animations.EasingInOut; duration: Suru.animations.FastDuration } }

        Repeater {
            id: itemRepeater

            delegate: PageIndicatorSelectorDelegate {
                highlightScale: pageIndicatorSelector.highlightScale
                width: mainRowLayout.dotWidth
                isCurrent: index == pageIndicatorSelector.currentIndex
                isSwipeSelected: this == internal.highlightedItem
                isExtraHighlighted: index == pageIndicatorSelector.extraHighlightedIndex
                swipeSelectMode: pageIndicatorSelector.swipeSelectMode
                itemIndex: index
                itemTitle: modelData && modelData.title ? modelData.title
                                    : model.title && model.title ? model.title : ""
                itemIconName: modelData && modelData.iconName ? modelData.iconName
                                    : model.iconName && model.iconName ? model.iconName : ""
                itemText: modelData && modelData.shortText ? modelData.shortText
                                    : model.shortText && model.shortText ? model.shortText : ""

                onSelected: pageIndicatorSelector.newIndexSelected(itemIndex)
            }
        }
    }

    // Input handlers
    Item {
        anchors.fill: bg

        TapHandler {
            id: swipeHandler

            // Already mapped to global
            readonly property real mouseX: point.position.x
            readonly property real mouseY: point.position.y

            acceptedPointerTypes: PointerDevice.Finger
            margin: pageIndicatorSelector.swipeHandlerOutsideMargin
            gesturePolicy: TapHandler.ReleaseWithinBounds

            onPressedChanged: {
                if (pressed) {
                    internal.swipeSelectMode = true
                    Common.Haptics.playSubtle()
                } else {
                    if (internal.highlightedItem) {
                        pageIndicatorSelector.newIndexSelected(internal.highlightedItem.itemIndex)
                        Common.Haptics.play()
                    }
                    internal.swipeSelectMode = false
                }
            }
        }

        HoverHandler {
            id: bgHoverHandler

            // Already mapped to global
            readonly property real mouseX: point.position.x
            readonly property real mouseY: point.position.y

            enabled: pageIndicatorSelector.mouseHoverEnabled && !swipeHandler.pressed
            acceptedPointerTypes: PointerDevice.GenericPointer | PointerDevice.Cursor | PointerDevice.Pen
            margin: pageIndicatorSelector.hoverHandlerOutsideMargin
        }
    }
}
