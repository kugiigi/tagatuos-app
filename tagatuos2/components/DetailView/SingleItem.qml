import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems
import "../Common"
import "../../library/ApplicationFunctions.js" as AppFunctions
import "../../library/ProcessFunc.js" as Process

UbuntuListView {
    id: root

    readonly property int countLimit: 10
    property bool isOverLimit: model.count >  countLimit

    interactive: false
    height: model !== undefined ? isOverLimit ? units.gu(7) * (countLimit + 1) : units.gu(7) * model.count : 0
    clip: true
    currentIndex: -1
    //    highlight: Rectangle{
    //        color: theme.palette.highlighted.overlay
    //    }
    anchors {
        top: parent.top
        left: parent.left
        leftMargin: units.gu(1)
        right: parent.right
        rightMargin: units.gu(1)
    }

    delegate: SingleItemChild {
        id: singleItemChild

        //        height: units.gu(5)
        itemName: name
        itemValue: AppFunctions.formatMoney(value, false)
        itemDescr: descr
        itemDate: date
        actions: [
            Action {
                iconName: "info"
                text: i18n.tr("View Details")
                onTriggered: {
                    //console.log(expense_id)
//                    var expenseDetails = listModels.getExpenseDetails(
//                                expense_id)
//                    var itemName
//                    var category
//                    var description
//                    var date
//                    var value
//                    itemName = expenseDetails.name
//                    category = expenseDetails.category_name
//                    description = expenseDetails.descr
//                    date = Process.relativeDate(expenseDetails.date,
//                                                "ddd, MMM d, yyyy", "Basic")
//                    value = AppFunctions.formatMoney(expenseDetails.value,
//                                                     false)
//                    popupDialog.contentLoader.setSource("DetailsDialog.qml", {
//                                                            category: category,
//                                                            itemName: itemName,
//                                                            description: description,
//                                                            date: date,
//                                                            value: value
//                                                        })
                    //                        popupDialog.contentLoader.sourceComponent = detailsDialogComponent
//                    popupDialog.show()
                poppingDialog.show(singleItemChild)
                }
            },
            Action {
                iconName: "edit"
                text: i18n.tr("Edit")
                onTriggered: {
                    mainPageStack.editExpense(expense_id)
                    root.currentIndex = -1
                }
            },
            Action {
                iconName: "delete"
                text: i18n.tr("Delete")
                onTriggered: {
                    mainView.listModels.deleteItem(expense_id)
                    root.currentIndex = -1
                }
            }
        ]

        PoppingDialog {
            id: poppingDialog

            maxHeight: units.gu(40)
            maxWidth: units.gu(30)
            parent:  mainView

            delegate: DetailsDialog{
                id: detailsDialog

                category: singleItemChild.category
                itemName: singleItemChild.itemName
                description: singleItemChild.desc
                date: singleItemChild.date
                value: singleItemChild.value

                Component.onCompleted: {
                    var expenseDetails = listModels.getExpenseDetails(
                                expense_id)

                    itemName = expenseDetails.name
                    category = expenseDetails.category_name
                    description = expenseDetails.descr
                    date = Process.relativeDate(expenseDetails.date,
                                                "ddd, MMM d, yyyy", "Basic")
                    value = AppFunctions.formatMoney(expenseDetails.value,
                                                     false)
                }

                onClosed: poppingDialog.close()
            }
        }

        onActionActiveChanged: {
            if (actionActive) {
                root.currentIndex = index
            } else {
                root.currentIndex = -1
            }
        }
    }

    ListItems.ThinDivider {
        visible: expandItem.visible
        z:2
        anchors {
            top: expandItem.top
            left: parent.left
            right: parent.right
            leftMargin: units.gu(1)
            rightMargin: units.gu(1)
        }
    }

    ViewAllItem {
        id: expandItem
        height: units.gu(7)
        visible: root.isOverLimit ? true : false
        anchors {
            bottom: root.bottom
        }
    }
}
