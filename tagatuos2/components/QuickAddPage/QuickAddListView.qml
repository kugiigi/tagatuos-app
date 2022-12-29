import QtQuick 2.9
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import "../Common"
//import "../DetailView"
import ".."
import "../../library/DataProcess.js" as DataProcess
import "../../library/ProcessFunc.js" as Process
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

    onActiveFocusChanged: {
        if(activeFocus){
            findToolBar.forceFocus()
        }
    }

    delegate: QuickAddItem {
        id: quickAdditem

        itemName: model.quickname
        itemValue: model.quickvalue //AppFunctions.formatMoney(quickvalue, false)
        itemDescr: model.descr
        itemCategory: model.category_name
        itemDate: model.quickdate
        itemTravelValue: model.travel_value
        itemRate: model.rate
        itemTravelCur: model.travelCur ? model.travelCur : ""
        itemHomeCur: model.homeCur ? model.homeCur : ""

        leadingActions: bottomBarNavigation.currentIndex === 1 ? leftListItemActions : null
        trailingActions: rightListItemActions

        onClicked: {
            addQuick(itemCategory, itemName, itemDescr, model.quickvalue, itemTravelValue, itemRate, itemHomeCur, itemTravelCur)
        }

        ListItemActions {
            id: rightListItemActions
            actions: [
                Action {
                    iconName: "edit"
                    text: i18n.tr("Edit")
                    visible: bottomBarNavigation.currentIndex === 1
                    onTriggered: {
                        PopupUtils.open(addDialog, null, {mode: "edit", quickID: model.quick_id, itemName: model.quickname, itemValue: model.quickvalue,itemDescr: model.descr, itemCategory: model.category_name})
                    }
                },
                Action {
                    iconName: "message-new"
                    text: i18n.tr("Custom Add")
                    onTriggered: {
                        var realValue
                        if(tempSettings.travelMode){
                            realValue = itemTravelValue > 0 ? itemTravelValue : model.quickvalue / tempSettings.exchangeRate
                        }else{
                            realValue = model.quickvalue
                        }

                        PopupUtils.open(addDialog, null, {mode: "custom", quickID: model.quick_id, itemName: model.quickname, itemValue: realValue,itemDescr: model.descr, itemCategory: model.category_name})
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

            delegate: DetailDialog{
                id: detailsDialog

                category: itemCategory
                itemName: quickAdditem.itemName
                description: itemDescr
                date: itemDate
                value: AppFunctions.formatMoney(itemValue, false)
                travelValue: itemTravelValue > 0 ? Process.formatMoney(itemTravelValue, itemTravelCur) : ""
                travelRate: itemRate > 0 ? itemRate : 0


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
                        DataProcess.deleteQuickExpense(model.quick_id)
                        mainView.listModels.deleteQuickItem(model.quick_id)
                    }
                }
            ]
        }
    }
}
