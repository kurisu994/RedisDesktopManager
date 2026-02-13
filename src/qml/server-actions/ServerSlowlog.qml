import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import QtCharts
import "./../common"
import "./../common/platformutils.js" as PlatformUtils
import "./../settings"

ServerAction {
    id: tab

    function stopTimer() {
        model.refreshSlowLog = false
    }


    Connections {
        target: tab.model? tab.model : null

        function onSlowLogChanged() {
            if (uiBlocked) {
                uiBlocked = false
            }
        }
    }

    ColumnLayout {

        anchors.fill: parent
        anchors.margins: 10

        BoolOption {
            Layout.preferredWidth: 200
            Layout.preferredHeight: 40

            value: true
            label: qsTranslate("RESP","Auto Refresh")

            onValueChanged: {
                tab.model.refreshSlowLog = value
            }
        }

        ListView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true

            model: tab.model.slowLog ? tab.model.slowLog : []

            header: Rectangle {
                width: parent.width
                height: 30
                color: sysPalette.mid
                z: 2

                Row {
                    anchors.fill: parent
                    Rectangle {
                        width: 600; height: 30; color: "transparent"; border.color: sysPalette.dark
                        Text { anchors.fill: parent; anchors.margins: 4; text: qsTranslate("RESP","Command"); font.bold: true; color: sysPalette.text; verticalAlignment: Text.AlignVCenter }
                    }
                    Rectangle {
                        width: 150; height: 30; color: "transparent"; border.color: sysPalette.dark
                        Text { anchors.fill: parent; anchors.margins: 4; text: qsTranslate("RESP","Processed at"); font.bold: true; color: sysPalette.text; verticalAlignment: Text.AlignVCenter }
                    }
                    Rectangle {
                        width: 150; height: 30; color: "transparent"; border.color: sysPalette.dark
                        Text { anchors.fill: parent; anchors.margins: 4; text: qsTranslate("RESP","Execution Time (μs)"); font.bold: true; color: sysPalette.text; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            delegate: Rectangle {
                width: parent.width
                height: 30
                color: index % 2 === 0 ? "transparent" : sysPalette.alternateBase

                Row {
                    anchors.fill: parent

                    Rectangle {
                        width: 600; height: 30; color: "transparent"
                        BetterLabel {
                            anchors.fill: parent; anchors.margins: 4
                            text: {
                                var result = "";
                                var cmd = modelData['cmd'];
                                if (cmd) {
                                    for (var idx in cmd) {
                                        result += cmd[idx] + " ";
                                    }
                                }
                                return result;
                            }
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        width: 150; height: 30; color: "transparent"
                        BetterLabel {
                            anchors.fill: parent; anchors.margins: 4
                            text: {
                                return new Date(modelData['time']*1000).toLocaleString(
                                            locale, PlatformUtils.dateTimeFormat);
                            }
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        width: 150; height: 30; color: "transparent"
                        Text {
                            anchors.fill: parent; anchors.margins: 4
                            text: modelData['exec_time'] || ""
                            elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
                            color: sysPalette.text
                        }
                    }
                }
            }
        }
    }
}
