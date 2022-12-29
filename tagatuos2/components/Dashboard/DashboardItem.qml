import QtQuick 2.9
import Lomiri.Components 1.3
import "../Common"

Column {
    id: rootItem

    property string headerText
    property string emptyText
    property string loadingText
    property string detailViewMode
    property ListModel model

    spacing: units.gu(1)
    height: childrenRect.height
    anchors {
        left: parent.left
        right: parent.right
    }

    function goToDetailView(sort){
//        var regex = new RegExp(sort);
//        mainPage.detailView.model.filter.pattern = regex
        mainPage.detailView.sort = sort
        mainPage.detailView.currentMode = rootItem.detailViewMode
//        mainPage.detailView.model.model = rootItem.model
        activateDetailView()
    }

    ViewHeader {
        id: todayHeader
        title.text: rootItem.headerText
        total: rootItem.model.totalValue
        action: Action {
            onTriggered: {
                rootItem.goToDetailView("")
            }
        }
    }

    EmptyState {
        id: emptyState
        z: -1

        title: rootItem.emptyText
        subTitle: i18n.tr("Use the bottom edge to add expenses")
        loadingTitle: rootItem.loadingText
        loadingSubTitle: i18n.tr("Please wait")
        isLoading: !flowLoader.visible
                   || rootItem.model.loadingStatus !== "Ready"
        anchors {
            right: parent.right
            left: parent.left
            margins: units.gu(1)
        }

        shown: rootItem.model.count === 0
               && rootItem.model.loadingStatus === "Ready"
    }

    Item {
        id: item

        height: itemFlickable.contentHeight //flowLoader.item !== null ? flowLoader.item.height : 0

        anchors {
            left: parent.left
            right: parent.right
        }

        /*WORKAROUND: To always display each flowitem*/
        Flickable {
            id: itemFlickable

            contentHeight: flowLoader.item !== null ? flowLoader.item.height + units.gu(
                                                          3) : 0
            height: contentHeight
            anchors {
                left: parent.left
                right: parent.right
            }

            clip: true
            interactive: false

            Loader {
                id: flowLoader
                asynchronous: true
                anchors {
                    left: parent.left
                    right: parent.right
                }

                //                anchors.fill: parent
                sourceComponent: FlowItems {
                    id: flowItem

                    onItemSelected:{
                        console.log("sample: " + itemIndex)
                        console.log(model.get(itemIndex).category_name)
                        rootItem.goToDetailView(model.get(itemIndex).category_name)
                    }

                    noDate: true
                    model: rootItem.model
                    flickable: itemFlickable
                    delegate: FlowItem {
                    }
                }
                visible: status == Loader.Ready
            }
        }
    }
}
