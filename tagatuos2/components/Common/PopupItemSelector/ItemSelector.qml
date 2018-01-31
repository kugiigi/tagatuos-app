import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    id: itemSelector

    property alias model: listView.model
    property alias title: selectorHeader.title

    anchors.fill: parent
    clip: true

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

        function returnValue(){
            var result

            for (var i=0; (i < ViewItems.selectedIndices.length; i++) {
                     if(result){
                         result = model.get(i)["text"])
                     }else{
                         result = result + ", " + model.get(i)["text"])
                     }
            return
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
