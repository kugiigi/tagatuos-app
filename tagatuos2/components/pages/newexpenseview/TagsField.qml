import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../.." as Components
import "../../../common" as Common
import "../../../common/menus" as Menus
import "../../../common/listitems" as ListItems
import "../../../library/functions.js" as Functions

Common.TextFieldWithAutoComplete {
    id: tagsField

    property string tags
    readonly property var tagsList: tags ? tags.split(",") : []
    readonly property bool hasTags: tagsList.length > 0

    function commitTag(_newTag = "") {
        if (_newTag && _newTag.trim() !== "") {
            addToTags(_newTag)
        } else {
            if (text.trim() !== "") {
                addToTags(text)
            }
        }

        text = ""
    }

    function clearTags() {
        tags = ""
        text = ""
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

    model: mainView.mainModels.searchExpenseTagsModel
    propertyName: "tagName"
    overrideCommit: true
    horizontalAlignment: Text.AlignHCenter
    placeholderText: i18n.tr("Add tags (Enter comma after each tag)")
    iconName: "tag"
    useCustomBackground: true
    topPadding: tagsFlow.visible ? rowLayout.height + Suru.units.gu(2) : Suru.units.gu(1)
    searchFunction: function() {
        model.excludedList = tags + "," + text
    }
    checkBeforeSearchFunction: function() {
        let _text = text
        let _newTag = _text.substring(0, _text.length - 1)

        if (_text.charAt(_text.length - 1) === ",") {
            if (_newTag.trim() !== "") {
                tagsField.commit(_newTag, false)
            } else {
                text = ""
            }

            return false
        }

        return true
    }

    onCommit: {
        if (data) {
            commitTag(data)
        }
    }

    Behavior on topPadding { NumberAnimation { easing: Suru.animations.EasingInOut; duration: Suru.animations.SnapDuration } }

    onVisibleChanged: if (visible) text = ""
    onAccepted: commit(text, true)

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
}
