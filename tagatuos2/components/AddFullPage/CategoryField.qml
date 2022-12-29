import QtQuick 2.9
import Lomiri.Components 1.3
import "../Common"


PopupItemSelector{
    id: currencyPopupItemSelector

    titleText: i18n.tr("Category")
    selectedValue: model.get(0).category_name
    model: listModels.modelCategories
    valueRolename: "category_name"
    textRolename: "category_name"
    divider.visible: false
    commitOnSelect: true
//    forceFullscreen: true

    title.textSize: Label.Medium
    title.font.weight: Text.Normal
    subtitle.textSize: Label.Medium

    onConfirmSelection: {
        selectedValue = selections
    }

    onActiveFocusChanged: {
        if(activeFocus){
            root.resetFocus()
        }
    }
}
