import QtQuick
import QtQuick.Controls

TextArea {
    id: root

    function clear() {
        text = ""
    }

    wrapMode: TextEdit.WrapAnywhere
    textFormat: TextEdit.PlainText
}
