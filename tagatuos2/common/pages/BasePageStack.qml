import QtQuick 2.12
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Controls.Suru 2.2
import Lomiri.Components 1.3
import QtQuick.Layouts 1.12
import "../gestures" as Gestures
import ".." as Common

QQC2.Page {
    id: basePageStack

    property bool enableShortcuts: false
    property alias headerExpanded: pageHeader.expanded
    property alias pageHeader: pageHeader
    property alias customTitleItem: pageHeader.customTitleItem
    property alias initialItem: mainStackView.initialItem
    property alias currentItem: mainStackView.currentItem
    property alias depth: mainStackView.depth
    property alias stackView: mainStackView
    property alias middleBottomGesture: middleBottomEdgeHandler
    property var defaultLeftActions: [ backAction ]
    property var defaultRightActions: []

    property bool isWideLayout: false
    property bool forceShowBackButton: false

    // Gestures
    property bool enableBottomGestureHint: false
    property bool physicalBasedGestures: true
    property bool enableHeaderPullDown: true
    property bool enableBottomSideSwipe: true
    property bool enableDirectActions: false
    property bool enableDirectActionsDelay: true
    property bool enableBottomQuickSwipe: false
    property bool enableHorizontalSwipe: false
    property real bottomGestureAreaHeight: units.gu(2)
    property real directActionsHeight: 3

    signal back

    clip: true
    focus: true

    function push(item) {
        mainStackView.push(item)
    }

    function pop() {
        mainStackView.pop()
    }

    function clear() {
        mainStackView.clear()
    }

    Common.BaseAction {
        id: backAction

        text: i18n.tr("Back")
        tooltipText: i18n.tr("Go back to previous page")
        iconName: "back"
        visible: (mainStackView.depth > 1 || forceShowBackButton) && (mainStackView.currentItem && mainStackView.currentItem.showBackButton)
        shortcut: enableShortcuts ? StandardKey.Back : ""
        enabled: visible

        onTrigger: {
            if (mainStackView.depth > 1) {
                mainStackView.pop()
            } else {
                basePageStack.back()
            }
        }
    }

    header: BasePageHeader {
        id: pageHeader

        showDivider: false
        expandable: basePageStack.enableHeaderPullDown && basePageStack.parent.height >= units.gu(60)
        currentItem: mainStackView.currentItem
        leftActions: currentItem && currentItem.headerLeftActions
                        ? [...basePageStack.defaultLeftActions, ...currentItem.headerLeftActions]
                        : basePageStack.defaultLeftActions
        rightActions: currentItem && currentItem.headerRightActions
                        ? [...currentItem.headerRightActions, ...basePageStack.defaultRightActions]
                        : basePageStack.defaultRightActions
    }

    QQC2.StackView {
        id: mainStackView

        focus: true
        anchors.fill: parent
        onCurrentItemChanged: {
            currentItem.pageManager = basePageStack
            if (currentItem.hasOwnProperty("isWideLayout")) {
                currentItem.isWideLayout = Qt.binding(function() { return basePageStack.isWideLayout } )
            }
        }
    }

    // Swipe area for reverting back the header to default height
    SwipeArea {
        id: swipeHeaderRevert

        z: mainStackView.z + 1
        enabled: pageHeader.expanded
        anchors.fill: parent
        immediateRecognition: false
        grabGesture: true
        direction: SwipeArea.Upwards

        onDraggingChanged: {
            if (!dragging && pageHeader.expanded && pageHeader.height <= pageHeader.maxHeight - pageHeader.expansionThreshold * 2) {
                pageHeader.expanded = false
            }
        }

        onDistanceChanged: {
            if (dragging && pageHeader.height > pageHeader.defaultHeight
                    && pageHeader.height <= pageHeader.maxHeight
                ) {

                let newValue = pageHeader.maxHeight - distance

                switch (true) {
                    case newValue <= pageHeader.defaultHeight:
                        pageHeader.height = pageHeader.defaultHeight
                        break
                    case newValue >= pageHeader.maxHeight:
                        pageHeader.height = pageHeader.maxHeight
                        break
                    default:
                        pageHeader.height = newValue
                        break
                }
            }
        }
    }

    Gestures.GoIndicator {
        id: goForwardIcon

        iconName: enabled && pageHeader.rightVisibleActionsCount > 1 ? "navigation-menu"
                                    : pageHeader.rightVisibleAction ? pageHeader.rightVisibleAction.iconName
                                                                    : ""
        swipeProgress: bottomBackForwardHandle.swipeProgress
        enabled: pageHeader.rightVisibleActionsCount > 0
        anchors {
            right: parent.right
            rightMargin: units.gu(3)
            verticalCenter: parent.verticalCenter
        }
    }

    Gestures.GoIndicator {
        id: goBackIcon

        iconName: enabled && pageHeader.leftVisibleActionsCount > 1 ? "navigation-menu"
                                    : pageHeader.leftVisibleAction ? pageHeader.leftVisibleAction.iconName
                                                                   : ""
        swipeProgress: bottomBackForwardHandle.swipeProgress
        enabled: pageHeader.leftVisibleActionsCount > 0
        anchors {
            left: parent.left
            leftMargin: units.gu(3)
            verticalCenter: parent.verticalCenter
        }
    }

    ActivityIndicator {
        id: busyIndicator

        anchors.centerIn: parent
        running: basePageStack.currentItem ? false : true
        opacity: running ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { LomiriNumberAnimation {} }
    }

    RowLayout {
        id: bottomRowLayout

        property real sideSwipeAreaWidth: basePageStack.width * (basePageStack.width > basePageStack.height ? 0.15 : 0.30)

        spacing: 0
        z: swipeHeaderRevert.z + 1
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        opacity: basePageStack.currentItem ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { LomiriNumberAnimation {} }

        Gestures.BottomSwipeArea {
            Layout.fillHeight: true
            Layout.fillWidth: !horizontalSwipeItem.visible
            Layout.preferredWidth: bottomRowLayout.sideSwipeAreaWidth
            Layout.alignment: Qt.AlignBottom | Qt.AlignLeft

            enabled: basePageStack.enableBottomSideSwipe
            model: pageHeader.leftActions
            enableQuickActions: basePageStack.enableDirectActions
            enableQuickActionsDelay: basePageStack.enableBottomQuickSwipe
                                                || (!basePageStack.enableBottomQuickSwipe && basePageStack.enableDirectActionsDelay)
            triggerSignalOnQuickSwipe: true
            edge: Gestures.BottomSwipeArea.Edge.Left
            maxQuickActionsHeightInInch: basePageStack.directActionsHeight
            availableHeight: mainStackView.height
            availableWidth: mainStackView.width
            implicitHeight: Suru.units.gu(basePageStack.bottomGestureAreaHeight)

            onTriggered: {
                if (!basePageStack.enableDirectActions
                        || (basePageStack.enableDirectActions && basePageStack.enableBottomQuickSwipe)) {
                    pageHeader.triggerLeftFromBottom()
                    Common.Haptics.play()
                }
            }
        }
        
        Item {
            id: horizontalSwipeItem

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignBottom

            MouseArea {
                id: bottomEdgeHint

                readonly property alias color: recVisual.color
                readonly property real defaultHeight: units.gu(0.5)

                hoverEnabled: true
                height: defaultHeight

                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    bottomMargin: defaultHeight
                }

                Behavior on opacity { LomiriNumberAnimation {} }

                Rectangle {
                    id: recVisual

                    visible: basePageStack.enableBottomGestureHint
                    color: bottomEdgeHint.containsMouse ? LomiriColors.silk : LomiriColors.ash
                    radius: height / 2
                    height: bottomEdgeHint.containsMouse ? units.gu(1) : units.gu(0.5)
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        right: parent.right
                    }
                }
            }

            Gestures.HorizontalSwipeHandle {
                id: bottomBackForwardHandle

                enabled: basePageStack.enableHorizontalSwipe
                leftAction: goBackIcon
                rightAction: goForwardIcon
                immediateRecognition: true
                usePhysicalUnit: basePageStack.physicalBasedGestures
                height: Suru.units.gu(basePageStack.bottomGestureAreaHeight)
                swipeHoldDuration: 700
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }

                rightSwipeHoldEnabled: false
                leftSwipeHoldEnabled: false

                onRightSwipe:  pageHeader.triggerLeftFromBottom()
                onLeftSwipe:  pageHeader.triggerRightFromBottom()
                onPressedChanged: if (pressed) Common.Haptics.playSubtle()
            }

            Gestures.SwipeGestureHandler {
                id: middleBottomEdgeHandler

                enabled: true
                usePhysicalUnit: basePageStack.physicalBasedGestures
                immediateRecognition: !bottomBackForwardHandle.enabled
                height: Suru.units.gu(basePageStack.bottomGestureAreaHeight)
                swipeHoldDuration:  500
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
            }
        }

        Gestures.BottomSwipeArea {
            Layout.fillHeight: true
            Layout.fillWidth: !horizontalSwipeItem.visible
            Layout.preferredWidth: bottomRowLayout.sideSwipeAreaWidth
            Layout.alignment: Qt.AlignBottom | Qt.AlignRight

            enabled: basePageStack.enableBottomSideSwipe
            model: pageHeader.rightActions
            enableQuickActions: basePageStack.enableDirectActions
            enableQuickActionsDelay: basePageStack.enableBottomQuickSwipe
                                                || (!basePageStack.enableBottomQuickSwipe && basePageStack.enableDirectActionsDelay)
            triggerSignalOnQuickSwipe: true
            edge: Gestures.BottomSwipeArea.Edge.Right
            maxQuickActionsHeightInInch: basePageStack.directActionsHeight
            availableHeight: mainStackView.height
            availableWidth: mainStackView.width
            implicitHeight: Suru.units.gu(basePageStack.bottomGestureAreaHeight)

            onTriggered: {
                if (!basePageStack.enableDirectActions
                        || (basePageStack.enableDirectActions && basePageStack.enableBottomQuickSwipe)) {
                    pageHeader.triggerRightFromBottom()
                    Common.Haptics.play()
                }
            }
        }
    }
}
