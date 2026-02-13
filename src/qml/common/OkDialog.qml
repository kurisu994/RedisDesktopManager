import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

// Qt6 兼容的 OkDialog，替代 Qt5 的 MessageDialog
BetterDialog {
    id: root

    property string text: ""
    property string detailedText: ""
    property var icon: undefined

    implicitWidth: 450

    contentItem: ColumnLayout {
        spacing: 10

        BetterLabel {
            text: root.text
            Layout.fillWidth: true
            Layout.margins: 10
            wrapMode: Text.WordWrap
        }

        BetterLabel {
            text: root.detailedText
            Layout.fillWidth: true
            Layout.margins: 10
            wrapMode: Text.WordWrap
            visible: root.detailedText !== ""
            font.pixelSize: 11
            color: sysPalette.mid
        }
    }

    footer: BetterDialogButtonBox {
        BetterButton {
            text: qsTranslate("RESP","OK")
            DialogButtonBox.buttonRole: DialogButtonBox.AcceptRole
            onClicked: root.close()
        }
    }
}
