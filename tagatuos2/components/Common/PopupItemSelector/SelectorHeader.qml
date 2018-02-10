import QtQuick 2.4
import Ubuntu.Components 1.3

PageHeader {
    id: selectorHeader

    StyleHints {
        foregroundColor: theme.palette.normal.overlayText
        backgroundColor: theme.palette.normal.overlay
        dividerColor: UbuntuColors.slate
    }

    title: root.multipleSelection ? i18n.tr("Select values") : i18n.tr("Select a value")


    contents: Label {
        text: selectorHeader.title
        textSize: Label.Large
        font.weight: Font.Normal
        anchors.centerIn: parent
        fontSizeMode: Text.HorizontalFit
        horizontalAlignment: Text.Center
        color: theme.palette.normal.foregroundText
        minimumPixelSize: units.gu(3)
        elide: Text.ElideRight
    }

    trailingActionBar{
        actions: [
            Action {
                id: selectedAllAction

                text: i18n.tr("Select All")
                visible: root.multipleSelection
                iconName: "select"
                onTriggered: {
                    listView.selectAll()
                }
            },

            Action {
                id: selectedNoneAction

                text: i18n.tr("Clear Selection")
                visible: root.multipleSelection
                iconName: "select-none"
                onTriggered: {
                    listView.clearSelection()
                }
            }
        ]
    }
}
