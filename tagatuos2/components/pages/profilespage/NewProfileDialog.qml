import QtQuick 2.12
import Lomiri.Components 1.3 as UT
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../../../common/dialogs" as Dialogs
import "../../../common/listitems" as ListItems
import "../.." as Components

Dialogs.DialogWithContents {
    id: newProfileDialog

    readonly property bool isAddMode: mode == "add"
    readonly property bool isEditMode: mode == "edit"

    property string mode: "add"
    property int profileId
    property string displayName
    property string homeCurrency: "USD"
    property bool enableOverlay
    property color overlayColor
    property real overlayOpacity

    signal proceed(string displayName, string homeCurrency, bool enableOverlay, color overlayColor, real overlayOpacity)
    signal cancel

    anchorToKeyboard: true
    destroyOnClose: true
    title: isAddMode ? i18n.tr("New Profile") : i18n.tr("Edit Profile")

    onAboutToShow: {
        if (isEditMode) {
            nameField.text = displayName
            colorOverlayFields.enableOverlay = enableOverlay
            colorOverlayFields.overlayColor = overlayColor
            colorOverlayFields.overlayOpacity = overlayOpacity * 100
        }
    }

    onOpened: {
        mainView.temporaryDisableColorOverlay = true
        nameField.focusTextField()
    }

    onClosed: {
        mainView.temporaryDisableColorOverlay = false
        if (colorOverlayFields.testOverlay) {
            colorOverlayFields.testOverlay.destroy()
        }
    }

    onCancel: close()

    NameField {
        id: nameField

        Layout.fillWidth: true
        flickable: newProfileDialog.flickable
    }

    ListItems.BaseComboBoxDelegate {
        id: homeCurrencyCombobox

        Layout.fillWidth: true
        text: i18n.tr("Home currency")
        model: mainView.mainModels.currenciesModel
        helpText: i18n.tr("The home currency that is used to process, format and display expenses")
        controlMaximumWidth: Suru.units.gu(60)
        valueRole: "currency_code"
        textRole: "descr"
        currentIndex: findIndexOfValue(newProfileDialog.homeCurrency)

        onActivated: {
            let _newValue
            if (Array.isArray(model)) {
                _newValue = model[index][valueRole]
            } else {
                _newValue = model.get(index)[valueRole]
            }
            newProfileDialog.homeCurrency = _newValue
        }
    }

    ColorOverlayFields {
        id: colorOverlayFields

        property Rectangle testOverlay

        Layout.fillWidth: true
        flickable: newProfileDialog.flickable
        onEnableOverlayChanged: {
            if (enableOverlay) {
                testOverlay = testColorOverlayComponent.createObject(mainView.overlay)
                testOverlay.opacity = Qt.binding( function() { return colorOverlayFields.overlayOpacity / 100 } )
                testOverlay.color = Qt.binding( function() { return colorOverlayFields.overlayColor } )
            } else {
                if (testOverlay) {
                    testOverlay.destroy()
                }
            }
        }
    }

    Component {
        id: testColorOverlayComponent

        Rectangle {
            z: 100
            anchors.fill: parent
            opacity: colorOverlayFields.overlayOpacity / 100
            parent: mainView.overlay
            visible: colorOverlayFields.enableOverlay
            color: colorOverlayFields.overlayColor
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Suru.units.gu(2)

        UT.Button {
            Layout.fillWidth: true
            text: i18n.tr("Save")
            enabled: nameField.text.trim() !== ""
            color: mainView.uitkColors.normal.positive

            onClicked: {
                mainView.keyboard.commit()
                newProfileDialog.proceed(nameField.text, newProfileDialog.homeCurrency, colorOverlayFields.enableOverlay, colorOverlayFields.overlayColor, colorOverlayFields.overlayOpacity / 100)
            }
        }

        UT.Button {
            Layout.fillWidth: true
            enabled: visible
            text: i18n.tr("Cancel")
            color: Suru.neutralColor

            onClicked: newProfileDialog.cancel()
        }
    }
}

