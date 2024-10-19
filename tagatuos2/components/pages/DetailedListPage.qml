import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
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

    property bool isToday: Functions.isToday(dateViewPath.currentItem.fromDate)
    property bool isThisWeek: Functions.isThisWeek(dateViewPath.currentItem.fromDate)
    property bool isThisMonth: Functions.isThisMonth(dateViewPath.currentItem.fromDate)
    property bool isThisYear: Functions.isThisYear(dateViewPath.currentItem.fromDate)
    readonly property bool dateIsCurrent: (isToday && isByDay) || (isThisWeek && isByWeek) || (isThisMonth && isByMonth)
    property string todayDate: Functions.getToday()
    readonly property string currentFromDate: dateViewPath.currentItem.fromDate
    readonly property string currentBaseDate: dateViewPath.baseDate
    readonly property string actualFromDate: currentFromDate ? Functions.getFromDate(scope, currentFromDate) : ""
    readonly property string actualToDate: currentFromDate ? Functions.getToDate(scope, currentFromDate) : ""
    readonly property int currentWeekday: isByDay ? Functions.getWeekDay(actualFromDate) : -1
    readonly property int currentMonth: isByMonth ? Functions.getMonth(actualFromDate) : -1
    readonly property int currentWeekOfYear: isByWeek ? Functions.getWeekOfYear(actualFromDate) : -1
    readonly property int currentMonthWeek: currentMonthStartWeek <= currentWeekOfYear ? currentWeekOfYear - currentMonthStartWeek
                                                    : currentYearWeekCount - currentMonthStartWeek + 1
    readonly property var currentMonthWeekData: isByWeek ? Functions.getWeekDataOfMonth(actualFromDate) : { startWeek: 0, endWeek: 0 }
    readonly property var currentMonthStartWeek: currentMonthWeekData.startWeek
    readonly property var currentMonthEndWeek: currentMonthWeekData.endWeek
    readonly property int currentYearWeekCount: Functions.getWeeksInYear(detailedListPage.actualFromDate)

    readonly property int todayWeekday: isByDay && isThisWeek ? Functions.getWeekDay(todayDate) : -1
    readonly property int todayMonth: isByMonth && isThisYear ? Functions.getMonth(todayDate) : -1
    readonly property int todayWeekOfYear: isByWeek ? Functions.getWeekOfYear(todayDate) : -1
    readonly property int todayMonthWeek: isByWeek && isThisMonth ? currentMonthStartWeek <= todayWeekOfYear ? todayWeekOfYear - currentMonthStartWeek
                                                                    : todayWeekOfYear - currentMonthStartWeek + 1
                                                     : -1

    readonly property bool isByMonth: scope == "month"
    readonly property bool isByDay: scope == "day"
    readonly property bool isByWeek: scope == "week"
    readonly property bool isAscending: order == "asc"
    readonly property bool isDescending: order == "desc"
    readonly property bool isSortByCategory: sort == "category"
    readonly property bool isSortByDate: sort == "date"

    property string currentCategory: "all"
    property string scope: "day"
    property string order: "asc"
    property string sort: "category"
    property bool coloredCategory: false
    property bool isTravelMode: false
    property bool isSearchMode: false
    property bool shownInNarrow: false
    property string travelCurrency

    flickable: dateViewPath.currentItem.view
    title: {
        let _profileName = mainView.profiles.currentName()
        if (isSearchMode) {
            return i18n.tr("Searching: %1").arg(_profileName)
        }

        return shownInNarrow ? _profileName : i18n.tr("Expenses")
    }
    focus: !mainView.newExpenseView.isOpen && mainView.sidePageIsOpen
    showBackButton: !isSearchMode

    signal refresh

    headerLeftActions: [ exitSearchAction ]
    headerRightActions: [ lastDataAction, nextDataAction, searchAction, sortAction, criteriaAction, todayAction, addAction ]

    function showInSearchMode() {
        if (mainView.sidePage) {
            mainView.sidePage.show()
            isSearchMode = true
        }
    }

    function focusSearchField() {
        expenseSearchView.focusSearchField()
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
        internal.setBaseDate(todayDate)
    }

    function goToLastData() {
        let lastDate = mainView.expenses.lastDateWithData(currentCategory, currentFromDate, scope)
        if (lastDate) {
            internal.setBaseDate(lastDate)
        } else {
            mainView.tooltip.display(i18n.tr("No older data"))
        }
    }

    function goToNextData() {
        let lastDate = mainView.expenses.nextDateWithData(currentCategory, currentFromDate, scope)
        if (lastDate) {
            internal.setBaseDate(lastDate)
        } else {
            mainView.tooltip.display(i18n.tr("No newer data"))
        }
    }

    onIsSearchModeChanged: {
        if (!isSearchMode) {
            dateViewPath.forceActiveFocus()
        }
    }

    Common.BaseAction {
        id: addAction

        text: i18n.tr("New Expense")
        shortText: i18n.tr("New")
        iconName: "add"
        shortcut: StandardKey.New
        visible: !detailedListPage.isSearchMode
        enabled: visible

        onTrigger: newEntry()
    }

    Common.BaseAction {
        id: exitSearchAction

        text: i18n.tr("Exit")
        iconName: "back"
        shortcut: StandardKey.Cancel
        visible: detailedListPage.isSearchMode
        enabled: detailedListPage.focus && detailedListPage.visible && visible

        onTrigger: detailedListPage.isSearchMode = false
    }

    Common.BaseAction {
        id: searchAction

        text: i18n.tr("Search")
        iconName: "find"
        shortcut: StandardKey.Find
        visible: detailedListPage.isSearchMode ? !expenseSearchView.searchFieldIsFocused : true
        enabled: detailedListPage.focus && detailedListPage.visible && visible

        onTrigger: {
            detailedListPage.isSearchMode = true
            expenseSearchView.focusSearchField()
        }
    }

    Common.BaseAction {
        id: todayAction

        text: i18n.tr("View Today")
        shortText: i18n.tr("Today")
        iconName: "calendar-today"
        visible: ((detailedListPage.isByDay && !detailedListPage.isToday)
                        || (detailedListPage.isByMonth && !detailedListPage.isThisMonth)
                        || (detailedListPage.isByWeek && !detailedListPage.isThisWeek)
                 )
                    && !detailedListPage.isSearchMode

        onTrigger: goToday()
    }

    Common.BaseAction {
        id: nextAction

        enabled: detailedListPage.focus && detailedListPage.visible && !detailedListPage.isSearchMode
        text: i18n.tr("Next")
        iconName: "go-next"
        shortcut: StandardKey.MoveToNextChar

        onTrigger: next()
    }

    Common.BaseAction {
        id: previousAction

        enabled: detailedListPage.focus && detailedListPage.visible && !detailedListPage.isSearchMode
        text: i18n.tr("Previous")
        iconName: "go-previous"
        shortcut: StandardKey.MoveToPreviousChar

        onTrigger: previous()
    }

    Common.BaseAction {
        id: lastDataAction

        enabled: detailedListPage.focus && detailedListPage.visible && !detailedListPage.isSearchMode
        onlyShowInBottom: true
        text: i18n.tr("View Last Data")
        iconName: "go-first"
        shortcut: StandardKey.MoveToPreviousWord

        onTrigger: goToLastData()
    }

    Common.BaseAction {
        id: nextDataAction

        enabled: detailedListPage.focus && detailedListPage.visible && !detailedListPage.isSearchMode
        onlyShowInBottom: true
        text: i18n.tr("View Next Data")
        iconName: "go-last"
        shortcut: StandardKey.MoveToNextWord

        onTrigger: goToNextData()
    }

    Common.BaseAction {
        id: criteriaAction

        enabled: detailedListPage.focus && detailedListPage.visible && !detailedListPage.isSearchMode
        onlyShowInBottom: true
        text: i18n.tr("Sort and Filter")
        shortText: i18n.tr("Sort")
        iconName: "filters"

        onTrigger: navigationRow.criteria()
    }

    Common.BaseAction {
        id: sortAction

        text: expenseSearchView.isAscending ? i18n.tr("Ascending") : i18n.tr("Descending")
        shortText: expenseSearchView.isAscending ? i18n.tr("Asc") : i18n.tr("Desc")
        iconName: "calendar"
        visible: detailedListPage.isSearchMode && !expenseSearchView.isEmpty

        onTrigger: expenseSearchView.toggleDateSort()
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

        onTrigger: {
            mainView.newExpenseView.openInEditMode(contextMenu.itemData)
        }
    }

    Common.BaseAction {
        id: goToDateAction

        text: i18n.tr("View this day")
        iconName: "go-last"
        visible: contextMenu.isFromSearch

        onTrigger: {
            detailedListPage.scope = "day"
            exitSearchAction.triggered()
            internal.setBaseDate(contextMenu.itemData.entryDate)
        }
    }

    Common.BaseAction {
        id: createNewExpenseAction

        text: i18n.tr("New expense")
        iconName: "add"
        visible: contextMenu.isFromSearch

        onTrigger: {
            mainView.newExpenseView.openInEntryMode(contextMenu.itemData)
        }
    }

    Common.BaseAction {
        id: searchSeparatorAction

        visible: contextMenu.isFromSearch
        separator: true
    }

    Common.BaseAction {
        id: deleteAction

        text: i18n.tr("Delete")
        iconName: "delete"

        onTrigger: {
            let _popup = deleteExpenseDialogComponent.createObject(mainView.mainSurface, { expenseData: contextMenu.itemData })
            _popup.proceed.connect(function() {
                let _tooltipMsg

                if (mainView.expenses.delete(contextMenu.itemData.expenseID, contextMenu.itemData.entryDate)) {
                    _tooltipMsg = i18n.tr("Expense deleted")
                } else {
                    _tooltipMsg = i18n.tr("Deletion failed")
                }
                
                mainView.tooltip.display(_tooltipMsg)
            })

            _popup.openDialog();
        }
    }

    Common.BaseAction {
        id: separatorAction

        separator: true
    }

    Component {
        id: deleteExpenseDialogComponent

        Components.DeleteExpenseDialog {}
    }

    Menus.ContextMenu {
        id: contextMenu

        readonly property Components.ExpenseData itemData: Components.ExpenseData {
            id: expenseDataObj
        }
        property bool isFromSearch: false

        actions: [ deleteAction, separatorAction, editAction, searchSeparatorAction, goToDateAction, createNewExpenseAction ]
        listView: isFromSearch ? expenseSearchView.view : dateViewPath.currentItem.view

        onClosed: isFromSearch = false
    }
    
    CriteriaPopup {
        id: criteriaPopup

        activeCategory: detailedListPage.currentCategory
        dateValue: new Date(dateViewPath.currentItem.fromDate)
        sort: detailedListPage.sort
        scope: detailedListPage.scope
        order: detailedListPage.order
        coloredCategory: detailedListPage.coloredCategory

        function rebindValues() {
            dateValue = Qt.binding(function() { return new Date(detailedListPage.currentFromDate) } )
            activeCategory = Qt.binding(function() { return detailedListPage.currentCategory } )
            sort = Qt.binding(function() { return detailedListPage.sort } )
            scope = Qt.binding(function() { return detailedListPage.scope } )
            order = Qt.binding(function() { return detailedListPage.order } )
            coloredCategory = Qt.binding(function() { return detailedListPage.coloredCategory } )
        }

        onSelect: {
            let _refreshNeeded = false

            if (detailedListPage.currentCategory !== selectedCategory
                    || detailedListPage.order != selectedOrder
                    || detailedListPage.sort != selectedSort
                    || detailedListPage.scope != selectedScope) {
                _refreshNeeded = true
            }
            detailedListPage.currentCategory = selectedCategory
            detailedListPage.sort = selectedSort
            detailedListPage.scope = selectedScope
            detailedListPage.order = selectedOrder
            detailedListPage.coloredCategory = selectedColoredCategory
            internal.setBaseDate(Functions.formatDateForDB(selectedDate))

            if (_refreshNeeded) {
                detailedListPage.refresh()
            }

            // Rebind values
            rebindValues()
        }

        onRejected: rebindValues()
    }
    
    Connections {
        target: mainView

        onCurrentDateChanged: {
            navigationRow.labelRefresh()

            // Rebind values when current date changed
            detailedListPage.todayDate = mainView.currentDate
            detailedListPage.isToday = Qt.binding( function() { return Functions.isToday(dateViewPath.currentItem.fromDate) } )
            detailedListPage.isThisWeek = Qt.binding( function() { return Functions.isThisWeek(dateViewPath.currentItem.fromDate) } )
            detailedListPage.isThisMonth = Qt.binding( function() { return Functions.isThisMonth(dateViewPath.currentItem.fromDate) } )
            detailedListPage.isThisYear = Qt.binding( function() { return Functions.isThisYear(dateViewPath.currentItem.fromDate) } )
        }
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
                spacing: 0

                ValuesNavigationRow {
                    id: navigationRow

                    property bool allowExpandChanged: true

                    // TODO: Replace using the 'date' property
                    // Updates long label
                    function labelRefresh() {
                        dateTitle = Qt.binding(function() { return Functions.formatDateForNavigation(detailedListPage.currentFromDate, detailedListPage.scope) })
                    }

                    date: detailedListPage.currentFromDate
                    scope: detailedListPage.scope
                    dateIsCurrent: detailedListPage.dateIsCurrent
                    category: detailedListPage.currentCategory

                    Component.onCompleted: labelRefresh()

                    Layout.fillWidth: true
                    Layout.preferredHeight: isExpanded ? Suru.units.gu(12) : Suru.units.gu(4)
                    Layout.margins: Suru.units.gu(1)
                    z: 1

                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            easing: Suru.animations.EasingOut
                            duration: Suru.animations.SnapDuration
                        }
                    }

                    Connections {
                        target: detailedListPage

                        onFlickableChanged: navigationRow.isExpanded = true
                    }

                    Timer {
                        id: expandDelay

                        running: false
                        interval: 50
                        onTriggered: navigationRow.allowExpandChanged = true
                    }

                    Connections {
                        target: detailedListPage.flickable

                        onVerticalVelocityChanged: {
                            if (navigationRow.allowExpandChanged && target.moving) {
                                if (target.verticalVelocity > 0) {
                                    if (navigationRow.isExpanded) {
                                        navigationRow.allowExpandChanged = false
                                    }
                                    navigationRow.isExpanded = false
                                } else if (target.verticalVelocity < 0) {
                                    if (!navigationRow.isExpanded) {
                                        navigationRow.allowExpandChanged = false
                                    }
                                    navigationRow.isExpanded = true
                                } else {
                                    navigationRow.allowExpandChanged = true
                                }
                            } else {
                                expandDelay.restart()
                            }
                        }

                        onContentYChanged: {
                            if (target.contentY == target.originY) {
                                navigationRow.isExpanded = true
                            }
                        }

                        onContentHeightChanged: {
                            if (target.contentHeight < target.height - target.topMargin - target.bottomMargin) {
                                navigationRow.isExpanded = true
                            }
                        } 
                    }

                    onCriteria: criteriaPopup.openPopup()
                    onNext: nextAction.triggered()
                    onPrevious: previousAction.triggered()
                    onNextData: nextDataAction.triggered()
                    onPreviousData: lastDataAction.triggered()
                }
            }
        }

        Components.TagsList {
            id: tagsFlow

            Layout.fillWidth: true
            Layout.leftMargin: Suru.units.gu(3)
            Layout.rightMargin: Suru.units.gu(3)
            Layout.margins: Suru.units.gu(2)

            readonly property var tagsList: mainView.settings.tagOfTheDay !== "" ? mainView.settings.tagOfTheDay.split(",") : []

            model: tagsList
            visible: opacity > 0
            opacity: detailedListPage.isToday && mainView.settings.tagOfTheDayDate !== "" && Functions.isToday(mainView.settings.tagOfTheDayDate) ? 1 : 0
            spacing: Suru.units.gu(1)

            Behavior on opacity { NumberAnimation { easing: Suru.animations.EasingInOut; duration: Suru.animations.BriskDuration } }
        }

        Common.BasePathView {
            id: dateViewPath

            readonly property string baseDate: internal.internalBaseDate

            objectName: "dateViewPath"

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
                property string fromDate: {
                    switch (detailedListPage.scope) {
                        case "week":
                            return Functions.addDays(dateViewPath.baseDate, (dateViewPath.loopCurrentIndex + dateViewPath.indexType(index)) * 7, true)
                            break
                        case "month":
                            return Functions.addMonths(dateViewPath.baseDate, dateViewPath.loopCurrentIndex + dateViewPath.indexType(index), true)
                            break
                        case "day":
                        default:
                            return Functions.addDays(dateViewPath.baseDate, dateViewPath.loopCurrentIndex + dateViewPath.indexType(index), true)
                            break
                    }
                }
                property string toDate: fromDate

                height: parent.height
                width: parent.width

                function loadData() {
                    listView.model.load(detailedListPage.currentCategory, detailedListPage.scope, fromDate, fromDate, detailedListPage.sort, detailedListPage.order)
                }

                onFromDateChanged: loadData()

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
                    bottomMargin: summaryValues.visible && !summaryValues.isExpanded
                                        ? summaryValues.height + summaryValues.anchors.bottomMargin
                                                + indicatorSelectorLoader.height + indicatorSelectorLoader.anchors.bottomMargin
                                        : 0
                    pageHeader: detailedListPage.pageManager.pageHeader
                    z: 0
                    boundsBehavior: Flickable.DragOverBounds
                    focus: true
                    currentIndex: -1
                    visible: model.ready

                    // Do not use default since we have controls at the bottom that should be behind the scroll positioner
                    enableScrollPositioner: false

                    section.property: {
                        if (detailedListPage.isSortByCategory) {
                            return detailedListPage.currentCategory === "all" ? "group_id" : ""
                        } else if(detailedListPage.isSortByDate && !detailedListPage.isByDay) {
                            return "group_id"
                        } else {
                            return ""
                        }
                    }
                    section.delegate: ValuesSectionDelegate {
                        type: detailedListPage.sort
                        coloredCategory: detailedListPage.coloredCategory
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

                    ValuesSectionDelegate {
                        visible: listView.currentSection !== "" && listView.count > 0
                        type: detailedListPage.sort
                        coloredCategory: detailedListPage.coloredCategory
                        sectionObj: listView.currentSection
                        view: dateViewPath
                        displayTravelTotal: summaryValues.isTravelMode && summaryValues.onlyOneTravelTotal
                                                    && summaryValues.currentTravelCurrency == travelCurrency
                        travelCurrency: summaryValues.theOnlyTravelCurrency
                        height: Suru.units.gu(5)
                        topMargin: Suru.units.gu(1)

                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                    }

                    model: mainView.mainModels.detailedListModels[index]

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
                        categoryName: model.category_name
                        tags: model.tags
                        highlighted: listView.currentIndex == index
                        showDate: detailedListPage.isByMonth || detailedListPage.isByWeek || detailedListPage.isSortByDate
                        showCategory: detailedListPage.isSortByDate
                        coloredCategory: detailedListPage.coloredCategory

                        onShowContextMenu: {
                            contextMenu.itemData.expenseID = expenseID
                            contextMenu.itemData.name = itemName
                            contextMenu.itemData.entryDate = entryDate
                            contextMenu.itemData.category = model.category_name
                            contextMenu.itemData.value = homeValue
                            contextMenu.itemData.tags = tags
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
            bottom: indicatorSelectorLoader.top
            bottomMargin: Suru.units.gu(2)
            horizontalCenter: parent.horizontalCenter
        }

        isTravelMode: detailedListPage.isTravelMode
        currentTravelCurrency: detailedListPage.travelCurrency
        opacity: dateViewPath.currentItem.view.moving ? 0.5 : 1
        valuesModel: dateViewPath.currentItem.model.summaryValues
        visible: dateViewPath.currentItem.model.ready && !dateViewPath.currentItem.isEmpty && dateViewPath.currentItem.model.count > 1

        Behavior on opacity { NumberAnimation { easing: Suru.animations.EasingInOut; duration: Suru.animations.BriskDuration } }
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

    Loader {
        id: indicatorSelectorLoader
        
        readonly property bool swipeSelectMode: item && item.swipeSelectMode
        readonly property bool isHovered: item && item.isHovered
        readonly property real defaultBottomMargin: Suru.units.gu(4)
        //bottomMargin for views
        readonly property real viewBottomMargin: item ? (swipeSelectMode ? item.storedHeightBeforeSwipeSelectMode : height) + indicatorSelectorLoader.defaultBottomMargin
                                                      : 0

        active: mainView.settings.enableFastDateScroll
        opacity: dateViewPath.currentItem.view.moving ? 0.5 : 1
        asynchronous: true
        height: item ? item.height : 0 // Since height doesn't reset when inactive
        focus: false
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            bottomMargin: (swipeSelectMode && !isHovered ? mainView.convertFromInch(0.3) : 0) + defaultBottomMargin
            leftMargin: Suru.units.gu(1)
            rightMargin: Suru.units.gu(1)
        }

        Behavior on anchors.bottomMargin { NumberAnimation { duration: Suru.animations.SnapDuration } }
        Behavior on opacity { NumberAnimation { easing: Suru.animations.EasingInOut; duration: Suru.animations.BriskDuration } }

        sourceComponent: Common.PageIndicatorSelector {
            swipeEnabled: !detailedListPage.pageManager.bottomGestureIsSwiping
            mouseHoverEnabled: !detailedListPage.pageManager.bottomGestureIsSwiping
            swipeHandlerOutsideMargin: 0
            indicatorSelectedWidth: Suru.units.gu(4)
            backgroundOpacity: 1
            model: {
                switch (true) {
                    case detailedListPage.isByWeek:
                        return weekList
                    case detailedListPage.isByMonth:
                        return monthsList
                    case detailedListPage.isByDay:
                    default:
                        return weekDaysList
                }
            }
            currentIndex: {
                switch (true) {
                    case detailedListPage.isByWeek:
                        return detailedListPage.currentMonthWeek
                    case detailedListPage.isByMonth:
                        return detailedListPage.currentMonth
                    case detailedListPage.isByDay:
                    default:
                        return detailedListPage.currentWeekday
                }
            }
            extraHighlightedIndex: {
                switch (true) {
                    case detailedListPage.isByWeek:
                        return detailedListPage.todayMonthWeek
                    case detailedListPage.isByMonth:
                        return detailedListPage.todayMonth
                    case detailedListPage.isByDay:
                    default:
                        return detailedListPage.todayWeekday
                }
            }

            onNewIndexSelected: {
                let _selectedIndex = newIndex
                let _date

                switch (true) {
                    case detailedListPage.isByWeek:
                        _date = Functions.getSpecificWeekOfYear(detailedListPage.currentFromDate, detailedListPage.currentMonthStartWeek + _selectedIndex)
                        break
                    case detailedListPage.isByMonth:
                        _date = Functions.getSpecificMonthOfYear(detailedListPage.currentFromDate, _selectedIndex)
                        break
                    case detailedListPage.isByDay:
                    default:
                        _date = Functions.getSpecificDayOfWeek(detailedListPage.currentFromDate, _selectedIndex)
                        break
                }

                internal.setBaseDate(_date)
            }
        }
        readonly property var weekDaysFullNameList: detailedListPage.isByDay ? Functions.weekDaysFullNameList() : []
        readonly property var weekDaysShortNameList: detailedListPage.isByDay ? Functions.weekDaysShortNameList() : []
        readonly property var weekDaysList: weekDaysFullNameList.length === 7 ? [
            { title: weekDaysFullNameList[0], shortText: weekDaysShortNameList[0] }
            , { title: weekDaysFullNameList[1], shortText: weekDaysShortNameList[1] }
            , { title: weekDaysFullNameList[2], shortText: weekDaysShortNameList[2] }
            , { title: weekDaysFullNameList[3], shortText: weekDaysShortNameList[3] }
            , { title: weekDaysFullNameList[4], shortText: weekDaysShortNameList[4] }
            , { title: weekDaysFullNameList[5], shortText: weekDaysShortNameList[5] }
            , { title: weekDaysFullNameList[6], shortText: weekDaysShortNameList[6] }
        ] : []

        readonly property var weekList: detailedListPage.isByWeek ? generateWeekList(detailedListPage.currentMonthStartWeek, detailedListPage.currentMonthEndWeek) : []
        readonly property var monthsList: [
            { title: i18n.tr("January"), shortText: i18n.tr("Ja") }
            , { title: i18n.tr("February"), shortText: i18n.tr("Fe") }
            , { title: i18n.tr("March"), shortText: i18n.tr("Mr") }
            , { title: i18n.tr("April"), shortText: i18n.tr("Ap") }
            , { title: i18n.tr("May"), shortText: i18n.tr("My") }
            , { title: i18n.tr("June"), shortText: i18n.tr("Jn") }
            , { title: i18n.tr("July"), shortText: i18n.tr("Jl") }
            , { title: i18n.tr("August"), shortText: i18n.tr("Au") }
            , { title: i18n.tr("September"), shortText: i18n.tr("Se") }
            , { title: i18n.tr("October"), shortText: i18n.tr("Oc") }
            , { title: i18n.tr("November"), shortText: i18n.tr("Nv") }
            , { title: i18n.tr("December"), shortText: i18n.tr("De") }
        ]

        function generateWeekList(_startWeek, _endWeek) {
            let _count = 0
            let _list = []

            if (_endWeek > _startWeek) {
                _count = _endWeek - _startWeek + 1
            } else {
                let _weeksInYear = detailedListPage.currentYearWeekCount
                _count = _weeksInYear - _startWeek + 2
            }

            for (let i = 0; i < _count; i++) {
                _list.push({ title: i18n.tr("Week %1").arg(i + 1), shortText: i + 1})
            }

            return _list
        }
    }

    Common.ScrollPositionerItem {
        id: scrollPositioner

        active: true
        target: dateViewPath.currentItem.view
        bottomMargin: summaryValues.visible && position == Common.ScrollPositionerItem.Position.Middle
                                ? summaryValues.height + Suru.units.gu(5) : Suru.units.gu(5)
        position: mainView.settings.scrollPositionerPosition
        buttonWidthGU: mainView.settings.scrollPositionerSize
    }
    
    ExpenseSearchView {
        id: expenseSearchView

        anchors.fill: parent
        visible: detailedListPage.isSearchMode
        model: mainView.mainModels.searchExpenseModel
        pageHeader: detailedListPage.pageManager.pageHeader
        isTravelMode: detailedListPage.isTravelMode
        travelCurrency: detailedListPage.travelCurrency
        contextMenu: contextMenu
        coloredCategory: detailedListPage.coloredCategory
    }

    QtObject {
        id: internal

        property string internalBaseDate: detailedListPage.todayDate

        function setBaseDate(_newBaseDate) {
            if (_newBaseDate == internalBaseDate) {
                dateViewPath.scrollToBegginer()
            } else {
                internalBaseDate = _newBaseDate
            }
        }
    }
}
