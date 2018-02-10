import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../Common"
import "../DetailView"
import "../../library/DataProcess.js" as DataProcess
import "../../library/ApplicationFunctions.js" as AppFunctions

ListView {
    id: listView

    interactive: true
    model: mainView.listModels.modelQuickAdd
    snapMode: ListView.SnapToItem
    clip: true
    anchors {
        left: parent.left
        right: parent.right
        top: parent.top
        bottom: bottomBarNavigation.visible ? bottomBarNavigation.top : parent.bottom
    }

    delegate: QuickAddItem {
        id: quickAdditem

        itemName: quickname
        itemValue: AppFunctions.formatMoney(quickvalue, false)
        itemDescr: descr
        itemCategory: category_name
        itemDate: quickdate

        leadingActions: bottomBarNavigation.currentIndex === 1 ? leftListItemActions : null
        trailingActions: rightListItemActions

        onClicked: {
            addQuick(itemCategory, itemName, itemDescr, quickvalue)
        }

        ListItemActions {
            id: rightListItemActions
            actions: [
                Action {
                    iconName: "edit"
                    text: i18n.tr("Edit")
                    visible: bottomBarNavigation.currentIndex === 1
                    onTriggered: {
                        PopupUtils.open(addDialog, null, {mode: "edit", quickID: quick_id, itemName: quickname, itemValue: quickvalue,itemDescr: descr, itemCategory: category_name})
                    }
                },
                Action {
                    iconName: "message-new"
                    text: i18n.tr("Custom Add")
                    onTriggered: {
                        PopupUtils.open(addDialog, null, {mode: "custom", quickID: quick_id, itemName: quickname, itemValue: quickvalue,itemDescr: descr, itemCategory: category_name})
                    }
                }
                ,
                Action {
                    iconName: "info"
                    text: i18n.tr("Information")
                    visible: bottomBarNavigation.currentIndex === 0
                    onTriggered: {
                        poppingDialog.show(quickAdditem)
                    }
                }
            ]
        }
        PoppingDialog {
            id: poppingDialog

            maxHeight: units.gu(40)
            maxWidth: units.gu(30)
            parent:  mainView

            delegate: DetailsDialog{
                id: detailsDialog

                category: itemCategory
                itemName: quickAdditem.itemName
                description: itemDescr
                date: itemDate
                value: itemValue

                onClosed: poppingDialog.close()
            }
        }
        ListItemActions {
            id: leftListItemActions
            actions: [
                Action {
                    iconName: "delete"
                    text: i18n.tr("Delete")
                    onTriggered: {
                        DataProcess.deleteQuickExpense(quick_id)
                        mainView.listModels.deleteQuickItem(quick_id)
                    }
                }
            ]
        }
    }
}
