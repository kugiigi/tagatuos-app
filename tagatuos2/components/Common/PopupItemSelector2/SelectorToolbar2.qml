import QtQuick 2.9
import Lomiri.Components 1.3
import ".."

Toolbar {
    id: toolBar

    anchors {
        left: parent.left
        right: parent.right
        bottom: parent.bottom
    }

    height: units.gu(6)

    style: Rectangle{
        color: theme.palette.normal.foreground
    }

    Component {
        id: buttonDelegate
        ActionButtonDelegate {
        }
    }

    leadingActionBar {
        actions: [
            Action {
                id: cancelAction

                property color color: theme.palette.normal.foreground

                text: i18n.tr("Cancel")
                iconName: "cancel"
                onTriggered: {
                    root.close()
                }
            }
        ]

        delegate: buttonDelegate
    }

    trailingActionBar {
        actions: [
            Action {
                id: saveAction

                property color color: theme.palette.normal.foreground

                iconName: "ok"
                text: i18n.tr("OK")
                onTriggered: {
                    root.confirmSelection(itemSelector.getReturnValue(),
                                          itemSelector.geValuesOrder())
                }
            }
        ]
        delegate: buttonDelegate
    }
}
