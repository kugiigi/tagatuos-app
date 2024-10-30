import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../.." as Components
import "../../pages/newexpenseview" as NewExpenseView
import "../../../common" as Common


Item {
    id: expenseSearchView

    readonly property alias searchText: searchField.text
    readonly property bool isEmpty: resultsListView.count == 0
    readonly property bool searchTextIsEmpty: searchField.text.trim() == ""
    readonly property bool searchFieldIsFocused: searchField.activeFocus
    readonly property ListView view: resultsListView
    readonly property bool isAscending: resultsListView.model.order == "asc"
    readonly property bool isDescending: resultsListView.model.order == "desc"

    property bool coloredCategory: false
    property bool isTravelMode: false
    property string travelCurrency: "USD"
    property alias model: resultsListView.model
    property alias pageHeader: resultsListView.pageHeader
    property var contextMenu

    function focusSearchField() {
        searchField.forceActiveFocus()
        searchField.selectAll()
    }

    function toggleDateSort() {
        if (resultsListView.model.order == "asc") {
            resultsListView.model.order = "desc"
        } else {
            resultsListView.model.order = "asc"
        }
    }

    onVisibleChanged: {
        if (visible) {
            focusSearchField()
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            bottomMargin: mainView.keyboardRectangle.height
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.margins: Suru.units.gu(1)
            Layout.bottomMargin: 0

            NewExpenseView.TagsField {
                id: searchField

                readonly property bool isTags: focusLabel.currentFocusType === 4

                Layout.fillWidth: true

                useCustomBackground: false
                iconName: ""
                enableTagsProcessing: isTags
                horizontalAlignment: isTags && hasTags ? Text.AlignHCenter : Text.AlignLeft
                listHorizontalAlignment: hasTags ? Text.AlignHCenter : Text.AlignLeft
                tagsListLeftMargin: focusLabel.width + Suru.units.gu(2)
                placeholderText: isTags ? i18n.tr("Add tags (Enter comma after each tag)") : i18n.tr("Type to search...")
                inputMethodHints: Qt.ImhNoPredictiveText
                leftPadding: isTags && hasTags ? Suru.units.gu(1) : tagsListLeftMargin

                KeyNavigation.down: resultsListView

                onIsTagsChanged: {
                    if (hasTags) clearTags()

                    if (isTags) {
                        searchField.text = ""
                    }
                }
                onTagsChanged: searchDelay.restart()
                onTextChanged: {
                    // Change focused search type when text is empty and the user pressed/entered space
                    if (text === " ") {
                        if (focusLabel.currentFocusType === 4) {
                            focusLabel.currentFocusType = 0
                        } else {
                            focusLabel.currentFocusType += 1
                        }
                        text = ""
                    } else {
                        if (!isTags) {
                            if (text.charAt(text.length - 1) == " ") { // Trailing single space
                                searchDelay.triggered()
                            } else {
                                searchDelay.restart()
                            }
                        }
                    }
                }

                Timer {
                    id: searchDelay
                    interval: 300
                    onTriggered: {
                        let _focus = focusLabel.model[focusLabel.currentFocusType].id
                        resultsListView.model.focus = _focus

                        // For some reason searchField.isTags isn't updated here yet
                        if (_focus === "tags") {
                            resultsListView.model.searchText = searchField.tags
                        } else {
                            let _trimmedText = searchField.text.trim()
                            resultsListView.model.searchText = _trimmedText
                        }
                    }
                }

                FocusedSearchLabel {
                    id: focusLabel

                    property bool clearTextWorkaround: false

                    anchors {
                        top: parent.top
                        topMargin: searchField.hasTags ? Suru.units.gu(1.5) : Suru.units.gu(0.5)
                        left: parent.left
                        leftMargin: Suru.units.gu(0.5)
                    }

                    onCurrentFocusTypeChanged: {
                        if (clearTextWorkaround) {
                            clearSpaceDelayTimer.restart()
                        } else {
                            if (searchField.text.trim() !== "") {
                                searchDelay.triggered()
                            }
                        }
                    }

                    onItemSelectedFromMenu: {
                        // WORKAROUND: Cursor text do not properly adjust when left padding changes
                        if (searchField.text.trim() !== "") {
                            // Change cursor position to solve the issue
                            let _currentPos = searchField.cursorPosition
                            searchField.cursorPosition = 1
                            searchField.cursorPosition = _currentPos
                        } else {
                            // Insert 2 space to trigger the movement of the cursor
                            // and then clear the text again with clearSpaceDelayTimer
                            focusLabel.clearTextWorkaround = true
                            searchField.text = "  "
                        }
                    }

                    Timer {
                        id: clearSpaceDelayTimer
                        interval: 1
                        onTriggered: {
                            focusLabel.clearTextWorkaround = false
                            searchField.text = ""
                        }
                    }
                }
            }
        }
        
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Components.EmptyState {
                id: emptyState
               
                anchors.centerIn: parent
                title: expenseSearchView.searchTextIsEmpty ? i18n.tr("Search your expenses") : i18n.tr("No results found")
                loadingTitle: i18n.tr("Searching expenses...")
                loadingSubTitle: i18n.tr("Please wait")
                isLoading: !resultsListView.model.ready
                shown: (expenseSearchView.isEmpty || !resultsListView.model.ready) && !searchDelay.running
            }

            Common.BaseListView {
                id: resultsListView

                anchors.fill: parent
                bottomMargin: Suru.units.gu(4)
                clip: true
                currentIndex: -1
                visible: model.ready

                delegate: ValueListDelegate {
                    id: valuesListDelegate

                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: units.gu(1)
                    }

                    showDate: true
                    showCategory: true
                    coloredCategory: expenseSearchView.coloredCategory
                    isTravelMode: expenseSearchView.isTravelMode
                    currentTravelCurrency: expenseSearchView.travelCurrency
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
                    payeeName: model.payee_name
                    payeeLocation: model.payee_location
                    payeeOtherDescr: model.payee_other_descr
                    highlighted: resultsListView.currentIndex == index

                    onShowContextMenu: {
                        expenseSearchView.contextMenu.itemData.expenseID = expenseID
                        expenseSearchView.contextMenu.itemData.name = itemName
                        expenseSearchView.contextMenu.itemData.entryDate = entryDate
                        expenseSearchView.contextMenu.itemData.category = model.category_name
                        expenseSearchView.contextMenu.itemData.value = homeValue
                        expenseSearchView.contextMenu.itemData.description = comments
                        expenseSearchView.contextMenu.itemData.tags = tags
                        expenseSearchView.contextMenu.itemData.payeeName = payeeName
                        expenseSearchView.contextMenu.itemData.payeeLocation = payeeLocation
                        expenseSearchView.contextMenu.itemData.payeeOtherDescription = payeeOtherDescr
                        expenseSearchView.contextMenu.itemData.travelData.rate = exchangeRate
                        expenseSearchView.contextMenu.itemData.travelData.homeCur = homeCurrency
                        expenseSearchView.contextMenu.itemData.travelData.travelCur = travelCurrency
                        expenseSearchView.contextMenu.itemData.travelData.value = travelValue
                        expenseSearchView.contextMenu.isFromSearch = true

                        resultsListView.currentIndex = index
                        expenseSearchView.contextMenu.popupMenu(valuesListDelegate, mouseX, mouseY)
                    }

                    onClicked: {
                        if (isExpandable) {
                            isExpanded = !isExpanded
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar { width: 10 }

                NumberAnimation on opacity {
                    running: resultsListView.count > 0
                    from: 0
                    to: 1
                    easing: Suru.animations.EasingInOut
                    duration: Suru.animations.BriskDuration
                }
            }
        }
    }

    Rectangle {
        z: -1
        color: Suru.backgroundColor
        anchors.fill: parent

        // Mouse events Eater
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onWheel: wheel.accepted = true;
        }

    }
}
