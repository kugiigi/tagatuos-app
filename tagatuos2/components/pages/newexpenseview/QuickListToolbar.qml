import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../../../common" as Common

Common.BaseToolbar {
    id: toolbar

    readonly property bool isFullyShown: y == (parent.height - height)

    Behavior on y {
        NumberAnimation {
            easing: Suru.animations.EasingOut
            duration: Suru.animations.BriskDuration
        }
    }

    backgroundColor: Suru.backgroundColor

    state: "shown"

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: toolbar
                y: toolbar.parent.height
            }
        },
        State {
            name: "shown"
            PropertyChanges {
                target: toolbar
                y: toolbar.parent.height - toolbar.height
            }
        }
    ]
}
