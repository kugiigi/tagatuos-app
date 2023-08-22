import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2

ToolTip {
    id: tooltip

    property int defaultTimeout: 3000
    property real marginTop: Suru.units.gu(10)
    property real marginBottom: parent.height - Suru.units.gu(10)

    delay: 200

    function display(customText, position, customTimeout) {
        switch(position) {
            case "TOP":
                y = Qt.binding(function() { return marginTop } );
                break;
            case "BOTTOM":
            default:
                y = Qt.binding(function() { return marginBottom } );
            break;
        }

        if (customTimeout) {
            timeout = customTimeout
        } else {
            timeout = defaultTimeout
        }

        text = customText

        visible = true
    }

    timeout: defaultTimeout
}
