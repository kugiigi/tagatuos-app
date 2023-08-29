import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
import QtCharts 2.3
import "../.." as Components
import "../../../common" as Common
import "../../../common/listitems" as ListItems
import "../../../library/functions.js" as Functions
import "../../../library/ApplicationFunctions.js" as AppFunctions

ItemDelegate {
    id: breakdownPieChart

    readonly property int currentTheme: mainView.suruTheme == Suru.Light ? ChartView.ChartThemeLight : ChartView.ChartThemeDark
    readonly property bool isEmpty: currentLabel.value == 0 && previousLabel.value == 0
//~     readonly property bool isEmpty: currentLabel.value == 0 || previousLabel.value == 0
    property alias chartTitle: titleLabel.text
    property alias model: instantiator.model
    property alias chart: chartView
    property real sideMargins: Suru.units.gu(1)
    property bool showDifference: false
    property Item originalParent: parent
    property Item selectedParent: parent

    signal rightClicked(real mouseX, real mouseY)

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0
    hoverEnabled: true

    onClicked: checked = true

    onCurrentThemeChanged: {
        delayPropertyChanges.restart()
    }

    states: [
        State {
            name: "normal"
            when: !checked
            ParentChange { target: breakdownPieChart; parent: originalParent; }
        }
        , State {
            name: "selected"
            when: checked
            ParentChange { target: breakdownPieChart; parent: selectedParent; }
        }
    ]

    transitions: Transition {
        ParentAnimation {
            id: parentAnimation

            ParallelAnimation {
                SequentialAnimation {
                    PropertyAction { target: chartView; property: "scale"; value: breakdownPieChart.checked ? 0.8 : 1 }
                    NumberAnimation {
                        target: chartView
                        property: "scale"
                        to: 1
                        easing: Suru.animations.EasingOut
                        duration: Suru.animations.BriskDuration
                    }
                }
                SequentialAnimation {
                    PropertyAction { target: breakdownPieChart; property: "opacity"; value: breakdownPieChart.checked ? 0 : 1 }
                    PropertyAction { target: breakdownPieChart.background; property: "visible"; value: false }
                    NumberAnimation {
                        target: breakdownPieChart
                        property: "opacity"
                        to: 1
                        duration: Suru.animations.BriskDuration
                    }
                    PropertyAction { target: breakdownPieChart.background; property: "visible"; value: true }
                }
            }
        }
    }

    Timer {
        id: delayPropertyChanges
        running: false
        interval: 1
        onTriggered: chartView.backgroundColor = "transparent"
    }

    background: Common.BaseBackgroundRectangle {
        control: abstractButton
        radius: Suru.units.gu(3)
    }

    contentItem: ChartView {
        id: chartView

        property bool currentHasLoaded: false
        property bool previousHasLoaded: false

        backgroundColor: "transparent"
        animationDuration: Suru.animations.SlowDuration
        legend.visible: false
        antialiasing: true
        theme: currentTheme
        margins {
            top: titleLabel.visible ? titleLabel.height + titleLabel.anchors.topMargin : breakdownPieChart.sideMargins
            bottom: breakdownPieChart.sideMargins
            left: breakdownPieChart.sideMargins
            right: breakdownPieChart.sideMargins
        }

        // Only enable animation when updating data
        Timer {
            id: disableAnimationDelay
            running: false
            interval: chartView.animationDuration
            onTriggered: chartView.animationOptions = ChartView.NoAnimation
        }

        Instantiator {
            id: instantiator

            asynchronous: true

            onObjectAdded: {
                if (index == 0) {
                    chartView.currentHasLoaded = false
                } else {
                    chartView.previousHasLoaded = false
                }
                chartView.animationOptions = ChartView.AllAnimations
                let pieSeries = chartView.createSeries(ChartView.SeriesTypePie, index == 0 ? "current" : "previous", null, null)

                for (let i = 0; i < object.data.count; i++) {
                    let _currentObj = object.data.get(i)
                    let pieSlice = pieSeries.append(_currentObj.label, _currentObj.value)
                    pieSlice.color = _currentObj.color
                }

                if (pieSeries.name == "current") {
                    currentLabel.value = pieSeries.sum
                    chartView.currentHasLoaded = true
                }

                if (pieSeries.name == "previous") {
                    previousLabel.value = pieSeries.sum
                    disableAnimationDelay.restart()
                    chartView.previousHasLoaded = true
                }

                if (index == 0) {
                    pieSeries.size = 1
                    pieSeries.holeSize = 0.8
                    pieSeries.opacity = 1

                    if (breakdownPieChart.showDifference) {
                        let _previous = chartView.series(0)
                        let _previousSum = _previous.sum
                        if (_previousSum > pieSeries.sum) {
                            pieSeries.endAngle = (pieSeries.sum / _previousSum) * 360
                        } else {
                            _previous.endAngle = (_previousSum / pieSeries.sum) * 360
                        }
                    }
                } else {
                    pieSeries.size = 0.75
                    pieSeries.holeSize = 0.6
                    pieSeries.opacity = 0.5
                }
            }

            onObjectRemoved: chartView.removeAllSeries()

            delegate: QtObject {
                property var data: model.data
            }
        }

        ColumnLayout {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: chartView.margins.top / 2
            }

            Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter

                text: breakdownPieChart.chartTitle
                visible: text.trim() !== "" && breakdownPieChart.isEmpty
                font.pixelSize: chartView.height * 0.08
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
            }

            Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter

                visible: text.trim() !== "" && breakdownPieChart.isEmpty
                font.pixelSize: chartView.height * 0.05
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
//~                 text: i18n.tr("No expenses for %1").arg(breakdownPieChart.chartTitle)
                text: i18n.tr("No expense")
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.maximumWidth: parent.width * 0.35

                visible: !breakdownPieChart.isEmpty

                Components.ColoredLabel {
                    id: currentLabel

                    property real value

                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    role: "value"
                    fontSizeMode: Text.HorizontalFit
                    font.pixelSize: chartView.height * 0.1
                    minimumPixelSize: Suru.units.gu(1)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: AppFunctions.formatMoney(value)
                }

                Components.ColoredLabel {
                    id: previousLabel

                    property real value

                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    role: "value"
                    opacity: 0.7
                    fontSizeMode: Text.HorizontalFit
                    font.pixelSize: chartView.height * 0.05
                    minimumPixelSize: Suru.units.gu(0.5)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: AppFunctions.formatMoney(value)
                }
            }
        }

        Label {
            id: titleLabel

            visible: text.trim() !== "" && !breakdownPieChart.isEmpty

            anchors {
                top: parent.top
                topMargin: Suru.units.gu(1)
                left: parent.left
                right: parent.right
            }
            font.pixelSize: chartView.height * 0.08
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
        }
        
        Rectangle {
            visible: breakdownPieChart.isEmpty
            radius: width / 2
            color: "transparent"
            border {
                width: Suru.units.dp(2)
                color: Suru.tertiaryForegroundColor
            }
            anchors {
                fill: parent
                leftMargin: chartView.margins.left
                rightMargin: chartView.margins.right
                topMargin: chartView.margins.top
                bottomMargin: chartView.margins.bottom
            }
        }

        AbstractButton {
            id: abstractButton

            property bool highlighted: false

            anchors.fill: parent
            hoverEnabled: false
            onClicked: breakdownPieChart.clicked()
            onPressAndHold: breakdownPieChart.pressAndHold()
        }

        Common.MouseAreaContext {
            anchors.fill: parent

            onTrigger: breakdownPieChart.rightClicked(mouseX, mouseY)
        }
    }
}
