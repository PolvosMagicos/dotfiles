// Bar.qml
import Quickshell
import QtQuick

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 30

            ClockWidget {
                anchors.centerIn: parent
            }

            Row {
                spacing: 8
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                Battery {}

                Text {
                    text: "|"
                    color: "#666666"
                }

                Memory {}

                Text {
                    text: "|"
                    color: "#666666"
                }

                Cpu {}
            }
        }
    }
}
