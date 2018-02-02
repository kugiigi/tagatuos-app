import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: itemSelector

    property alias model: listView.model
    property alias title: selectorHeader.title

    anchors.fill: parent
    clip: true

    function getReturnValue(){
        var result

        for (var i=0;i < listView.model.count; i++) {
            if(listView.ViewItems.selectedIndices.indexOf(i) > -1){
                if(!result){
                    result = listView.model.get(i)["value"]
                }else{
                    result = result + ";" + listView.model.get(i)["value"]
                }
            }
        }

        return result
    }


    function geValuesOrder(){
        var result

        for (var i=0;i < listView.model.count; i++) {
            if(!result){
                result = listView.model.get(i)["value"]
            }else{
                result = result + ";" + listView.model.get(i)["value"]
            }
        }

        return result
    }

    function initializeSelectedValues(initialValues){

        var selectedIndices = initialValues.split(";")

        for (var i=0;i < listView.model.count; i++) {
            if(selectedIndices.indexOf(listView.model.get(i)["value"]) > -1 ){
                listView.ViewItems.selectedIndices.push(i)
            }
        }
    }

    SelectorHeader{
        id: selectorHeader

        anchors{
            left: parent.left
            right: parent.right
            top: parent.top
        }
    }


    UbuntuListView {
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
            UbuntuNumberAnimation { property: "y"; duration: UbuntuAnimation.BriskDuration }
        }

        delegate: ListItemDelegate {
            id: listItemDelegate
            titleText: text

            onClicked: {
                selected = !selected
            }
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
}
