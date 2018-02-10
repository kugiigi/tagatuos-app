import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtQuick.Layouts 1.1

ListItem {
    id: root

    property string itemName
    property string itemValue
    property string itemDescr
    property string itemCategory
    property string itemDate

    divider {
        visible: false
        anchors {
            leftMargin: units.gu(2)
            rightMargin: units.gu(2)
        }
    }

    highlightColor: theme.palette.highlighted.background


    ListItemLayout {
        title.text: root.itemName
        subtitle.text: root.itemDescr

        ColumnLayout {
            id: contentColumn

            SlotsLayout.position: SlotsLayout.Trailing
            spacing: units.gu(0.5)
            layoutDirection: Qt.RightToLeft

            function adjustLayout(){
                if (categoryLabel.width > valueLabel.width) {
                    width = categoryLabel.width
                    valueLabel.width = categoryLabel.width
                } else {
                    width = valueLabel.width
                    categoryLabel.width = valueLabel.width
                }
            }

            //WORKAROUND: Dynamic setting of width depending on which is longer to retain right alignment
            Component.onCompleted: {
//                categoryLabel.text = root.itemCategory
//                valueLabel.text = root.itemValue
//                adjustLayout()
            }

            Label {
                id: categoryLabel

                text: root.itemCategory
                textSize: Label.Small
                fontSizeMode: Text.HorizontalFit
                horizontalAlignment: Text.AlignRight
                color: theme.palette.normal.foregroundText
                minimumPixelSize: units.gu(2)
                elide: Text.ElideRight
                Layout.fillWidth : true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignRight
            }
            Label {
                id: valueLabel

                text: root.itemValue
                textSize: Label.Large
                font.weight: Font.Light
                fontSizeMode: Text.HorizontalFit
                horizontalAlignment: Text.AlignRight
                minimumPixelSize: units.gu(2)
                elide: Text.ElideRight
                Layout.fillWidth : true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignRight
            }
        }
    }
}
