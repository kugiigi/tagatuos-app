import QtQuick 2.4
import Ubuntu.Components 1.3

//ListItem {
//    id: root

//    property string text
//    property string iconName

//    highlightColor: theme.palette.highlighted.overlay

////    MouseArea{

////    }

//    ListItemLayout {
//        title.text: root.text
//        title.color: theme.palette.normal.overlayText

//        Icon {
//            id: valueLabel
//            name: root.iconName
//            height: width
//            width: units.gu(2)
//            SlotsLayout.position: SlotsLayout.Leading
//            color: theme.palette.normal.overlayText
//        }
//    }
//}

Row{
    id: root

    property string title
    property string icon
    property alias text: label.text
    property alias iconName: icon.name


    spacing: units.gu(1)
    height: units.gu(5)


    Icon {
        id: icon
        //name: root.icon
        height: width
        width: units.gu(2)
        color: root.title === i18n.tr("Delete") ? theme.palette.normal.negative : theme.palette.normal.overlayText
    }

    Label {
        id: label
            //text: root.title
            textSize: Label.Large
            font.weight: Font.Normal
            fontSizeMode: Text.HorizontalFit
            color: theme.palette.normal.overlayText
            minimumPixelSize: units.gu(3)
            elide: Text.ElideRight
        }
}
