import QtQuick 2.9
import Lomiri.Components 1.3
import Lomiri.Components.Themes.Ambiance 1.3

Column {

    id: nameField

    property alias title: nameLabel.text
    property alias placeholderText: textName.placeholderText
    property alias text: textName.text
    property string size: "Normal"

    spacing: units.gu(1)


    anchors {
        left: parent.left
        leftMargin: units.gu(2)
        right: parent.right
        rightMargin: units.gu(2)
    }

    function forceActiveFocus(){
        textName.forceActiveFocus()
    }

    Label {
        id: nameLabel

        visible: text !== ""
//        text: i18n.tr("Report Name")
        font.weight: Text.Normal
        color: theme.palette.normal.foregroundText
        anchors {
            left: parent.left
            right: parent.right
        }
    }

    TextField {
        id: textName
        placeholderText: i18n.tr("Enter report name ")
        hasClearButton: true
        height: switch(nameField.size){
                case "Large":
                    units.gu(5)
                    break
                default:
                    units.gu(2)
                    break
                }
        font.pixelSize: switch(nameField.size){
                        case "Large":
                            units.gu(4)
                            break
                        default:
                            units.gu(2)
                            break
                        }
        anchors {
            left: parent.left
            right: parent.right
        }

        style: TextFieldStyle {
            //overlaySpacing: 0
            //frameSpacing: 0
            background: Item {
            }
            color: theme.palette.normal.overlayText
        }
    }

}
