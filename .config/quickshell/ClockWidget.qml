// ClockWidget.qml
import QtQuick
import "." as Local
import "theme.js" as Theme

Text {
    text: Local.Time.time
    color: Theme.text
    font.pixelSize: 13
    font.weight: 600
}
