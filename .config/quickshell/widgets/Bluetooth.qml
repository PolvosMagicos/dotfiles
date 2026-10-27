pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth as Bluez
import Quickshell.Widgets
import ".." as Config
import "." as Local
import "../style/theme.js" as Theme

Item {
    id: root

    signal toggleRequested()

    property var adapter: Bluez.Bluetooth.defaultAdapter
    property bool popupVisible: false
    property var scanningAdapter: null
    property var pendingDevice: null
    property string errorMessage: ""
    property bool pairingAgentReady: false
    readonly property bool powered: !!root.adapter && root.adapter.enabled
    readonly property var connectedDevice: root.powered ? root.adapter.devices.values.find(device => device.connected) : null
    readonly property bool canToggle: !!root.adapter && (root.adapter.state === Bluez.BluetoothAdapterState.Enabled || root.adapter.state === Bluez.BluetoothAdapterState.Disabled)

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    visible: root.adapter !== null
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: "Bluetooth devices"
    Accessible.onPressAction: root.toggleRequested()
    Keys.onSpacePressed: root.toggleRequested()
    Keys.onReturnPressed: root.toggleRequested()

    function closePopup() {
        root.popupVisible = false;
    }

    function togglePopup() {
        root.popupVisible = !root.popupVisible;
    }

    function updateDiscovery() {
        const shouldScan = root.popupVisible && root.powered;
        if (root.scanningAdapter && (!shouldScan || root.scanningAdapter !== root.adapter)) {
            root.scanningAdapter.discovering = false;
            root.scanningAdapter = null;
        }
        if (shouldScan && !root.scanningAdapter && !root.adapter.discovering) {
            root.scanningAdapter = root.adapter;
            root.adapter.discovering = true;
        }
    }

    function finishConnection(message) {
        connectionTimeout.stop();
        root.pendingDevice = null;
        root.errorMessage = message;
    }

    function connectDevice(device) {
        if (!root.powered || !device || root.pendingDevice || device.connected || device.blocked || device.pairing || device.state === Bluez.BluetoothDeviceState.Connecting || device.state === Bluez.BluetoothDeviceState.Disconnecting)
            return;

        root.errorMessage = "";
        root.pendingDevice = device;
        connectionTimeout.restart();
        if (device.paired)
            device.connect();
        else if (root.pairingAgentReady)
            device.pair();
        else
            pairingAgent.running = true;
    }

    Process {
        id: pairingAgent
        command: ["busctl", "--user", "--timeout=15s", "call", "org.blueman.Applet", "/org/blueman/Applet", "org.blueman.Applet", "QueryPlugins"]
        onExited: function (exitCode, exitStatus) {
            if (exitCode === 0) {
                root.pairingAgentReady = true;
                if (root.pendingDevice && root.powered)
                    root.pendingDevice.pair();
            } else if (root.pendingDevice) {
                root.finishConnection("Could not start Blueman's pairing agent. Try again.");
            }
        }
    }

    onPopupVisibleChanged: root.updateDiscovery()
    onAdapterChanged: root.updateDiscovery()
    onPoweredChanged: {
        root.updateDiscovery();
        if (!root.powered && root.pendingDevice) {
            const device = root.pendingDevice;
            root.finishConnection("");
            if (device.pairing)
                device.cancelPair();
        }
    }
    onVisibleChanged: {
        if (!visible)
            root.closePopup();
    }
    onPendingDeviceChanged: {
        if (!root.pendingDevice)
            connectionTimeout.stop();
    }
    Component.onDestruction: {
        if (root.scanningAdapter)
            root.scanningAdapter.discovering = false;
        if (root.pendingDevice && root.pendingDevice.pairing)
            root.pendingDevice.cancelPair();
    }

    Connections {
        target: root.pendingDevice

        function onPairedChanged() {
            if (root.pendingDevice && root.pendingDevice.paired)
                root.pendingDevice.connect();
        }
        function onConnectedChanged() {
            if (root.pendingDevice && root.pendingDevice.connected)
                root.finishConnection("");
        }
        function onPairingChanged() {
            if (root.pendingDevice && !root.pendingDevice.pairing && !root.pendingDevice.paired) {
                root.pairingAgentReady = false;
                root.finishConnection("Pairing failed. Put the device in pairing mode and try again.");
            }
        }
        function onStateChanged() {
            if (root.pendingDevice && root.pendingDevice.paired && root.pendingDevice.state === Bluez.BluetoothDeviceState.Disconnected)
                root.finishConnection("Could not connect to the device. Try again.");
        }
    }

    Timer {
        id: connectionTimeout
        interval: 60000
        onTriggered: {
            const device = root.pendingDevice;
            root.finishConnection("Connection timed out. Try again.");
            if (device && device.pairing)
                device.cancelPair();
        }
    }

    Row {
        id: content
        spacing: 4
        anchors.centerIn: parent

        IconImage {
            implicitSize: 14
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -1
            source: Quickshell.iconPath("bluetooth-symbolic", true)
            layer.enabled: true
            layer.effect: MultiEffect {
                // Flatten the source color so the tint matches the text exactly.
                contrast: -1
                brightness: 0.5
                colorization: 1
                colorizationColor: root.powered ? Theme.text : Theme.overlay0
            }
        }

        Text {
            objectName: "bluetoothStatus"
            text: root.connectedDevice ? (root.connectedDevice.name || root.connectedDevice.address) : root.adapter ? Bluez.BluetoothAdapterState.toString(root.adapter.state).toLowerCase() : ""
            color: root.powered ? Theme.text : Theme.overlay0
            font.family: Config.Theme.monoFontFamily
            font.pixelSize: Config.Theme.fontSize
            font.weight: 500
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Local.BluetoothPopup {
        adapter: root.adapter
        anchorItem: content
        anchorWindow: root.QsWindow.window
        open: root.popupVisible && root.visible
        pendingDevice: root.pendingDevice
        errorMessage: root.errorMessage
        onDismissed: root.closePopup()
        onPowerRequested: {
            if (root.canToggle)
                root.adapter.enabled = !root.adapter.enabled;
        }
        onConnectRequested: device => root.connectDevice(device)
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggleRequested()
    }
}
