pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import Quickshell
import Quickshell.Bluetooth as Bluez
import Quickshell.Widgets
import ".." as Config
import "../style/theme.js" as Theme

PopupWindow {
    id: root
    objectName: "bluetoothPopup"

    required property Item anchorItem
    required property var anchorWindow
    property var adapter: null
    property var pendingDevice: null
    property string errorMessage: ""
    property bool open: false
    property bool mounted: false
    readonly property bool powered: !!root.adapter && root.adapter.enabled

    signal dismissed()
    signal powerRequested()
    signal connectRequested(var device)

    color: "transparent"
    grabFocus: true
    visible: root.mounted
    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight
    anchor.window: root.anchorWindow
    anchor.adjustment: PopupAdjustment.Flip | PopupAdjustment.Slide
    anchor.onAnchoring: {
        if (!root.anchorWindow || !root.anchorItem)
            return;
        const point = root.anchorWindow.mapFromItem(root.anchorItem, Math.round((root.anchorItem.width - root.implicitWidth) / 2), root.anchorItem.height + 8);
        anchor.rect.x = Math.round(point.x);
        anchor.rect.y = Math.round(point.y);
        anchor.rect.width = 1;
        anchor.rect.height = 1;
    }

    onOpenChanged: {
        if (root.open) {
            closeAnimation.stop();
            root.mounted = true;
        } else if (root.mounted) {
            closeAnimation.restart();
        }
    }
    onVisibleChanged: {
        if (!visible && root.open) {
            root.mounted = false;
            root.dismissed();
        }
    }
    Timer {
        interval: 8000
        running: root.open
        onTriggered: root.dismissed()
    }
    SequentialAnimation {
        id: closeAnimation
        PauseAnimation { duration: 135 }
        onFinished: root.mounted = false
    }

    Rectangle {
        id: frame
        width: implicitWidth
        height: implicitHeight
        implicitWidth: 320
        implicitHeight: body.implicitHeight + 24
        radius: 12
        color: Theme.surface0
        border.width: 1
        border.color: Theme.surface2
        y: root.open ? 0 : -8
        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.98
        transformOrigin: Item.TopRight
        focus: true
        Keys.onEscapePressed: root.dismissed()

        Behavior on y {
            NumberAnimation { duration: 135; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 110; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 135; easing.type: Easing.OutCubic }
        }

        Column {
            id: body
            x: 12
            y: 12
            width: parent.width - 24
            spacing: 10

            Row {
                width: parent.width
                spacing: 8

                Text {
                    width: parent.width - powerSwitch.width - parent.spacing
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Bluetooth"
                    color: Theme.text
                    font.family: Config.Theme.monoFontFamily
                    font.pixelSize: Config.Theme.fontSize
                    font.weight: 700
                }

                Controls.Switch {
                    id: powerSwitch
                    objectName: "bluetoothPowerSwitch"
                    width: 40
                    height: 26
                    padding: 0
                    text: "Enable Bluetooth"
                    checked: root.powered
                    enabled: !!root.adapter && (root.adapter.state === Bluez.BluetoothAdapterState.Enabled || root.adapter.state === Bluez.BluetoothAdapterState.Disabled)
                    onClicked: root.powerRequested()
                    contentItem: Item {}
                    indicator: Rectangle {
                        width: 40
                        height: 22
                        y: 2
                        radius: 11
                        color: powerSwitch.checked ? Theme.blue : Theme.surface2
                        opacity: powerSwitch.enabled ? 1 : 0.5
                        border.width: powerSwitch.activeFocus ? 1 : 0
                        border.color: Theme.text
                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            x: powerSwitch.checked ? 21 : 3
                            y: 3
                            color: Theme.text
                            Behavior on x { NumberAnimation { duration: 110 } }
                        }
                    }
                }
            }

            Text {
                width: parent.width
                text: !root.adapter ? "Bluetooth unavailable" : root.adapter.state === Bluez.BluetoothAdapterState.Blocked ? "Bluetooth is blocked by the system" : !root.powered ? "Enable Bluetooth to find devices" : root.adapter.discovering ? "Scanning for devices…" : "Available devices"
                wrapMode: Text.WordWrap
                color: Theme.subtext1
                font.family: Config.Theme.monoFontFamily
                font.pixelSize: Config.Theme.fontSize
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.surface2
            }

            ListView {
                id: devices
                objectName: "bluetoothDeviceList"
                width: parent.width
                height: visible ? Math.min(count * 58, 300) : 0
                visible: root.powered
                clip: true
                spacing: 4
                boundsBehavior: Flickable.StopAtBounds
                model: root.adapter ? root.adapter.devices : null
                Controls.ScrollBar.vertical: Controls.ScrollBar {}

                delegate: Controls.Button {
                    id: deviceButton
                    required property var modelData
                    objectName: "bluetoothDevice-" + modelData.address
                    width: devices.width
                    height: 54
                    padding: 8
                    enabled: root.powered && !root.pendingDevice && !modelData.connected && !modelData.blocked && !modelData.pairing && modelData.state !== Bluez.BluetoothDeviceState.Connecting && modelData.state !== Bluez.BluetoothDeviceState.Disconnecting
                    Accessible.name: modelData.name || modelData.address
                    onClicked: root.connectRequested(modelData)
                    background: Rectangle {
                        radius: 8
                        color: deviceButton.hovered || deviceButton.activeFocus ? Theme.surface1 : "transparent"
                        border.width: deviceButton.activeFocus ? 1 : 0
                        border.color: Theme.blue
                    }
                    contentItem: Row {
                        spacing: 8
                        IconImage {
                            implicitSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                            source: Quickshell.iconPath(deviceButton.modelData.icon || "bluetooth-symbolic", true)
                            opacity: deviceButton.enabled || deviceButton.modelData.connected ? 1 : 0.5
                        }
                        Column {
                            width: deviceButton.width - deviceButton.padding * 2 - 24
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3
                            Text {
                                width: parent.width
                                text: deviceButton.modelData.name || deviceButton.modelData.address
                                elide: Text.ElideRight
                                color: deviceButton.modelData.connected ? Theme.blue : Theme.text
                                font.family: Config.Theme.monoFontFamily
                                font.pixelSize: Config.Theme.fontSize
                                font.weight: 700
                            }
                            Text {
                                width: parent.width
                                text: deviceButton.modelData.blocked ? "Blocked" : deviceButton.modelData.connected ? "Connected" : deviceButton.modelData.pairing ? "Pairing…" : root.pendingDevice === deviceButton.modelData || deviceButton.modelData.state === Bluez.BluetoothDeviceState.Connecting ? "Connecting…" : deviceButton.modelData.paired ? "Paired · Click to connect" : "Click to pair and connect"
                                elide: Text.ElideRight
                                color: Theme.subtext1
                                font.family: Config.Theme.monoFontFamily
                                font.pixelSize: Config.Theme.fontSize - 2
                            }
                        }
                    }
                }
            }

            Text {
                visible: root.powered && devices.count === 0
                text: "No devices found yet"
                color: Theme.overlay0
                font.family: Config.Theme.monoFontFamily
                font.pixelSize: Config.Theme.fontSize
            }

            Text {
                width: parent.width
                visible: root.errorMessage !== ""
                text: root.errorMessage
                wrapMode: Text.WordWrap
                color: Theme.red
                font.family: Config.Theme.monoFontFamily
                font.pixelSize: Config.Theme.fontSize - 2
            }
        }
    }
}
