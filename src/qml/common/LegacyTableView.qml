import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./platformutils.js" as PlatformUtils

// Qt6 兼容的简易表格组件，替代 Qt5 Controls 1.x TableView
// 使用者需要定义 columns 和 delegate
ListView {
    id: tableRoot
    clip: true

    // 列定义：[{role: "xxx", title: "XXX", width: 100, delegate: Component}, ...]
    property var columns: []

    // 表头
    header: Rectangle {
        width: tableRoot.width
        height: 30
        color: sysPalette.mid
        z: 2

        Row {
            anchors.fill: parent
            Repeater {
                model: tableRoot.columns
                Rectangle {
                    width: modelData.width || 100
                    height: 30
                    color: "transparent"
                    border.color: sysPalette.dark
                    border.width: 1

                    Text {
                        anchors.fill: parent
                        anchors.margins: 4
                        text: modelData.title || ""
                        font.bold: true
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        color: sysPalette.text
                    }
                }
            }
        }
    }

    // 默认 delegate：显示列数据
    delegate: Rectangle {
        width: tableRoot.width
        height: 30
        color: index % 2 === 0 ? "transparent" : sysPalette.alternateBase

        Row {
            anchors.fill: parent
            Repeater {
                model: tableRoot.columns
                Rectangle {
                    width: modelData.width || 100
                    height: 30
                    color: "transparent"

                    Text {
                        anchors.fill: parent
                        anchors.margins: 4
                        text: {
                            var role = modelData.role
                            if (!role) return ""
                            var item = tableRoot.model[index]
                            if (item && item[role] !== undefined) return String(item[role])
                            return ""
                        }
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        color: sysPalette.text
                    }
                }
            }
        }
    }
}
