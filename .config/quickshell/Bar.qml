pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import Niri 0.1
import "theme.js" as Theme

Scope {
    Niri {
        id: niriSvc
        Component.onCompleted: connect()
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 34
            color: Theme.base

            Workspaces {
                niriService: niriSvc
                screen: panel.modelData
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
            }

            FocusedApp {
                niriService: niriSvc
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            Row {
                id: statsRow
                spacing: 8
                height: parent.height
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                Item {
                    width: cpu.implicitWidth
                    height: statsRow.height

                    Cpu {
                        id: cpu
                        anchors.centerIn: parent
                    }
                }

                Item {
                    width: sep1.implicitWidth
                    height: statsRow.height

                    Text {
                        id: sep1
                        anchors.centerIn: parent
                        text: "•"
                        color: Theme.overlay0
                    }
                }

                Item {
                    width: mem.implicitWidth
                    height: statsRow.height

                    Memory {
                        id: mem
                        anchors.centerIn: parent
                    }
                }

                Item {
                    width: sep2.implicitWidth
                    height: statsRow.height

                    Text {
                        id: sep2
                        anchors.centerIn: parent
                        text: "•"
                        color: Theme.overlay0
                    }
                }

                Item {
                    width: amd.implicitWidth
                    height: statsRow.height

                    AmdGpu {
                        id: amd
                        anchors.centerIn: parent
                    }
                }

                Item {
                    width: sep3.implicitWidth
                    height: statsRow.height

                    Text {
                        id: sep3
                        anchors.centerIn: parent
                        text: "•"
                        color: Theme.overlay0
                    }
                }

                Item {
                    width: nvidia.implicitWidth
                    height: statsRow.height

                    NvidiaGpu {
                        id: nvidia
                        anchors.centerIn: parent
                    }
                }

                Item {
                    width: sep4.implicitWidth
                    height: statsRow.height

                    Text {
                        id: sep4
                        anchors.centerIn: parent
                        text: "•"
                        color: Theme.overlay0
                    }
                }

                Item {
                    width: bat.implicitWidth
                    height: statsRow.height

                    Battery {
                        id: bat
                        anchors.centerIn: parent
                    }
                }

                Item {
                    width: sep5.implicitWidth
                    height: statsRow.height

                    Text {
                        id: sep5
                        anchors.centerIn: parent
                        text: "•"
                        color: Theme.overlay0
                    }
                }

                Item {
                    width: clock.implicitWidth
                    height: statsRow.height

                    ClockWidget {
                        id: clock
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }
}
