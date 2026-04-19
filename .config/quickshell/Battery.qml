import QtQuick
import Quickshell.Services.UPower

Text {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property real pct: root.battery.percentage * 100

    visible: root.battery.ready && root.battery.isLaptopBattery
    text: `BAT ${Math.round(root.pct)}%`

    color: {
        if (root.pct >= 80)
            return "#4caf50";   // green
        if (root.pct >= 30)
            return "#fbc02d";   // yellow
        return "#e53935";                       // red
    }
}
