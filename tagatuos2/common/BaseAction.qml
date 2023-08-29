import QtQuick.Controls 2.12 as QQC2

QQC2.Action {
    id: action

    property bool visible: true
    property bool separator: false
    property bool triggerOnTriggered: true
    property string shortText: text
    property string tooltipText
    property string iconName
    icon.name: iconName
    enabled: visible

    signal trigger(bool isBottom, var caller)
    onTriggered: if (triggerOnTriggered) trigger(false, parent)
}
