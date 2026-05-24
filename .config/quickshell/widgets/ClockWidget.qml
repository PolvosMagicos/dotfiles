// ClockWidget.qml
import QtQuick
import ".." as Config
import "../style/theme.js" as Theme
import "../services" as Services

Text {
    text: Services.Time.time
    color: Theme.text
    font.family: Config.Theme.monoFontFamily
    font.pixelSize: Config.Theme.fontSize
    font.weight: 700
}
