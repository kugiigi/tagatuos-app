import QtQuick 2.9
import Ubuntu.Components 1.3
import "../../library/ApplicationFunctions.js" as ApplicationFunctions

Label {
    id: categoryLabel

    property real recMargin: units.gu(0.3)

    text: root.category
    font.weight: Font.Normal
    textSize: Label.Small
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere


    Rectangle{
        id: categoryRectangle

        z: categoryLabel.z - 1
        radius: units.gu(0.2)

        color: listModels.modelCategories.getColor(root.category)
        width: categoryLabel.contentWidth + categoryLabel.recMargin * 2
        height: categoryLabel.height

        anchors{
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: -categoryLabel.recMargin
        }

        onColorChanged: {
            categoryLabel.color = ApplicationFunctions.getContrastYIQ(categoryRectangle.color) ? UbuntuColors.jet : UbuntuColors.porcelain
        }
    }

}
