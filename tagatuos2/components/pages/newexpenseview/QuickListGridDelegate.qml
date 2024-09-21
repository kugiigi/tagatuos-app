import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import Lomiri.Components 1.3 as UT
import QtQuick.Layouts 1.12
import "../../../common" as Common
import "../../../common/listitems" as ListItems
import "../../../library/ApplicationFunctions.js" as AppFunctions
import "../.." as Components

Item {
    id: gridDelegate

    readonly property bool isGridDisplay: GridView.view.gridType == QuickListGridView.GridType.Rectangle
    property alias highlighted: itemDelegate.highlighted
    property int type: QuickListGridView.Type.QuickList
    property string expenseName
    property string categoryName
    property string description
    property string value

    property bool isTravelMode: false
    property string travelCurrency

    signal clicked
    signal rightClicked(real mouseX, real mouseY)
    signal doubleClicked
    signal pressAndHold
    signal pressed
    signal released

    width: GridView.view.cellWidth
    height: GridView.view.cellHeight

    ListItems.BaseItemDelegate {
        id: itemDelegate

        anchors {
            fill: parent
            margins: gridDelegate.isGridDisplay ? Suru.units.gu(1) : Suru.units.gu(0.8)
        }
        
        onClicked: gridDelegate.clicked()
        onRightClicked: gridDelegate.rightClicked(mouseX, mouseY)
        onDoubleClicked: gridDelegate.doubleClicked()
        onPressAndHold: {
            Common.Haptics.play()
            gridDelegate.pressAndHold()
        }
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
                
                Components.CategoryRectangle {
                    id: categoryRec

                    categoryName: gridDelegate.categoryName
                    visible: categoryName
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
                            Layout.maximumHeight: font.pixelSize * maximumLineCount

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
                    text: gridDelegate.isTravelMode ? AppFunctions.formatMoneyTravel(gridDelegate.value, false)
                                        : AppFunctions.formatMoney(gridDelegate.value, false)
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
