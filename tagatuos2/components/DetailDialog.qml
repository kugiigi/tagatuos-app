import QtQuick 2.9
import Ubuntu.Components 1.3
import "DetailDialog"
import "../components/Common"

Item {
    id: root

    property string category
    property string itemName
    property string description
    property string date
    property string value
    property string travelValue
    property real travelRate

    signal closed

    DetailName {
        id: detailName

        anchors {
            margins: units.gu(2)
            left: parent.left
            right: parent.right
            top: parent.top
        }
    }

    Item {
        id: categoryDateRow

        anchors{
            left: parent.left
            right: parent.right
            top: detailName.bottom
            margins: units.gu(2)
        }

        DetailCategory {
            id: detailCategory

            anchors {
                top: parent.top
                left: parent.left
                right: detailDate.left
                leftMargin: recMargin
            }
        }

        DetailDate {
            id: detailDate

            anchors {
                top: parent.top
                right: parent.right
            }
        }
    }



    DetailDescription {
        id: detailDescription

        anchors {
            margins: units.gu(2)
            left: parent.left
            right: parent.right
            top: categoryDateRow.bottom
            topMargin: units.gu(3)
            bottom: detailValue.top
            bottomMargin: units.gu(1)
        }
    }

    DetailValue {
        id: detailValue

        anchors {
            margins: units.gu(1)
            left: parent.left
            right: parent.right
            bottom: closeButton.top
        }
    }

    Item {
        id: closeButton

        height: units.gu(5)
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        ActionButtonDelegate {
            anchors.fill: parent

            action: Action {
                iconName: "close"
                text: i18n.tr("Close")
                onTriggered: root.closed()
            }
        }
    }
}
