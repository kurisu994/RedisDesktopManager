import QtQuick
import QtQuick.Controls as LC
import "./platformutils.js" as PlatformUtils

LC.TableView {
    rowDelegate: Rectangle {
        height: 30
        color: styleData.selected ? sysPalette.highlight : styleData.alternate? sysPalette.alternateBase : "transparent"
    }
}
