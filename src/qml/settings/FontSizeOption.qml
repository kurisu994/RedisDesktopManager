import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../common"
import "."

ComboboxOption {
    id: root

    property int minFontSize: 4
    property int maxFontSize: 16

    Component.onCompleted: {
        var m = []
        for (var c=minFontSize; c <= maxFontSize; c++) {
            m.push(c)
        }
        model = m;
    }
}

