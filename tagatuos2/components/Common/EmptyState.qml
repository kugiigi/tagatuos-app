import QtQuick 2.9
import Lomiri.Components 1.3


/*
 Component which displays an empty state (approved by design). It offers an
  icon, title and subtitle to describe the empty state.
  */
Item {
    id: emptyState

    // Public APIs
    property string iconName
    property alias iconSource: emptyIcon.source
    property alias iconColor: emptyIcon.color
    property alias title: emptyLabel.text
    property alias subTitle: emptySublabel.text
    property string loadingTitle//: loading.title
    property string loadingSubTitle//: loading.subTitle
    property alias isLoading: loading.visible
    property alias shown: emptyItem.visible

    readonly property real widthLimit: units.gu(30)
    readonly property real heightLimit: units.gu(40)

//    height: isLoading || shown ? childrenRect.height : 0
    height: isLoading ? loading.height : shown ? emptyItem.height : 0
    anchors.left: parent.left
    anchors.right: parent.right

    LoadingComponent {
        id: loading
        visible: false
        title: loadingTitle
        subTitle: loadingSubTitle
    }

    Item {
        id: emptyItem
        visible: false
        height: visible ? childrenRect.height : 0
        anchors.left: parent.left
        anchors.right: parent.right

        Icon {
            id: emptyIcon
            anchors.horizontalCenter: parent.horizontalCenter
            name: emptyState.iconName
            //anchors.top: parent.top
            height: visible ? parent.width <= widthLimit ? (parent.width * 0.3) : units.gu(
                                                               10) : 0
            width: height
            visible: parent.parent.height <= heightLimit
                     || emptyState.iconName === "" ? false : true
            color: "#BBBBBB"
        }

        Label {
            id: emptyLabel
            anchors.top: emptyIcon.bottom
            anchors.topMargin: emptyIcon.visible ? units.gu(5) : units.gu(2)
            anchors.left: parent.left
            anchors.right: parent.right
            //anchors.horizontalCenter: parent.horizontalCenter
            fontSize: parent.width <= widthLimit ? "medium" : "large"
            font.weight: Text.Normal
//            font.bold: true
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            visible: isLoading ? false : true
        }

        Label {
            id: emptySublabel
            anchors.top: emptyLabel.bottom
            //anchors.horizontalCenter: parent.horizontalCenter
            fontSize: parent.width <= widthLimit ? "small" : "medium"
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            anchors.left: parent.left
            anchors.right: parent.right
            visible: isLoading ? false : true
        }
    }
}
