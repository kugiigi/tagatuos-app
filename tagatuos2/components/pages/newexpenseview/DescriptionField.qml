import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import "../.." as Components
import "../../../common" as Common
import "../../../library/functions.js" as Functions

TextArea {
    id: descriptionField

    property Common.BaseFlickable flickable
    readonly property bool highlighted: activeFocus

    placeholderText: i18n.tr("Add description, more details or comments")
    font.pixelSize: Suru.units.gu(2)
    wrapMode: TextInput.WordWrap

    Keys.onPressed: {
        switch (event.key) {
            case Qt.Key_Backspace:
                if (text == "") {
                    focusScrollConnections.focusPrevious()
                }
                break
            case Qt.Key_Down:
                if (text == "") {
                    focusScrollConnections.focusNext()
                }
                break
        }
    }
    
    Components.FocusScrollConnections {
        id: focusScrollConnections

        target: descriptionField
        flickable: descriptionField.flickable
        enableAcceptedFocus: false
    }

    background: Common.BaseBackgroundRectangle {
        control: descriptionField
        radius: Suru.units.gu(1)
        enableHoveredHighlight: false
        highlightColor: "transparent"
    }
}
