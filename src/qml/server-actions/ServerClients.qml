import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import QtCharts
import "./../common"
import "./../common/platformutils.js" as PlatformUtils
import "./../settings"
import "./../value-editor"

ServerAction {
    id: tab

    Connections {
        target: tab.model? tab.model : null

        function onClientsChanged() {
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
                tab.model.refreshClients = value
            }
        }        

        LegacyTableView {
            Layout.fillHeight: true
            Layout.fillWidth: true

            model: tab.model.clients ? tab.model.clients : []

            columns: [
                {role: "addr", title: qsTranslate("RESP","Client Address"), width: 200},
                {role: "age", title: qsTranslate("RESP","Age (sec)"), width: 75},
                {role: "idle", title: qsTranslate("RESP","Idle"), width: 75},
                {role: "flags", title: qsTranslate("RESP","Flags"), width: 75},
                {role: "db", title: qsTranslate("RESP","Current Database"), width: 120}
            ]
        }
    }
}
