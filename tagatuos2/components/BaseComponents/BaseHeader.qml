import QtQuick 2.9
import Ubuntu.Components 1.3

PageHeader {
    id:root

    StyleHints {
            foregroundColor: theme.palette.normal.overlayText
            backgroundColor: theme.palette.normal.overlay
            dividerColor: UbuntuColors.slate
        }

    Behavior on height {
        UbuntuNumberAnimation {
            easing: UbuntuAnimation.StandardEasing
            duration: UbuntuAnimation.BriskDuration
        }
    }
}
