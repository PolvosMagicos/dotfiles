import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Networking
import "../style/theme.js" as Theme

Row {
    id: root
    spacing: 4

    readonly property var wifiDevice: {
        const devices = Networking.devices.values;
        for (let i = 0; i < devices.length; ++i) {
            const dev = devices[i];
            if (dev && dev.type === DeviceType.Wifi)
                return dev;
        }
        return null;
    }

    readonly property var connectedNetwork: {
        if (!root.wifiDevice)
            return null;

        const networks = root.wifiDevice.networks.values;
        for (let i = 0; i < networks.length; ++i) {
            const net = networks[i];
            if (net && net.connected)
                return net;
        }
        return null;
    }

    readonly property real strength: root.connectedNetwork ? root.connectedNetwork.signalStrength : 0

    visible: root.wifiDevice !== null

    IconImage {
        id: wifiIcon
        implicitSize: 16

        source: {
            let icon = "";

            if (!root.connectedNetwork) {
                icon = "network-wireless-offline-symbolic";
            } else if (root.strength < 0.20) {
                icon = "network-wireless-signal-none-symbolic";
            } else if (root.strength < 0.40) {
                icon = "network-wireless-signal-weak-symbolic";
            } else if (root.strength < 0.60) {
                icon = "network-wireless-signal-ok-symbolic";
            } else if (root.strength < 0.80) {
                icon = "network-wireless-signal-good-symbolic";
            } else {
                icon = "network-wireless-signal-excellent-symbolic";
            }

            return Quickshell.iconPath(icon, true);
        }

        opacity: root.connectedNetwork ? 1.0 : 0.65
    }

    Text {
        text: root.connectedNetwork ? ` ${root.connectedNetwork.name} ${Math.round(root.strength * 100)}%` : "offline"
        color: root.connectedNetwork ? Theme.text : Theme.overlay0
        font.pixelSize: 12
        font.weight: 700
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideRight
    }
}
