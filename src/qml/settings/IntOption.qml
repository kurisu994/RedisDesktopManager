import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "./../common"

Item {
    id: root
    property string label
    property string description
    property int value
    property alias min: val.from
    property alias max: val.to

    onValueChanged: {
        if (val.value != root.value) {
            val.value = root.value
        }
    }

    RowLayout {
        anchors.fill: parent

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            BetterLabel {
                Layout.fillWidth: true
                Layout.fillHeight: !root.description
                text: root.label
            }

            Text {
                color: disabledSysPalette.text
                text: root.description
                visible: root.description
            }
        }

        BetterSpinBox {
            id: val

            Layout.minimumWidth: 80

            onValueChanged: {
                root.value = value
            }
        }
    }
}

