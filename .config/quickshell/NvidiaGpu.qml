import QtQuick
import Quickshell.Io
import "theme.js" as Theme

Text {
    id: root

    property string value: "OFF"
    readonly property real pct: Number(root.value)

    text: Number.isNaN(root.pct) ? `dGPU: ${root.value}` : `dGPU: ${Math.round(root.pct)}%`
    font.pixelSize: 12
    font.weight: 700

    color: {
        if (root.value === "OFF") return Theme.overlay0
        if (Number.isNaN(root.pct)) return Theme.overlay0
        if (root.pct >= 80) return Theme.red
        if (root.pct >= 40) return Theme.yellow
        return Theme.green
    }

    Process {
        id: nvProc
        command: [
            "sh",
            "-c",
            "if command -v nvidia-smi >/dev/null 2>&1; then " +
            "out=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1); " +
            "if [ -n \"$out\" ]; then echo \"$out\"; else echo OFF; fi; " +
            "else echo OFF; fi"
        ]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const out = this.text.trim()
                root.value = out !== "" ? out : "OFF"
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            if (!nvProc.running)
                nvProc.running = true
        }
    }
}
