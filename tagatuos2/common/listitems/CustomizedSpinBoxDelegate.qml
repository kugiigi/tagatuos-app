import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Layouts 1.12
import QtQuick.Controls.Suru 2.2

RoundedItemDelegate {
    id: customizedSpinBoxDelegate

    property alias label: mainLabel
    property alias helpText: helpButton.text

    property real controlMaximumWidth: 0
    property int defaultValue: 1

    // From SpinBox
    property alias value: spinBoxItem.value
    property alias from: spinBoxItem.from
    property alias to: spinBoxItem.to
    property alias stepSize: spinBoxItem.stepSize
    property alias textFromValue: spinBoxItem.textFromValue

    signal reset
    signal valueModified

    transparentBackground: true
    interactive: false
    rightPadding: units.gu(1)

    contentItem: ColumnLayout {
        RowLayout {
            QQC2.Label {
                id: mainLabel

                Layout.fillWidth: true
                text: customizedSpinBoxDelegate.text
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                maximumLineCount: 2
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
            
            CustomizedButton {
                id: resetButton

                visible: customizedSpinBoxDelegate.defaultValue != spinBoxItem.value
                display: QQC2.AbstractButton.IconOnly
                tooltipText: i18n.tr("Reset to default")
                icon.name: "reset"
                transparentBackground: true

                onClicked: customizedSpinBoxDelegate.reset()
            }

            // Dummy spacer
            Item {
                Layout.fillWidth: true
            }

            SettingsHelpButton {
                id: helpButton
            }
        }

        QQC2.SpinBox {
            id: spinBoxItem

            Layout.fillWidth: true
            Layout.maximumWidth: customizedSpinBoxDelegate.controlMaximumWidth > 0 ? customizedSpinBoxDelegate.controlMaximumWidth
                                        : parent.width

            onValueModified: customizedSpinBoxDelegate.valueModified()
        }
    }
}
