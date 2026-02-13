import QtQuick
import QtQuick.Controls

Button {
    id: root

    property string iconSource
    property string tooltip

    icon.source: root.iconSource
    icon.width: 18
    icon.height: 18
    icon.color: "transparent"
    implicitHeight: 30
    opacity: root.enabled ? 1.0 : 0.8
    font.capitalization: Font.Capitalize

    palette.button: sysPalette.button
    palette.brightText: sysPalette.highlightedText
    palette.windowText: sysPalette.text
    palette.buttonText: enabled ? sysPalette.text : disabledSysPalette.text
    palette.highlight: sysPalette.highlight

    MouseArea {
            id: mouseArea
            anchors.fill: parent
            onPressed: function(event) { event.accepted = false }
            cursorShape: Qt.PointingHandCursor
    }

    BetterToolTip {
        title: root.tooltip
    }
}

