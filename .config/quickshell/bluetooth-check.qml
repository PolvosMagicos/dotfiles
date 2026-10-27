//@ pragma IconTheme Papirus
// Run from an isolated copy with quickshell --path bluetooth-check.qml.
import QtQuick
import QtTest
import Quickshell
import Quickshell.Bluetooth as Bluez
import "widgets" as Widgets

PanelWindow {
    id: testPanel
    anchors { top: true; left: true }
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: 400
    implicitHeight: 100
    visible: true

    component FakeDevice: QtObject {
        property string name: "Test device"
        property string address: "00:00:00:00:00:00"
        property string icon: "bluetooth-symbolic"
        property bool paired: false
        property bool pairing: false
        property bool connected: false
        property bool blocked: false
        property bool batteryAvailable: false
        property real battery: 0
        property int state: Bluez.BluetoothDeviceState.Disconnected
        property int connectCalls: 0
        property int pairCalls: 0
        function connect() {
            connectCalls++;
            state = Bluez.BluetoothDeviceState.Connecting;
        }
        function pair() {
            pairCalls++;
            pairing = true;
        }
        function cancelPair() {
            pairing = false;
        }
    }

    FakeDevice { id: savedDevice; address: "00:00:00:00:00:01"; paired: true }
    FakeDevice { id: nearbyDevice; address: "00:00:00:00:00:02" }
    FakeDevice { id: blockedDevice; address: "00:00:00:00:00:03"; blocked: true }

    QtObject {
        id: mockAdapter
        property bool enabled: false
        property bool discovering: false
        property int state: enabled ? Bluez.BluetoothAdapterState.Enabled : Bluez.BluetoothAdapterState.Disabled
        property QtObject devices: QtObject {
            property var values: [savedDevice, nearbyDevice, blockedDevice]
        }
    }

    Widgets.Bluetooth {
        id: widget
        adapter: mockAdapter
        pairingAgentReady: true
        onToggleRequested: togglePopup()
    }

    Widgets.Bluetooth {
        id: missingAdapter
        adapter: null
    }

    Widgets.PopupSlider {
        id: sliderPopup
        anchorItem: widget
        anchorWindow: testPanel
        iconText: "☀"
        onDismissed: open = false
    }

    TestCase {
        id: check
        when: false

        function assert(condition, message) {
            if (!condition)
                throw new Error(message);
        }

        function test_sliderDismissal() {
            assert(sliderPopup.grabFocus, "Slider popups grab focus before showing");
            // shortcut: QtTest clicks lack Wayland input serials, verify real outside clicks manually.
            sliderPopup.grabFocus = false;
            for (const label of ["Brightness", "Volume"]) {
                sliderPopup.label = label;
                sliderPopup.open = true;
                wait(200);
                assert(sliderPopup.backingWindowVisible, label + " popup opens");
                sliderPopup.visible = false;
                assert(!sliderPopup.open && !sliderPopup.mounted, label + " popup clears its state on dismissal");
                sliderPopup.visible = Qt.binding(() => sliderPopup.mounted);
                sliderPopup.open = true;
                wait(200);
                assert(sliderPopup.backingWindowVisible, label + " popup reopens after dismissal");
                sliderPopup.open = false;
                wait(200);
                assert(!sliderPopup.mounted, label + " popup finishes closing");
            }
        }

        function test_control() {
            wait(300);
            assert(!missingAdapter.visible, "Hide when no adapter is present");
            assert(widget.visible && !widget.powered, "Display the disabled adapter");
            assert(widget.width > 16 && widget.height > 0, "Render the icon and status");
            const barStatus = findChild(widget, "bluetoothStatus");
            assert(barStatus.text === "disabled", "Show the adapter state when powered off");
            const popup = findChild(widget, "bluetoothPopup");
            assert(popup.grabFocus, "Grab focus before showing so outside clicks dismiss the popup");
            // shortcut: QtTest clicks lack Wayland input serials, verify real outside clicks manually.
            popup.grabFocus = false;
            mouseClick(widget, widget.width / 2, widget.height / 2, Qt.RightButton);
            assert(!mockAdapter.enabled && !widget.popupVisible, "Right-click has no action");
            mouseClick(widget);
            wait(200);
            const powerSwitch = findChild(widget, "bluetoothPowerSwitch");
            const deviceList = findChild(widget, "bluetoothDeviceList");
            assert(widget.popupVisible && popup.mounted, "Left-click opens the popup");
            assert(popup.backingWindowVisible && powerSwitch.visible, "Render the popup and switch");
            powerSwitch.clicked();
            wait(200);
            assert(widget.powered && mockAdapter.discovering, "Switch enables Bluetooth and starts scanning");
            assert(barStatus.text === "enabled", "Show enabled when no device is connected");
            assert(deviceList.count === 3, "Show saved and nearby devices");

            const savedRow = deviceList.itemAtIndex(0);
            assert(savedRow !== null, "Render saved-device rows");
            savedRow.clicked();
            assert(savedDevice.connectCalls === 1 && widget.pendingDevice === savedDevice, "Click connects a paired device");
            widget.connectDevice(nearbyDevice);
            assert(nearbyDevice.pairCalls === 0, "Prevent overlapping attempts");
            savedDevice.connected = true;
            savedDevice.state = Bluez.BluetoothDeviceState.Connected;
            assert(!widget.pendingDevice, "Clear the completed attempt");
            assert(barStatus.text === savedDevice.name, "Show the connected device name in the bar");
            savedDevice.name = "Renamed headphones";
            assert(barStatus.text === "Renamed headphones", "Update the bar when the connected device is renamed");
            savedDevice.name = "";
            assert(barStatus.text === savedDevice.address, "Use the address for an unnamed device");
            savedDevice.name = "Test device";
            const savedStatus = findChild(savedRow, "bluetoothDeviceStatus-" + savedDevice.address);
            assert(savedStatus.text === "Connected", "Do not show an unavailable battery level");
            savedDevice.batteryAvailable = true;
            savedDevice.battery = 0.42;
            assert(savedStatus.text === "Connected · 42% battery", "Show the reported battery percentage");
            savedDevice.battery = 0;
            assert(savedStatus.text === "Connected · 0% battery", "Keep a reported zero battery visible");
            savedDevice.batteryAvailable = false;
            assert(savedStatus.text === "Connected", "Hide the percentage when battery data disappears");

            const nearbyRow = deviceList.itemAtIndex(1);
            assert(nearbyRow !== null, "Render nearby-device rows");
            nearbyRow.clicked();
            assert(nearbyDevice.pairCalls === 1 && nearbyDevice.connectCalls === 0, "Pair a new device first");
            nearbyDevice.paired = true;
            nearbyDevice.pairing = false;
            assert(nearbyDevice.connectCalls === 1, "Connect after pairing succeeds");
            nearbyDevice.connected = true;
            nearbyDevice.state = Bluez.BluetoothDeviceState.Connected;
            assert(!widget.pendingDevice, "Finish connecting a new device");

            savedDevice.connected = false;
            assert(barStatus.text === nearbyDevice.name, "Show the remaining device after the first disconnects");
            savedDevice.state = Bluez.BluetoothDeviceState.Disconnected;
            widget.connectDevice(savedDevice);
            savedDevice.state = Bluez.BluetoothDeviceState.Disconnected;
            assert(!widget.pendingDevice && widget.errorMessage !== "", "Show connection failures and allow retry");
            nearbyDevice.connected = false;
            assert(barStatus.text === "enabled", "Restore the adapter state when all devices disconnect");
            nearbyDevice.paired = false;
            nearbyDevice.state = Bluez.BluetoothDeviceState.Disconnected;
            widget.connectDevice(nearbyDevice);
            nearbyDevice.pairing = false;
            assert(!widget.pendingDevice && widget.errorMessage !== "", "Show pairing failures");
            widget.pairingAgentReady = true;
            widget.connectDevice(blockedDevice);
            assert(blockedDevice.pairCalls === 0, "Do not connect blocked devices");

            widget.connectDevice(nearbyDevice);
            powerSwitch.clicked();
            assert(!widget.powered && !mockAdapter.discovering && !widget.pendingDevice && !nearbyDevice.pairing, "Power off stops scanning and cancels pending pairing");
            for (const state of [Bluez.BluetoothAdapterState.Blocked, Bluez.BluetoothAdapterState.Enabling, Bluez.BluetoothAdapterState.Disabling]) {
                mockAdapter.state = state;
                assert(!powerSwitch.enabled, "Disable the switch while blocked or transitioning");
            }
            mockAdapter.state = Bluez.BluetoothAdapterState.Enabled;
            mockAdapter.enabled = true;
            assert(mockAdapter.discovering, "Resume scanning when powered on");
            widget.closePopup();
            wait(200);
            assert(!mockAdapter.discovering && !popup.mounted, "Close the popup and stop its scan");
            mockAdapter.discovering = true;
            widget.togglePopup();
            widget.closePopup();
            assert(mockAdapter.discovering, "Leave another application's scan running");

            mockAdapter.discovering = false;
            widget.togglePopup();
            wait(200);
            popup.visible = false;
            assert(!widget.popupVisible && !mockAdapter.discovering, "Synchronize compositor dismissal and stop scanning");
            popup.visible = Qt.binding(() => popup.mounted);
            widget.togglePopup();
            wait(200);
            assert(popup.backingWindowVisible, "Reopen after outside dismissal");
            wait(7400);
            assert(widget.popupVisible, "Keep the popup open until 8 seconds have elapsed");
            tryVerify(() => !widget.popupVisible && !popup.mounted && !mockAdapter.discovering, 1500, "Close after 8 seconds and stop scanning");

            widget.pairingAgentReady = false;
            widget.connectDevice(nearbyDevice);
            for (let attempt = 0; attempt < 50 && !nearbyDevice.pairing; ++attempt)
                wait(100);
            assert(widget.pairingAgentReady && nearbyDevice.pairing, "Start Blueman's pairing agent before pairing");
            mockAdapter.enabled = false;
        }
    }

    Timer {
        interval: 100
        running: true
        onTriggered: {
            try {
                check.test_control();
                check.test_sliderDismissal();
                console.log("Bluetooth checks passed");
                Qt.quit();
            } catch (error) {
                console.error(error);
                Qt.exit(1);
            }
        }
    }
}
