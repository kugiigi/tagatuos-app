import QtQuick 2.4
import Ubuntu.Components 1.3

ListItem {
    id: listItem

    property string titleText

    highlightColor: theme.palette.highlighted.foreground
    divider.visible: false
    selectMode: true
    clip: true


    ListItemLayout {
        id: listItemLayout

        title.text: titleText
        title.color: theme.palette.normal.foregroundText
        title.textSize: Label.Small
        title.font.weight: tickIcon.visible ? Font.Normal : Font.Light

        Icon {
            id: tickIcon
            SlotsLayout.position: SlotsLayout.Leading
            color: theme.palette.normal.foregroundText
            width: units.gu(2)
            height: width
            name: listItem.selected ? "tick" : "select-none"
            visible: true /*if (root.multipleSelection) {
                         listItem.selected
                     } else {
                         listItem.selected
                     }*/

            asynchronous: true
        }
    }
}
