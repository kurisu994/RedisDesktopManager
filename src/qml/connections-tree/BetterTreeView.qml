import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.Models
import QtQuick.Window
import "./../common/platformutils.js" as PlatformUtils
import "./../common"
import "."

// Qt6 兼容的 TreeView 包装器
TreeView {
    id: root
    focus: true

    model: connectionsManager

    property bool sortConnections: false

    selectionModel: ItemSelectionModel {
        id: connectionTreeSelectionModel
        model: connectionsManager
    }

    delegate: Item {
        id: delegateRoot
        implicitWidth: root.width
        implicitHeight: PlatformUtils.isOSXRetina(Screen) ? 25 : 30

        required property int row
        required property int column
        required property bool current
        required property bool selected
        required property bool expanded
        required property int depth
        required property bool isTreeNode
        required property bool hasChildren
        required property var model

        // 提供与 Qt5 TreeView styleData 兼容的接口
        readonly property var styleData: QtObject {
            readonly property var value: delegateRoot.model.metadata !== undefined ? delegateRoot.model.metadata : ({})
            readonly property bool selected: delegateRoot.selected
            readonly property var index: root.index(delegateRoot.row, delegateRoot.column)
            readonly property bool isExpanded: delegateRoot.expanded
        }

        Rectangle {
            anchors.fill: parent
            color: delegateRoot.selected ? sysPalette.highlight : "transparent"
        }

        // 缩进 + 展开箭头
        Row {
            id: indentRow
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            Item { width: delegateRoot.depth * 12; height: 1 }

            // 展开/折叠箭头（使用文本替代缺失的图标）
            Text {
                width: 14; height: 14
                anchors.verticalCenter: parent.verticalCenter
                visible: delegateRoot.isTreeNode && delegateRoot.hasChildren
                text: delegateRoot.expanded ? "▼" : "▶"
                font.pixelSize: 10
                color: sysPalette.text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                TapHandler {
                    onTapped: root.toggleExpanded(delegateRoot.row)
                }
            }

            Item {
                width: (delegateRoot.isTreeNode && delegateRoot.hasChildren) ? 0 : 14
                height: 1
                visible: !(delegateRoot.isTreeNode && delegateRoot.hasChildren)
            }
        }

        TreeItemDelegate {
            id: itemRoot
            anchors.left: indentRow.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            treeRoot: root
            sortConnections: root.sortConnections

            // 注入 styleData
            property var styleData: delegateRoot.styleData
        }

        TapHandler {
            acceptedButtons: Qt.LeftButton
            onTapped: {
                var idx = root.index(delegateRoot.row, delegateRoot.column)
                root.selectionModel.setCurrentIndex(idx, ItemSelectionModel.ClearAndSelect)
                connectionsManager && connectionsManager.sendEvent(idx, "click")
            }
        }
    }

    onExpanded: function(row, depth) {
        var idx = root.index(row, 0)
        connectionsManager.setExpanded(idx)
        // 触发 click 事件加载子节点数据
        connectionsManager.sendEvent(idx, "click")
    }

    onCollapsed: function(row, depth) {
        var idx = root.index(row, 0)
        connectionsManager.setCollapsed(idx)
    }

    Connections {
        target: connectionsManager

        function onExpand(index) {
            var row = root.rowAtIndex(index)
            if (row >= 0 && !root.isExpanded(row))
                root.expand(row)
        }
    }
}
