import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import "theme.js" as Theme

Item {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audioNode: root.sink ? root.sink.audio : null
    readonly property real vol: root.audioNode ? root.audioNode.volume : 0

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    visible: Pipewire.ready && !!root.audioNode

    Row {
        id: content
        spacing: 4
        anchors.centerIn: parent

        IconImage {
            id: volumeIcon
            implicitSize: 16

            source: {
                if (!root.audioNode)
                    return "";

                let icon = "";
                if (root.audioNode.muted || root.vol <= 0.001)
                    icon = "audio-volume-muted-symbolic";
                else if (root.vol < 0.34)
                    icon = "audio-volume-low-symbolic";
                else if (root.vol < 0.67)
                    icon = "audio-volume-medium-symbolic";
                else
                    icon = "audio-volume-high-symbolic";

                return Quickshell.iconPath(icon, true);
            }

            opacity: root.audioNode && root.audioNode.muted ? 0.65 : 1.0
        }

        Text {
            text: root.audioNode ? (root.audioNode.muted ? " muted" : ` ${Math.round(root.vol * 100)}%`) : ""
            color: root.audioNode && root.audioNode.muted ? Theme.overlay0 : Theme.text
            font.pixelSize: 12
            font.weight: 700
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.audioNode)
                root.audioNode.muted = !root.audioNode.muted;
        }
    }
}
