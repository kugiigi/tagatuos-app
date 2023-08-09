import QtQuick 2.12

Item {
	id: keyboardRectangle
    
    property alias keyboard: keyboardConnection
		
	height: keyboardConnection.target.visible ? keyboardConnection.target.keyboardRectangle.height / (units.gridUnit / 8) : 0
	anchors{
		left: parent.left
		right: parent.right
		bottom: parent.bottom
	}

    Connections {
        id: keyboardConnection
        target: Qt.inputMethod
    }
}
 
