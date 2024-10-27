import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import Lomiri.Components 1.3 as UT
import QtQuick.Layouts 1.12
import "." as Common
import "../components" as Components
import "listitems" as ListItems

TextField {
    id: textField

    readonly property bool isFocused: activeFocus || autoCompleteListView.activeFocus

    property Common.BaseFlickable flickable
    property alias model: autoCompleteListView.model
    property alias delegate: autoCompleteListView.delegate
    property string propertyName: "name"
    property bool overrideCommit: false
    property alias iconName: leftIcon.name
    property bool useCustomBackground: true

    // Function that is executed before changing the search text
    property var searchFunction: function () {}

    signal commit(var data, bool refocus)

    font.pixelSize: Suru.units.gu(2)
    wrapMode: TextInput.WordWrap
    inputMethodHints: Qt.ImhNoPredictiveText
    selectByMouse: true
    leftPadding: leftIcon.visible ? leftIcon.width + Suru.units.gu(2) : Suru.units.gu(1)
    bottomPadding: autoCompleteListView.visible ? autoCompleteListView.height + Suru.units.gu(2) : Suru.units.gu(1)

    onCommit: {
        if (!overrideCommit) {
            let _newText = data

            if (_newText && _newText.trim() !== "") {
                text = _newText
            }
        }

        deselect()
        if (refocus) {
            internal.delayedActiveFocus()
        }
    }

    onTextChanged: {
        searchDelay.stop()

        if (!internal.doNotProcessTextChange && textField.isFocused) {
            internal.hideAutoCompleteListView = false
            searchDelay.restart()
        }
    }

    onAccepted: internal.hideAutoCompleteListView = true
    onIsFocusedChanged: if (!isFocused) textField.model.searchText = ""

    Keys.onUpPressed: focusScrollConnections.focusPrevious()
    Keys.onDownPressed: {
        if (autoCompleteListView.visible && autoCompleteListView.count > 0) {
            autoCompleteListView.forceActiveFocus()
        } else {
            focusScrollConnections.focusNext()
        }
    }

    QtObject {
        id: internal

        property bool doNotProcessTextChange: false
        property bool hideAutoCompleteListView: true

        readonly property Timer delayedActiveFocusTimer: Timer {
            interval: 1
            onTriggered: textField.forceActiveFocus()
        }

        // To properly focus in most events especially when pressing Enter
        function delayedActiveFocus() {
            delayedActiveFocusTimer.restart()
        }
    }

    Timer {
        id: searchDelay
        interval: 300
        onTriggered: {
            let _trimmedText = textField.text.trim()

            textField.searchFunction()
            textField.model.order = "asc"
            textField.model.searchText = _trimmedText
        }
    }

    Components.FocusScrollConnections {
        id: focusScrollConnections

        target: textField
        flickable: textField.flickable
    }

    Loader {
        id: customBackgroundLoader
        active: textField.useCustomBackground
        asynchronous: true
        sourceComponent: Common.BaseBackgroundRectangle {
            control: textField
            radius: Suru.units.gu(1)
            enableHoveredHighlight: false
            highlightColor: "transparent"
        }
        onLoaded: textField.background = item
    }

    UT.Icon {
        id: leftIcon

        visible: name !== ""
        anchors {
            top: parent.top
            topMargin: textField.topPadding
            left: parent.left
            leftMargin: Suru.units.gu(1)
        }
        color: Suru.foregroundColor
        width: Suru.units.gu(2)
        height: width
    }

    Common.ThinDivider {
        visible: autoCompleteListView.visible
        anchors {
            left: parent.left
            right: parent.right
            bottom: autoCompleteListView.top
            leftMargin: Suru.units.gu(2)
            rightMargin: anchors.leftMargin
        }
    }

    Connections {
        target: textField.model ? textField.model : null
        ignoreUnknownSignals: true

        onReadyChanged: {
            if (target.ready) {
                let _text = textField.text
                let _firstItem = textField.model.get(0)
                let _firstItemText = autoCompleteListView.firstItemText

                if (_firstItemText.search(_text) === 0 && textField.isFocused) {
                    internal.doNotProcessTextChange = true
                    textField.text = _firstItemText
                    textField.select(_text.length, _firstItemText.length)
                    internal.doNotProcessTextChange = false
                }
            }
        }
    }

    ListView {
        id: autoCompleteListView

        readonly property string firstItemText: model.count > 0 ? model.get(0)[textField.propertyName].toString() : ""
        readonly property bool autoCompleteIsOffered: firstItemText !== "" && firstItemText === textField.text

        signal itemClicked(var data)

        visible: !internal.hideAutoCompleteListView
                    && textField.isFocused
                    && textField.model.ready
                    && textField.model.count > 0
                    && !(textField.model.count === 1 && autoCompleteIsOffered) // Hide when auto complete is offered and it's the only item
        currentIndex: firstItemText === textField.text ? 0 : -1
        keyNavigationEnabled: true
        height: contentHeight
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: Suru.units.gu(1)
        }

        onItemClicked: {
            textField.commit(data, true)
            internal.hideAutoCompleteListView = true
        }

        Keys.onUpPressed: {
            if (currentIndex === 0) {
                textField.forceActiveFocus()
            } else {
                event.accepted = false
            }
        }
        Keys.onReturnPressed: {
            currentItem.clicked()
        }

        delegate: Common.TextFieldWithAutoCompleteDelegate {
            propertyName: textField.propertyName
        }
    }
}
