import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import "../../../common" as Common
import "../../../library/functions.js" as Functions
import "../.." as Components

RowLayout {
    id: navigationRow

    property string date
    property string scope: "day"
    property var dateLabels: date && scope ? Functions.getDateLabelsForNavigation(date, scope) : ["", "", ""]
    property string category

    property alias itemTitle: itemLabel.text
    property alias dateTitle: longDateLabel.text

    property bool isExpanded: true
    property bool dateIsCurrent: false

    readonly property bool noFilter: category === "all"
    readonly property string categoryLabel: noFilter ? i18n.tr("All")
                                                     : mainView.mainModels.categoriesModel.getItem(category, "category_name").category_name

    signal criteria
    signal next
    signal previous
    signal nextData
    signal previousData

    onNext: Common.Haptics.playSubtle()
    onPrevious: Common.Haptics.playSubtle()
    onNextData: Common.Haptics.play()
    onPreviousData: Common.Haptics.play()

    spacing: 0

    Common.BaseButton {
        id: detailsButton

        Layout.fillWidth: true
        Layout.fillHeight: true

        onClicked: navigationRow.criteria()

        ColumnLayout {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: Suru.units.gu(2)
                right: parent.right
                rightMargin: anchors.leftMargin
            }

            spacing: Suru.units.gu(1.25)

            Components.ColoredLabel {
                id: longDateLabel

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                visible: !navigationRow.isExpanded
                fontSizeMode: Text.HorizontalFit
                font.pixelSize: Suru.units.gu(2)
                minimumPixelSize: Suru.units.gu(2)
                font.italic: true
                role: "date"
            }

            Components.ColoredLabel {
                id: secondaryDateLabel

                Layout.fillWidth: true

                visible: navigationRow.isExpanded
                verticalAlignment: Text.AlignBottom
                fontSizeMode: Text.HorizontalFit
                font.pixelSize: Suru.units.gu(2.5)
                minimumPixelSize: Suru.units.gu(1.5)
                role: "date"
                text: dateLabels ? dateLabels[1] : ""
                Behavior on font.pixelSize {
                    NumberAnimation {
                        duration: Suru.animations.SnapDuration
                    }
                }
            }

            RowLayout {
                visible: navigationRow.isExpanded
                spacing: Suru.units.gu(2)

                Components.ColoredLabel {
                    id: mainDateLabel

                    Layout.alignment: Qt.AlignLeft

                    horizontalAlignment: Text.AlignHCenter
                    fontSizeMode: Text.HorizontalFit
                    font.pixelSize: Suru.units.gu(5)
                    minimumPixelSize: Suru.units.gu(2)
                    font.weight: Font.DemiBold
                    role: "date"
                    text: dateLabels ? dateLabels[0] : ""
                    color: navigationRow.dateIsCurrent ? Suru.secondaryBackgroundColor : Suru.secondaryForegroundColor
                    background: Rectangle {
                        visible: opacity > 0
                        opacity: navigationRow.dateIsCurrent ? 1 : 0
                        color: Suru.secondaryForegroundColor
                        radius: Suru.units.gu(1.5)
                        Behavior on opacity {
                            NumberAnimation {
                                duration: Suru.animations.BriskDuration
                            }
                        }
                    }
                    topInset: Suru.units.gu(-0.5)
                    bottomInset: Suru.units.gu(-0.5)
                    leftInset: Suru.units.gu(-0.5)
                    rightInset: Suru.units.gu(-0.5)
                    Behavior on font.pixelSize {
                        NumberAnimation {
                            duration: Suru.animations.SnapDuration
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Suru.animations.BriskDuration
                        }
                    }
                }

                Components.ColoredLabel {
                    id: itemLabel

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    visible: !navigationRow.noFilter
                    fontSizeMode: Text.HorizontalFit
                    font.pixelSize: Suru.units.gu(3)
                    minimumPixelSize: Suru.units.gu(1.5)
                    Suru.textLevel: Suru.HeadingOne
                    text: navigationRow.noFilter ? i18n.tr("All")
                                        : mainView.mainModels.categoriesModel.getItem(navigationRow.category, "category_name").category_name
                    role: "category"
                }
            }
        }
    }

    Common.BaseButton {
        id: prevButton

        Layout.fillHeight: true
        display: AbstractButton.IconOnly
        icon {
            name: "previous"
            height: Suru.units.gu(3)
            width: Suru.units.gu(3)
        }
        onClicked: navigationRow.previous()
        onPressAndHold: navigationRow.previousData()
        onRightClicked: navigationRow.previousData()
    }

    Common.BaseButton {
        id: nextButton

        Layout.fillHeight: true
        display: AbstractButton.IconOnly
        icon {
            name: "next"
            height: Suru.units.gu(3)
            width: Suru.units.gu(3)
        }
        onClicked: navigationRow.next()
        onPressAndHold: navigationRow.nextData()
        onRightClicked: navigationRow.nextData()
    }
}
