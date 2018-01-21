import QtQuick 2.4
import Ubuntu.Components 1.3
import "../ui"
import "../components/BottomEdge"
import "../components/Common"

BottomEdge {
    id: root

    preloadContent: true
    height: parent.height

    contentComponent: Item {
        width: root.width
        height: root.height * root.dragProgress

        InitialRectangle {
            opacity: root.status === BottomEdge.Committed ? 0 : 1
            z: 100
            anchors.fill: parent
            color: UbuntuColors.green
            text: i18n.tr("Add Expense")
            onOpacityChanged: {
                if (opacity === 0) {
                    if (root.activeRegion.objectName === "default_BottomEdgeRegion") {
                        if (addFullPageLoader.active) {
                            root.collapse()
                            root.contentItem.visible = false
                        }
                        mainPageStack.addExpense()
                    }
                }
            }
        }
    }

    hint {
        action: Action {
            text: i18n.tr("New Expense")
            iconName: "add"
            onTriggered: root.commit()
            shortcut: "Ctrl+N"
        }
//        status: "Locked"
    }

//    onCollapseCompleted: root.hint.status = "Locked"

    BottomEdgeRegion {
        id: quickAddRegion
        objectName: "quickadd"
        from: 0.0
        to: 0.4
        contentComponent: QuickAddPage {
            id: quickAddPage

            width: root.width
            height: root.status === BottomEdge.Committed ? root.height * quickAddRegion.to : root.height * root.dragProgress
            isContentShown: root.status === BottomEdge.Committed

            onClose: root.collapse()

            InitialRectangle {
                opacity: root.status === BottomEdge.Committed ? 0 : 1
                z: 100
                anchors.fill: parent
                color: UbuntuColors.blue
                text: i18n.tr("Quick Expense")
            }
        }
    }

    BottomEdgeRegion {
        objectName: "adddebt"
        from: 0.8
        to: 1.0
        contentComponent: AddDebtPage {
            id: addDebtPage

            width: root.width
            height: root.status === BottomEdge.Committed ? root.height : root.height
                                                           * root.dragProgress

            Button {
                text: "Close"
                height: units.gu(4)
                anchors {
                    left: parent.left
                    right: parent.right
                }
                onTriggered: {
                    root.collapse()
                }
            }

            InitialRectangle {
                opacity: root.status === BottomEdge.Committed ? 0 : 1
                z: 100
                anchors.fill: parent
                color: UbuntuColors.red
                text: i18n.tr("New Debt")
            }
        }
    }
}
