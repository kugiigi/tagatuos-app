import QtQuick.Controls 2.12

ToolTip {
    id: tooltip

    property int defaultTimeout: 3000
    property real marginTop: 60
    property real marginBottom: parent.height - 100

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
