import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes.Ambiance 1.3
import Ubuntu.Keyboard 0.1

Column {
    id: column

    property alias text: valueTextField.text

    spacing: units.gu(1)

    anchors {
        left: parent.left
        leftMargin: units.gu(2)
        right: parent.right
        rightMargin: units.gu(2)
    }

    Label {
        id: valueLabel
        text: i18n.tr("Value")
        font.weight: Text.Normal
        color: theme.palette.normal.foregroundText
        anchors {
            left: parent.left
            right: parent.right
        }
    }

    TextField {
        id: valueTextField
        // this value is to avoid letter being cut off
        height: units.gu(4.3)
        width: parent.width <= units.gu(50) ? parent.width : parent.width * 0.5
        horizontalAlignment: TextInput.AlignRight
        inputMethodHints: Qt.ImhDigitsOnly

        InputMethod.extensions: { "enterKeyText": i18n.dtr("tagatuos-app", root.mode === "add" ? "Add" : "Save") }
        anchors {
            left: parent.left
        }

        placeholderText: "0.0"
        validator: DoubleValidator {
            decimals: 2
        }
        hasClearButton: true
    }
}
