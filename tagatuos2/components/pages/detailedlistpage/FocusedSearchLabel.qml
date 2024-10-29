import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import "../../../common" as Common
import "../../../common/menus" as Menus

Common.BaseButton {
    id: focusLabel

    property var model: [
        { id: "all", name: i18n.tr("All") }
        , { id: "name", name: i18n.tr("Name") }
        , { id: "descr", name: i18n.tr("Description") }
        , { id: "payee", name: i18n.tr("Payee") }
        , { id: "tags", name: i18n.tr("Tags") }
    ]

    property int currentFocusType: 0

    signal itemSelectedFromMenu

    text: model[currentFocusType].name
    label.color: Suru.highlightColor
    label.font.weight: Font.DemiBold

    onClicked: focusedSearchTypesMenuComponent.createObject(mainView.overlay).show("", focusLabel, false)

    Rectangle {
        anchors {
            right: parent.right
            rightMargin: Suru.units.gu(-0.5)
            top: parent.top
            bottom: parent.bottom
        }
        width: Suru.units.dp(1)
        color: Suru.highlightColor
    }
    
    Component {
        id: focusedSearchTypesMenuComponent

        Menus.AdvancedMenu {
            id: focusedSearchTypesMenu

            type: Menus.AdvancedMenu.Type.ItemAttached
            doNotOverlapCaller: true
            destroyOnClose: true
            minimumWidth: Suru.units.gu(20)
            maximumWidth: Suru.units.gu(30)

            Repeater {
                id: focusedTypesMenuItemRepeater

                model: focusLabel.model

                Menus.BaseMenuItem {
                    text: modelData ? modelData.name : ""
                    visible: focusLabel.currentFocusType !== index
                    onTriggered: {
                        // WORKAROUND: Execute itemSelectedFromMenu twice
                        // so that we can handle both empty and non-empty
                        // for the cursor position issue
                        focusLabel.itemSelectedFromMenu()
                        focusLabel.currentFocusType = index
                        focusLabel.itemSelectedFromMenu()
                    }
                }
            }
        }
    }
}
