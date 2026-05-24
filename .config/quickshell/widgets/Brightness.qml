import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import ".." as Config
import "." as Local
import "../style/theme.js" as Theme

Item {
    id: root

    signal toggleRequested()

    property string connectorName: ""
    property string devicePath: ""
    property string deviceName: ""
    property string backend: "none"
    property int brightnessValue: 0
    property int maxBrightness: 100
    property real pendingValue: 0
    property bool popupVisible: false
    property string iconGlyph: "☀"

    readonly property bool available: root.devicePath !== ""
    readonly property bool canSet: root.backend !== "none"
    readonly property real pct: root.maxBrightness > 0 ? root.brightnessValue / root.maxBrightness : 0

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    visible: root.available

    function refresh() {
        if (!refreshProc.running)
            refreshProc.running = true;
    }

    function closePopup() {
        root.popupVisible = false;
    }

    function togglePopup() {
        root.popupVisible = !root.popupVisible;
    }

    function scheduleSet(value) {
        if (!root.canSet || root.maxBrightness <= 0)
            return;

        root.pendingValue = Math.max(0, Math.min(1, value));
        root.brightnessValue = Math.round(root.pendingValue * root.maxBrightness);
        applyTimer.restart();
    }

    Row {
        id: content
        spacing: 4
        anchors.centerIn: parent

        Text {
            text: root.iconGlyph
            color: root.canSet ? Theme.text : Theme.overlay0
            opacity: root.canSet ? 1.0 : 0.65
            font.family: Config.Theme.monoFontFamily
            font.pixelSize: Config.Theme.fontSize
            font.weight: 700
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: ` ${Math.round(root.pct * 100)}%`
            color: root.canSet ? Theme.text : Theme.overlay0
            font.family: Config.Theme.monoFontFamily
            font.pixelSize: Config.Theme.fontSize
            font.weight: 700
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Process {
        id: refreshProc

        command: [
            "sh",
            "-c",
            "for mode in enabled connected any; do " +
            "for conn in /sys/class/drm/card*-eDP-*; do " +
            "[ -e \"$conn\" ] || continue; " +
            "status=$(cat \"$conn/status\" 2>/dev/null); " +
            "enabled=$(cat \"$conn/enabled\" 2>/dev/null); " +
            "case \"$mode\" in " +
            "enabled) [ \"$status\" = connected ] && [ \"$enabled\" = enabled ] || continue ;; " +
            "connected) [ \"$status\" = connected ] || continue ;; " +
            "any) ;; " +
            "esac; " +
            "conn_path=$(readlink -f \"$conn\"); " +
            "for dir in \"$conn_path\"/*; do " +
            "[ -d \"$dir\" ] || continue; " +
            "[ -f \"$dir/max_brightness\" ] || continue; " +
            "[ -f \"$dir/brightness\" ] || [ -f \"$dir/actual_brightness\" ] || continue; " +
            "cur=$(cat \"$dir/brightness\" 2>/dev/null || cat \"$dir/actual_brightness\" 2>/dev/null); " +
            "max=$(cat \"$dir/max_brightness\" 2>/dev/null); " +
            "[ -n \"$cur\" ] && [ -n \"$max\" ] || continue; " +
            "backend=none; " +
            "if command -v busctl >/dev/null 2>&1; then backend=logind; " +
            "elif command -v brightnessctl >/dev/null 2>&1; then backend=brightnessctl; " +
            "elif [ -w \"$dir/brightness\" ]; then backend=sysfs; fi; " +
            "printf '%s\\t%s\\t%s\\t%s\\t%s\\t%s\\n' " +
            "\"$(basename \"$conn\")\" \"$dir\" \"$(basename \"$dir\")\" \"$cur\" \"$max\" \"$backend\"; " +
            "exit 0; " +
            "done; " +
            "done; " +
            "done"
        ]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split("\t");
                if (parts.length >= 6) {
                    root.connectorName = parts[0];
                    root.devicePath = parts[1];
                    root.deviceName = parts[2];
                    root.brightnessValue = Number(parts[3]);
                    root.maxBrightness = Number(parts[4]);
                    root.backend = parts[5] !== "" ? parts[5] : "none";
                } else {
                    root.connectorName = "";
                    root.devicePath = "";
                    root.deviceName = "";
                    root.brightnessValue = 0;
                    root.maxBrightness = 100;
                    root.backend = "none";
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Timer {
        id: applyTimer
        interval: 80
        repeat: false

        onTriggered: {
            if (root.canSet && !setProc.running)
                setProc.running = true;
        }
    }

    Process {
        id: setProc

        command: [
            "sh",
            "-c",
            "if [ \"$1\" = \"logind\" ]; then " +
            "busctl call org.freedesktop.login1 /org/freedesktop/login1/session/auto " +
            "org.freedesktop.login1.Session SetBrightness ssu backlight \"$2\" \"$5\" >/dev/null 2>&1; " +
            "elif [ \"$1\" = \"brightnessctl\" ]; then " +
            "brightnessctl --class=backlight --device=\"$2\" set \"$3%\" >/dev/null 2>&1; " +
            "elif [ \"$1\" = \"sysfs\" ] && [ -n \"$4\" ] && [ -w \"$4/brightness\" ]; then " +
            "printf '%s\\n' \"$5\" > \"$4/brightness\"; " +
            "fi",
            "sh",
            root.backend,
            root.deviceName,
            String(Math.round(root.pendingValue * 100)),
            root.devicePath,
            String(Math.round(root.pendingValue * root.maxBrightness))
        ]

        stdout: StdioCollector {
            onStreamFinished: root.refresh()
        }
    }

    Local.PopupSlider {
        id: popup

        anchorItem: root
        anchorWindow: QsWindow.window
        label: "Brightness"
        iconText: root.iconGlyph
        valueText: `${Math.round(root.pct * 100)}%`
        accent: Theme.yellow
        value: root.pct
        sliderEnabled: root.canSet
        iconPixelSize: 19
        visible: root.popupVisible && root.visible

        onVisibleChanged: {
            if (!visible && root.popupVisible)
                root.popupVisible = false;
        }

        onValueDragged: root.scheduleSet(value)
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggleRequested()
    }

    onVisibleChanged: {
        if (!visible)
            root.popupVisible = false;
    }
}
