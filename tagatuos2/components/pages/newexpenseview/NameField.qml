import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import "../.." as Components
import "../../../common" as Common
import "../../../library/functions.js" as Functions

TextField {
    id: nameField

    property Flickable flickable

    placeholderText: i18n.tr("Enter expense name")
    font.pixelSize: Suru.units.gu(3.5)
    horizontalAlignment: TextInput.AlignHCenter
    wrapMode: TextInput.WordWrap
    inputMethodHints: Qt.ImhNoPredictiveText
    property bool highlighted: false

    Keys.onUpPressed: console.log("Do not rmeove focus")
    Keys.onDownPressed: focusScrollConnections.focusNext()

    Components.FocusScrollConnections {
        id: focusScrollConnections

        target: nameField
        flickable: nameField.flickable
    }

    background: Common.BaseBackgroundRectangle {
        control: nameField
        radius: Suru.units.gu(1)
//~         backgroundColor: control.activeFocus ? Suru.backgroundColor
//~                                 : Suru.backgroundColor.hslLightness > 0.5 ? Qt.darker(Suru.backgroundColor, 1.5) : Qt.lighter(Suru.backgroundColor, 2.0)
//~         borderColor: backgroundColor
    }
}
