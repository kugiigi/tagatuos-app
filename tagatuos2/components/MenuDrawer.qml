import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2

Drawer {
    id: menuDrawer
    
    property alias model: listView.model
    
    readonly property real minimumWidth: Suru.units.gu(30)
    readonly property real maximumWidth: Suru.units.gu(40)
    readonly property real preferredWidth: parent.width * 0.25

    property real listViewTopMargin

    signal itemClicked(string itemCode)

    width: Math.min(Math.max(preferredWidth, minimumWidth), maximumWidth)
    height: parent.height
    dragMargin: 0

    background: Rectangle { color: Suru.backgroundColor }

    function openTop() {
        listView.verticalLayoutDirection = ListView.TopToBottom
        open()
    }

    function openBottom() {
        listView.verticalLayoutDirection = ListView.BottomToTop
        open()
    }

    function resetListIndex() {
        listView.currentIndex = -1
    }

    ListView {
        id: listView

        focus: true
        currentIndex: -1
        anchors.fill: parent
        topMargin: menuDrawer.listViewTopMargin

        delegate: ItemDelegate {
            width: parent.width
            text: modelData.title
            highlighted: ListView.isCurrentItem
            icon {
                name: modelData ? modelData.iconName : ""
                color: Suru.foregroundColor
                width: Suru.units.gu(2.5)
                height: Suru.units.gu(2.5)
            }

            onClicked: {
                menuDrawer.itemClicked(modelData.itemCode)
                drawer.close()
            }
        }

        ScrollIndicator.vertical: ScrollIndicator { }
    }
}
