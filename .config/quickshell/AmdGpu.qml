import QtQuick
import Quickshell.Io
import "theme.js" as Theme

Text {
    id: root

    property string value: "--"
    readonly property real pct: Number(root.value)

    text: Number.isNaN(root.pct) ? `iGPU: ${root.value}` : `iGPU: ${Math.round(root.pct)}%`
    font.pixelSize: 12
    font.weight: 500

    color: {
        if (Number.isNaN(root.pct)) return Theme.overlay0
        if (root.pct >= 80) return Theme.red
        if (root.pct >= 40) return Theme.yellow
        return Theme.sapphire
    }

    Process {
        id: amdProc
        command: [
            "sh",
            "-c",
            "for card in /sys/class/drm/card[0-9]*; do " +
            "[ -f \"$card/device/vendor\" ] || continue; " +
            "vendor=$(cat \"$card/device/vendor\" 2>/dev/null); " +
            "boot=$(cat \"$card/device/boot_vga\" 2>/dev/null || echo 0); " +
            "if [ \"$vendor\" = \"0x1002\" ] && [ \"$boot\" = \"1\" ] && [ -f \"$card/device/gpu_busy_percent\" ]; then " +
            "cat \"$card/device/gpu_busy_percent\"; exit 0; " +
            "fi; " +
            "done; " +
            "echo --"
        ]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const out = this.text.trim()
                root.value = out !== "" ? out : "--"
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            if (!amdProc.running)
                amdProc.running = true
        }
    }
}
