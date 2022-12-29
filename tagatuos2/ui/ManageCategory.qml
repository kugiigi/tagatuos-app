import QtQuick 2.9
import Lomiri.Components 1.3
import Lomiri.Components.Themes.Ambiance 1.3
import "../components"
import "../components/Common"
import "../components/BaseComponents"
import "../library"
import Lomiri.Components.Popups 1.3
import "../library/DataProcess.js" as DataProcess
import "../library/ProcessFunc.js" as Process


Page {

    property string pagemode
    property string currentCategory
    property string currentDescription
    property color currentColor
    property string dialogResponse

    id: pageCategories


    header: BaseHeader {
        title: i18n.tr("Categories")

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
            _realPage = addCategoryComponent.createObject(null, properties)
            commit()
        }

        Component.onCompleted: {
            _realPage = addCategoryComponent.createObject(null)
        }

        Component.onDestruction: {
            _realPage.destroy()
        }

        onCollapseCompleted: {
            _realPage.active = false
            _realPage.destroy()
            _realPage = addCategoryComponent.createObject(null)
        }

        onCommitCompleted: {
            _realPage.active = true
        }

        Component {
            id: addCategoryComponent
            AddCategory {
                id: addCategoryPage
                anchors.fill: parent
                onCancel: bottomEdgePage.collapse()
                onSaved: bottomEdgePage.collapse()
            }
        }
    }

    //functions
    function addNew() {
        pageCategories.openAddCategory("add")
    }

    function loadCategories() {
        mainView.listModels.modelCategories.getItems()
        checkEmpty()
    }

    function checkEmpty() {
        if (mainView.listModels.modelCategories.count === 0) {
            emptyState.visible = true
        } else {
            emptyState.visible = false
        }
    }

    function openAddCategory(mode) {
        pageCategories.pagemode = mode
        //pageCategories.bottomEdgeState = "expanded"
        var properties = {

        }

        properties["mode"] = pageCategories.pagemode
        properties["category_name"] = pageCategories.currentCategory
        properties["description"] = pageCategories.currentDescription
        properties["categoryColor"] = pageCategories.currentColor
                === "" || mode === "add" ? "white" : pageCategories.currentColor
        bottomEdgePage.commitWithProperties(properties)
    }

    onActiveChanged: {
        //bottomEdge.edgeState = "collapsed"
        if (active === true) {
            loadCategories()
        }
    }

    EmptyState {
        id: emptyState
        iconName: "stock_note"
        title: i18n.tr("No Category Exists")
        subTitle: i18n.tr("Tap/Click the '+' button to add categories")
        anchors {
            right: parent.right
            left: parent.left
            verticalCenter: parent.verticalCenter
            margins: units.gu(1)
        }
    }

    ScrollView {
        anchors.fill: parent
        anchors.topMargin: pageCategories.header.height
        LomiriListView {
            id: groupedList

            property string category

            anchors.fill: parent
            interactive: true
            model: mainView.listModels.modelCategories
            clip: true
            currentIndex: -1
            highlightFollowsCurrentItem: true
            highlight: ListViewHighlight {
            }
            highlightMoveDuration: 200


            LomiriNumberAnimation on opacity {
                running: groupedList.count > 0
                from: 0
                to: 1
                easing: LomiriAnimation.StandardEasing
                duration: LomiriAnimation.FastDuration
            }

            delegate: ListItem {
                id: listWithActions

                property int currentIndex: index
                property string itemAction: dialogResponse

                divider.visible: false

                Rectangle{
                    id: categoryColorRec
                    width: units.gu(3)
                    height: width
                    transform: Rotation { origin.x: categoryColorRec.width; origin.y: categoryColorRec.height; angle: 45}
                    color: colorValue === "default" ? "white" : colorValue !== undefined ? colorValue : "white"
                    anchors{
                        verticalCenter: parent.top
                        right: parent.left
                    }
                }

                ListItemLayout {
                    id: layout
                    title.text: category_name
                    subtitle.text: descr
                }

                onItemActionChanged: {
                    if (dialogResponse === "YES"
                            && category_name === groupedList.category) {
                        DataProcess.deleteCategory(category_name)
                        groupedList.model.remove(currentIndex)
                        checkEmpty()
                    }
                }

                leadingActions: ListItemActions {
                    id: leading
                    actions: Action {
                        iconName: "delete"
                        text: i18n.tr("Delete")
                        onTriggered: {
                            dialogResponse = ""
                            groupedList.category = category_name
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
                                pageCategories.currentCategory = category_name
                                pageCategories.currentDescription = descr
                                pageCategories.currentColor = colorValue
                                        === "default" ? "white" : colorValue
                                pageCategories.openAddCategory("edit")
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
            title: i18n.tr("Delete Category")
            text: i18n.tr("Are you sure you want to delete this category?") + "<br>" + i18n.tr("If you continue, all expenses under this category will be moved under 'Uncategorized'")
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
                    color: LomiriColors.red
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
