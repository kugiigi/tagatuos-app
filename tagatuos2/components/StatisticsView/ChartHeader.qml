import QtQuick 2.9
import Ubuntu.Components 1.3
import "../Common"

ListItem {
    id: chartHeader

    signal reload
    signal next
    signal previous

    property string dateLabel: switch (chart.range) {
                               case "Today":
                                   i18n.tr("today")
                                   break
                               case "Yesterday":
                                   i18n.tr("yesterday")
                                   break
                               case "This Year":
                                   i18n.tr("this year")
                                   break
                               case "This Month":
                                   i18n.tr("this month")
                                   break
                               case "This Week":
                                   i18n.tr("this week")
                                   break
                               case "Last Year":
                                   i18n.tr("last year")
                                   break
                               case "Last Month":
                                   i18n.tr("last month")
                                   break
                               case "Last Week":
                                   i18n.tr("last week")
                                   break
                               case "Recent":
                                   i18n.tr("for the past 7 days")
                                   break
                               default:
                                   i18n.tr("Default")
                                   break
                               }

    HeaderWithSubtitle {
        id: headerTitle

        title: switch (chart.type) {
               case "LINE":
                   i18n.tr("Your expense trends ") + chartHeader.dateLabel
                   break
               case "PIE":
                   i18n.tr("Your expense breakdown ") + chartHeader.dateLabel
                   break
               default:
                   "Placeholder"
               }

        subtitle: if (chart.type !== "PIE") {
                      switch (chart.mode) {
                      case "Year":
                          i18n.tr("By Year")
                          break
                      case "Month":
                          i18n.tr("By Month")
                          break
                      case "Week":
                          i18n.tr("By Week")
                          break
                      case "Day":
                          i18n.tr("By Day")
                          break
                      default:
                          ""
                          break
                      }
                  } else {
                      ""
                  }

        anchors {
            left: parent.left
            leftMargin: units.gu(1)
            right: actionBar.left
            top: parent.top
            bottom: parent.bottom
        }
    }

    ActionBar {
        id: actionBar

        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            rightMargin: units.gu(1)
        }

        actions: [
            Action {
                id: refreshAction

                iconName: "view-refresh"
                onTriggered: {
                    reload()
                }
            },
            Action {
                iconName: "next"
                onTriggered: next()
            },
            Action {
                iconName: "previous"
                onTriggered: previous()
            }
        ]
    }
}
