import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes.Ambiance 1.3
import Ubuntu.Keyboard 0.1

Column {
    id: column

    property alias text: valueTextField.text
    property bool focused: valueTextField.activeFocus

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

        property string enterKeyLabel: switch(root.mode){
                                       case "add":
                                           i18n.tr("Add")
                                           break
                                       case "edit":
                                           i18n.tr("Save")
                                           break
                                       case "custom":
                                           i18n.tr("Add")
                                           break
                                       default:
                                           i18n.tr("Add")
                                           break

                                       }

        // this value is to avoid letter being cut off
        height: units.gu(4.3)
        width: parent.width <= units.gu(50) ? parent.width : parent.width * 0.5
        horizontalAlignment: TextInput.AlignRight
        inputMethodHints: Qt.ImhDigitsOnly

        InputMethod.extensions: { "enterKeyText": i18n.dtr("tagatuos-app", enterKeyLabel)}

        anchors {
            left: parent.left
        }

        placeholderText: "0.00"
        validator: DoubleValidator {
            decimals: tempSettings.currentCurrencyPrecision //2
        }
        hasClearButton: true
    }
}
