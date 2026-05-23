pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import "../style/theme.js" as Theme

PopupWindow {
    id: root

    required property Item anchorItem
    required property var anchorWindow

    property string label: ""
    property string iconSource: ""
    property string iconText: ""
    property string valueText: ""
    property color accent: Theme.blue
    property real value: 0
    property bool sliderEnabled: true
    property int iconPixelSize: 16

    // Pass sinkLinks.linkGroups here.
    property var streamModel: null

    signal valueDragged(real value)

    color: "transparent"
    grabFocus: true

    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight

    anchor.window: root.anchorWindow
    anchor.adjustment: PopupAdjustment.Flip | PopupAdjustment.Slide

    anchor.onAnchoring: {
        if (!root.anchorWindow || !root.anchorItem)
            return;

        const point = root.anchorWindow.mapFromItem(root.anchorItem, Math.round((root.anchorItem.width - root.implicitWidth) / 2), root.anchorItem.height + 8);

        anchor.rect.x = Math.round(point.x);
        anchor.rect.y = Math.round(point.y);
        anchor.rect.width = 1;
        anchor.rect.height = 1;
    }

    function clamp01(value) {
        return Math.max(0, Math.min(1, value));
    }

    function percentText(value) {
        return `${Math.round(value * 100)}%`;
    }

    function streamName(node) {
        if (!node)
            return "Unknown app";

        const props = node.properties || {};

        const app = props["application.name"] || node.description || node.nickname || node.name || "Unknown app";

        const media = props["media.name"] || props["media.title"] || "";

        if (media !== "" && media !== app)
            return `${app} · ${media}`;

        return app;
    }

    function streamIcon(node) {
        if (!node)
            return Quickshell.iconPath("application-x-executable-symbolic", true);

        const props = node.properties || {};

        const icon = props["application.icon-name"] || props["media.icon-name"] || props["application.process.binary"] || "application-x-executable-symbolic";

        return Quickshell.iconPath(icon, true);
    }

    component VolumeSlider: Item {
        id: slider

        property real value: 0
        property color accent: Theme.blue
        property bool sliderEnabled: true

        signal valueDragged(real nextValue)

        width: parent ? parent.width : 196
        height: 18
        opacity: slider.sliderEnabled ? 1.0 : 0.5

        readonly property real clampedValue: Math.max(0, Math.min(1, slider.value))
        readonly property real handleX: slider.clampedValue * (width - handle.width)

        Rectangle {
            id: track

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 6
            radius: 999
            color: Theme.surface2
        }

        Rectangle {
            anchors.left: track.left
            anchors.verticalCenter: track.verticalCenter
            width: track.width * slider.clampedValue
            height: track.height
            radius: track.radius
            color: slider.accent
        }

        Rectangle {
            id: handle

            width: 14
            height: 14
            radius: 999
            x: slider.handleX
            y: Math.round((slider.height - height) / 2)
            color: Theme.text
            border.width: 1
            border.color: slider.accent
        }

        MouseArea {
            anchors.fill: parent
            enabled: slider.sliderEnabled
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            function setValue(mouseX) {
                const span = Math.max(1, slider.width - handle.width);
                const next = Math.max(0, Math.min(1, mouseX / span));
                slider.valueDragged(next);
            }

            onPressed: function (mouse) {
                setValue(mouse.x - (handle.width / 2));
            }

            onPositionChanged: function (mouse) {
                if (pressed)
                    setValue(mouse.x - (handle.width / 2));
            }
        }
    }

    Rectangle {
        id: frame

        width: implicitWidth
        height: implicitHeight
        implicitWidth: 260
        implicitHeight: body.implicitHeight + 24
        radius: 12
        color: Theme.surface0
        border.width: 1
        border.color: Theme.surface2

        Column {
            id: body

            x: 12
            y: 12
            width: parent.width - 24
            spacing: 10

            Row {
                width: parent.width
                spacing: 8

                IconImage {
                    visible: root.iconText === ""
                    implicitSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                    source: root.iconSource
                    opacity: root.sliderEnabled ? 1.0 : 0.65
                }

                Text {
                    visible: root.iconText !== ""
                    text: root.iconText
                    color: root.sliderEnabled ? Theme.text : Theme.overlay0
                    opacity: root.sliderEnabled ? 1.0 : 0.65
                    font.pixelSize: root.iconPixelSize
                    font.weight: 700
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: root.label
                    color: Theme.text
                    font.pixelSize: 12
                    font.weight: 700
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: root.valueText
                    color: root.sliderEnabled ? Theme.subtext1 : Theme.overlay0
                    font.pixelSize: 12
                    font.weight: 700
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            VolumeSlider {
                value: root.value
                accent: root.accent
                sliderEnabled: root.sliderEnabled

                onValueDragged: function (nextValue) {
                    root.valueDragged(nextValue);
                }
            }

            Rectangle {
                visible: root.streamModel && root.streamModel.count > 0
                width: parent.width
                height: 1
                color: Theme.surface2
            }

            Text {
                visible: root.streamModel && root.streamModel.count > 0
                text: "Applications"
                color: Theme.subtext1
                font.pixelSize: 11
                font.weight: 700
            }

            Repeater {
                model: root.streamModel

                delegate: Column {
                    id: appEntry

                    required property var modelData
                    readonly property var node: modelData ? modelData.source : null
                    readonly property var audio: node ? node.audio : null

                    width: parent.width
                    spacing: 6
                    visible: !!appEntry.node && !!appEntry.audio
                    height: visible ? implicitHeight : 0

                    PwObjectTracker {
                        objects: appEntry.node ? [appEntry.node] : []
                    }

                    Row {
                        id: appHeader

                        width: parent.width
                        spacing: 8

                        IconImage {
                            id: appIcon

                            implicitSize: 16
                            anchors.verticalCenter: parent.verticalCenter
                            source: root.streamIcon(appEntry.node)
                            opacity: appEntry.audio && appEntry.audio.muted ? 0.55 : 1.0

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    if (appEntry.audio)
                                        appEntry.audio.muted = !appEntry.audio.muted;
                                }
                            }
                        }

                        Text {
                            id: appName

                            width: Math.max(0, appHeader.width - 16 - 8 - appPercent.width - 8)
                            text: root.streamName(appEntry.node)
                            color: appEntry.audio && appEntry.audio.muted ? Theme.overlay0 : Theme.text
                            font.pixelSize: 12
                            font.weight: 700
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            id: appPercent

                            text: appEntry.audio ? (appEntry.audio.muted ? "muted" : root.percentText(appEntry.audio.volume)) : ""
                            color: appEntry.audio && appEntry.audio.muted ? Theme.overlay0 : Theme.subtext1
                            font.pixelSize: 11
                            font.weight: 700
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    VolumeSlider {
                        value: appEntry.audio ? appEntry.audio.volume : 0
                        accent: root.accent
                        sliderEnabled: !!appEntry.audio

                        onValueDragged: function (nextValue) {
                            if (appEntry.audio) {
                                appEntry.audio.muted = false;
                                appEntry.audio.volume = nextValue;
                            }
                        }
                    }
                }
            }
        }
    }
}
