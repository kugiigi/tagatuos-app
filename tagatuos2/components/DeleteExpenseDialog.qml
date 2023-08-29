import QtQuick 2.12
import Lomiri.Components 1.3 as UT
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../common/dialogs" as Dialogs
import "../library/functions.js" as Functions

Dialogs.DialogWithContents {
    id: deleteExpenseDialog

    property ExpenseData expenseData

    signal proceed
    signal cancel

    destroyOnClose: true

    title: i18n.tr("Delete Expense")

    onProceed: close()
    onCancel: close()

    Label {
        Layout.fillWidth: true
        Suru.textLevel: Suru.Paragraph
        text: i18n.tr("Are you sure you want to delete this expense?")
        wrapMode: Text.WordWrap
    }

    RowLayout {
        Label {
            Layout.fillWidth: true
            Suru.textLevel: Suru.HeadingThree
            visible: text.trim() !== ""
            text: deleteExpenseDialog.expenseData ? deleteExpenseDialog.expenseData.name : ""
            wrapMode: Text.WordWrap
        }

        ColoredLabel {
            Layout.alignment: Qt.AlignRight
            visible: text.trim() !== ""
            Suru.textLevel: Suru.HeadingThree
            horizontalAlignment: Text.AlignHCenter
            text: deleteExpenseDialog.expenseData ? Functions.formatMoney(deleteExpenseDialog.expenseData.value, deleteExpenseDialog.expenseData.travelData.homeCur)
                            : ""
            wrapMode: Text.WordWrap
            role: "value"
        }
    }

    Label {
        Layout.fillWidth: true
        visible: text.trim() !== ""
        Suru.textLevel: Suru.Paragraph
        text: deleteExpenseDialog.expenseData ? deleteExpenseDialog.expenseData.description : ""
        wrapMode: Text.WordWrap
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Suru.units.gu(2)

        UT.Button {
            Layout.fillWidth: true
            text: i18n.tr("Delete")
            color: theme.palette.normal.negative

            onClicked: deleteExpenseDialog.proceed()
        }

        UT.Button {
            Layout.fillWidth: true
            enabled: visible
            text: i18n.tr("Cancel")
            color: Suru.neutralColor

            onClicked: deleteExpenseDialog.cancel()
        }
    }
}
