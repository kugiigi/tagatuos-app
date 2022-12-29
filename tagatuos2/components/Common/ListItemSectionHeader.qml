import QtQuick 2.9
import Lomiri.Components 1.3


ListItem {
    id: root

    //Public APIs
    property alias title: labelTitle.text
    property alias  fontWeight: labelTitle.font.weight
    property alias fontSize: labelTitle.fontSize

    height: units.gu(4)
    divider.visible: true
    divider.height: units.gu(0.2)
    highlightColor: "transparent"
    Label {
        id: labelTitle
        font.weight: Font.DemiBold
        fontSize: "small"
        elide: Text.ElideRight
        fontSizeMode: Text.HorizontalFit
        minimumPixelSize: units.gu(2)
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: units.gu(1)
        }
        //text: section
    }
}
