import QtQuick 2.12
import "../library/functions.js" as Functions

QtObject {
    id: expenseData
    
    property int expenseID: -1
    property string entryDate: Functions.getToday()
    property string name: ""
    property string description: ""
    property string category: ""
    property real value: 0
    property string tags: ""

    readonly property QtObject travelData: QtObject {
        property real rate: mainView.settings.exchangeRate
        property string homeCur: mainView.settings.currentCurrency
        property string travelCur: mainView.settings.travelCurrency
        property real value: 0
    }

    function reset() {
        expenseID = -1
        entryDate = Functions.getToday()
        name = ""
        description = ""
        category = ""
        value = 0
        tags = ""

        travelData.rate = mainView.settings.exchangeRate
        travelData.homeCur = mainView.settings.currentCurrency
        travelData.travelCur = mainView.settings.travelCurrency
        travelData.value = 0
    }
}
