import QtQuick
import Quickshell.Io
import "theme.js" as Theme

Item {
    id: root

    property int pct: 0

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Process {
        id: cpuProc
        command: ["sh", "-c", "read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; total1=$((user + nice + system + idle + iowait + irq + softirq + steal)); idle1=$((idle + iowait)); sleep 1; read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat; total2=$((user + nice + system + idle + iowait + irq + softirq + steal)); idle2=$((idle + iowait)); diff_total=$((total2 - total1)); diff_idle=$((idle2 - idle1)); if [ \"$diff_total\" -gt 0 ]; then echo $(((100 * (diff_total - diff_idle)) / diff_total)); else echo 0; fi"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const value = Number(this.text.trim());
                if (!Number.isNaN(value))
                    root.pct = value;
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (!cpuProc.running)
                cpuProc.running = true;
        }
    }

    Row {
        id: row

        Text {
            text: `CPU: ${root.pct}%`
            font.pixelSize: 12
            font.weight: 700
            color: {
                if (root.pct >= 80)
                    return Theme.red;
                if (root.pct >= 50)
                    return Theme.yellow;
                return Theme.mauve;
            }
        }
    }
}
