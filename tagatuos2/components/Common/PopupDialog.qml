import QtQuick 2.4
import Ubuntu.Components 1.3

Rectangle {
    id: root

    property alias content: loaderItem.sourceComponent
    property alias contentLoader: loaderItem

    color: theme.palette.normal.overlay
    border {
        color: UbuntuColors.blue
        width: units.gu(0.1)
    }

    radius: units.gu(1)
    visible: opacity === 1 ? true : false
    width: parent.width < units.gu(50) ? parent.width * 0.8 : units.gu(40)
    //    height: parent.height < units.gu(30) ? parent.height * 0.8 : childrenRect.height + units.gu(4)
    height: flickable.height
    opacity: 0
    z: Number.MAX_VALUE

    anchors {
        centerIn: parent
    }

    Behavior on opacity {
        UbuntuNumberAnimation {
            easing: UbuntuAnimation.StandardEasing
            duration: UbuntuAnimation.SlowDuration
        }
    }

    InverseMouseArea {
        onClicked: hide()
        //        sensingArea: flickable
    }

    Flickable {
        id: flickable
        width: root.width
        contentHeight: loaderItem.item !== null ? loaderItem.item.height : 0
        height: /*root.parent.height < units.gu(30)
                && l*/loaderItem.item.height + units.gu(10) >= root.parent.height ? root.parent.height * 0.8 : loaderItem.item.height + units.gu(
                              4)
        interactive: true
        clip: true

        Loader {
            id: loaderItem
            asynchronous: true
            anchors{
                left: parent.left
                right: parent.right
            }

            //            onLoaded:{
            //                item.forceActiveFocus()
            //            }
            visible: status == Loader.Ready
        }
    }


    //    onActiveFocusChanged:{
    //        if(!activeFocus){
    //            console.log("naout of focus")
    //            hide()
    //        }
    //    }

    //    Connections{
    //        target: loaderItem.item
    //        onActiveFocusChanged:{
    //            if(!activeFocus){
    //                console.log("naout of focus")
    //                hide()
    //            }
    //        }
    //    }
    function show() {
        opacity = 1
    }
    function hide() {
        opacity = 0
    }
}
