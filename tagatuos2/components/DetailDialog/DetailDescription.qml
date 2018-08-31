import QtQuick 2.4
import Ubuntu.Components 1.3


ScrollView {
    id: descriptionScrollView

    Flickable {
        id: flickable

        boundsBehavior: Flickable.DragAndOvershootBounds
        interactive: true
        clip: true
        contentHeight: descriptionLabel.contentHeight
        anchors{
            left: parent.left
            leftMargin: units.gu(-1)
            rightMargin: units.gu(-2)
            right: parent.right
            top: parent.top
        }

        TextArea {
            id: descriptionLabel

            text: root.description
            font.pointSize: Label.Medium
            color: theme.palette.normal.backgroundSecondaryText
            autoSize: true
            readOnly: true
            maximumLineCount: 0
            verticalAlignment: TextEdit.AlignVCenter
            wrapMode: TextEdit.WordWrap
            cursorVisible: false

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }


            onCursorVisibleChanged: {
                if (selectedText.length === 0) {
                    cursorVisible = false
                }
            }


            onSelectedTextChanged: {
                if (selectedText.length > 0) {
                    cursorVisible = true
                }else{
                    cursorVisible = false
                }
            }
        }
    }
}
