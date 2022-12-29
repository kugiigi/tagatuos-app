import QtQuick 2.9
import Lomiri.Components 1.3

NavigationItem{
    id: navigationWithState

    property bool isActive: false

    iconColor: isActive ? theme.palette.normal.positive : theme.palette.normal.position
}
