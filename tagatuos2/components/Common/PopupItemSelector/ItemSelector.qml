import QtQuick 2.9
import Lomiri.Components 1.3

Item {
    id: itemSelector

    property alias model: listView.model
    property alias title: selectorHeader.title

    clip: true


    function getReturnValue(){
        var result

        for (var i=0;i < listView.model.count; i++) {
            if(listView.ViewItems.selectedIndices.indexOf(i) > -1){
                if(!result){
                    result = listView.model.get(i)[root.valueRolename]
                }else{
                    result = result + ";" + listView.model.get(i)[root.valueRolename]
                }
            }
        }

        return result
    }


    function geValuesOrder(){
        var result

        for (var i=0;i < listView.model.count; i++) {
            if(!result){
                result = listView.model.get(i)[root.valueRolename]
            }else{
                result = result + ";" + listView.model.get(i)[root.valueRolename]
            }
        }

        return result
    }

    function initializeSelectedValues(initialValues){

        var selectedIndices = initialValues.split(";")

        for (var i=0;i < listView.model.count; i++) {
            if(selectedIndices.indexOf(listView.model.get(i)[root.valueRolename]) > -1 ){
                listView.ViewItems.selectedIndices.push(i)
            }
        }

        // TODO: Does not really work correctly. It's always at the beginning
//        listView.positionViewAtIndex(listView.ViewItems.selectedIndices[0],ListView.Center)
        listView.positionViewAtIndex(listView.ViewItems.selectedIndices[0],ListView.Beginning)
    }

    SelectorHeader{
        id: selectorHeader

        anchors{
            left: parent.left
            right: parent.right
            top: parent.top
        }
    }

//    Item{
//        id: selectorHeader
//        property string title: "Test"
//    }


    LomiriListView {
        id: listView


        clip: true
        currentIndex: -1

        ViewItems.dragMode: root.withOrdering
        ViewItems.onDragUpdated: {
                if (event.status == ListItemDrag.Started) {
                    event.accept = true
                } else {
                    model.move(event.from, event.to, 1);
                }
            }

        anchors{
            left: parent.left
            leftMargin: units.gu(-5)
            right: parent.right
            top: selectorHeader.bottom
            bottom: selectorToolbar.top
        }


        displaced: Transition {
            LomiriNumberAnimation { property: "y"; duration: LomiriAnimation.BriskDuration }
        }

        delegate: ListItemDelegate {
            id: listItemDelegate

            titleText: root.model.get(index)[[root.textRolename]]
        }

        Component.onCompleted: {
            itemSelector.initializeSelectedValues(root.selectedValue)
        }


        function clearSelection() {
            ViewItems.selectedIndices = []
        }

        function selectAll() {
            var tmp = []

            for (var i=0; i < model.count; i++) {
                tmp.push(i)
            }

            ViewItems.selectedIndices = tmp
        }
    }

    SelectorToolbar{
        id: selectorToolbar

        anchors{
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }
//    Rectangle{
//        id: selectorToolbar

//        color: "green"
//        height: units.gu(5)
//        anchors{
//            left: parent.left
//            right: parent.right
//            bottom: parent.bottom
//        }
//    }
}
