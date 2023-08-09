/*
 * Copyright 2020 UBports Foundation
 *
 * This file is part of morph-browser.
 *
 * morph-browser is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * morph-browser is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import QtQuick.Controls 2.12 as QQC2
import Lomiri.Components 1.3
import QtQuick.Layouts 1.12

QQC2.RadioButton {
    id: customizedRadioButton

    enum Position {
        Right
        , Left
    }

    property alias label: mainLabel
    property int checkBoxPosition: CustomizedRadioButton.Position.Left
    property string color

    checked: false
    indicator: Item {}

    contentItem: RowLayout {
        layoutDirection: checkBoxPosition == CustomizedRadioButton.Position.Right ? Qt.LeftToRight : Qt.RightToLeft

        QQC2.Label {
            id: mainLabel

            Layout.fillWidth: true
            text: customizedRadioButton.text
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            maximumLineCount: 2
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }

        QQC2.RadioButton {
            id: radioButtonItem

            onCheckedChanged: customizedRadioButton.checked = checked
            Binding {
                target: radioButtonItem
                property: "checked"
                value: customizedRadioButton.checked
            }
        }
    }
}
