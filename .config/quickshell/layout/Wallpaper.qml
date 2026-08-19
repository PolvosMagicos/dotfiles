import Quickshell
import Quickshell.Wayland
import QtQuick

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore

            WlrLayershell.layer: WlrLayer.Background
            WlrLayershell.namespace: "quickshell-wallpaper"

            anchors {
                top: true
                right: true
                bottom: true
                left: true
            }

            Image {
                anchors.fill: parent
                source: "file:///home/polvos-magicos/dotfiles/assets/wallpapers/shinji-asuka-happy-ending.png"
                fillMode: Image.PreserveAspectCrop
                smooth: true
                mipmap: true
            }

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 0.20
            }
        }
    }
}
