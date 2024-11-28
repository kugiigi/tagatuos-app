import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "." as Common
import "listitems" as ListItems

ListItems.BaseItemDelegate {
    id: itemDelegate

    property string propertyName: "name"
    property int horizontalAlignment: Text.AlignHCenter

    highlighted: ListView.view.currentIndex == index
    transparentBackground: true

    anchors {
        left: parent.left
        right: parent.right
    }

    text: model ? model[itemDelegate.propertyName] : ""

    onClicked: ListView.view.itemClicked(text)

    contentItem: Label {
        Layout.fillWidth: true
        text: itemDelegate.text
        wrapMode: Text.WordWrap
        horizontalAlignment: itemDelegate.horizontalAlignment
    }
}
