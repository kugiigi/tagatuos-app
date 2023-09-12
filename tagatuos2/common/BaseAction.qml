import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2

Action {
    id: action

    property bool visible: true
    property bool onlyShowInBottom: false
    property bool separator: false
    property bool triggerOnTriggered: true
    property string shortText: text
    property string tooltipText
    property string iconName
    icon {
        name: iconName
        color: Suru.foregroundColor
    }
    enabled: visible

    signal trigger(bool isBottom, var caller)
    onTriggered: if (triggerOnTriggered) trigger(false, parent)
}
