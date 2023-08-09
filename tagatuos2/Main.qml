import QtQuick 2.12
import Lomiri.Components 1.3 as UT
//~ import Lomiri.Components.Themes.Ambiance 1.3 as Ambiance
//~ import Lomiri.Components.Themes.SuruDark 1.3 as SuruDark
import QtQuick.Controls 2.12
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.12
//~ import Qt.labs.settings 1.0
import UserMetrics 0.1
//~ import "components"
//~ import "components/ListModels"
//~ import "components/Common"
//~ import "ui"
import "library/DataProcess.js" as DataProcess
import "library/dataUtils.js" as DataUtils
import "library/functions.js" as Functions
import "common/pages" as PageComponents
import "components/pages" as Pages
import "components/models" as Models
import "common" as Common
import "components"

ApplicationWindow {
    id: mainView
    objectName: "mainView"

//~     readonly property QtObject drawer: drawerLoader.item
    readonly property string current_version: "1.0"
    readonly property var suruTheme: switch(settings.currentTheme) {
            case "System":
                if (Theme.name == "Lomiri.Components.Themes.SuruDark") {
                    Suru.Dark
                } else {
                    Suru.Light
                }
                break
            case "Ambiance":
                Suru.Light
                break
            case "SuruDark":
                Suru.Dark
                break
        }
    
    property string displayMode: "Phone" //"Desktop" //"Phone" //"Tablet"
//~     property QtObject theme: Suru.theme === 1 ? suruDarkTheme : ambianceTheme
    property var dataUtils: DataUtils.dataUtils
//~     property var profiles: dataUtils.profiles
    property var categories: dataUtils.categories
    property var expenses: dataUtils.expenses(settings.activeProfile)   
    property string currentDate: Functions.getToday()
    
    property alias settings: settingsLoader.item
    property alias mainModels: listModelsLoader.item
    property alias keyboard: keyboardRec.keyboard
    property alias mainPage: mainPageLoader.item
//~     property alias corePage: corePage

    title: "Tagatuos"
//~     visible: false
    visible: true
    minimumWidth: 300

    Suru.theme: suruTheme //Suru.Light //Suru.Dark

    width: switch (displayMode) {
           case "Phone":
               units.gu(50)
               break
           case "Tablet":
               units.gu(100)
               break
           case "Desktop":
               units.gu(120)
               break
           default:
               units.gu(120)
               break
           }
    height: switch (displayMode) {
            case "Phone":
                units.gu(89)
                break
            case "Tablet":
                units.gu(56)
                break
            case "Desktop":
                units.gu(68)
                break
            default:
                units.gu(68)
                break
            }

    Component.onCompleted: {
        /*Meta data processing*/
        var currentDataBaseVersion = DataProcess.checkUserVersion()

        if (currentDataBaseVersion === 0) {
            DataProcess.createInitialData()
        }

        DataProcess.databaseUpgrade(currentDataBaseVersion)
        settingsLoader.active = true
    }

//~     Ambiance.Palette { id: ambianceTheme }
//~     SuruDark.Palette { id: suruDarkTheme }

    function checkIfDayChanged() {
        if (!Functions.isToday(currentDate)) {
            currentDate = Functions.getToday()
        }
    }

    Metric {
        id: userMetric
        
        property string circleMetric

        name: "expenseCounter"
        format: circleMetric
        emptyFormat: i18n.tr("No expense yet for today")
        domain: "tagatuos2.kugiigi"
    }

    UT.MainView {
        //Only for making translation work
        id: dummyMainView
        applicationName: "tagatuos2.kugiigi"
        visible: false
    }

    Connections {
        target: Qt.application

        onStateChanged: {
            if (state == Qt.ApplicationActive) {
                checkIfDayChanged()
            }
        }
    }

    UT.LiveTimer {
        frequency: UT.LiveTimer.Hour
        onTrigger: {
            checkIfDayChanged()
        }
    }

//~     /* Reload data when day changes */
//~     LiveTimer {
//~         property var prevDate: new Date().setHours(0,0,0,0)
//~         frequency: LiveTimer.Hour
//~         onTrigger: {
//~             var now = new Date().setHours(0,0,0,0)

//~             if (+now !== +prevDate) {
//~                 var currentDate1 = mainPage.detailView.currentDate1
//~                 var currentDate2 = mainPage.detailView.currentDate2
                
//~                 switch (mainPage.detailView.currentMode) {
//~                     case "today":
//~                     case "recent":
//~                     case "yesterday":
//~                     case "yesterday":
//~                     case "thisweek":
//~                     case "thismonth":
//~                     case "lastweek":
//~                     case "lastmonth":
//~                         mainView.listModels.modelSortFilterExpense.model.load("Category")
//~                         break
//~                     case "calendar-daily":
//~                         mainView.listModels.modelSortFilterExpense.model.load("Category", currentDate1)
//~                         break
//~                     case "calendar-weekly":
//~                     case "calendar-monthly":
//~                         mainView.listModels.modelSortFilterExpense.model.load("Category", currentDate1, currentDate2)
//~                         break
//~                 }
                
//~                 mainView.listModels.dashboardModel.initialise()
//~             }
//~             prevDate = now
//~         }
//~     }

    Common.GlobalTooltip {
        id: tooltip
        parent: mainView.mainPage
        marginTop: mainPage.mainPage ? mainPage.mainPage.pageHeader.height + units.gu(5) : 0
    }

    Loader {
        id: settingsLoader

        active: false
        asynchronous: true
        sourceComponent: SettingsComponent {}

        onLoaded: listModelsLoader.active = true
    }

    Loader {
        id: listModelsLoader

        active: false
        asynchronous: true
        sourceComponent: Models.MainModels {
            id: listModels

//~             Connections {
//~                 target: tempSettings
//~                 onDashboardItemsChanged: {
//~                     dashboardModel.initialise()
//~                 }
//~             }
        }

        onLoaded: {
//~             listModels.modelCategories.getItems()
            mainPageLoader.active = true
        }
    }

    Loader {
        id: mainPageLoader

        active: false
        asynchronous: true
        visible: status == Loader.Ready
        anchors.fill: parent
        sourceComponent: PageComponents.BasePageStack {
            id: corePage
            initialItem: Pages.DetailedListPage {}
        }
    }

    Common.KeyboardRectangle {
        id: keyboardRec
    }
}
