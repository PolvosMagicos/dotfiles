// Time.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
    readonly property string time: Qt.formatDateTime(
        clock.date,
        "ddd d MMM • h:mm AP"
    )

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
