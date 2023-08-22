import QtQuick 2.12
import "../common" as Common
import "../library/functions.js" as Functions

Item {
    id: focusScrollConnections

    property alias enabled: connections.enabled
    property alias target: connections.target
    property Flickable flickable
    property bool enableAcceptedFocus: true
    property bool enableActiveFocusScroll: true
    property bool enableLineCountScroll: true

    function focusPrevious() {
        if (target.activeFocus) {
            let _prevItem = target.nextItemInFocusChain(false)
            _prevItem.forceActiveFocus()
        }
    }

    function focusNext() {
        if (target.activeFocus) {
            let _nextItem = target.nextItemInFocusChain(true)
            _nextItem.forceActiveFocus()
        }
    }

    Connections {
        id: connections

        ignoreUnknownSignals: true

        onAccepted: if (enableAcceptedFocus) focusNext()

        onActiveFocusChanged: {
            if (target.activeFocus && enableActiveFocusScroll) {
                Functions.scrollToView(target, flickable, 0, 0)
            }
        }

        // For TextArea
        onLineCountChanged: {
            if (target.activeFocus && enableLineCountScroll) {
                Functions.scrollToView(target, flickable, 0, 0)
            }
        }
    }
}
