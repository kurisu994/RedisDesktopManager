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
        model.refreshPubSubMonitor = false
    }

    Connections {
        target: tab.model? tab.model : null

        function onPubSubChannelsChanged() {
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
            label: qsTranslate("RESP","Enable")

            onValueChanged: {
                tab.model.refreshPubSubMonitor = value
            }
        }

        ListView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true

            model: tab.model.pubSubChannels ? tab.model.pubSubChannels : []

            header: Rectangle {
                width: parent.width
                height: 30
                color: sysPalette.mid
                z: 2

                Row {
                    anchors.fill: parent
                    Rectangle {
                        width: 200; height: 30; color: "transparent"; border.color: sysPalette.dark
                        Text { anchors.fill: parent; anchors.margins: 4; text: qsTranslate("RESP","Channel Name"); font.bold: true; color: sysPalette.text; verticalAlignment: Text.AlignVCenter }
                    }
                    Rectangle {
                        width: 200; height: 30; color: "transparent"; border.color: sysPalette.dark
                        Text { anchors.fill: parent; anchors.margins: 4; text: ""; font.bold: true; color: sysPalette.text; verticalAlignment: Text.AlignVCenter }
                    }
                }
            }

            delegate: Rectangle {
                width: parent.width
                height: 50

                Row {
                    anchors.fill: parent

                    Rectangle {
                        width: 200; height: 50; color: "transparent"
                        Text {
                            anchors.fill: parent; anchors.margins: 4
                            text: modelData["addr"] || ""
                            elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
                            color: sysPalette.text
                        }
                    }

                    Rectangle {
                        width: 200; height: 50; color: "transparent"
                        BetterButton {
                            objectName: "rdm_server_info_pub_sub_subscribe_to_channel_btn"
                            anchors.centerIn: parent
                            text: qsTranslate("RESP","Subscribe in Console")
                            onClicked: {
                                var channelName = modelData["addr"] || ""
                                console.log(channelName)
                                tab.model.subscribeToChannel(channelName)
                            }
                        }
                    }
                }
            }
        }
    }
}
