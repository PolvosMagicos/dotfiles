import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Widgets

Row {
    spacing: 6

    readonly property var battery: UPower.displayDevice

    visible: battery.ready && battery.isLaptopBattery

    IconImage {
        source: Quickshell.hasThemeIcon(battery.iconName) ? Quickshell.iconPath(battery.iconName) : ""
        implicitSize: 18
        visible: source !== ""
    }

    Text {
        text: `${Math.round(battery.percentage * 100)}%`
    }
}
