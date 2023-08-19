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

    function reset() {
        expenseID = -1
        entryDate = Functions.getToday()
        name = ""
        description = ""
        category = ""
        value = 0
    }
}
