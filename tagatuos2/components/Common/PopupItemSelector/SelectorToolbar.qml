import QtQuick 2.4
import Ubuntu.Components 1.3

Toolbar {
    id: toolBar

    anchors {
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }

    height: units.gu(6)

    leadingActionBar.actions: [
        Action {
            id: cancelAction

            iconName: "cancel"
            onTriggered: {
                poppingDialog.close()
            }
        }
    ]
    trailingActionBar.actions: [
        Action {
            id: saveAction

            iconName: "ok"

            onTriggered: {
                poppingDialog.close()
                root.confirmSelection(itemSelector.getReturnValue(),itemSelector.geValuesOrder())
            }
        }
    ]
}
