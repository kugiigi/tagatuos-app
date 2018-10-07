import QtQuick 2.9
import Ubuntu.Components 1.3


Column{
    id: detailValue

    Label {
        id: valueLabel

        text: root.value
        color: theme.palette.normal.backgroundText
        font.weight: Font.DemiBold
        textSize: Label.XLarge
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors {
            left: parent.left
            right: parent.right
        }
    }

    Label {
        id: travelValueLabel

        visible: text !== "" ? true : false
        text: root.travelValue
        color: theme.palette.normal.backgroundSecondaryText
        textSize: Label.Large
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter

        anchors {
            left: parent.left
            right: parent.right
        }
    }

    Label {
        id: travelRateLabel

        visible: travelValueLabel.text !== "" ? true : false
        text: "@" + root.travelRate
        color: theme.palette.normal.backgroundTertiaryText
        textSize: Label.Medium
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter

        anchors {
            left: parent.left
            right: parent.right
        }
    }
}


