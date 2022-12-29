import QtQuick 2.9
import Lomiri.Components 1.3

PageHeader {
    id:root

    StyleHints {
            foregroundColor: theme.palette.normal.overlayText
            backgroundColor: theme.palette.normal.overlay
            dividerColor: LomiriColors.slate
        }

    Behavior on height {
        LomiriNumberAnimation {
            easing: LomiriAnimation.StandardEasing
            duration: LomiriAnimation.BriskDuration
        }
    }
}
