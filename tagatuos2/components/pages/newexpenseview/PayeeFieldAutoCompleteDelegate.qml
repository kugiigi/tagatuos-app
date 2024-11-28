import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../../../common" as Common

Common.TextFieldWithAutoCompleteDelegate {
    id: itemDelegate

    readonly property bool locationHasValue: payeeLocation.trim() !== ""
    readonly property bool otherDescrHasValue: payeeOtherDescr.trim() !== ""

    property string payeeName: model.payeeName
    property string payeeLocation: model.payeeLocation
    property string payeeOtherDescr: model.payeeOtherDescr

    onClicked: {
        let _data = {
            payeeName: payeeName
            , payeeLocation: payeeLocation
            , payeeOtherDescr: payeeOtherDescr
        }
        ListView.view.itemClicked(_data)
    }

    contentItem: ColumnLayout {
        Label {
            Layout.fillWidth: true
            visible: itemDelegate.payeeName.trim() !== ""
            text: itemDelegate.payeeName
            wrapMode: Text.WordWrap
        }

        Label {
            Layout.fillWidth: true
            visible: itemDelegate.locationHasValue || itemDelegate.otherDescrHasValue
            text: {
                switch(true) {
                    case itemDelegate.locationHasValue && itemDelegate.otherDescrHasValue:
                        return i18n.tr("%1 - %2").arg(itemDelegate.payeeLocation).arg(itemDelegate.payeeOtherDescr)
                    case itemDelegate.locationHasValue:
                        return itemDelegate.payeeLocation
                    case itemDelegate.otherDescrHasValue:
                        return itemDelegate.payeeOtherDescr
                    default:
                        return ""
                }
            }
            wrapMode: Text.WordWrap
        }
    }
}
