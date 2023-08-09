import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12

BaseDialog {
    id: deleteConfirmDialog

    readonly property bool checked: checkBox.checkState === Qt.Checked
    property alias subtitle: subtitleLabel.text
    property bool showCheckbox
    property alias checkBoxTitle: checkBox.text

    parent: mainView.corePage
    height: column.height + Suru.units.gu(18)
    standardButtons: Dialog.Ok | Dialog.Cancel

    onAboutToShow: {
        checkBox.checkState = Qt.Unchecked
    }

    ColumnLayout {
        id: column

        spacing: Suru.units.gu(2)
        anchors {
            top: parent.top
            topMargin: Suru.units.gu(2)
            left: parent.left
            right: parent.right
        }

        Label {
            id: subtitleLabel

            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        CheckBox {
            id: checkBox

            visible: deleteConfirmDialog.showCheckbox
            Layout.fillWidth: true
        }
    }
}
