import QtQuick
import QtQuick.Controls
import "."

BetterDialog {
    id: root

    implicitWidth: label.contentWidth + 50

    property alias text: label.text

    BetterLabel {
        id: label
        anchors.fill: parent
        anchors.margins: 10
    }

    footer: BetterDialogButtonBox {
        BetterButton {
            text: qsTranslate("RESP","OK")
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
        }
    }
}
