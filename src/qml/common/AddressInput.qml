import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "."

RowLayout {    
    property alias placeholderText: textField.placeholderText
    property alias host: textField.text
    property alias port: portField.value
    property alias validationError: textField.validationError

    BetterTextField {
        id: textField
        objectName: "rdm_connection_address_host_field"
        Layout.fillWidth: true        
    }

    BetterLabel { text: ":" }

    BetterSpinBox {
        id: portField
        objectName: "rdm_connection_address_port_field"
        from: 1
        to: 10000000
        value: 22
    }
}
