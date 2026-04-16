// ClockWidget.qml
import QtQuick
import "." as Local

Text {
  // we no longer need time as an input

  // directly access the time property from the Time singleton
  text: Local.Time.time
}
