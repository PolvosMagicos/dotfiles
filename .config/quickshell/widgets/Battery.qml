import QtQuick
import Quickshell.Services.UPower
import ".." as Config
import "../style/theme.js" as Theme

Text {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property real pct: root.battery.percentage * 100

    visible: root.battery.ready && root.battery.isLaptopBattery
    text: `BAT: ${Math.round(root.pct)}%`
    font.family: Config.Theme.monoFontFamily
    font.pixelSize: Config.Theme.fontSize
    font.weight: 700

    color: {
        if (root.pct >= 80)
            return Theme.green;
        if (root.pct >= 30)
            return Theme.yellow;
        return Theme.red;
    }
}
