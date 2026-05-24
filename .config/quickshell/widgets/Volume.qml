import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import ".." as Config
import "." as Local
import "../style/theme.js" as Theme

Item {
    id: root

    signal toggleRequested

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audioNode: root.sink ? root.sink.audio : null
    readonly property real vol: root.audioNode ? root.audioNode.volume : 0
    property bool popupVisible: false
    readonly property var streamModel: sinkLinks.linkGroups

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
            anchors.verticalCenter: parent.verticalCenter

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
            font.family: Config.Theme.monoFontFamily
            font.pixelSize: Config.Theme.fontSize
            font.weight: 700
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    PwNodeLinkTracker {
        id: sinkLinks
        node: Pipewire.defaultAudioSink
    }

    function closePopup() {
        root.popupVisible = false;
    }

    function togglePopup() {
        root.popupVisible = !root.popupVisible;
    }

    Local.PopupSlider {
        id: popup

        anchorItem: root
        anchorWindow: QsWindow.window
        label: "Volume"
        iconSource: volumeIcon.source
        valueText: root.audioNode ? `${Math.round(root.vol * 100)}%` : ""
        accent: Theme.blue
        value: root.vol
        sliderEnabled: !!root.audioNode
        visible: root.popupVisible && root.visible

        streamModel: sinkLinks.linkGroups

        onVisibleChanged: {
            if (!visible && root.popupVisible)
                root.popupVisible = false;
        }

        onValueDragged: function (value) {
            if (root.audioNode) {
                root.audioNode.muted = false;
                root.audioNode.volume = value;
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function (mouse) {
            if (!root.audioNode)
                return;

            if (mouse.button === Qt.RightButton) {
                root.audioNode.muted = !root.audioNode.muted;
            } else {
                root.toggleRequested();
            }
        }
    }

    onVisibleChanged: {
        if (!visible)
            root.popupVisible = false;
    }
}
