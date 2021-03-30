import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes.Ambiance 1.3

Column {

    id: descriptionField

    property alias text: textName.text

    spacing: units.gu(1)


    anchors {
        left: parent.left
        leftMargin: units.gu(2)
        right: parent.right
        rightMargin: units.gu(2)
    }

    function forceFocus(){
        textName.forceActiveFocus()
    }

    Label {
        id: nameLabel
        text: i18n.tr("Description")
        font.weight: Text.Normal
        color: theme.palette.normal.foregroundText
        anchors {
            left: parent.left
            right: parent.right
        }
    }

    TextField {
        id: textName
        placeholderText: i18n.tr("Enter expense description ")
        hasClearButton: true
        anchors {
            left: parent.left
            right: parent.right
        }

        // Disable predictive text
        inputMethodHints: Qt.ImhNoPredictiveText

        style: TextFieldStyle {
            //overlaySpacing: 0
            //frameSpacing: 0
            background: Item {
            }
            color: theme.palette.normal.overlayText
        }

        onTextChanged: {
            mainView.listModels.modelExpenseAutoComplete.load(
                        textName.text)
            if (textName.text !== "") {
                autoCompletePopover.show = true
            } else {
                autoCompletePopover.show = false
            }
        }

        onActiveFocusChanged: {
            if(activeFocus){
                root.elementWithFocus = "Description"
            }
        }
    }

}
