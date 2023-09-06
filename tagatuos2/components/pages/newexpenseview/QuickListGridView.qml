import QtQuick 2.12
import QtQml.Models 2.2
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import "../.." as Components
import "../../../common" as Common
import "../../../library/functions.js" as Functions

GridView {
    id: quickListGridView

    enum GridType {
        Rectangle
        , List
    }

    enum Type {
        QuickList
        , History
    }

    readonly property real preferredGridWidth: Suru.units.gu(30)
    readonly property real preferredGridHeight: Suru.units.gu(15)
    readonly property real preferredListHeight: Suru.units.gu(10)
    readonly property int minimumColumns: 2
    readonly property real itemMargins: Suru.units.gu(1)

    property Common.BaseFlickable flickable
    property bool isTravelMode: false
    property string travelCurrency
    property real exchangeRate
    property alias baseModel: filteredModel.model
    property Components.ExpenseData expenseData
    property int gridType: QuickListGridView.GridType.Rectangle
    property int type: QuickListGridView.Type.QuickList

    property int columnCount: {
        let intendedCount = Math.floor(width / preferredGridWidth)
        return Math.max(intendedCount, minimumColumns)
    }

    signal createNewExpense()
    signal requestNewExpense()
    signal requestClose

    QtObject {
        id: internal

        property int previousIndex: 0
    }

    model: filteredModel
    currentIndex: -1
    interactive: false
    keyNavigationEnabled: true
    boundsMovement: contentY == 0 ? Flickable.StopAtBounds : Flickable.FollowBoundsBehavior
    boundsBehavior: Flickable.DragOverBounds

    onActiveFocusChanged: {
        if (!activeFocus) {
            internal.previousIndex = currentIndex
            currentIndex = -1
        } else {
            if (internal.previousIndex > -1) {
                currentIndex = internal.previousIndex
            }
        }
    }

    onVisibleChanged: {
        if (!visible) {
            currentIndex = -1
            internal.previousIndex = 0
        } else {
            currentIndex = -1
        }
    }

    cellWidth: {
        switch (quickListGridView.gridType) {
            case QuickListGridView.GridType.List:
                return width
            default:
                return width / columnCount
        }
    }

    cellHeight: {
        switch (quickListGridView.gridType) {
            case QuickListGridView.GridType.List:
                return quickListGridView.preferredListHeight
            case QuickListGridView.GridType.Rectangle:
            default:
                return quickListGridView.preferredGridHeight
        }
    }

    Keys.onEnterPressed: currentItem.clicked()
    Keys.onReturnPressed: currentItem.clicked()

    add: Transition {
        NumberAnimation {
            properties: "y"
            easing: Suru.animations.EasingIn
            duration: Suru.animations.SnapDuration
        }
    }

    MouseArea {
        z: -1
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: quickListGridView.requestClose()
    }

    DelegateModel {
        id: filteredModel

        function update(searchText) {
            if (items.count > 0) {
                items.setGroups(0, items.count, ["items"]);
            }

            if (searchText) {
                filterOnGroup = "match"
                let _match = [];
                let _searchTextUpper = searchText.toUpperCase()
                let _nameUpper
                let _descrUpper
                let _item

                for (var i = 0; i < items.count; ++i) {
                    _item = items.get(i);
                    _nameUpper = _item.model.name.toUpperCase()
                    _descrUpper = _item.model.description.toUpperCase()

                    if (_nameUpper.indexOf(_searchTextUpper) > -1 || _descrUpper.indexOf(_searchTextUpper) > -1 ) {
                        _match.push(_item);
                    }
                }

                for (i = 0; i < _match.length; ++i) {
                    _item = _match[i];
                    _item.inMatch = true;
                }
            } else {
                filterOnGroup = "items"
            }
        }

        groups: [
            DelegateModelGroup {
                id: matchGroup

                name: "match"
                includeByDefault: false
            }
        ]

        delegate: QuickListGridDelegate {
            readonly property bool hasValue: value > 0
            readonly property bool showTravelValue: isTravelMode && travelCurrency != ""
                                    && travelCurrency == quickListGridView.travelCurrency

            highlighted: GridView.isCurrentItem
            scale: highlighted ? 1.05 : 1
            Behavior on scale {
                NumberAnimation {
                    easing: Suru.animations.EasingIn
                    duration: Suru.animations.FastDuration
                }
            }
            type: quickListGridView.type
            expenseName: model.name
            value: showTravelValue ? model.travel_value : model.value
            description: model.description
            categoryName: model.categoryName
            isTravelMode: quickListGridView.isTravelMode
            travelCurrency: model.travel_currency ? model.travel_currency : ""

            function createOrRequestNewExpense() {
                quickListGridView.expenseData.reset()
                quickListGridView.expenseData.entryDate = Functions.getToday()
                quickListGridView.expenseData.name = expenseName
                quickListGridView.expenseData.description = description
                quickListGridView.expenseData.category = categoryName
                quickListGridView.expenseData.value = value

                if (showTravelValue) {
                    quickListGridView.expenseData.value = model.value
                    quickListGridView.expenseData.travelData.value = model.travel_value
                } else if (isTravelMode) {
                    quickListGridView.expenseData.value = value * quickListGridView.exchangeRate
                    quickListGridView.expenseData.travelData.value = value
                }

                if (hasValue) {
                    quickListGridView.createNewExpense()
                } else {
                    quickListGridView.requestNewExpense()
                }
            }

            onHighlightedChanged: {
                if (highlighted) {
                    quickListGridView.flickable.scrollToItem(this, 0, 0)
                }
            }

            onClicked: {
                expenseData.reset()
                expenseData.name = expenseName
                expenseData.description = description
                expenseData.category = categoryName
                expenseData.value = value

                if (showTravelValue) {
                    expenseData.value = model.value
                    expenseData.travelData.value = model.travel_value
                } else if (isTravelMode) {
                    expenseData.value = value * quickListGridView.exchangeRate
                    expenseData.travelData.value = value
                }

                quickListGridView.requestNewExpense()
            }

            onRightClicked: createOrRequestNewExpense()
            onPressAndHold: createOrRequestNewExpense()
        }
    }
}
