import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "../components/Common"
import "../components/BaseComponents"
import "../library"
import "../library/DataProcess.js" as DataProcess
import "../library/ProcessFunc.js" as Process


Page {

    property string pagemode
    property string currentCategory
    property string currentDescription
    property color currentColor
    property string dialogResponse

    id: root


    header: BaseHeader {
        title: i18n.tr("Reports")

        trailingActionBar.actions: [
            Action {
                iconName: "add"
                text: i18n.tr("Add")
                onTriggered: {
                    addNew()
                }
            }
        ]
    }


    BottomEdge {
        id: bottomEdgePage

        hint {
            visible: false
            enabled: false
        }

        height: parent ? parent.height : 0
        enabled: false
        visible: false

        contentComponent: Item {
            id: pageContent
            implicitWidth: bottomEdgePage.width
            implicitHeight: bottomEdgePage.height
            children: bottomEdgePage._realPage
        }

        property var _realPage: null

        function commitWithProperties(properties) {
            _realPage.destroy()
            _realPage = addReportComponent.createObject(null, properties)
            commit()
        }

        Component.onCompleted: {
            _realPage = addReportComponent.createObject(null)
        }

        Component.onDestruction: {
            _realPage.destroy()
        }

        onCollapseCompleted: {
            _realPage.active = false
            _realPage.destroy()
            _realPage = addReportComponent.createObject(null)
        }

        onCommitCompleted: {
            _realPage.active = true
        }

        Component {
            id: addReportComponent
            AddReport {
                id: addReportPage
                anchors.fill: parent
                onCancel: bottomEdgePage.collapse()
                onSaved: bottomEdgePage.collapse()
            }
        }
    }

    //functions
    function addNew() {
        root.openAddReport("add")
    }

    function loadReports() {
        groupedList.model.getItems()
    }


    function openAddReport(mode) {
        root.pagemode = mode

        var properties = {

        }

        properties["mode"] = root.pagemode
        properties["category_name"] = root.currentCategory
        properties["description"] = root.currentDescription
        properties["categoryColor"] = root.currentColor
                === "" || mode === "add" ? "white" : root.currentColor
        bottomEdgePage.commitWithProperties(properties)
    }

    onActiveChanged: {
        if (active === true) {
            loadReports()
        }
    }

    EmptyState {
        id: emptyState
        iconName: "x-office-spreadsheet-symbolic"
        title: i18n.tr("No custom reports")
        subTitle: i18n.tr("Use the '+' button to add custom reports")
        anchors {
            right: parent.right
            left: parent.left
            verticalCenter: parent.verticalCenter
            margins: units.gu(1)
        }

        shown: groupedList.model.loadingStatus === "Ready" && groupedList.model.count === 0
    }


    ScrollView {
        anchors.fill: parent
        anchors.topMargin: root.header.height
        UbuntuListView {
            id: groupedList

            property string report_id

            anchors.fill: parent
            interactive: true
            model: mainView.listModels.modelReports
            clip: true
            currentIndex: -1
            highlightFollowsCurrentItem: true
            highlight: ListViewHighlight {
            }
            highlightMoveDuration: 200


            UbuntuNumberAnimation on opacity {
                running: groupedList.count > 0
                from: 0
                to: 1
                easing: UbuntuAnimation.StandardEasing
                duration: UbuntuAnimation.FastDuration
            }

            delegate: ListItem {
                id: listWithActions

                property int currentIndex: index
                property string itemAction: dialogResponse

                ListItemLayout {
                    id: layout
                    title.text: report_name
                    subtitle.text: switch(type){
                                   case "LINE":
                                       i18n.tr("Trends")
                                       break
                                   case "PIE":
                                       i18n.tr("Breakdown")
                                       break
                                   default:
                                       i18n.tr("Chart")
                                       break
                                   }
                }

                onItemActionChanged: {
                    if (dialogResponse === "YES"
                            && report_id === groupedList.report_id) {
                        DataProcess.deleteReport(report_id)
                        groupedList.model.remove(currentIndex)
                    }
                }

                leadingActions: ListItemActions {
                    id: leading
                    actions: Action {
                        iconName: "delete"
                        text: i18n.tr("Delete")
                        onTriggered: {
                            dialogResponse = ""
                            groupedList.report_id = report_id
                            PopupUtils.open(dialog)
                        }
                    }
                }

                trailingActions: ListItemActions {
                    id: trailing
                    actions: [
                        Action {
                            iconName: "edit"
                            text: i18n.tr("Edit")
                            onTriggered: {
                                root.currentCategory = category_name
                                root.currentDescription = descr
                                root.currentColor = colorValue
                                        === "default" ? "white" : colorValue
                                root.openAddReport("edit")
                            }
                        }
                    ]
                }
            }
        }
    }

    Component {
        id: dialog
        Dialog {
            id: dialogue
            title: i18n.tr("Delete Report")
            text: i18n.tr("Are you sure you want to delete this report?")
            Row {
                id: buttonsRow
                spacing: width * 0.1
                Button {
                    text: i18n.tr("Cancel")
                    width: parent.width * 0.45
                    onClicked: PopupUtils.close(dialogue)
                }
                Button {
                    text: i18n.tr("Delete")
                    color: UbuntuColors.red
                    width: parent.width * 0.45
                    onClicked: {
                        dialogResponse = "YES"
                        PopupUtils.close(dialogue)
                    }
                }
            }
        }
    }
}
