import QtQuick 2.9
import Lomiri.Components 1.3
import Lomiri.Components.Themes.Ambiance 1.3

Column {
    id: commentsField

    property alias text: textareaDescr.text

    spacing: units.gu(1)

    anchors {
        left: parent.left
        right: parent.right
        leftMargin: units.gu(2)
        rightMargin: units.gu(2)
    }

    function forceFocus(){
        textareaDescr.forceActiveFocus()
    }

    Label {
        id: descrLabel
        text: i18n.tr("Details/Comments")
        font.weight: Text.Normal
        color: theme.palette.normal.foregroundText
        anchors {
            left: parent.left
            right: parent.right
        }
    }
    TextArea {
        id: textareaDescr
        height: units.gu(4)//textName.height + units.gu(1)
        autoSize: true
        //contentWidth: units.gu(30)
        placeholderText: i18n.tr("Add details / comments")
        anchors {
            left: parent.left
            right: parent.right
        }
        style: TextFieldStyle {
            background: Item {
            }
            color: theme.palette.normal.overlayText
        }

        onActiveFocusChanged: {
            if(activeFocus){
                root.elementWithFocus = "Comments"
            }
        }
    }

}
