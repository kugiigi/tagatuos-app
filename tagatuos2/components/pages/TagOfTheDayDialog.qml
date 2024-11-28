import QtQuick 2.12
import Lomiri.Components 1.3 as UT
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../../common/dialogs" as Dialogs
import "../../common/listitems" as ListItems
import "../../library/functions.js" as Functions
import ".." as Components
import "newexpenseview" as NewExpenseView

Dialogs.DialogWithContents {
    id: tagOfTheDayDialog


    property string date: mainView.settings.tagOfTheDayDate
    property string tags: mainView.settings.tagOfTheDay

    signal proceed(string date, string tags)
    signal cancel

    preferredWidth: parent.width
    maximumWidth: Suru.units.gu(60)
    bottomMargin: 0
    anchorToKeyboard: true
    destroyOnClose: true
    title: i18n.tr("Tags of the Day")

    onOpened: {
        tagsField.forceActiveFocus()
    }

    onProceed: close()
    onCancel: close()

    Label {
        Layout.fillWidth: true
        Suru.textLevel: Suru.Caption
        text: i18n.tr("Tags of the day will be automatically added to all your new expenses today")
        wrapMode: Text.WordWrap
    }

    NewExpenseView.TagsField {
        id: tagsField

        Layout.fillWidth: true
        flickable: tagOfTheDayDialog.flickable
        tags: tagOfTheDayDialog.tags
        useCustomBackground: false
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Suru.units.gu(2)

        UT.Button {
            Layout.fillWidth: true
            text: i18n.tr("Save")
            color: mainView.uitkColors.normal.positive

            onClicked: {
                mainView.keyboard.commit()
                tagOfTheDayDialog.proceed(Functions.getToday(), tagsField.tags)
            }
        }

        UT.Button {
            Layout.fillWidth: true
            enabled: visible
            text: i18n.tr("Cancel")
            color: Suru.neutralColor

            onClicked: tagOfTheDayDialog.cancel()
        }
    }
}

