// ClockWidget.qml
import QtQuick
import "../style/theme.js" as Theme
import "../services" as Services

Text {
    text: Services.Time.time
    color: Theme.text
    font.pixelSize: 12
    font.weight: 700
}
