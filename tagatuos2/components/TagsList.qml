import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import "../common" as Common

Flow {
    id: tagsList

    property alias model: repeater.model

    property bool editable: false
    property int textLevel: Suru.HeadingThree

    spacing: Suru.units.gu(0.25)

    signal deleteTag(string tag)

    Repeater {
        id: repeater

        delegate: Label {
            id: tagDelegate

            z: tagHoverHandler.hovered ? 2 : 1
            text: modelData
            // Make sure text is wrapped when it exceeds the Flow's width
            width: implicitWidth > tagsList.width ? tagsList.width : implicitWidth
            Suru.textLevel: tagsList.textLevel
            wrapMode: Text.WordWrap
            color: Suru.backgroundColor
            elide: Text.ElideRight
            leftPadding: Suru.units.gu(0.5)
            rightPadding: Suru.units.gu(0.5)
            background: Rectangle {
                radius: Suru.units.gu(0.5)
                color: Suru.tertiaryForegroundColor
            }

            function deleteFromTags() {
                tagsList.deleteTag(text)
            }

            Common.BaseButton {
                id: deleteButton

                property bool temporarilyShow: false

                anchors.centerIn: parent

                onTemporarilyShowChanged: if (temporarilyShow) hideDelayTimer.restart()

                Timer {
                    id: hideDelayTimer
                    interval: 1000
                    onTriggered: deleteButton.temporarilyShow = false
                }

                visible: tagsList.editable && (tagHoverHandler.hovered || temporarilyShow)
                display: AbstractButton.IconOnly
                hoverEnabled: true

                icon {
                    name: "delete"
                    width: Suru.units.gu(1.5)
                    height: Suru.units.gu(1.5)
                    color: Suru.secondaryForegroundColor
                }

                onClicked: tagDelegate.deleteFromTags()

                ToolTip.delay: 500
                ToolTip.visible: hovered
                ToolTip.text: i18n.tr("Delete tag")
                ToolTip.onVisibleChanged: ToolTip.delay = 500
            }

            TapHandler {
                id: tagTapHandler

                acceptedPointerTypes: PointerDevice.Finger

                enabled: tagsList.editable
                onSingleTapped: deleteButton.temporarilyShow = true

                onLongPressed: {
                    tagDelegate.deleteFromTags()
                    Common.Haptics.playSubtle()
                }
            }

            HoverHandler {
                id: tagHoverHandler

                enabled: tagsList.editable
                acceptedPointerTypes: PointerDevice.GenericPointer | PointerDevice.Cursor | PointerDevice.Pen
            }
        }
    }
}
