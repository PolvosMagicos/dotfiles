pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import Niri 0.1
import "../style/theme.js" as Theme
import "../widgets" as Widgets

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

            Row {
                id: leftRow
                spacing: 8
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                Widgets.Workspaces {
                    niriService: niriSvc
                    screen: panel.modelData
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id: sepLeft1
                    text: "•"
                    color: Theme.overlay0
                    anchors.verticalCenter: parent.verticalCenter
                }

                Widgets.Wifi {
                    id: wifiWidget
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    id: sepLeft2
                    text: "•"
                    color: Theme.overlay0
                    visible: wifiWidget.visible || volumeWidget.visible
                    anchors.verticalCenter: parent.verticalCenter
                }

                Widgets.Volume {
                    id: volumeWidget
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Widgets.FocusedApp {
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

                    Widgets.Cpu {
                        id: cpu
                        anchors.centerIn: parent
                    }
                }

                Item {
                    width: sepRigth1.implicitWidth
                    height: statsRow.height

                    Text {
                        id: sepRigth1
                        anchors.centerIn: parent
                        text: "•"
                        visible: cpu.visible || mem.visible
                        color: Theme.overlay0
                    }
                }

                Item {
                    width: mem.implicitWidth
                    height: statsRow.height

                    Widgets.Memory {
                        id: mem
                        anchors.centerIn: parent
                    }
                }

                Item {
                    width: sepRigth2.implicitWidth
                    height: statsRow.height

                    Text {
                        id: sepRigth2
                        anchors.centerIn: parent
                        text: "•"
                        visible: mem.visible || amd.visible
                        color: Theme.overlay0
                    }
                }

                Item {
                    width: amd.implicitWidth
                    height: statsRow.height

                    Widgets.AmdGpu {
                        id: amd
                        anchors.centerIn: parent
                    }
                }

                Item {
                    width: sepRigth3.implicitWidth
                    height: statsRow.height

                    Text {
                        id: sepRigth3
                        anchors.centerIn: parent
                        text: "•"
                        visible: amd.visible || nvidia.visible
                        color: Theme.overlay0
                    }
                }

                Item {
                    width: nvidia.implicitWidth
                    height: statsRow.height

                    Widgets.NvidiaGpu {
                        id: nvidia
                        anchors.centerIn: parent
                    }
                }

                Item {
                    width: sepRigth4.implicitWidth
                    height: statsRow.height

                    Text {
                        id: sepRigth4
                        anchors.centerIn: parent
                        text: "•"
                        visible: nvidia.visible || bat.visible
                        color: Theme.overlay0
                    }
                }

                Item {
                    width: bat.implicitWidth
                    height: statsRow.height

                    Widgets.Battery {
                        id: bat
                        anchors.centerIn: parent
                    }
                }

                Item {
                    width: sepRigth5.implicitWidth
                    height: statsRow.height

                    Text {
                        id: sepRigth5
                        anchors.centerIn: parent
                        text: "•"
                        visible: bat.visible || clock.visible
                        color: Theme.overlay0
                    }
                }

                Item {
                    width: clock.implicitWidth
                    height: statsRow.height

                    Widgets.ClockWidget {
                        id: clock
                        anchors.centerIn: parent
                    }
                }
            }
        }
    }
}
