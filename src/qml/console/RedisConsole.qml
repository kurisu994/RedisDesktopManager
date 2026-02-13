import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../common"
import "../common/platformutils.js" as PlatformUtils
import "."
import rdm.models 1.0

Rectangle {
    id: root
    color: "#3A3A3A"

    property bool cursorInEditArea: false
    property string prompt
    property int promptPosition
    property int promptLength: prompt.length
    property alias busy: textArea.readOnly

    property string initText:
          "<span style='color: white; font-size: 13pt;'>RESP.app Redis Console</span><br/>" +
          qsTranslate("RESP","Connecting...")


    function setPrompt(txt, display) {
        console.log("set prompt: ", txt, display)
        prompt = txt

        if (display)
            displayPrompt();
    }

    function displayPrompt() {
        textArea.insert(textArea.length, prompt)
        promptPosition = textArea.length - promptLength
        //textArea.cursorPosition = textArea.length - 1
    }

    function clear() {
        textArea.clear()
    }

    function addOutput(text, type) {

        if (type == "error") {
            textArea.append("<span style='color: red; font-family: "
                            + appSettings.valueEditorFont + "'>"
                            + qmlUtils.escapeHtmlEntities(text) + '</span>')
        } else {            
            textArea.append("<code style='color: white;white-space: pre-wrap;font-family: "
                            + appSettings.valueEditorFont + "'>"
                            + qmlUtils.escapeHtmlEntities(text) + '</code>')
        }

        if (type == "complete" || type == "error") {
            textArea.blockAllInput = false
            textArea.append("<br/>")
            displayPrompt()
        }
    }

    signal execCommand(string command)

    BaseConsole {
        id: textArea
        anchors.fill: parent
        background: null
        color: "yellow"
        readOnly: root.promptLength == 0 || blockAllInput
        textFormat: TextEdit.RichText

        property bool blockAllInput: false
        property int commandStartPos: root.promptPosition + root.promptLength

        function getCurrentCommand() {
            return getText(commandStartPos, length)
        }

        Keys.onPressed: {
            if (readOnly) {
                console.log("Console is read-only. Ignore Key presses.")
                return
            }

            var cursorInReadOnlyArea = cursorPosition < commandStartPos

            if (event.key == Qt.Key_Backspace && cursorPosition <= commandStartPos) {
                event.accepted = true
                console.log("Block backspace")
                return
            }

            if (event.key == Qt.Key_Left && cursorPosition <= commandStartPos) {
                event.accepted = true
                console.log("Block left arrow")
                return
            }

            if (((event.modifiers == Qt.NoModifier) || (event.modifiers & Qt.ShiftModifier))
                    && cursorInReadOnlyArea) {
                cursorPosition = length
                event.accepted = true
                console.log("Block Input in Read-Only area")
                return
            }

            if (event.matches(StandardKey.Undo)
                    && cursorPosition == commandStartPos) {
                event.accepted = true
                console.log("Block Undo")
                return
            }

            if (selectionStart < commandStartPos
                    && (event.matches(StandardKey.Cut)
                        || event.key == Qt.Key_Delete
                        || event.key == Qt.Key_Backspace)) {
                event.accepted = true
                console.log("Block Cut/Delete")
                return
            }

            if (event.matches(StandardKey.Paste)) {
                event.accepted = true
                console.log("Block Reach Text Input")
                hiddenBuffer.text = ""
                hiddenBuffer.paste()

                if (cursorInReadOnlyArea)
                    cursorPosition = length

                insert(cursorPosition, hiddenBuffer.text.trim())

                return
            }

            if (event.key == Qt.Key_Up || event.key == Qt.Key_Down) {
                var command;

                if (commandsHistoryModel.historyNavigation) {
                    if (event.key == Qt.Key_Down) {
                        command = commandsHistoryModel.getNextCommand()
                    } else {
                        command = commandsHistoryModel.getPrevCommand()
                    }
                } else {
                    command = commandsHistoryModel.getCurrentCommand()
                }

                remove(commandStartPos, length)
                insert(commandStartPos, command)

                event.accepted = true
                return
            }

            if (event.key == Qt.Key_Return && cursorPosition > commandStartPos) {
                var command = getText(commandStartPos, length)
                blockAllInput = true
                event.accepted = true

                if (command.toLowerCase() === "clear") {
                    root.clear()
                    root.displayPrompt()
                    blockAllInput = false
                } else {
                    root.execCommand(command)
                }

                commandsHistoryModel.appendCommand(command)
            }

            autocompleteModel.filterString = "^" + getText(commandStartPos, cursorPosition) + event.text
        }

        Component.onCompleted: {
            textArea.text = root.initText
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton

            onClicked: {
                menu.popup()
            }
        }

        Menu {
            id: menu

            MenuItem {
                text: qsTranslate("RESP","Clear")
                icon.source: PlatformUtils.getThemeIcon("cleanup.svg")
                onTriggered: {
                    root.clear()
                    root.displayPrompt()
                }
            }
        }
    }

    ColumnLayout {
        objectName: "rdm_autocomplete_results"
        height: 150
        width: root.width - x - 50

        x: textArea.cursorRectangle? textArea.cursorRectangle.x : 0
        y: textArea.cursorRectangle? textArea.cursorRectangle.y + 20 : 0
        z: 255
        visible: {
            return cmdAutocomplete.count > 0
                    && autocompleteModel.filterString.length > 0
                    && textArea.cursorPosition >= textArea.commandStartPos
        }

        ListView {
            id: cmdAutocomplete            

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            model: autocompleteModel

            header: Rectangle {
                width: cmdAutocomplete.width
                height: 30
                color: sysPalette.mid
                z: 2

                Row {
                    anchors.fill: parent
                    Rectangle { width: 120; height: 30; color: "transparent"; border.color: sysPalette.dark
                        Text { anchors.fill: parent; anchors.margins: 4; text: "Command"; font.bold: true; color: sysPalette.text; verticalAlignment: Text.AlignVCenter }
                    }
                    Rectangle { width: 250; height: 30; color: "transparent"; border.color: sysPalette.dark
                        Text { anchors.fill: parent; anchors.margins: 4; text: qsTranslate("RESP","Arguments"); font.bold: true; color: sysPalette.text; verticalAlignment: Text.AlignVCenter }
                    }
                    Rectangle { width: 350; height: 30; color: "transparent"; border.color: sysPalette.dark
                        Text { anchors.fill: parent; anchors.margins: 4; text: qsTranslate("RESP","Description"); font.bold: true; color: sysPalette.text; verticalAlignment: Text.AlignVCenter }
                    }
                    Rectangle { width: 60; height: 30; color: "transparent"; border.color: sysPalette.dark
                        Text { anchors.fill: parent; anchors.margins: 4; text: qsTranslate("RESP","Available since"); font.bold: true; color: sysPalette.text; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            delegate: Rectangle {
                width: cmdAutocomplete.width
                height: 30
                color: index % 2 === 0 ? "transparent" : sysPalette.alternateBase

                property string commandName: {
                    try {
                        return consoleAutocompleteModel.getRow(
                            autocompleteModel.getOriginalRowIndex(index)
                        )["name"] || "#"
                    } catch(err) {
                        return "#"
                    }
                }

                Row {
                    anchors.fill: parent

                    // Command 列
                    Rectangle {
                        width: 120; height: 30; color: "transparent"
                        Text {
                            anchors.fill: parent; anchors.margins: 4
                            text: model.name || ""
                            elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
                            color: sysPalette.text; maximumLineCount: 1
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                textArea.remove(textArea.commandStartPos, textArea.cursorPosition)
                                textArea.insert(textArea.commandStartPos, commandName)
                                autocompleteModel.filterString = commandName
                            }
                        }
                    }

                    // Arguments 列
                    Rectangle {
                        width: 250; height: 30; color: "transparent"
                        Text {
                            anchors.fill: parent; anchors.margins: 4
                            text: model.arguments || ""
                            elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
                            color: sysPalette.text; maximumLineCount: 1
                        }
                    }

                    // Description 列
                    Rectangle {
                        width: 350; height: 30; color: "transparent"
                        Text {
                            anchors.fill: parent; anchors.margins: 4
                            text: model.summary || ""
                            elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
                            color: sysPalette.text; maximumLineCount: 1
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Qt.openUrlExternally("https://redis.io/commands/" + commandName)
                            }
                        }
                    }

                    // Available since 列
                    Rectangle {
                        width: 60; height: 30; color: "transparent"
                        Text {
                            anchors.fill: parent; anchors.margins: 4
                            text: model.since || ""
                            elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
                            color: sysPalette.text; maximumLineCount: 1
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.minimumWidth: 150
            Layout.minimumHeight: closeBtn.implicitHeight

            Item {
                Layout.fillWidth: true
            }

            Button {
                id: closeBtn
                text: qsTranslate("RESP","Close")
                onClicked: {
                    autocompleteModel.filterString = ""
                }
            }
        }
    }

    SortFilterProxyModel {
        id: autocompleteModel
        source: consoleAutocompleteModel

        filterSyntax: SortFilterProxyModel.RegExp
        filterCaseSensitivity: Qt.CaseInsensitive
        filterRole: "name"
    }

    TextArea {
        id: hiddenBuffer
        visible: false
        textFormat: TextEdit.PlainText
    }

    ListModel {
        id: commandsHistoryModel
        property int currentIndex: 0
        property bool historyNavigation: false

        function getCurrentCommand() {
            checkCurrentPos()
            var res = get(currentIndex)
            historyNavigation = true
            return res["cmd"]
        }

        function getNextCommand() {
            currentIndex += 1
            return getCurrentCommand()
        }

        function getPrevCommand() {
            currentIndex -= 1
            return getCurrentCommand()
        }

        function checkCurrentPos() {
            if (currentIndex >= count)
                currentIndex = commandsHistoryModel.count - 1

            if (currentIndex < 0)
                currentIndex = 0
        }

        function appendCommand(cmdStr) {
            append({"cmd": cmdStr})
            currentIndex = count - 1
            historyNavigation = false
        }
    }
}
