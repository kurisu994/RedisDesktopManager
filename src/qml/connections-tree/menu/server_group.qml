import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "."
import "./../../common/platformutils.js" as PlatformUtils

InlineMenu {
    id: root

    model: {
        return [
                    {
                        'icon': PlatformUtils.getThemeIcon("settings.svg"), 'event': 'edit', "help": qsTranslate("RESP","Edit Connection Group"),
                        "shortcut": "Ctrl+E",
                    },
                    {
                        'icon': PlatformUtils.getThemeIcon("delete.svg"), 'event': 'delete', "help": qsTranslate("RESP","Delete Connection Group"),
                        "shortcut": "D",
                    },
                ]
    }
}
