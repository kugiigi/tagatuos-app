import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import Lomiri.Components 1.3 as UT
import QtQuick.Layouts 1.12
import "detailedlistpage"
import ".." as Components
import "../../common" as Common
import "../../common/pages" as Pages
import "../../common/menus" as Menus
import "../../common/dialogs" as Dialogs
import "../../library/functions.js" as Functions

Pages.BasePage {
    id: detailedListPage

    readonly property bool isToday: Functions.isToday(dateViewPath.currentItem.fromDate)
    readonly property string currentFromDate: dateViewPath.currentItem.fromDate
    readonly property string currentBaseDate: dateViewPath.baseDate

    property string currentCategory: "all"
    property string scope: "day"
    property bool isTravelMode: false
    property string travelCurrency

    flickable: dateViewPath.currentItem.view
    title: mainView.profiles.currentName()
    focus: !mainView.newExpenseView.isOpen

    signal refresh

//~     headerRightActions: [addAction, todayAction, lastDataAction, nextDataAction, sortAction, profilesAction]
//~     headerRightActions: [addAction, todayAction, lastDataAction, nextDataAction]
    headerRightActions: [ addAction, todayAction ]

    Connections {
        target: mainView.settings
        onActiveProfileChanged: {
            refresh()
        }
    }

    function next() {
        dateViewPath.incrementCurrentIndex()
    }

    function previous() {
        dateViewPath.decrementCurrentIndex()
    }

    function newEntry() {
        mainView.newExpenseView.openInSearchMode()
    }
    
    function goToday() {
        if (scope == "day") {
            internal.setBaseDate(Functions.getToday())
        }
    }

    function goToLastData() {
        let lastDate = mainView.expenses.lastDateWithData(currentCategory, currentFromDate)
        if (lastDate) {
            internal.setBaseDate(lastDate)
        } else {
            mainView.tooltip.display(i18n.tr("No older data"))
        }
    }

    function goToNextData() {
        let lastDate = mainView.expenses.nextDateWithData(currentCategory, currentFromDate)
        if (lastDate) {
            internal.setBaseDate(lastDate)
        } else {
            mainView.tooltip.display(i18n.tr("No newer data"))
        }
    }

    Common.BaseAction {
        id: addAction

        text: i18n.tr("New Entry")
        shortText: i18n.tr("New")
        iconName: "add"
        shortcut: StandardKey.New

        onTrigger: newEntry()
    }

    Common.BaseAction {
        id: todayAction

        text: i18n.tr("View Today")
        shortText: i18n.tr("Today")
        iconName: "calendar-today"
        visible: !detailedListPage.isToday

        onTrigger: goToday()
    }

    Common.BaseAction {
        id: nextAction

        enabled: detailedListPage.focus
        text: i18n.tr("Next")
        iconName: "go-next"
        shortcut: StandardKey.MoveToNextChar
        onTrigger: next()
    }

    Common.BaseAction {
        id: previousAction

        enabled: detailedListPage.focus
        text: i18n.tr("Previous")
        iconName: "go-previous"
        shortcut: StandardKey.MoveToPreviousChar
        onTrigger: previous()
    }

    Common.BaseAction {
        id: lastDataAction

        enabled: detailedListPage.focus
        text: i18n.tr("View Last Data")
        iconName: "go-first"
        shortcut: StandardKey.MoveToPreviousWord

        onTrigger: goToLastData()
    }

    Common.BaseAction {
        id: nextDataAction

        enabled: detailedListPage.focus
        text: i18n.tr("View Next Data")
        iconName: "go-last"
        shortcut: StandardKey.MoveToNextWord

        onTrigger: goToNextData()
    }

    Common.BaseAction {
        id: sortAction

        text: i18n.tr("Sort")
        iconName: "sort-listitem"
        visible: false

        onTrigger:{}
    }

    Common.BaseAction {
        id: profilesAction

        text: i18n.tr("Switch Profile")
        iconName: "account"

        onTrigger: profilesPopup.openPopup()
    }

    Common.BaseAction {
        id: editAction

        text: i18n.tr("Edit")
        iconName: "edit"

        onTrigger:{
            mainView.newExpenseView.openInEditMode(contextMenu.itemData)
        }
    }

    Common.BaseAction {
        id: deleteAction

        text: i18n.tr("Delete")
        iconName: "delete"

        onTrigger: {
            let _popup = deleteExpenseDialogComponent.createObject(detailedListPage, { expenseData: contextMenu.itemData })
            _popup.proceed.connect(function() {
                let _tooltipMsg

                if (mainView.expenses.delete(contextMenu.itemData.expenseID, contextMenu.itemData.entryDate)) {
                    _tooltipMsg = i18n.tr("Expense deleted")
                } else {
                    _tooltipMsg = i18n.tr("Deletion failed")
                }
                
                mainView.tooltip.display(_tooltipMsg)
            })
            _popup.openBottom();
        }
    }

    Common.BaseAction {
        id: separatorAction

        separator: true
    }

    Component {
        id: deleteExpenseDialogComponent

        Components.DeleteExpenseDialog {
            
        }
    }

    Menus.ContextMenu {
        id: contextMenu

        readonly property Components.ExpenseData itemData: Components.ExpenseData {
            id: expenseDataObj
        }

        actions: [ editAction, separatorAction, deleteAction ]
        listView: dateViewPath.currentItem.view
    }
    
    CriteriaPopup {
        id: criteriaPopup

        activeCategory: detailedListPage.currentCategory
        dateValue: new Date(dateViewPath.currentItem.fromDate)
        onSelect: {
            detailedListPage.currentCategory = selectedCategory
            internal.setBaseDate(Functions.formatDateForDB(selectedDate))
            detailedListPage.refresh()
            dateValue = Qt.binding(function() { return new Date(detailedListPage.currentFromDate) } )
        }
    }

    UT.LiveTimer {
        frequency: UT.LiveTimer.Hour
        onTrigger: navigationRow.labelRefresh()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            z: 1
            Layout.fillWidth: true
            implicitHeight: navigationRowLayout.height
            color: Suru.backgroundColor

            ColumnLayout {
                id: navigationRowLayout

                anchors {
                    left: parent.left
                    right: parent.right
                }

                ValuesNavigationRow {
                    id: navigationRow

                    function labelRefresh() {
                        dateTitle = Qt.binding(function() { return Functions.relativeDate(detailedListPage.currentFromDate,"ddd, MMM DD", "Basic") })
                    }

                    Component.onCompleted: labelRefresh()

                    Layout.fillWidth: true
                    Layout.preferredHeight: Suru.units.gu(10)
                    Layout.margins: Suru.units.gu(1)
                    z: 1

                    biggerDateLabel: detailedListPage.currentCategory === "all"
                    itemTitle: detailedListPage.currentCategory === "all" ? i18n.tr("All")
                                    : mainView.mainModels.categoriesModel.getItem(detailedListPage.currentCategory, "category_name").category_name

                    onCriteria: criteriaPopup.openPopup()
                    onNext: nextAction.triggered()
                    onPrevious: previousAction.triggered()
                    onNextData: nextDataAction.triggered()
                    onPreviousData: lastDataAction.triggered()
                }

                ToolSeparator {
                    id: separator
            
                    Layout.fillWidth: true
                    z: navigationRow.z
                    orientation: Qt.Horizontal
                    topPadding: 0
                    bottomPadding: 0
                }
            }
        }

        Common.BasePathView {
            id: dateViewPath

            readonly property string baseDate: internal.internalBaseDate

            objectName: "dateViewPath"

            Layout.topMargin: Suru.units.gu(1)
            Layout.fillWidth: true
            Layout.fillHeight: true

            onBaseDateChanged: {
                dateViewPath.scrollToBegginer()
            }

            delegate: Item {
                id: pathViewDelegate

                readonly property bool isEmpty: count === 0

                property alias model: listView.model
                property alias count: listView.count
                property alias view: listView
                property string fromDate: Functions.addDays(dateViewPath.baseDate, dateViewPath.loopCurrentIndex + dateViewPath.indexType(index), true)
                property string toDate: fromDate

                height: parent.height
                width: parent.width

                function loadData() {
                    listView.model.load(detailedListPage.currentCategory, detailedListPage.scope, fromDate, fromDate)
                }
                
                onFromDateChanged: {
                    loadData()
                }

                Connections {
                    target: detailedListPage
                    onRefresh: loadData()
                }

                Components.EmptyState {
                    id: emptyState
                   
                    anchors.centerIn: parent
                    title: i18n.tr("No data")
                    loadingTitle: i18n.tr("Loading data")
                    loadingSubTitle: i18n.tr("Please wait")
                    isLoading: !listView.model.ready
                    shown: pathViewDelegate.isEmpty || !listView.model.ready
                }

                Common.BaseListView {
                    id: listView

                    anchors.fill: parent
                    bottomMargin: summaryValues.visible && !summaryValues.isExpanded ? summaryValues.height + summaryValues.anchors.bottomMargin
                                                    : 0
                    pageHeader: detailedListPage.pageManager.pageHeader
                    z: 0
                    boundsBehavior: Flickable.DragOverBounds
                    focus: true
                    currentIndex: -1
                    visible: model.ready
                    section.property: detailedListPage.currentCategory === "all" ? "category_id" : ""
                    section.delegate: ValuesSectionDelegate {
                        sectionObj: section
                        view: dateViewPath
                        displayTravelTotal: summaryValues.isTravelMode && summaryValues.onlyOneTravelTotal
                                                    && summaryValues.currentTravelCurrency == travelCurrency
                        travelCurrency: summaryValues.theOnlyTravelCurrency
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                    }

                    model: mainView.mainModels.detailedListModels[index]

                    function getCategoryTotal(_categoryName) {
                        let _total = 0
                        for (let i = 0; i <= listView.model.count - 1; i++) {
                            let _current = listView.model.get(i)
                            if (_current.category_name == _categoryName) {
                                _total += _current.value
                            }
                        }
                        return _total
                    }

                    delegate: ValueListDelegate {
                        id: valuesListDelegate

                        anchors {
                            left: parent.left
                            right: parent.right
                            margins: units.gu(1)
                        }

                        isTravelMode: detailedListPage.isTravelMode
                        currentTravelCurrency: detailedListPage.travelCurrency
                        expenseID: model.expense_id
                        homeValue: model.value
                        homeCurrency: model.home_currency
                        travelValue: model.travel_value
                        travelCurrency: model.travel_currency
                        exchangeRate: model.rate
                        entryDate: model.entry_date
                        entryDateRelative: model.entry_date_relative
                        comments: model.descr
                        itemName: model.name
                        highlighted: listView.currentIndex == index

                        onShowContextMenu: {
                            contextMenu.itemData.expenseID = expenseID
                            contextMenu.itemData.name = itemName
                            contextMenu.itemData.entryDate = entryDate
                            contextMenu.itemData.category = model.category_name
                            contextMenu.itemData.value = homeValue
                            contextMenu.itemData.description = comments
                            contextMenu.itemData.travelData.rate = exchangeRate
                            contextMenu.itemData.travelData.homeCur = homeCurrency
                            contextMenu.itemData.travelData.travelCur = travelCurrency
                            contextMenu.itemData.travelData.value = travelValue

                            listView.currentIndex = index
                            contextMenu.popupMenu(valuesListDelegate, mouseX, mouseY)
                        }

                        onClicked: {
                            if (isExpandable) {
                                isExpanded = !isExpanded
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar { width: 10 }

                    NumberAnimation on opacity {
                        running: listView.count > 0
                        from: 0
                        to: 1
                        easing: Suru.animations.EasingInOut
                        duration: Suru.animations.BriskDuration
                    }
                }
            }
        }
    }

    SummaryValuesDelegate {
        id: summaryValues

        anchors {
            bottom: parent.bottom
            bottomMargin: Suru.units.gu(4)
            horizontalCenter: parent.horizontalCenter
        }

        isTravelMode: detailedListPage.isTravelMode
        currentTravelCurrency: detailedListPage.travelCurrency
        opacity: dateViewPath.currentItem.view.moving ? 0.5 : 1
        valuesModel: dateViewPath.currentItem.model.summaryValues
        visible: dateViewPath.currentItem.model.ready && !dateViewPath.currentItem.isEmpty && dateViewPath.currentItem.model.count > 1

        NumberAnimation on opacity {
            running: !dateViewPath.currentItem.isEmpty
            from: 0
            to: 1
            easing: Suru.animations.EasingInOut
            duration: Suru.animations.BriskDuration
        }

        Behavior on implicitHeight {
            NumberAnimation {
                duration: Suru.animations.FastDuration
                easing: Suru.animations.EasingOut
            }
        }
    }

    QtObject {
        id: internal

        property string internalBaseDate: Functions.getToday()

        function setBaseDate(_newBaseDate) {
            if (_newBaseDate == internalBaseDate) {
                dateViewPath.scrollToBegginer()
            } else {
                internalBaseDate = _newBaseDate
            }
        }
    }
}
