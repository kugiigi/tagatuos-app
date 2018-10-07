import QtQuick 2.9
import Ubuntu.Components 1.3
import "../../components/Common"
import Ubuntu.Components.ListItems 1.3 as ListItems

Column {
    id: travelFields

    property bool isEditMode: false
    property string homeCurrency
    property string travelCurrency
    property real rate


    spacing: units.gu(1)

    anchors {
        left: parent.left
//        leftMargin: units.gu(2)
        right: parent.right
//        rightMargin: units.gu(2)
    }

//    Behavior on height { PropertyAnimation {
//            easing: UbuntuAnimation.StandardEasing
//            duration: UbuntuAnimation.SleepyDuration
//        onRunningChanged: console.log("running!")
//        }
//    }

     Behavior on height { SmoothedAnimation { velocity: 200 } }

    Row{
        id: labelRow

        anchors{
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
        }

        spacing: units.gu(2)


        Label {
            id: mainLabel
//            text: tempSettings.travelMode ? i18n.tr("Travel Mode is ON") : i18n.tr("Travel Data")
            text: root.withTravelData ? i18n.tr("Travel Data") : i18n.tr("Travel Mode is ON")
            font.weight: Text.Normal
            color: root.withTravelData ? theme.palette.normal.foregroundText: theme.palette.normal.positive
            anchors.verticalCenter: parent.verticalCenter
        }


        Button{
            id: editButton

            iconName: travelFields.isEditMode ? "close" : "edit"
            visible: root.withTravelData
            width: units.gu(1.5)
//            height: width
            color: "transparent"
            onClicked: travelFields.isEditMode = !travelFields.isEditMode
        }
    }




    Label {
        id: currencyLabel

        property color secondaryFontColor: theme.palette.normal.backgroundTertiaryText

        text: travelFields.rate + " " + '<font color=\"' + secondaryFontColor + '\">' + travelFields.homeCurrency
              + '</font>' + " = 1 " + '<font color=\"' + secondaryFontColor + '\">' + travelFields.travelCurrency +'</font>'
        visible: !travelFields.isEditMode
        font.weight: Text.Normal
        textSize: Label.Large
        color: theme.palette.normal.backgroundSecondaryText
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
        }
    }

    Loader {
        id: editCurrencyLoader

        active: travelFields.isEditMode
        asynchronous: true
        visible: status == Loader.Ready
        sourceComponent: EditCurrencyFields{}

        anchors{
            left: parent.left
            right: parent.right
        }

        UbuntuNumberAnimation on opacity {
            running: editCurrencyLoader.visible
            from: 0
            to: 1
            easing: UbuntuAnimation.StandardEasing
            duration: UbuntuAnimation.SlowDuration
        }

    }


    ListItems.ThinDivider {
        height: units.gu(0.3)
        color: theme.palette.normal.backgroundTertiaryText
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: units.gu(1)
            rightMargin: units.gu(1)
        }
    }
}
