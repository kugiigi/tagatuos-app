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
        opacity: tempSettings.hideBottomHint ? 0 : 1
        action: Action {
            text: i18n.tr("New Expense")
            iconName: "add"
            onTriggered: root.commit()
            shortcut: "Ctrl+N"
        }
        status: mainView.showBottomEdgeHint ? BottomEdgeHint.Locked : BottomEdgeHint.Inactive
    }

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
        id: backRegion
        objectName: "backRegion"
        from: 0.0
        to: 0.0

        property int leadingActionsCount: mainPageStack.currentPage.header.leadingActionBar.actions.length
        property Action backAction

        onLeadingActionsCountChanged: {
                loadBackAction()
        }

        function loadBackAction() {

            backAction = null
            quickAddRegion.from = 0.0
            to = 0.0

            var leadingActionBarActions = mainPageStack.currentPage.header.leadingActionBar.actions

            if (leadingActionsCount > 0) {
                for (var i = 0; i < leadingActionBarActions.length; i++) {

                    if (leadingActionBarActions[i].visible
                            && leadingActionBarActions[i].iconName === "back") {
                        backAction = leadingActionBarActions[i]
                        quickAddRegion.from = 0.1
                        to = 0.1
                    }
                }
            }

        }

        contentComponent: Item{
            width: root.width
            height: root.status === BottomEdge.Committed ? root.height * backRegion.to : root.height * root.dragProgress

            InitialRectangle {
                opacity: root.status === BottomEdge.Committed ? 0 : 1
                z: 100
                anchors.fill: parent

                color: UbuntuColors.warmGrey
                text: i18n.tr("Back")
                onOpacityChanged: {
                    if (opacity === 0) {
                        if (root.activeRegion.objectName === "backRegion") {
                            backRegion.backAction.trigger()
                            root.collapse()
                            root.contentItem.visible = false
                        }
                    }
                }
            }
        }

    }


    // TODO: Removed temporarily since not yet implemented
//    BottomEdgeRegion {
//        objectName: "adddebt"
//        from: 0.8
//        to: 1.0
//        contentComponent: AddDebtPage {
//            id: addDebtPage

//            width: root.width
//            height: root.status === BottomEdge.Committed ? root.height : root.height
//                                                           * root.dragProgress

//            Button {
//                text: "Close"
//                height: units.gu(4)
//                anchors {
//                    left: parent.left
//                    right: parent.right
//                }
//                onTriggered: {
//                    root.collapse()
//                }
//            }

//            InitialRectangle {
//                opacity: root.status === BottomEdge.Committed ? 0 : 1
//                z: 100
//                anchors.fill: parent
//                color: UbuntuColors.red
//                text: i18n.tr("New Debt")
//            }
//        }
//    }
}
