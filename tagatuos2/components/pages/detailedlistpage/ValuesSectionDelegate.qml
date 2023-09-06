import QtQuick 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../.." as Components
import "../../../library/functions.js" as Functions
import "../../../library/ApplicationFunctions.js" as AppFunctions

Rectangle {
    id: sectionItem

    property var sectionObj
    property var view
    property bool displayTravelTotal: false
    property string travelCurrency
    property string type: "category"
    readonly property string groupName: sectionObj.split("|")[0]
    readonly property real groupTotal: sectionObj.split("|")[1]
    readonly property real groupTravelTotal: sectionObj.split("|")[2]

    color: Suru.backgroundColor
    height: Suru.units.gu(4)

    RowLayout {
        spacing: Suru.units.gu(2)
        anchors {
            fill: parent
            leftMargin: Suru.units.gu(2)
            rightMargin: anchors.leftMargin
        }

        Components.ColoredLabel {
            Suru.textLevel: Suru.HeadingThree
            text: sectionItem.groupName
            role: sectionItem.type == "category" ? "category" : "date"
        }

        Components.ColoredLabel {
            Layout.alignment: Qt.AlignRight
            Suru.textLevel: Suru.Caption

            text: {
                if (sectionItem.view.currentIndex > -1 && sectionItem.groupName) {
                    if (sectionItem.displayTravelTotal) {
                        return Functions.formatMoney(sectionItem.groupTravelTotal, sectionItem.travelCurrency, null)
                    }

                    return AppFunctions.formatMoney(sectionItem.groupTotal, false)
                }

                return ""
            }
            role: "value"
        }
    }
}
