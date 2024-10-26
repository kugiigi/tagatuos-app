import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../.." as Components
import "../../../common" as Common
import "../../../common/menus" as Menus
import "../../../common/listitems" as ListItems
import "../../../library/functions.js" as Functions

TextField {
    id: tagsField

    property Common.BaseFlickable flickable
    readonly property bool highlighted: activeFocus
    readonly property bool isFocused: activeFocus || autoCompleteListView.activeFocus

    property bool doNotProcessTextChange: false
    property string tags
    readonly property var tagsList: tags ? tags.split(",") : []
    readonly property bool hasTags: tagsList.length > 0
    readonly property Timer delayedActiveFocusTimer: Timer {
        interval: 1
        onTriggered: tagsField.forceActiveFocus()
    }

    function commitTag(_newTag = "", _refocus = true) {
        if (_newTag && _newTag.trim() !== "") {
            addToTags(_newTag)
        } else {
            if (text.trim() !== "") {
                addToTags(text)
            }
        }

        text = ""

        if (_refocus) {
            delayedActiveFocus()
        }
    }

    // To properly focus in most events especially when pressing Enter
    function delayedActiveFocus() {
        delayedActiveFocusTimer.restart()
    }

    function clearTags() {
        tags = ""
        text = ""
        searchDelay.triggered()
    }

    function deleteTag(_tag) {
        if (_tag === tags) {
            tags = ""
        } else {
            tags = tags.replace(_tag + ",", "") //Remove if start of list
            tags = tags.replace("," + _tag + ",", ",") //Remove if middle of string
            //Remove if end of string
            let _regEx = new RegExp("," + _tag + "$");
            tags = tags.replace(_regEx, "")
        }
    }

    function addToTags(_newTag) {
        if (!tagsList.includes(_newTag)) {
            if (hasTags) {
                tags += "," + _newTag
            } else {
                tags = _newTag
            }
        }
    }

    placeholderText: i18n.tr("Add tags (Enter comma after each tag)")
    font.pixelSize: Suru.units.gu(2)
    horizontalAlignment: TextInput.AlignHCenter
    wrapMode: TextInput.WordWrap
    inputMethodHints: Qt.ImhNoPredictiveText
    selectByMouse: true
    topPadding: tagsFlow.visible ? rowLayout.height + Suru.units.gu(2) : Suru.units.gu(1)
    bottomPadding: autoCompleteListView.visible ? autoCompleteListView.height + Suru.units.gu(2) : Suru.units.gu(1)

    Behavior on topPadding { NumberAnimation { easing: Suru.animations.EasingInOut; duration: Suru.animations.SnapDuration } }

    onTextChanged: {
        searchDelay.stop()

        if (!doNotProcessTextChange) {
            let _text = text
            let _newTag = _text.substring(0, _text.length - 1)

            if (_text.charAt(_text.length - 1) === ",") {
                if (_newTag.trim() !== "") {
                    tagsField.commitTag(_newTag, false)
                } else {
                    text = ""
                }
            } else {
                searchDelay.restart()
            }
        }
    }

    onVisibleChanged: if (visible) text = ""
    onIsFocusedChanged: if (!isFocused) mainView.mainModels.searchExpenseTagsModel.searchText = ""
    onAccepted: commitTag(text, true)

    Timer {
        id: searchDelay
        interval: 300
        onTriggered: {
            let _trimmedText = tagsField.text.trim()

            mainView.mainModels.searchExpenseTagsModel.order = "asc"
            mainView.mainModels.searchExpenseTagsModel.excludedList = tags + "," + text
            mainView.mainModels.searchExpenseTagsModel.searchText = _trimmedText
        }
    }

    Keys.onUpPressed: focusScrollConnections.focusPrevious()
    Keys.onDownPressed: {
        if (autoCompleteListView.visible && autoCompleteListView.count > 0) {
            autoCompleteListView.forceActiveFocus()
        } else {
            focusScrollConnections.focusNext()
        }
    }

    Components.FocusScrollConnections {
        id: focusScrollConnections

        target: tagsField
        flickable: tagsField.flickable
    }

    background: Common.BaseBackgroundRectangle {
        control: tagsField
        radius: Suru.units.gu(1)
        highlightColor: "transparent"
    }

    RowLayout {
        id: rowLayout

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Suru.units.gu(1)
        }

        Components.TagsList {
            id: tagsFlow

            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth: true

            model: tagsField.tagsList
            visible: tagsField.hasTags
            editable: true

            onDeleteTag: tagsField.deleteTag(tag)
        }

        Common.BaseButton {
            id: clearButton

            Layout.alignment: Qt.AlignRight

            visible: tagsField.hasTags
            display: AbstractButton.IconOnly
            hoverEnabled: true
            icon {
                name: "toolkit_input-clear"
                width: Suru.units.gu(3)
                height: Suru.units.gu(3)
                color: Suru.secondaryForegroundColor
            }
            transparentBackground: true

            onClicked: tagsField.clearTags()
            ToolTip.delay: 500
            ToolTip.visible: hovered
            ToolTip.text: i18n.tr("Clear all tags")
            ToolTip.onVisibleChanged: ToolTip.delay = 500
        }
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
        target: mainView.mainModels.searchExpenseTagsModel

        onReadyChanged: {
            if (target.ready) {
                let _text = tagsField.text
                let _firstItem = mainView.mainModels.searchExpenseTagsModel.get(0)
                let _firstItemText = _firstItem ? _firstItem.tagName : ""

                if (autoCompleteListView.firstText !== ""
                        && _firstItemText.search(_text) === 0) {
                    tagsField.doNotProcessTextChange = true
                    tagsField.text = _firstItemText
                    tagsField.select(_text.length, _firstItemText.length)
                    tagsField.doNotProcessTextChange = false
                }
            }
        }
    }

    ListView {
        id: autoCompleteListView

        visible: (tagsField.isFocused)
                    && mainView.mainModels.searchExpenseTagsModel.ready
                    && mainView.mainModels.searchExpenseTagsModel.count > 0
        currentIndex: -1
        keyNavigationEnabled: true
        height: contentHeight
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: Suru.units.gu(1)
        }
        model: mainView.mainModels.searchExpenseTagsModel

        onActiveFocusChanged: {
            if (activeFocus) {
                currentIndex = 0
            } else {
                currentIndex = -1
            }
        }

        Keys.onUpPressed: {
            if (currentIndex === 0) {
                tagsField.forceActiveFocus()
            } else {
                event.accepted = false
            }
        }
        Keys.onReturnPressed: {
            currentItem.clicked()
        }

        delegate: ListItems.BaseItemDelegate {
            id: itemDelegate

            highlighted: autoCompleteListView.currentIndex == index
            transparentBackground: true

            anchors {
                left: parent.left
                right: parent.right
            }
            text: model ? model.tagName : ""
            onClicked: {
                tagsField.commitTag(text, true)
            }
            contentItem: Label {
                text: itemDelegate.text
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
