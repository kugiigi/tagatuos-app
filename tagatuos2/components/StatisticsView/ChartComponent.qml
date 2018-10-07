import QtQuick 2.9
import Ubuntu.Components 1.3
import "../Common"
import "../QChart"

Item {
    id: root

    property var model: [{range: "This Year",mode: "Month",type: "LINE"},{range: "This Week",mode: "Day",type: "LINE"},{range: "Recent",mode: "Day",type: "PIE"},{range: "This Month",mode: "Day",type: "PIE"},{range: "Last Month",mode: "Day",type: "PIE"}]
    property int currentModelIndex: 0
    property alias chart: chartLoader.item

    function next(){
        timer.restart()
        if(currentModelIndex === (model.length - 1)){
            currentModelIndex = 0
        }else{
            currentModelIndex++
        }

        chart.reload()
    }

    function previous(){
        timer.restart()
        if(currentModelIndex === 0){
            currentModelIndex = (model.length - 1)
        }else{
            currentModelIndex--
        }

        chart.reload()
    }

    Timer{
        id: timer

        interval: 8000
        running: mainPage.currentPage === "Statistics" //true

        onTriggered: root.next()
    }


    ChartHeader{
        id: chartHeader

        anchors{
            left: parent.left
            right: parent.right
            top: parent.top
        }

        onReload: {
            timer.restart()
            chart.reload()
        }
        onNext: root.next()
        onPrevious: root.previous()
    }


    Loader {
        id: chartLoader

        active: true
        asynchronous: true
        visible: status == Loader.Ready
        sourceComponent: chartComponent

        onLoaded: item.reload()

        anchors{
            top: chartHeader.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
    }

    Component {
        id: chartComponent

        Chart{
            id: chart

            range: model[currentModelIndex].range
            mode: model[currentModelIndex].mode
            type: model[currentModelIndex].type

            onDoubleClicked: {
                root.next()
            }
        }
    }
}
