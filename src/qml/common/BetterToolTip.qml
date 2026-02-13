import QtQuick
import QtQuick.Controls

ToolTip {
    property string title

    visible: title && hovered
    contentItem: Text {
           text: title
           color: sysPalette.text
    }

    background: Rectangle {
        border.width: 1
        color: sysPalette.base
        border.color: sysPalette.mid
    }
}
