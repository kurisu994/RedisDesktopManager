import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls as LC
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

        LegacyTableView {
            Layout.fillHeight: true
            Layout.fillWidth: true

            model: tab.model.slowLog ? tab.model.slowLog : []

            LC.TableViewColumn {
                role: "cmd"
                title: qsTranslate("RESP","Command")
                width: 600

                delegate: BetterLabel {
                    text: {
                        var result = "";
                        for (var index in modelData['cmd']) {
                            result += modelData['cmd'][index] + " ";
                        }
                        return result;
                    }
                    elide: styleData.elideMode
                }
            }

            LC.TableViewColumn {
                role: "time"
                title: qsTranslate("RESP","Processed at")
                width: 150

                delegate: BetterLabel {
                    text: {
                        return new Date(modelData['time']*1000).toLocaleString(
                                    locale, PlatformUtils.dateTimeFormat);
                    }
                    elide: styleData.elideMode
                }

            }

            LC.TableViewColumn {
                role: "exec_time"
                title: qsTranslate("RESP","Execution Time (μs)")
                width: 150
            }
        }
    }
}
