import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import "../../../common" as Common
import "../.." as Components

ComboBox {
    id: categoryField

    readonly property bool highlighted: false
    property color color: Suru.InformationHighlight ? Suru.activeFocusColor : Suru.foregroundColor
    property Flickable flickable

    model: mainView.mainModels.categoriesModel
    textRole: "category_name"
    implicitHeight: Suru.units.gu(6)
    font.pixelSize: Suru.units.gu(2.5)
    editable: true
    focus: false
//~     inputMethodHints: Qt.ImhNoPredictiveText

    onAccepted: focusScrollConnections.focusNext()
    onActiveFocusChanged: {
        if (!activeFocus && find(editText) === -1) {
             editText = currentText
        }
    }

    background: Common.BaseBackgroundRectangle {
        control: categoryField
        radius: Suru.units.gu(1)
    }

    Components.FocusScrollConnections {
        id: focusScrollConnections

        target: textField
        flickable: categoryField.flickable
    }

    indicator: Button {
        property var control: categoryField

        width: control.height * 0.8
        height: width
        focusPolicy: Qt.NoFocus

        anchors {
            verticalCenter: parent.verticalCenter
            left: control.mirrored ? parent.left : undefined
            right: control.mirrored ? undefined : parent.right
            leftMargin: control.leftPadding
            rightMargin: control.rightPadding
        }

        icon.name: "down"
        icon.color: Suru.foregroundColor
        icon.width: Suru.units.gu(3)
        icon.height: Suru.units.gu(3)
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0

        background: Item {}

        onClicked: control.popup.open()
    }

    contentItem: TextField {
        id: textField

        property var control: categoryField

        leftPadding: control.mirrored && control.indicator ? control.indicator.width + control.spacing : 0
        rightPadding: !control.mirrored && control.indicator ? control.indicator.width + control.spacing : 0

        text: control.editable ? control.editText : control.displayText

        enabled: control.editable
        autoScroll: control.editable
        readOnly: control.down
        inputMethodHints: Qt.ImhNoPredictiveText
        validator: control.validator
        font: control.font
        Suru.highlightType: Suru.InformationHighlight
        color: control.color ? control.color : Suru.foregroundColor
        selectionColor: Suru.highlightColor
        selectedTextColor: 'white'

        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter

        background: Item {}

//~         function focusPrevious() {
//~             let _prevItem = nextItemInFocusChain(false)
//~             _prevItem.forceActiveFocus()
//~         }

//~         function focusNext() {
//~             let _nextItem = nextItemInFocusChain(true)
//~             _nextItem.forceActiveFocus()
//~         }

        onActiveFocusChanged: {
            if (activeFocus) {
                selectAll()
            }
        }
    }

}
