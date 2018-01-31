import QtQuick 2.4
import Ubuntu.Components 1.3

PageHeader {
    id: selectorHeader

    StyleHints {
        foregroundColor: theme.palette.normal.overlayText
        backgroundColor: theme.palette.normal.overlay
        dividerColor: UbuntuColors.slate
    }

    title: i18n.tr("Select value(s)")



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
}
