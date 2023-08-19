import QtQuick 2.12
import Lomiri.Components 1.3 as UT
//~ import QtQml.Models 2.2
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "newexpenseview"
import ".." as Components
import "../../common" as Common
import "../../common/gestures" as Gestures
import "../../library/functions.js" as Functions

FocusScope {
    id: newExpenseView

    readonly property bool resultsIsEmpty: quickListGridView.model.count == 0
                                                    && historyGridView.model.count == 0 && !searchDelay.running
    readonly property bool contextActionsShown: resultsIsEmpty || internal.forceContextActions
    readonly property bool isGridDisplay: displayType == QuickListGridView.GridType.Rectangle
    readonly property bool isOpen: internal.isOpen
    readonly property bool animating: showAnimation.running

    property alias view: mainFlickable
    property alias searchText: searchField.text
    property bool entryMode: false
    property bool searchMode: false
    property real dragDistance: 0
    property bool isWideLayout: false
    property int displayType: QuickListGridView.GridType.Rectangle

    focus: isOpen

    opacity: isOpen || dragDistance > 0 || animating ? 1 : 0
    visible: opacity > 0

    QtObject {
        id: internal

        readonly property bool tall: newExpenseView.height >= units.gu(80)
        readonly property real partialShowY: newExpenseView.height / 3

        property bool isOpen: false
        property bool partiallyShown: false
        property bool forceContextActions: false
        property Components.ExpenseData expenseData: expenseDataObj
        property int currentExpenseID: expenseData.expenseID

        function checkRequiredFields() {
            if (nameField.text.trim() == "") {
                nameField.forceActiveFocus()
                return false
            }

            if (valueField.text.trim() == "") {
                valueField.forceActiveFocus()
                return false
            }

            return true
        }

        function focusRelevantField() {
            if (nameField.text.trim() == "") {
                nameField.forceActiveFocus()
                return
            }

            categoryField.forceActiveFocus()
        }
    }

    Components.ExpenseData {
        id: expenseDataObj
    }

    function createNewExpense() {
        if (mainView.expenses.add(internal.expenseData)) {
            mainView.tooltip.display(i18n.tr("New expense added"))
            close()
        } else {
            mainView.tooltip.display(i18n.tr("New expense failed"))
        }
    }

    function switchToEntryMode() {
        entryMode = true
    }

    function exitEntryMode() {
        entryMode = false
        internal.expenseData.reset()
    }

    function save() {
        if (entryMode) {
            /*Commits the OSK*/
            mainView.keyboard.commit()

            if (!internal.checkRequiredFields()) {
                mainView.tooltip.display(i18n.tr("Please fill required fields"))
                return
            } else {
                let _txtName = nameField.text
                let _txtDescr = descriptionField.text
                let _txtCategory = categoryField.currentText
                let _realValue = valueField.text
                let _txtDate = Functions.getToday()

                if (!dateField.checked) {
                    _txtDate = Functions.formatDateForDB(dateField.dateValue)
                }

                internal.expenseData.reset()
                internal.expenseData.entryDate = _txtDate
                internal.expenseData.name = _txtName
                internal.expenseData.description = _txtDescr
                internal.expenseData.category = _txtCategory
                internal.expenseData.value = _realValue

//~                 var newExpense
//~                 var today = new Date(Process.getToday())
//~                 var txtDate = Process.dateFormat(0, dateLabel.date)
//~                 var realTravelValue

//~                 //Travel Data
//~                 var travelData

//~                 if(travelFields.visible){
//~                     var realRate = travelFields.rate
//~                     var txtHomeCur = travelFields.homeCurrency
//~                     var txtTravelCur = travelFields.travelCurrency

//~                     realTravelValue = parseFloat(valueTextField.text)
//~                     realValue = valueTextField.homeValue

//~                     travelData = {"rate": realRate, "homeCur": txtHomeCur, "travelCur": txtTravelCur, "value": realTravelValue}

//~                 }else{
//~                     realValue = parseFloat(valueTextField.text)
//~                 }

                if (internal.currentExpenseID > -1) {
//~                     var updatedItem = {
//~                         expense_id: root.itemID,
//~                         category_name: txtCategory,
//~                         name: txtName,
//~                         descr: txtDescr,
//~                         date: txtDate,
//~                         value: realValue,
//~                         travel: travelData
//~                     }
//~                     updateExpense(_data)
                    updateExpense()
                } else {
//~                     createNewExpense(_data)
                    createNewExpense()
                }
            }
        }
    }

    function reset() {
        view.resetScroll()
        view.focus = false        
        contextActionsListView.currentIndex = -1
        quickListGridView.currentIndex = -1
        historyGridView.currentIndex = -1
        dateField.checkState = Qt.Checked

        searchText = ""
        internal.isOpen = false
        internal.partiallyShown = false
        internal.forceContextActions = false
        searchMode = false
        exitEntryMode()
    }

    function openInSearchMode() {
        searchMode = true
        open()
    }

    function open() {
        if (searchMode) {
            focusInput()
            animateToFull()
        } else {
            if (internal.tall) {
                animateToPartial()
            } else {
                animateToFull()
            }
        }

        forceActiveFocus()
    }

    function close() {
        reset()
    }

    function animateToFull() {
        internal.partiallyShown = false
        showAnimation.to = 0
        showAnimation.restart()
    }

    function animateToPartial() {
        internal.partiallyShown = true
        searchMode = false
        showAnimation.to = height / 3
        showAnimation.restart()
    }

    function focusInput() {
        searchMode = true
        searchField.selectAll();
        searchField.forceActiveFocus()
    }

    onSearchModeChanged: {
        if (internal.partiallyShown && searchMode) {
            animateToFull()
        }
    }

    onEntryModeChanged: {
        if (entryMode) {
            if (internal.partiallyShown) {
                animateToFull()
            }

            internal.focusRelevantField()
        } else {
            // Remove focus from the entry fields
            mainFlickable.forceActiveFocus()
        }
    }

    Keys.onPressed: {
        switch (event.key) {
            case Qt.Key_Escape:
                closeAction.triggered()
                return;
            case Qt.Key_Right:
            case Qt.Key_Left:
            case Qt.Key_Down:
                mainFlickable.focus = true;
                break;
            case Qt.Key_Up:
                focusInput();
                break;
        }
        if (event.text.trim() !== "") {
            focusInput();
            searchText = event.text;
        }

        event.accepted = true;
    }

    Behavior on opacity {
        NumberAnimation {
            easing: Suru.animations.EasingIn
            duration: Suru.animations.SnapDuration
        }
    }

    Rectangle {
        visible: opacity > 0
        color: "black"
        anchors.fill: parent
        opacity: 0.8

        Behavior on opacity {
            NumberAnimation {
                easing: Suru.animations.EasingIn
                duration: Suru.animations.SnapDuration
            }
        }

        MouseArea {
            anchors.fill: parent
            preventStealing: true
            onClicked: newExpenseView.close()
        }
    }

    Label {
        Suru.textLevel: Suru.HeadingOne
        visible: opacity > 0
        opacity: height > Suru.units.gu(6) && !closeSwipeAreaLoader.dragging ? 1 : 0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: newExpenseView.searchMode || newExpenseView.entryMode ? i18n.tr("New Expense") : i18n.tr("Quick Expense")
        color: Suru.backgroundColor
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: mainLayout.top
        }

        Behavior on opacity {
            NumberAnimation {
                easing: Suru.animations.EasingIn
                duration: Suru.animations.SnapDuration
            }
        }
    }

    ColumnLayout {
        id: mainLayout

        readonly property real preferrredWidth: Suru.units.gu(100)

        y: {
            if (internal.isOpen) {
                if (closeSwipeAreaLoader.dragging) {
                    if (internal.partiallyShown) {
                        let _newValue = closeSwipeAreaLoader.distance + internal.partialShowY
                        return _newValue > 0 ? _newValue : 0
                    } else {
                        if (closeSwipeAreaLoader.distance >= 0) {
                            return closeSwipeAreaLoader.distance
                        }
                     }

                     return closeSwipeAreaLoader.distance
                 }

                 return showAnimation.to
             }

            return parent.height - newExpenseView.dragDistance
        }

        height: newExpenseView.entryMode ? parent.height - mainView.keyboardRectangle.height : parent.height
        width: Math.min(preferrredWidth, parent.width)
        anchors.horizontalCenter: parent.horizontalCenter
        
        NumberAnimation on y {
            id: showAnimation

            running: false
            to: 0
            easing: Suru.animations.EasingOut
            duration: Suru.animations.SnapDuration
            onStopped: internal.isOpen = true
        }
        
        Behavior on y {
            enabled: newExpenseView.dragDistance == 0 && internal.isOpen
            NumberAnimation {
                easing: Suru.animations.EasingOut
                duration: Suru.animations.SnapDuration
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.margins: Suru.units.gu(1)
            Layout.topMargin: searchField.visible ? Suru.units.gu(5) : 0
            Layout.preferredHeight: searchField.visible ? searchField.height : 0

            Behavior on Layout.topMargin {
                NumberAnimation {
                    easing: Suru.animations.EasingOut
                    duration: Suru.animations.SnapDuration
                }
            }

            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    easing: Suru.animations.EasingOut
                    duration: Suru.animations.SnapDuration
                }
            }

            TextField {
                id: searchField

                Layout.fillWidth: true

                visible: newExpenseView.searchMode && !newExpenseView.entryMode
                placeholderText: i18n.tr("Enter expense name")
                inputMethodHints: Qt.ImhNoPredictiveText

                KeyNavigation.down: internal.contextActionsShown ? contextActionsListView 
                                                : quickListGridView.count > 0 ? quickListGridView : historyGridView

                focus: visible
                onTextChanged: {
                    var trimmedText = text.trim()
                    internal.forceContextActions = false

                    if (trimmedText) {
                        if (text.substr(text.length - 2) == "  ") { // Trailing double space
                            internal.forceContextActions = true
                        }
                    }

                    if (text.charAt(text.length - 1) == " ") { // Trailing single space
                        searchDelay.triggered()
                    } else {
                        searchDelay.restart()
                    }
                }
    //~             onAccepted: tabslist.selectFirstItem()
    //~             onActiveFocusChanged: {
    //~                 if (activeFocus) {
    //~                     tabslist.searchMode = true
    //~                 }

    //~                 if (KeyNavigation.down == tabslist.view) {
    //~                     tabslist.view.processFocusChange()
    //~                 }
    //~             }

                Timer {
                    id: searchDelay
                    interval: 300
                    onTriggered: {
                        let _trimmedText = searchField.text.trim()
                        mainFlickable.resetScroll()
                        quickListGridView.model.update(_trimmedText)
                        mainView.mainModels.historyEntryExpensesModel.searchText = _trimmedText
                    }
                }
            }
        }

        Flickable {
            id: mainFlickable
            
            readonly property real defaultTopMargin: Suru.units.gu(2)

            Layout.fillWidth: true
            Layout.fillHeight: true

            boundsBehavior: Flickable.DragOverBounds
            boundsMovement: Flickable.StopAtBounds
            clip: true
            topMargin: defaultTopMargin
            bottomMargin: toolbar.height
            contentHeight: contentsColumnLayout.height
            interactive: !internal.partiallyShown

            function resetScroll() {
                contentY = -defaultTopMargin
            }

            onMovingChanged: {
                if (moving && searchField.text.trim() == "" && !internal.tall && !newExpenseView.isWideLayout) {
                    newExpenseView.searchMode = false
                }
            }

            ColumnLayout {
                id: contentsColumnLayout

                anchors {
                    left: parent.left
                    right: parent.right
                }

                ColumnLayout {
                    Layout.fillHeight: false

                    visible: !newExpenseView.entryMode

                    ContextActionsListView {
                        id: contextActionsListView

                        Layout.fillWidth: true
                        Layout.margins: Suru.units.gu(1)
                        Layout.topMargin: 0
                        Layout.preferredHeight: contentHeight

                        visible: newExpenseView.contextActionsShown
                        focus: visible
                        isWideLayout: newExpenseView.isWideLayout

                        function requestExpense() {
                            internal.expenseData.reset()
                            internal.expenseData.entryDate = Functions.getToday()
                            internal.expenseData.name = searchField.text

                            newExpenseView.switchToEntryMode()
                        }

                        onRequestNewExpense: requestExpense()
                        onRequestNewQuickExpense: requestExpense()
                    }

                    QuickListGridView {
                        id: quickListGridView

                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight

                        gridType: newExpenseView.displayType
                        type: QuickListGridView.Type.QuickList
                        baseModel: mainView.mainModels.quickExpensesModel
                        expenseData: internal.expenseData

                        onRequestNewExpense: newExpenseView.switchToEntryMode()
                        onCreateNewExpense: newExpenseView.createNewExpense()
                        onRequestClose: newExpenseView.close()
                    }

                    QuickListGridView {
                        id: historyGridView

                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight

                        gridType: newExpenseView.displayType
                        type: QuickListGridView.Type.History
                        baseModel: mainView.mainModels.historyEntryExpensesModel
                        expenseData: internal.expenseData

                        onRequestNewExpense: newExpenseView.switchToEntryMode()
                        onCreateNewExpense: newExpenseView.createNewExpense()
                        onRequestClose: newExpenseView.close()
                    }
                }

                ColumnLayout {
                    Layout.fillHeight: false
                    Layout.topMargin: Suru.units.gu(5)
                    Layout.bottomMargin: Suru.units.gu(2)
                    Layout.leftMargin: Suru.units.gu(2)
                    Layout.rightMargin: Suru.units.gu(2)

                    spacing: Suru.units.gu(2)
                    visible: newExpenseView.entryMode

                    DateField {
                        id: dateField

//~                         readonly property bool dateModified: priv.editEntryDate != Functions.formatDateForDB(dateField.dateValue)

                        Layout.fillWidth: true
                    }

                    NameField {
                        id: nameField

                        Layout.fillWidth: true
                        flickable: mainFlickable
                        text: internal.expenseData.name
                    }

                    CategoryField {
                        id: categoryField

                        Layout.fillWidth: true
                        flickable: mainFlickable
                        currentIndex: internal.expenseData.category ? model.find(internal.expenseData.category, "value") : 0
                    }

                    ValueField {
                        id: valueField

                        Layout.fillWidth: true

                        flickable: mainFlickable
                        text: internal.expenseData.value == 0 ? "" : internal.expenseData.value
                    }

                    DescriptionField {
                        id: descriptionField

                        Layout.fillWidth: true
                        flickable: mainFlickable
                        text: internal.expenseData.description
                    }
                }
            }
        }
    }

    Loader {
        id: closeSwipeAreaLoader

        readonly property bool dragging: item && item.dragging
        readonly property real distance: item ? item.distance : 0
        readonly property int direction: item ? item.direction : -1

        asynchronous: true
        anchors.fill: mainLayout
        sourceComponent: Gestures.SwipeGestureHandler {
            readonly property int stageTrigger: {
                if (direction == UT.SwipeArea.Vertical) {
                    return usePhysicalUnit ? 3 : 2
                }

                return usePhysicalUnit ? 4 : 3
            }
            readonly property int stagePartialTrigger: internal.tall ? usePhysicalUnit ? 2 : 1
                                                                : 99 // Trigger for switching to partial show

            enabled: newExpenseView.view.contentY == -newExpenseView.view.defaultTopMargin
            direction: internal.partiallyShown ? UT.SwipeArea.Vertical : UT.SwipeArea.Downwards
            immediateRecognition: false
            usePhysicalUnit: true

            onStageChanged: {
                if (stage == stageTrigger && !newExpenseView.entryMode) Common.Haptics.play()
                if (stage == stagePartialTrigger && !internal.partiallyShown) Common.Haptics.playSubtle()
            }

            onDraggingChanged: {
                if (!dragging) {
                    if (direction == UT.SwipeArea.Downwards) {
                        if (towardsDirection) {
                            if (stage >= stageTrigger && !newExpenseView.entryMode) {
                                newExpenseView.close()
                            } else if (stage >= stagePartialTrigger) {
                                if (distance > 0) {
                                    newExpenseView.animateToPartial()
                                }
                            }
                        }
                    } else if (direction == UT.SwipeArea.Vertical) {
                        if (stage >= stageTrigger) {
                            if (distance > 0 && towardsDirection && !newExpenseView.entryMode) {
                                newExpenseView.close()
                            } else if (distance < 0) {
                                newExpenseView.animateToFull()
                            }
                        }
                    }
                }
            }
        }
    }

    QuickListToolbar {
        id: toolbar

        anchors {
            left: mainLayout.left
            right: mainLayout.right
        }

        states: [
            State {
                name: "default"
                AnchorChanges {
                    target: toolbar
                    anchors.bottom: undefined
                }
            }
            , State {
                name: "anchored"
                when: newExpenseView.entryMode
                AnchorChanges {
                    target: toolbar
                    anchors.bottom: mainLayout.bottom
                }
            }
        ]
        height: Suru.units.gu(7)

        state: internal.isOpen ? "shown" : "hidden"

        leftActions: [ closeAction ]

        rightActions: [
            Common.BaseAction {
                text: newExpenseView.isGridDisplay ? i18n.tr("Show list") : i18n.tr("Show grid")
                shortText: newExpenseView.isGridDisplay ? i18n.tr("List") : i18n.tr("Grid")
                icon.name: newExpenseView.isGridDisplay ? "view-list-symbolic" : "view-grid-symbolic"
                visible: !newExpenseView.entryMode

                onTrigger: {
                    if (newExpenseView.isGridDisplay) {
                        newExpenseView.displayType = QuickListGridView.GridType.List
                    } else {
                        newExpenseView.displayType = QuickListGridView.GridType.Rectangle
                    }
                }
            }
            , Common.BaseAction {
                text: i18n.tr("Save")
                iconName: "save"
                visible: newExpenseView.entryMode

                onTrigger: newExpenseView.save();
            }
            , Common.BaseAction {
                text: i18n.tr("Search or create new expense")
                iconName: "compose"
                visible: !newExpenseView.entryMode

                onTrigger: newExpenseView.focusInput();
            }
        ]
    }

    Common.BaseAction {
        id: closeAction

        text: newExpenseView.entryMode ? i18n.tr("Cancel") : i18n.tr("Close")
        iconName: newExpenseView.entryMode ? "cancel" : "close"

        onTrigger: {
            if (newExpenseView.entryMode) {
                newExpenseView.exitEntryMode()
            } else {
                newExpenseView.close()
            }
        }
    }
}
