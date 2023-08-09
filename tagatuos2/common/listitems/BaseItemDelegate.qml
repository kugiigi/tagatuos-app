import QtQuick 2.12
import Lomiri.Components 1.3
import QtQuick.Controls 2.12 as QQC2
import QtQuick.Controls.Suru 2.2
import ".." as Common

QQC2.ItemDelegate {
    id: baseItemDelegate

    property string rightSideText
    property alias showDivider: backgroundRectangle.showDivider
    property alias radius: backgroundRectangle.radius
    property alias transparentBackground: backgroundRectangle.transparentBackground
    property alias backgroundColor: backgroundRectangle.backgroundColor
    property alias borderColor: backgroundRectangle.borderColor
    property alias highlightedBorderColor: backgroundRectangle.highlightedBorderColor
    property string tooltipText
    property bool interactive: true

    signal rightClicked(real mouseX, real mouseY)

    // TODO: Enable once UT's issue with hover is fixed
    hoverEnabled: false

    focusPolicy: Qt.TabFocus
    indicator: QQC2.Label {
        text: baseItemDelegate.rightSideText
        verticalAlignment: Text.AlignVCenter
        color: Suru.foregroundColor
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            rightMargin: units.gu(2)
        }
    }
    background: Common.BaseBackgroundRectangle {
        id: backgroundRectangle

        control: baseItemDelegate
        radius: Suru.units.gu(1.5)
    }

    Common.MouseAreaContext {
        anchors.fill: parent

        onTrigger: baseItemDelegate.rightClicked(mouseX, mouseY)
    }

    QQC2.ToolTip.delay: 1000
    QQC2.ToolTip.visible: hovered && baseItemDelegate.tooltipText !== ""
    QQC2.ToolTip.text: baseItemDelegate.tooltipText

    // Customize the global attached tooltip in QQC2 components
    QQC2.ToolTip.toolTip {
        readonly property real centeredImplicitWidth: Math.max(QQC2.ToolTip.toolTip.background ? QQC2.ToolTip.toolTip.background.implicitWidth : 0,
                            QQC2.ToolTip.toolTip.contentItem.implicitWidth + QQC2.ToolTip.toolTip.leftPadding + QQC2.ToolTip.toolTip.rightPadding)
        implicitWidth: Math.min(parent.width, centeredImplicitWidth)
        contentItem: QQC2.Label {
            text: QQC2.ToolTip.toolTip.text
            wrapMode: Text.WordWrap
            color: Suru.backgroundColor
        }
    }
}
