import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import Lomiri.Components 1.3 as UT
import QtQuick.Layouts 1.12
import "../../../common/listitems" as ListItems
import "../../../library/ApplicationFunctions.js" as AppFunctions
import "../.." as Components

Item {
    id: gridDelegate

    readonly property bool isGridDisplay: GridView.view.gridType == QuickListGridView.GridType.Rectangle
    property int type: QuickListGridView.Type.QuickList
    property string expenseName
    property string categoryName
    property string description
    property string value

    signal clicked
    signal rightClicked(real mouseX, real mouseY)
    signal doubleClicked
    signal pressAndHold
    signal pressed
    signal released

    width: GridView.view.cellWidth
    height: GridView.view.cellHeight

    ListItems.BaseItemDelegate {
        anchors {
            fill: parent
            margins: gridDelegate.isGridDisplay ? Suru.units.gu(1) : Suru.units.gu(0.8)
        }
        
        onClicked: gridDelegate.clicked()
        onRightClicked: gridDelegate.rightClicked(mouseX, mouseY)
        onDoubleClicked: gridDelegate.doubleClicked()
        onPressAndHold: gridDelegate.pressAndHold()
        onPressed: gridDelegate.pressed()
        onReleased: gridDelegate.released()

        tooltipText: gridDelegate.description

        indicator: Item {
            anchors {
                right: parent.right
                verticalCenter: parent.top
                verticalCenterOffset: gridDelegate.isGridDisplay ? 0 : height * 0.2
            }
            width: indicatorLayout.width
            height: indicatorLayout.height

            RowLayout {
                id: indicatorLayout

                Rectangle {
                    id: categoryRec

                    radius: height / 4
                    color: AppFunctions.getCategoryColor(gridDelegate.categoryName)
                    width: categoryLayout.width
                    height: categoryLayout.height

                    RowLayout {
                        id: categoryLayout

                        Label {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.bottomMargin: Suru.units.gu(0.2)
                            Layout.topMargin: Suru.units.gu(0.2)
                            Layout.leftMargin: Suru.units.gu(0.5)
                            Layout.rightMargin: Suru.units.gu(0.5)
                            Suru.textLevel: Suru.Small
                            color: AppFunctions.getContrastYIQ(categoryRec.color) ? "#111111" : "#F7F7F7" // Black - White
                            text: gridDelegate.categoryName
                        }
                    }
                }

                Rectangle {
                    radius: height / 4
                    color: Suru.tertiaryForegroundColor
                    width: Suru.units.gu(2.5)
                    height: width

                    UT.Icon {
                        anchors.centerIn: parent
                        width: Suru.units.gu(2)
                        height: width
                        name: type == QuickListGridView.Type.QuickList ? "starred" : "history"
                        color: Suru.backgroundColor
                    }
                }
            }
        }

        contentItem: Item {
            id: layout

            implicitHeight: layout.height
            implicitWidth: layout.width

            ColumnLayout {
                id: contentItemColumnLayout

                spacing: Suru.units.gu(0.5)
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                RowLayout {
                    id: rowLayout

                    Layout.alignment: Qt.AlignCenter

                    ColumnLayout {
                        id: nameDescrColumnLayout

                        spacing: 0

                        Components.ColoredLabel {
                            id: mainLabel

                            Layout.fillWidth: true
                            Layout.preferredHeight: font.pixelSize * maximumLineCount

                            visible: text !== ""
                            Suru.textLevel: Suru.HeadingThree
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: gridDelegate.expenseName
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            minimumPixelSize: Suru.units.gu(1.5)
                            fontSizeMode: Text.HorizontalFit
                            elide: Text.ElideRight
                        }
                    }
                }

                Components.ColoredLabel {
                    id: descrLabel

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter

                    Suru.textLevel: Suru.Caption
                    color: Suru.secondaryForegroundColor
                    horizontalAlignment: gridDelegate.isGridDisplay ? Text.AlignHCenter : Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    visible: gridDelegate.description !== ""
                    text: gridDelegate.description
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }

                Components.ColoredLabel {
                    id: valueLabel

                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter

                    Suru.textLevel: gridDelegate.isGridDisplay ? Suru.Paragraph : Suru.HeadingThree
                    verticalAlignment: Text.AlignVCenter
                    visible: gridDelegate.value > 0
                    text: AppFunctions.formatMoney(gridDelegate.value, false)
                    role: "value"
                }

                states: [
                    State {
                        name: "grid"
                        when: gridDelegate.isGridDisplay
                        ParentChange {
                            target: descrLabel
                            parent: contentItemColumnLayout
                        }
                        ParentChange {
                            target: valueLabel
                            parent: contentItemColumnLayout
                        }
                        PropertyChanges {
                            target: mainLabel
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    , State {
                        name: "list"
                        when: !gridDelegate.isGridDisplay
                        ParentChange {
                            target: descrLabel
                            parent: nameDescrColumnLayout
                        }
                        ParentChange {
                            target: valueLabel
                            parent: rowLayout
                        }
                        PropertyChanges {
                            target: mainLabel
                            horizontalAlignment: Text.AlignLeft
                        }
                    }
                ]
            }
        }
    }
}
