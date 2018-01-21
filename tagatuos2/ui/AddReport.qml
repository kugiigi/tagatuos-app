import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes.Ambiance 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../components/BaseComponents"
import "../components/Common"
import "../components/AddReport"
import "../components/QChart"
import "../library"
import "../library/DataProcess.js" as DataProcess
import "../library/ProcessFunc.js" as Process

Page {
    id: root

    property string mode
    property string report_name
    property string report_type
    property string date_range
    property string date_mode
    property var filter: {"category":[],"expense_name":[]}
    property var exceptions: {"category":[],"expense_name":[]}
    property string date1
    property string date2
    property string description

    property bool isLandscape: width >= units.gu(80)

    property alias chart: chartLoader.item

    signal cancel
    signal saved

    //    header: BaseHeader {
    //        title: root.mode === "add" ? i18n.tr("Add a custom report") : i18n.tr(
    //                                         "Edit Report") + " - " + report_name
    //        flickable: flickDialog
    //    }
    onActiveChanged: {
        if (active === true) {
            if (mainView.listModels.modelCategories.count === 0) {
                mainView.listModels.modelCategories.getCategories()
            }

            textName.forceActiveFocus()

            //loads data when in edit mode
            if (mode === "edit") {
                textName.text = report_name
                textareaDescr.text = description
                typeField.savedValue = report_type
                dateModeField.savedValue = date_mode
                dateRangeField.savedValue = date_range
            }else{
                report_type = typeField.savedValue
                date_mode = dateModeField.savedValue
                date_range = dateRangeField.savedValue
            }

            chartLoader.active = true
        }
    }

    PageBackGround {
    }

    NameField {
        id: textName
        size: "Large"
        anchors {
            top: parent.top
            topMargin: units.gu(1)
        }
    }

    Loader {
        id: chartLoader

//        active: true
        asynchronous: true
        visible: status == Loader.Ready
        sourceComponent: chartComponent

        onLoaded: item.reload()

        height: root.height > units.gu(
                    100) ? units.gu(45) : root.height < units.gu(
                               80) ? units.gu(35) : root.height / 2
        width: root.isLandscape ? root.width / 2 : undefined

        anchors {
            top: textName.bottom //parent.top
            left: parent.left
            right: root.isLandscape ? undefined : parent.right
        }
    }

    Component {
        id: chartComponent

        Chart {
            id: chart

            range: root.date_range
            mode: root.date_mode
            type: root.report_type
            dateFilter1: root.date1
            dateFilter2: root.date2
            filter: root.filter
            exception: root.exceptions
        }
    }

    ScrollView {
        id: scrollView

        anchors {
            left: root.isLandscape ? chartLoader.right : parent.left
            right: parent.right
            bottom: toolBar.top
            top: root.isLandscape ? root.top : chartLoader.bottom
            topMargin: units.gu(2)
            bottomMargin: units.gu(2)
        }
        Flickable {
            id: flickDialog

            boundsBehavior: Flickable.DragAndOvershootBounds
            contentHeight: columnContent.height + units.gu(1)
            interactive: true

            anchors.fill: parent

            flickableDirection: Flickable.VerticalFlick
            clip: true

            Column {
                id: columnContent

                spacing: units.gu(2)
                anchors {
                    left: parent.left
                    right: parent.right
                }

                DescriptionField {
                    id: textareaDescr
                }

                Flow {
                    id: dropdownFlow

                    readonly property int childCount: typeField.visibleCount
                                                      + dateRangeField.visibleCount
                                                      + dateModeField.visibleCount
                    readonly property real preferredItemWidth: dropdownFlow.width / childCount
                    property real itemWidth: preferredItemWidth >= units.gu(
                                                 15) ? preferredItemWidth : dropdownFlow.width

                    height: preferredItemWidth >= units.gu(
                                15) ? units.gu(5) : undefined
                    z: 1

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    TypeField {
                        id: typeField
                        property int visibleCount: visible ? 1 : 0
                        width: dropdownFlow.itemWidth
                        onToggle: {
                            root.report_type = savedValue
                            chart.reload()
                        }
                    }
                    DateRangeField {
                        id: dateRangeField
                        property int visibleCount: visible ? 1 : 0
                        width: dropdownFlow.itemWidth
                        onToggle: {
                            root.date_range = savedValue
                            chart.reload()
                        }
                    }
                    DateModeField {
                        id: dateModeField

                        property int visibleCount: visible ? 1 : 0
                        visible: typeField.savedValue === "LINE"
                        width: dropdownFlow.itemWidth
                        onToggle: {
                            root.date_mode = savedValue
                            chart.reload()
                        }
                    }
                }

                Flow {
                    id: customDateRange

                    property real itemWidth: (dropdownFlow.width / 2) >= units.gu(
                                                 15) ? (dropdownFlow.width / 2) : dropdownFlow.width

                    visible: dateRangeField.savedValue === "Custom"
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    DateFromField {
                        id: dateFromField
                        width: customDateRange.itemWidth
                    }
                    DateToField {
                        id: dateToField
                        width: customDateRange.itemWidth
                    }
                }

                FilterException {
                    id: filterField
                    title: i18n.tr("Filter")
                    categorySavedValue: root.filter.category
                }

                FilterException {
                    id: exceptionField
                    title: i18n.tr("Exception")
                    categorySavedValue: root.exceptions.category
                }
            }
        }
    }

    Component {
        id: buttonComponent
        ActionButtonDelegate {
        }
    }

    Toolbar {
        id: toolBar

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        trailingActionBar {
            delegate: buttonComponent
            actions: Action {
                shortcut: "Ctrl+S"
                text: i18n.tr("Save")
                onTriggered: {

                    /*Commits the OSK*/
                    keyboard.target.commit()

                    var txtName = textName.text
                    var txtDescr = textareaDescr.text
                    var txtIcon = ""
                    var txtColor = colorPicker.color

                    if (Process.checkRequired([txtName]) === false) {
                        textName.forceActiveFocus()
                    } else if (txtName !== report_name
                               && DataProcess.categoryExist(txtName) === true) {
                        PopupUtils.open(dialog)
                    } else {
                        switch (mode) {
                        case "edit":
                            DataProcess.updateCategory(report_name,
                                                       txtName, txtDescr,
                                                       txtIcon, txtColor)
                            break
                        case "add":
                            DataProcess.saveCategory(txtName, txtDescr,
                                                     txtIcon, txtColor)
                            break
                        }

                        listModels.modelCategories.getItems()
                        //checkEmpty()
                        root.saved()
                    }
                }
            }
        }
        leadingActionBar {
            delegate: buttonComponent
            actions: Action {
                shortcut: "Esc"
                text: i18n.tr("Cancel")
                onTriggered: {
                    root.cancel()
                }
            }
        }
    }
    Component {
        id: dialog
        Dialog {
            id: dialogue
            title: i18n.tr("Category already exists!")
            text: i18n.tr(
                      "That category already exists. Please choose a different name.")
            Button {
                text: "OK"
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }
    Connections {
        id: keyboard
        target: Qt.inputMethod
    }
}
