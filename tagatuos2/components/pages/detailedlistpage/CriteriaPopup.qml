import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import "../.." as Components
import "../../../common" as Common
import "../../../common/dialogs" as Dialogs
import "../../../library/functions.js" as Functions

Dialogs.BasePopup {
    id: criteriaPopup

    property string activeCategory
    property date dateValue

    signal select(string selectedCategory, date selectedDate)

    maximumWidth: Suru.units.gu(60)
    standardButtons: Dialog.Ok | Dialog.Cancel

    onAccepted: select(activeCategory, dateValue)

    header: Item {
        height: Suru.units.gu(7)

        Common.BaseButton {
            id: dateButton

            leftPadding: Suru.units.gu(1.5)
            rightPadding: leftPadding
            bottomPadding: leftPadding
            topPadding: leftPadding
            anchors.centerIn: parent
            focusPolicy: Qt.StrongFocus

            Suru.textLevel: Suru.HeadingTwo
            display: AbstractButton.TextOnly
            text: Functions.formatDate(criteriaPopup.dateValue, "ddd, MMMM DD, YYYY")

            onClicked: {
                highlighted = true
                var popup = datePickerComponent.createObject(detailedListPage, { dateTime: criteriaPopup.dateValue })
                popup.accepted.connect(function() {
//~                     criteriaPopup.dateValue = popup.dateTime
                    criteriaPopup.dateValue = popup.selectedDate
                })
                popup.closed.connect(function() {
                    dateButton.highlighted = false
                })
                popup.open();
            }
        }
    }

    Component {
        id: datePickerComponent
        Dialogs.DatePickerDialog {}
    }

    Item {
        anchors.fill: parent

        ButtonGroup {
            id: criteriaGroup
        }

        RadioDelegate {
            id: allRadioItem

            anchors {
               left: parent.left
               right: parent.right
            }
            text: i18n.tr("All")
            checked: criteriaPopup.activeCategory == "all"
            ButtonGroup.group: criteriaGroup
            
            onToggled: {
                if (checked) {
                    criteriaPopup.activeCategory = "all"
                }
            }

        }
  
        ListView {
            id: profilesListView
            
            clip: true
  
            model: mainView.mainModels.categoriesModel
            anchors {
                top: allRadioItem.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
  
            delegate: RadioDelegate {
                id: radioDelegate
    
                anchors {
                   left: parent.left
                   right: parent.right
                }
                text: model.category_name
                checked: criteriaPopup.activeCategory == model.category_name
                ButtonGroup.group: criteriaGroup
                
                onToggled: {
                    if (checked) {
                        criteriaPopup.activeCategory = model.category_name
                    }
                }

            }
  
            Keys.onEscapePressed: criteriaPopup.close()
        }
    }
}
