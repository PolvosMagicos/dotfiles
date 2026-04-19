import QtQuick
import Quickshell.Io
import "theme.js" as Theme

Item {
    id: root

    property int used: 0
    property int total: 0
    readonly property int pct: root.total > 0 ? Math.round((root.used / root.total) * 100) : 0

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Process {
        id: memProc
        command: ["sh", "-c", "free -m | awk '/^Mem:/ { print $3 \" \" $2 }'"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(/\s+/);
                if (parts.length >= 2) {
                    root.used = Number(parts[0]);
                    root.total = Number(parts[1]);
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (!memProc.running)
                memProc.running = true;
        }
    }

    Row {
        id: row

        Text {
            text: `MEM ${root.pct}%`
            color: {
                if (root.pct >= 80)
                    return Theme.red;
                if (root.pct >= 60)
                    return Theme.yellow;
                return Theme.blue;
            }
        }
    }
}
